let activeDocument

const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

class FakeClassList {
  constructor(classes = []) {
    this.classes = new Set(classes)
  }

  add(...classes) {
    classes.forEach((klass) => this.classes.add(klass))
  }

  remove(...classes) {
    classes.forEach((klass) => this.classes.delete(klass))
  }

  toggle(klass, force) {
    if (force === true) {
      this.classes.add(klass)
      return true
    }

    if (force === false) {
      this.classes.delete(klass)
      return false
    }

    if (this.classes.has(klass)) {
      this.classes.delete(klass)
      return false
    }

    this.classes.add(klass)
    return true
  }

  contains(klass) {
    return this.classes.has(klass)
  }
}

class FakeElement {
  constructor(tagName) {
    this.tagName = tagName
    this.dataset = {}
    this.attributes = {}
    this.style = {}
    this.classList = new FakeClassList()
    this.value = ''
  }

  setAttribute(name, value) {
    this.attributes[name] = String(value)
  }

  removeAttribute(name) {
    delete this.attributes[name]
  }

  scrollIntoView() {}

  contains(node) {
    if (node === this) return true
    return (this.children || []).some((child) => child === node || child.contains?.(node))
  }

  appendChild(child) {
    this.children = this.children || []
    this.children.push(child)
    return child
  }
}

function loadController() {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'combobox_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformedSource = source
    .replace('import { Controller } from "@hotwired/stimulus"', 'class Controller {}')
    .replace(
      'import { playOverlayEnter, playOverlayExit, cancelOverlayHide } from "controllers/flat_pack/reduced_motion"',
      `function playOverlayEnter(element) { element.classList.remove("hidden") }
function playOverlayExit(element, options = {}) { element.classList.add("hidden"); options.onHidden?.(); return 0 }
function cancelOverlayHide() {}`
    )
    .replace(/import \{[^}]+\} from "flat_pack\/click_outside"\n/, "")
    .replace('export default class extends Controller', 'class ComboboxController extends Controller') + '\nmodule.exports = ComboboxController\n'
  const clickOutsidePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'click_outside.js')
  const clickOutsideSource = fs.readFileSync(clickOutsidePath, 'utf8').replaceAll('export function ', 'function ')

  activeDocument = {
    listeners: [],
    addEventListener(type, listener, capture) {
      this.listeners.push({ type, listener, capture })
    },
    removeEventListener(type, listener, capture) {
      this.listeners = this.listeners.filter((entry) => {
        return entry.type !== type || entry.listener !== listener || entry.capture !== capture
      })
    }
  }

  const context = {
    module: { exports: {} },
    exports: {},
    document: activeDocument,
    clearTimeout() {}
  }

  vm.runInNewContext(clickOutsideSource + '\n' + transformedSource, context, { filename: filePath })

  return context.module.exports
}

function buildController() {
  const ControllerClass = loadController()
  const controller = new ControllerClass()
  const option = new FakeElement('div')
  option.dataset.label = 'Melbourne'
  option.dataset.value = 'melbourne'

  controller.element = new FakeElement('div')
  controller.inputTarget = new FakeElement('input')
  controller.valueTarget = new FakeElement('input')
  controller.listTarget = new FakeElement('div')
  controller.emptyTarget = new FakeElement('div')
  controller.optionTargets = [option]
  controller.listTarget.classList.add('hidden')
  controller.connect()

  return controller
}

test('open unhides the list and close hides it after overlay exit', () => {
  const controller = buildController()

  controller.open()

  assert.equal(controller.listTarget.classList.contains('hidden'), false)
  assert.equal(controller.inputTarget.attributes['aria-expanded'], 'true')
  assert.equal(controller.openList, true)

  controller.close()

  assert.equal(controller.listTarget.classList.contains('hidden'), true)
  assert.equal(controller.inputTarget.attributes['aria-expanded'], 'false')
  assert.equal(controller.openList, false)
})

test('close is a no-op when the list is already closed', () => {
  const controller = buildController()

  controller.close()

  assert.equal(controller.listTarget.classList.contains('hidden'), true)
  assert.equal(controller.openList, false)
})

test('mousedown outside closes, mousedown on the input does not, and disconnect removes the listener', () => {
  const controller = buildController()
  controller.element.appendChild(controller.inputTarget)
  controller.open()
  const press = (target) => {
    activeDocument.listeners
      .filter((entry) => entry.type === 'mousedown')
      .forEach((entry) => entry.listener({ target }))
  }

  assert.equal(activeDocument.listeners.some((entry) => entry.type === 'mousedown' && entry.capture === false), true)

  press(controller.inputTarget)
  assert.equal(controller.openList, true)

  press(new FakeElement('div'))
  assert.equal(controller.openList, false)

  controller.open()
  controller.disconnect()
  press(new FakeElement('div'))
  assert.equal(controller.openList, true)
  assert.equal(activeDocument.listeners.some((entry) => entry.type === 'mousedown'), false)
})
