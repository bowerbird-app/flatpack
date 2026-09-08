const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

function loadDrawerController(documentStub) {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'drawer_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformedSource = source
    .replace('import { Controller } from "@hotwired/stimulus"', 'class Controller {}')
    .replace(
      'import { prefersReducedMotion, motionDuration, motionTransition } from "controllers/flat_pack/reduced_motion"',
      'function prefersReducedMotion() { return false }\nfunction motionDuration() { return 0 }\nfunction motionTransition() { return "" }'
    )
    .replace('export default class extends Controller', 'class DrawerController extends Controller') + '\nmodule.exports = DrawerController\n'

  const context = {
    module: { exports: {} },
    exports: {},
    document: documentStub,
    window: { innerWidth: 800 },
    requestAnimationFrame(callback) { callback() },
    setTimeout(callback) { callback(); return 0 },
    clearTimeout() {}
  }

  vm.runInNewContext(transformedSource, context, { filename: filePath })

  return context.module.exports
}

function classListStub(initial = ['hidden']) {
  const names = new Set(initial)
  return {
    contains(name) { return names.has(name) },
    add(name) { names.add(name) },
    remove(name) { names.delete(name) }
  }
}

function buildController() {
  const originalParent = {
    name: 'original',
    insertBefore(node, sibling) {
      node.parentElement = this
      node.parentNode = this
      this.inserted = { method: 'insertBefore', sibling }
    },
    appendChild(node) {
      node.parentElement = this
      node.parentNode = this
      this.inserted = { method: 'appendChild' }
    }
  }

  const body = {
    name: 'body',
    style: {},
    dataset: {},
    appendChild(node) {
      this.appended = node
      node.parentElement = this
      node.parentNode = this
    }
  }

  const nextSibling = { id: 'next', parentNode: originalParent }
  const documentStub = {
    body,
    activeElement: null,
    documentElement: { clientWidth: 800 },
    addEventListener() {},
    removeEventListener() {}
  }

  const DrawerController = loadDrawerController(documentStub)
  const element = {
    id: 'filters-drawer',
    classList: classListStub(['hidden']),
    parentElement: originalParent,
    parentNode: originalParent,
    nextSibling,
    style: {},
    offsetHeight: 0,
    setAttribute() {}
  }

  const panel = {
    style: {},
    querySelectorAll() { return [] },
    setAttribute() {},
    focus() {}
  }

  const controller = Object.assign(new DrawerController(), {
    element,
    hasPanelTarget: true,
    panelTarget: panel,
    sideValue: 'left'
  })

  return { controller, element, body, originalParent, nextSibling }
}

test('open moves the overlay onto document.body', () => {
  const { controller, element, body } = buildController()

  controller.connect()
  controller.open()

  assert.equal(element.parentElement, body)
  assert.equal(body.appended, element)
})

test('close restores the overlay to its original parent', () => {
  const { controller, element, originalParent, nextSibling } = buildController()

  controller.connect()
  controller.open()
  controller.close()

  assert.equal(element.parentElement, originalParent)
  assert.equal(originalParent.inserted.method, 'insertBefore')
  assert.equal(originalParent.inserted.sibling, nextSibling)
})

test('disconnect restores the overlay if it is still on the body', () => {
  const { controller, element, originalParent } = buildController()

  controller.connect()
  controller.open()
  controller.disconnect()

  assert.equal(element.parentElement, originalParent)
})
