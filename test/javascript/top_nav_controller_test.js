const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

function loadTopNavController(globals) {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'top_nav_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformedSource = source
    .replace('import { Controller } from "@hotwired/stimulus"', 'class Controller {}')
    .replace('export default class extends Controller', 'class TopNavController extends Controller') + '\nmodule.exports = TopNavController\n'

  const context = {
    module: {exports: {}},
    exports: {},
    Node: {TEXT_NODE: 3, ELEMENT_NODE: 1},
    ...globals
  }

  vm.runInNewContext(transformedSource, context, {filename: filePath})

  return context.module.exports
}

function buildFrostController({
  windowScrollY = 0,
  siblingOverflow = null,
  siblingScrollTop = 0
} = {}) {
  const listeners = []
  const dataset = {}
  const sibling = siblingOverflow
    ? {
      nodeType: 1,
      scrollTop: siblingScrollTop,
      addEventListener(type, fn) {
        listeners.push({target: this, type, fn})
      },
      removeEventListener(type, fn) {
        const index = listeners.findIndex((entry) => entry.target === this && entry.type === type && entry.fn === fn)
        if (index >= 0) listeners.splice(index, 1)
      }
    }
    : null

  const parent = {
    nodeType: 1,
    parentElement: null
  }

  const element = {
    dataset,
    nextElementSibling: sibling,
    parentElement: parent
  }

  const windowStub = {
    scrollY: windowScrollY,
    addEventListener(type, fn) {
      listeners.push({target: 'window', type, fn})
    },
    removeEventListener(type, fn) {
      const index = listeners.findIndex((entry) => entry.target === 'window' && entry.type === type && entry.fn === fn)
      if (index >= 0) listeners.splice(index, 1)
    },
    getComputedStyle(node) {
      if (node === sibling) return {overflowY: siblingOverflow}
      return {overflowY: 'visible'}
    }
  }

  const documentStub = {
    body: {},
    documentElement: {scrollTop: 0}
  }

  const TopNavController = loadTopNavController({window: windowStub, document: documentStub})
  const controller = Object.assign(new TopNavController(), {element})

  return {controller, dataset, listeners, windowStub, sibling}
}

test('frost stays off at rest', () => {
  const {controller, dataset} = buildFrostController()

  controller.connect()

  assert.equal(dataset.scrolled, 'false')
})

test('window scroll turns frost on', () => {
  const {controller, dataset, listeners, windowStub} = buildFrostController()

  controller.connect()
  windowStub.scrollY = 24
  const scroll = listeners.find((entry) => entry.target === 'window' && entry.type === 'scroll')
  scroll.fn()

  assert.equal(dataset.scrolled, 'true')
})

test('a sibling overflow pane frosts the bar when window has not scrolled', () => {
  const {controller, dataset, listeners, sibling} = buildFrostController({
    siblingOverflow: 'auto',
    siblingScrollTop: 0
  })

  controller.connect()
  sibling.scrollTop = 40
  const scroll = listeners.find((entry) => entry.target === sibling && entry.type === 'scroll')
  scroll.fn()

  assert.equal(dataset.scrolled, 'true')
})

test('page scroll listens only to the window', () => {
  const {controller, listeners, sibling} = buildFrostController({
    siblingOverflow: 'auto',
    siblingScrollTop: 12
  })
  controller.element.closest = () => ({ dataset: { flatPackLayoutScroll: 'page' } })

  controller.connect()

  assert.equal(listeners.length, 1)
  assert.equal(listeners[0].target, 'window')
  assert.equal(listeners[0].type, 'scroll')
  assert.equal(listeners.some((entry) => entry.target === sibling), false)
})

test('disconnect removes scroll listeners', () => {
  const {controller, listeners} = buildFrostController({siblingOverflow: 'auto'})

  controller.connect()
  assert.ok(listeners.length > 0)

  controller.disconnect()

  assert.equal(listeners.length, 0)
})

test('the controller does not fold the row', () => {
  const source = fs.readFileSync(
    path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'top_nav_controller.js'),
    'utf8'
  )

  assert.equal(source.includes('collapseIntoMenu'), false)
  assert.equal(source.includes('hoistAlwaysDisplay'), false)
  assert.equal(source.includes('placeMenu'), false)
  assert.equal(source.includes('ResizeObserver'), false)
  assert.equal(source.includes('matchMedia'), false)
  assert.equal(source.includes('flatPackTopNavDisclosure'), false)
  assert.equal(source.includes('flatPackTopNavExpanded'), false)
})
