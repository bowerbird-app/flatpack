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
    documentElement: {scrollTop: 0},
    addEventListener() {},
    removeEventListener() {}
  }

  const TopNavController = loadTopNavController({window: windowStub, document: documentStub})
  const controller = Object.assign(new TopNavController(), {
    hasPanelTarget: false,
    hasMenuTarget: false,
    hasToggleTarget: false,
    element,
    sectionTargets: []
  })

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

test('disconnect removes scroll listeners', () => {
  const {controller, listeners} = buildFrostController({siblingOverflow: 'auto'})

  controller.connect()
  assert.ok(listeners.length > 0)

  controller.disconnect()

  assert.equal(listeners.length, 0)
})

function buildFitController({clientWidth, scrollWidth, viewportNarrow = false}) {
  const child = {nodeType: 1, dataset: {}, childNodes: []}
  const sectionChildren = [child]
  const section = {
    dataset: {flatPackTopNavCollapsible: 'true'},
    childNodes: sectionChildren,
    classList: {toggle() {}, remove() {}},
    insertBefore(node, before) {
      node.parentNode = section
      sectionChildren.splice(sectionChildren.indexOf(before), 0, node)
    },
    replaceChild(node, placeholder) {
      if (node.parentNode && node.parentNode.removeChild) node.parentNode.removeChild(node)
      sectionChildren.splice(sectionChildren.indexOf(placeholder), 1, node)
      node.parentNode = section
    }
  }
  const panelChildren = []
  const panel = {
    children: panelChildren,
    hidden: true,
    appendChild(node) {
      const index = sectionChildren.indexOf(node)
      if (index >= 0) sectionChildren.splice(index, 1)
      node.parentNode = panel
      panelChildren.push(node)
    },
    removeChild(node) {
      const index = panelChildren.indexOf(node)
      if (index >= 0) panelChildren.splice(index, 1)
    }
  }
  const menu = {classList: {toggle() {}}}
  const bar = {clientWidth, scrollWidth, dataset: {}}
  const TopNavController = loadTopNavController({
    window: {},
    document: {createComment() { return {nodeType: 8} }},
    Node: {TEXT_NODE: 3, ELEMENT_NODE: 1}
  })

  return {
    bar,
    child,
    sectionChildren,
    panelChildren,
    controller: Object.assign(new TopNavController(), {
      element: bar,
      mediaQuery: {matches: viewportNarrow},
      hasPanelTarget: true,
      hasMenuTarget: true,
      hasToggleTarget: false,
      sectionTargets: [section],
      panelTarget: panel,
      menuTarget: menu,
      movedNodes: [],
      breakpointValue: 768,
      fitting: false,
      menuOpen: false
    })
  }
}

test('a wide viewport collapses the bar when its content overflows', () => {
  const {controller, panelChildren, sectionChildren, child, bar} = buildFitController({
    clientWidth: 400,
    scrollWidth: 640
  })

  controller.applyLayout()

  assert.equal(panelChildren.length, 1)
  assert.equal(sectionChildren.includes(child), false)

  bar.clientWidth = 800
  controller.applyLayout()

  assert.equal(panelChildren.length, 0)
  assert.equal(sectionChildren[0], child)
})

test('a bar that fits keeps its sections inline', () => {
  const {controller, panelChildren} = buildFitController({clientWidth: 800, scrollWidth: 640})

  controller.applyLayout()

  assert.equal(panelChildren.length, 0)
})
