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
    .replace('export default class extends Controller', 'class ComboboxController extends Controller') + '\nmodule.exports = ComboboxController\n'

  const context = {
    module: { exports: {} },
    exports: {},
    document: {
      addEventListener() {},
      removeEventListener() {}
    },
    clearTimeout() {}
  }

  vm.runInNewContext(transformedSource, context, { filename: filePath })

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
