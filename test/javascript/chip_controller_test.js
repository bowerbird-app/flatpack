const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

class FakeCustomEvent {
  constructor(type, options = {}) {
    this.type = type
    this.bubbles = options.bubbles || false
    this.detail = options.detail
  }
}

function loadChipController(overrides = {}) {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'chip_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformedSource = source
    .replace('import { Controller } from "@hotwired/stimulus"', 'class Controller {}')
    .replace('export default class extends Controller', 'class ChipController extends Controller') + '\nmodule.exports = ChipController\n'

  const context = {
    module: { exports: {} },
    exports: {},
    URL,
    setTimeout,
    clearTimeout,
    ...overrides
  }

  vm.runInNewContext(transformedSource, context, { filename: filePath })

  return context.module.exports
}

function buildController({ fetchImpl, method = 'post', params = {}, value = 'ruby-failure' }) {
  const button = {
    disabled: false,
    attributes: {},
    setAttribute(name, value) {
      this.attributes[name] = value
    }
  }

  const dispatchedEvents = []
  const element = {
    dataset: {
      flatPackChipRemoveUrlValue: '/demo/chips/remove_callback',
      flatPackChipRemoveMethodValue: method,
      flatPackChipRemoveParamsValue: JSON.stringify(params)
    },
    removed: false,
    querySelector(selector) {
      if (selector === "button[aria-label='Remove']") return button

      return null
    },
    dispatchEvent(event) {
      dispatchedEvents.push(event)
    },
    remove() {
      this.removed = true
    }
  }

  const document = {
    querySelector(selector) {
      if (selector === "meta[name='csrf-token']") {
        return { content: 'csrf-token' }
      }

      return null
    }
  }

  const ChipController = loadChipController({
    fetch: fetchImpl,
    document,
    window: { location: { origin: 'http://example.test' } },
    CustomEvent: FakeCustomEvent
  })

  const controller = new ChipController()
  controller.element = element
  controller.chipTarget = { style: {} }
  controller.valueValue = value
  controller.removeUrlValue = '/demo/chips/remove_callback'
  controller.removeMethodValue = method
  controller.removeParamsValue = params
  controller.hasRemoveUrlValue = true
  controller.hasRemoveMethodValue = true
  controller.hasRemoveParamsValue = true

  return { button, controller, dispatchedEvents, element }
}

test('failed remove request preserves the chip and emits chip:remove-failed', async () => {
  const fetchCalls = []
  const { button, controller, dispatchedEvents, element } = buildController({
    fetchImpl: async (url, options) => {
      fetchCalls.push({ url, options })
      return { ok: false, status: 422 }
    },
    params: { tag: 'ruby', source: 'chips_demo', fail: true }
  })

  let prevented = false
  await controller.remove({ preventDefault() { prevented = true } })

  assert.equal(prevented, true)
  assert.equal(fetchCalls.length, 1)
  assert.equal(fetchCalls[0].url, '/demo/chips/remove_callback')
  assert.equal(fetchCalls[0].options.method, 'POST')
  assert.equal(fetchCalls[0].options.body, JSON.stringify({ tag: 'ruby', source: 'chips_demo', fail: true }))
  assert.equal(controller.removing, false)
  assert.equal(button.disabled, false)
  assert.equal(button.attributes['aria-busy'], 'false')
  assert.equal(element.removed, false)
  assert.equal(dispatchedEvents.length, 1)
  assert.equal(dispatchedEvents[0].type, 'chip:remove-failed')
  assert.equal(dispatchedEvents[0].detail.value, 'ruby-failure')
  assert.equal(dispatchedEvents[0].detail.element, controller.chipTarget)
  assert.equal(dispatchedEvents[0].detail.error, 'Chip remove request failed: 422')
})

test('remove request falls back to dataset values when Stimulus value flags are missing', async () => {
  const fetchCalls = []
  const { controller, element } = buildController({
    fetchImpl: async (url, options) => {
      fetchCalls.push({ url, options })
      return { ok: true, status: 200 }
    },
    method: 'get',
    params: { tag: 'ruby', source: 'chips_demo' },
    value: 'ruby'
  })

  controller.hasRemoveUrlValue = false
  controller.hasRemoveMethodValue = false
  controller.hasRemoveParamsValue = false

  await controller.remove({ preventDefault() {} })
  await new Promise((resolve) => setTimeout(resolve, 250))

  assert.equal(fetchCalls.length, 1)
  assert.equal(fetchCalls[0].options.method, 'GET')
  assert.equal(fetchCalls[0].url, 'http://example.test/demo/chips/remove_callback?tag=ruby&source=chips_demo')
  assert.equal(element.removed, true)
})
