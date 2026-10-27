const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

function loadController() {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'search_collapse_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformedSource = source
    .replace('import { Controller } from "@hotwired/stimulus"', 'class Controller {}')
    .replace(/import \{[^}]+\} from "flat_pack\/click_outside"\n/, "")
    .replace('export default class extends Controller', 'class SearchCollapseController extends Controller') + '\nmodule.exports = SearchCollapseController\n'
  const clickOutsidePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'click_outside.js')
  const clickOutsideSource = fs.readFileSync(clickOutsidePath, 'utf8').replaceAll('export function ', 'function ')

  const listeners = { pointerdown: new Set(), keydown: new Set() }
  const document = {
    addEventListener(type, handler) {
      listeners[type]?.add(handler)
    },
    removeEventListener(type, handler) {
      listeners[type]?.delete(handler)
    }
  }

  const context = {
    module: { exports: {} },
    exports: {},
    document,
    requestAnimationFrame: (fn) => setTimeout(fn, 0),
    cancelAnimationFrame: (id) => clearTimeout(id)
  }
  context.globalThis = context

  vm.runInNewContext(clickOutsideSource + '\n' + transformedSource, context, { filename: filePath })

  return { ControllerClass: context.module.exports, listeners, document }
}

function fakeNode() {
  const attributes = {}
  return {
    attributes,
    value: '',
    focused: false,
    inert: false,
    classList: {
      classes: new Set(),
      add(name) { this.classes.add(name) },
      contains(name) { return this.classes.has(name) }
    },
    setAttribute(name, value) { attributes[name] = String(value) },
    getAttribute(name) { return attributes[name] ?? null },
    focus() { this.focused = true },
    closest() { return null }
  }
}

function buildController({ collapsed = true, value = '' } = {}) {
  const { ControllerClass, listeners, document } = loadController()
  const controller = new ControllerClass()
  const element = fakeNode()
  const toggle = fakeNode()
  const field = fakeNode()
  const input = fakeNode()
  input.value = value
  const dropdown = fakeNode()
  element.contains = (target) => target === toggle || target === field || target === input || target === dropdown
  element.querySelector = (selector) => selector.includes('dropdown') ? dropdown : null
  element.dataset = {}

  controller.element = element
  controller.toggleTarget = toggle
  controller.fieldTarget = field
  controller.inputTarget = input
  controller.hasToggleTarget = true
  controller.hasFieldTarget = true
  controller.hasInputTarget = true
  controller.initialize()

  let collapsedValue = collapsed
  let skipping = true
  Object.defineProperty(controller, 'collapsedValue', {
    get() { return collapsedValue },
    set(next) {
      const previous = collapsedValue
      collapsedValue = next
      if (!skipping) controller.collapsedValueChanged(collapsedValue, previous)
    },
    configurable: true
  })
  controller.collapsedValueChanged(collapsedValue, undefined)
  skipping = false

  return { controller, element, toggle, field, input, dropdown, listeners, document }
}

function flushFrame() {
  return new Promise((resolve) => setTimeout(resolve, 0))
}

test('expand focuses the input and marks the button open', async () => {
  const { controller, element, toggle, field, input, listeners } = buildController()

  controller.expand({ preventDefault() {} })
  await flushFrame()

  assert.equal(controller.collapsedValue, false)
  assert.equal(element.dataset.fpCollapsed, 'false')
  assert.equal(toggle.inert, true)
  assert.equal(toggle.attributes['aria-expanded'], 'true')
  assert.equal(field.inert, false)
  assert.equal(input.focused, true)
  assert.equal(listeners.keydown.size, 1)
  assert.equal(listeners.pointerdown.size, 1)
})

test('escape on an empty field collapses and returns focus', async () => {
  const { controller, document, toggle, input, listeners } = buildController({ collapsed: false })
  await flushFrame()
  document.activeElement = input
  input.focused = false

  const event = { key: 'Escape', defaultPrevented: false, preventDefault() { this.defaultPrevented = true } }
  listeners.keydown.forEach((handler) => handler(event))

  assert.equal(event.defaultPrevented, true)
  assert.equal(controller.collapsedValue, true)
  assert.equal(toggle.focused, true)
  assert.equal(toggle.inert, false)
  assert.equal(listeners.keydown.size, 0)
})

test('a value ignores escape and outside clicks', async () => {
  const { controller, input, listeners } = buildController({ collapsed: false, value: 'lamps' })
  await flushFrame()

  const escape = { key: 'Escape', defaultPrevented: false, preventDefault() { this.defaultPrevented = true } }
  listeners.keydown.forEach((handler) => handler(escape))
  assert.equal(escape.defaultPrevented, false)
  assert.equal(controller.collapsedValue, false)

  const outside = fakeNode()
  listeners.pointerdown.forEach((handler) => handler({ target: outside }))
  assert.equal(controller.collapsedValue, false)
  assert.equal(input.value, 'lamps')
})

test('outside click on empty field collapses without stealing another control', async () => {
  const { controller, document, input, toggle, listeners } = buildController({ collapsed: false })
  await flushFrame()
  document.activeElement = input

  const other = fakeNode()
  other.closest = () => other
  const event = { target: other, defaultPrevented: false, preventDefault() { this.defaultPrevented = true } }
  listeners.pointerdown.forEach((handler) => handler(event))

  assert.equal(event.defaultPrevented, false)
  assert.equal(controller.collapsedValue, true)
  assert.equal(toggle.focused, false)
})

test('an open field that does not hold focus stays open when something else is clicked', async () => {
  const { controller, document, listeners } = buildController({ collapsed: false })
  await flushFrame()
  document.activeElement = fakeNode()

  const other = fakeNode()
  other.closest = () => other
  listeners.pointerdown.forEach((handler) => handler({ target: other, preventDefault() {} }))

  assert.equal(controller.collapsedValue, false)
  assert.equal(controller.element.dataset.fpCollapsed, 'false')
})

test('outside click on empty space returns focus to the button', async () => {
  const { controller, document, input, toggle, listeners } = buildController({ collapsed: false })
  await flushFrame()
  document.activeElement = input

  const canvas = fakeNode()
  const event = { target: canvas, defaultPrevented: false, preventDefault() { this.defaultPrevented = true } }
  listeners.pointerdown.forEach((handler) => handler(event))

  assert.equal(event.defaultPrevented, true)
  assert.equal(controller.collapsedValue, true)
  assert.equal(toggle.focused, true)
})

test('blur to another control collapses an empty field and leaves focus there', () => {
  const { controller, toggle } = buildController({ collapsed: false })
  const next = fakeNode()

  controller.dismiss({ relatedTarget: next })

  assert.equal(controller.collapsedValue, true)
  assert.equal(toggle.focused, false)
})

test('blur inside the shell stays open', () => {
  const { controller, input } = buildController({ collapsed: false, value: '' })

  controller.dismiss({ relatedTarget: input })

  assert.equal(controller.collapsedValue, false)
})

test('blur with no next target returns focus to the button', () => {
  const { controller, toggle } = buildController({ collapsed: false })

  controller.dismiss({ relatedTarget: null })

  assert.equal(controller.collapsedValue, true)
  assert.equal(toggle.focused, true)
})

test('connect opens a collapsed field that already has a value without focusing', () => {
  const { controller, input } = buildController({ collapsed: true, value: 'lamps' })

  controller.connect()

  assert.equal(controller.collapsedValue, false)
  assert.equal(input.focused, false)
})
