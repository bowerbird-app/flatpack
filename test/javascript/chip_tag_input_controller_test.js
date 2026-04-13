const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

function loadController(overrides = {}) {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'chip_tag_input_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformedSource = source
    .replace('import { Controller } from "@hotwired/stimulus"', 'class Controller {}')
    .replace('export default class extends Controller', 'class ChipTagInputController extends Controller') + '\nmodule.exports = ChipTagInputController\n'

  const context = {
    module: { exports: {} },
    exports: {},
    URL,
    CustomEvent: class {
      constructor(type, options = {}) {
        this.type = type
        this.bubbles = options.bubbles || false
        this.detail = options.detail
      }
    },
    window: { location: { origin: 'http://example.test' } },
    document: {
      querySelector(selector) {
        if (selector === "meta[name='csrf-token']") {
          return { content: 'csrf-token' }
        }

        return null
      }
    },
    fetch: async () => ({ ok: true, status: 200 }),
    ...overrides
  }

  vm.runInNewContext(transformedSource, context, { filename: filePath })

  return context.module.exports
}

function buildController({ autoSubmit = false, addUrl = null, addMethod = 'post', addParams = {}, fetchImpl } = {}) {
  const insertions = []
  const dispatchedEvents = []
  const chipsTarget = {
    existingValues: ['frontend'],
    querySelectorAll(selector) {
      if (selector !== '[data-flat-pack--chip-value-value]') {
        return []
      }

      return this.existingValues.map((value) => ({
        dataset: { flatPackChipValueValue: value }
      }))
    },
    insertAdjacentHTML(position, markup) {
      insertions.push({ position, markup })
      const valueMatch = markup.match(/data-flat-pack--chip-value-value="([^"]+)"/)
      if (valueMatch) {
        this.existingValues.push(valueMatch[1])
      }
    }
  }

  const ChipTagInputController = loadController(fetchImpl ? { fetch: fetchImpl } : {})
  const controller = new ChipTagInputController()
  controller.element = {
    dispatchEvent(event) {
      dispatchedEvents.push(event)
    }
  }
  controller.inputTarget = { value: '' }
  controller.chipsTarget = chipsTarget
  controller.templateTarget = {
    innerHTML: '<span data-flat-pack--chip-value-value="__TAG_VALUE__">__TAG_TEXT__</span>'
  }
  controller.autoSubmitValue = autoSubmit
  controller.hasAddUrlValue = Boolean(addUrl)
  controller.addUrlValue = addUrl
  controller.addMethodValue = addMethod
  controller.addParamsValue = addParams

  return { controller, dispatchedEvents, insertions }
}

test('pressing Enter adds a new chip locally when auto-submit is off', async () => {
  const { controller, dispatchedEvents, insertions } = buildController()
  let prevented = false

  await controller.handleKeydown({
    key: 'Enter',
    target: { value: 'API Platform' },
    preventDefault() { prevented = true }
  })

  assert.equal(prevented, true)
  assert.equal(controller.inputTarget.value, '')
  assert.equal(insertions.length, 1)
  assert.equal(insertions[0].position, 'beforeend')
  assert.match(insertions[0].markup, /API Platform/)
  assert.match(insertions[0].markup, /api-platform/)
  assert.equal(dispatchedEvents.length, 1)
  assert.equal(dispatchedEvents[0].type, 'chip:added')
  assert.equal(dispatchedEvents[0].detail.value, 'api-platform')
})

test('duplicate chip values are ignored in local mode', async () => {
  const { controller, dispatchedEvents, insertions } = buildController()

  await controller.handleKeydown({
    key: 'Enter',
    target: { value: 'Frontend' },
    preventDefault() {}
  })

  assert.equal(insertions.length, 0)
  assert.equal(dispatchedEvents.length, 0)
})

test('non-Enter keys do nothing', async () => {
  const { controller, insertions } = buildController()
  let prevented = false

  await controller.handleKeydown({
    key: 'Tab',
    target: { value: 'Docs' },
    preventDefault() { prevented = true }
  })

  assert.equal(prevented, false)
  assert.equal(insertions.length, 0)
})

test('auto-submit posts to the add callback and inserts only after success', async () => {
  const fetchCalls = []
  const { controller, dispatchedEvents, insertions } = buildController({
    autoSubmit: true,
    addUrl: '/demo/chips/add_callback',
    addMethod: 'post',
    addParams: { source: 'chips_demo', mode: 'auto' },
    fetchImpl: async (url, options) => {
      fetchCalls.push({ url, options })
      return { ok: true, status: 200 }
    }
  })

  await controller.handleKeydown({
    key: 'Enter',
    target: { value: 'Release Notes' },
    preventDefault() {}
  })

  assert.equal(fetchCalls.length, 1)
  assert.equal(fetchCalls[0].url, '/demo/chips/add_callback')
  assert.equal(fetchCalls[0].options.method, 'POST')
  assert.equal(fetchCalls[0].options.headers['X-CSRF-Token'], 'csrf-token')
  assert.deepEqual(JSON.parse(fetchCalls[0].options.body), {
    text: 'Release Notes',
    value: 'release-notes',
    source: 'chips_demo',
    mode: 'auto'
  })
  assert.equal(insertions.length, 1)
  assert.equal(dispatchedEvents.length, 1)
  assert.equal(dispatchedEvents[0].type, 'chip:added')
  assert.equal(dispatchedEvents[0].detail.text, 'Release Notes')
})

test('auto-submit failures leave the chip list unchanged and emit chip:add-failed', async () => {
  const fetchCalls = []
  const { controller, dispatchedEvents, insertions } = buildController({
    autoSubmit: true,
    addUrl: '/demo/chips/add_callback',
    addMethod: 'get',
    addParams: { source: 'chips_demo', fail: true },
    fetchImpl: async (url, options) => {
      fetchCalls.push({ url, options })
      return { ok: false, status: 422 }
    }
  })

  await controller.handleKeydown({
    key: 'Enter',
    target: { value: 'Blocked' },
    preventDefault() {}
  })

  assert.equal(fetchCalls.length, 1)
  assert.equal(fetchCalls[0].options.method, 'GET')
  const requestUrl = new URL(fetchCalls[0].url)
  assert.equal(requestUrl.origin, 'http://example.test')
  assert.equal(requestUrl.pathname, '/demo/chips/add_callback')
  assert.deepEqual(Object.fromEntries(requestUrl.searchParams.entries()), {
    source: 'chips_demo',
    fail: 'true',
    text: 'Blocked',
    value: 'blocked'
  })
  assert.equal(insertions.length, 0)
  assert.equal(dispatchedEvents.length, 1)
  assert.equal(dispatchedEvents[0].type, 'chip:add-failed')
  assert.equal(dispatchedEvents[0].detail.error, 'Chip add request failed: 422')
})