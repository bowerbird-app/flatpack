const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

function loadController() {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'read_more_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformedSource = source
    .replace('import { Controller } from "@hotwired/stimulus"', 'class Controller {}')
    .replace('export default class extends Controller', 'class ReadMoreController extends Controller') + '\nmodule.exports = ReadMoreController\n'

  const observers = []

  class ResizeObserver {
    constructor(callback) {
      this.callback = callback
      this.observed = []
      this.disconnected = false
      observers.push(this)
    }

    observe(target) {
      this.observed.push(target)
    }

    disconnect() {
      this.disconnected = true
    }
  }

  function getComputedStyle(element) {
    return {
      height: element.lineBox,
      getPropertyValue(name) {
        return name === '--read-more-lines' ? element.lines : ''
      }
    }
  }

  const context = {
    module: { exports: {} },
    exports: {},
    ResizeObserver,
    getComputedStyle
  }
  context.globalThis = context

  vm.runInNewContext(transformedSource, context, { filename: filePath })

  return { ControllerClass: context.module.exports, observers }
}

function buildController({ scrollHeight = 40, lines = '4', lineBox = '24px' } = {}) {
  const { ControllerClass, observers } = loadController()
  const controller = new ControllerClass()
  const element = { lines, style: {} }
  const line = { lineBox }
  const body = { scrollHeight }
  const span = { textContent: '' }
  const toggle = {
    hidden: true,
    attributes: {},
    setAttribute(name, value) { this.attributes[name] = String(value) },
    querySelector(selector) { return selector === 'span' ? span : null },
    span
  }

  controller.element = element
  controller.lineTarget = line
  controller.bodyTarget = body
  controller.toggleTarget = toggle
  controller.hasLineTarget = true
  controller.hasBodyTarget = true
  controller.hasToggleTarget = true
  controller.moreLabelValue = 'Show more'
  controller.lessLabelValue = 'Show less'
  controller.overflowingValue = false

  let openValue = false
  Object.defineProperty(controller, 'openValue', {
    get() { return openValue },
    set(next) {
      const previous = openValue
      openValue = next
      if (next !== previous) controller.openValueChanged(next, previous)
    },
    configurable: true
  })

  controller.connect()

  return { controller, element, line, body, toggle, span, observers }
}

test('content that fits hides the button', () => {
  const { toggle, body, observers } = buildController({ scrollHeight: 40 })

  assert.equal(toggle.hidden, true)
  assert.equal(toggle.attributes['aria-expanded'], 'false')
  assert.deepEqual(observers[0].observed, [body])
})

test('overflowing content shows Show more', () => {
  const { toggle, span, element } = buildController({ scrollHeight: 200 })

  assert.equal(toggle.hidden, false)
  assert.equal(toggle.attributes['aria-expanded'], 'false')
  assert.equal(span.textContent, 'Show more')
  assert.equal(element.style.maxHeight, undefined)
})

test('toggle flips the label and expanded state', () => {
  const { controller, toggle, span } = buildController({ scrollHeight: 200 })

  controller.toggle()

  assert.equal(toggle.attributes['aria-expanded'], 'true')
  assert.equal(span.textContent, 'Show less')

  controller.toggle()

  assert.equal(toggle.attributes['aria-expanded'], 'false')
  assert.equal(span.textContent, 'Show more')
})

test('a one pixel remainder does not count as overflow', () => {
  const { controller, body, toggle } = buildController({ scrollHeight: 97 })

  assert.equal(toggle.hidden, true)

  body.scrollHeight = 98
  controller.measure()

  assert.equal(toggle.hidden, false)
})

test('a missing line box hides the button', () => {
  const { toggle } = buildController({ scrollHeight: 500, lineBox: '0px' })

  assert.equal(toggle.hidden, true)
})

test('disconnect disconnects the ResizeObserver', () => {
  const { controller, observers } = buildController()
  const observer = observers[0]

  controller.disconnect()

  assert.equal(observer.disconnected, true)
  assert.equal(controller.observer, null)

  controller.disconnect()

  assert.equal(observer.disconnected, true)
})

test('a second connect does not stack observers', () => {
  const { controller, body, observers } = buildController()
  const first = observers[0]

  controller.connect()

  assert.equal(first.disconnected, true)
  const live = observers.filter((observer) => !observer.disconnected)
  assert.equal(live.length, 1)
  assert.deepEqual(live[0].observed, [body])
})
