const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')

test('picker checkbox classes use theme primary CSS vars', () => {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'picker_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')

  assert.match(source, /accent-\[var\(--color-primary\)\]/)
  assert.match(source, /checked:bg-\[var\(--color-primary\)\]/)
  assert.match(source, /checked:border-\[var\(--color-primary\)\]/)
  assert.match(source, /checked:text-\[var\(--color-primary-text\)\]/)
  assert.doesNotMatch(source, /"accent-primary"/)
  assert.doesNotMatch(source, /checked:bg-primary(?![-\[])/)
  assert.doesNotMatch(source, /checked:border-primary(?![-\[])/)
  assert.doesNotMatch(source, /"text-primary"/)
  assert.doesNotMatch(source, /emptyStateTarget\.textContent/)
  assert.doesNotMatch(source, /emptyStateTarget\.innerHTML/)
  assert.doesNotMatch(source, /errorStateTarget\.textContent\s*=/)
  assert.doesNotMatch(source, /errorStateTarget\.innerHTML/)
  assert.match(source, /#syncEmptyState/)
  assert.match(source, /#showLoadError/)
})

const vm = require('node:vm')

function classList(initial = []) {
  const classes = new Set(initial)
  return {
    classes,
    add(...names) { names.forEach((name) => classes.add(name)) },
    remove(...names) { names.forEach((name) => classes.delete(name)) },
    contains(name) { return classes.has(name) },
    toggle(name, force) {
      const has = classes.has(name)
      const should = force === undefined ? !has : Boolean(force)
      if (should) classes.add(name)
      else classes.delete(name)
      return should
    }
  }
}

function loadController({ fetchImpl } = {}) {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'picker_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformed = source
    .replace('import { Controller } from "@hotwired/stimulus"', 'class Controller {}')
    .replace('import { flatPackCopy } from "flat_pack/copy"', 'const flatPackCopy = (key) => key')
    .replace('import { createRemoteQuery } from "flat_pack/remote_query"', '')
    .replace('export default class extends Controller', 'class PickerController extends Controller') + '\nmodule.exports = PickerController\n'
  const remoteQueryPath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'remote_query.js')
  const remoteQuerySource = fs.readFileSync(remoteQueryPath, 'utf8').replaceAll('export function ', 'function ')
  const bridge = { pending: Promise.resolve() }
  const context = {
    module: { exports: {} },
    exports: {},
    URL,
    URLSearchParams,
    AbortController,
    fetch: fetchImpl || (async () => ({ ok: true, json: async () => ({ items: [] }) })),
    window: { location: { origin: 'http://example.test' } },
    setTimeout(fn) {
      fn()
      return 1
    },
    clearTimeout() {}
  }

  vm.runInNewContext(`${remoteQuerySource}\n${transformed}`, context, { filename: filePath })
  context.module.exports.bridge = bridge
  return context.module.exports
}

function buildController(options = {}) {
  const ControllerClass = loadController(options)
  const controller = new ControllerClass()
  const slotMarkup = '<button type="button" data-picker-empty-action="add">Add an asset</button>'
  controller.element = {
    querySelector() { return null },
    querySelectorAll() { return [] }
  }
  controller.itemsValue = [
    { id: 'hero', kind: 'image', name: 'hero.png', label: 'Homepage Hero', title: 'Homepage Hero' },
    { id: 'brief', kind: 'file', name: 'brief.pdf', label: 'Brief', title: 'Brief' }
  ]
  controller.acceptedKindsValue = []
  controller.searchableValue = true
  controller.searchModeValue = options.searchMode || 'local'
  controller.searchParamValue = 'q'
  controller.hasSearchEndpointValue = Boolean(options.endpoint)
  controller.searchEndpointValue = options.endpoint || ''
  controller.pickerIdValue = 'picker-demo'
  controller.resultsLayoutValue = 'list'
  controller.selectionModeValue = 'multiple'
  controller.outputModeValue = 'event'
  controller.hasFormValue = false
  controller.hasResultsTarget = true
  controller.hasEmptyStateTarget = true
  controller.resultsTarget = { innerHTML: '', className: '' }
  controller.emptyStateTarget = {
    classList: classList(['hidden']),
    textContent: 'No assets found',
    innerHTML: slotMarkup
  }
  controller.connect()
  return { controller, slotMarkup, bridge: ControllerClass.bridge }
}

test('local search shows the empty slot and hides it without rewriting the slot', () => {
  const { controller, slotMarkup } = buildController()

  assert.equal(controller.emptyStateTarget.classList.contains('hidden'), true)
  assert.equal(controller.emptyStateTarget.innerHTML, slotMarkup)
  assert.equal(controller.emptyStateTarget.textContent, 'No assets found')

  controller.search({ target: { value: 'zzzz-no-match' } })

  assert.equal(controller.emptyStateTarget.classList.contains('hidden'), false)
  assert.equal(controller.emptyStateTarget.classList.contains('flex'), true)
  assert.equal(controller.emptyStateTarget.innerHTML, slotMarkup)
  assert.equal(controller.emptyStateTarget.textContent, 'No assets found')
  assert.equal(controller.resultsTarget.innerHTML, '')

  controller.search({ target: { value: 'Hero' } })

  assert.equal(controller.emptyStateTarget.classList.contains('hidden'), true)
  assert.equal(controller.emptyStateTarget.classList.contains('flex'), false)
  assert.equal(controller.emptyStateTarget.innerHTML, slotMarkup)
  assert.match(controller.resultsTarget.innerHTML, /Homepage Hero/)
})

test('remote search shows and hides the empty slot without rewriting it', async () => {
  const responses = [
    { items: [] },
    { items: [{ id: 'hero', kind: 'image', name: 'hero.png', label: 'Homepage Hero', title: 'Homepage Hero' }] }
  ]
  let index = 0
  const { controller, slotMarkup } = buildController({
    searchMode: 'remote',
    endpoint: 'http://example.test/demo/picker_results',
    fetchImpl: () => ({
      ok: true,
      json: async () => responses[index++]
    })
  })

  controller.search({ target: { value: 'zzzz-no-match' } })
  await new Promise((resolve) => setImmediate(resolve))

  assert.equal(controller.emptyStateTarget.classList.contains('hidden'), false)
  assert.equal(controller.emptyStateTarget.classList.contains('flex'), true)
  assert.equal(controller.emptyStateTarget.innerHTML, slotMarkup)
  assert.equal(controller.resultsTarget.innerHTML, '')

  controller.search({ target: { value: 'Hero' } })
  await new Promise((resolve) => setImmediate(resolve))

  assert.equal(controller.emptyStateTarget.classList.contains('hidden'), true)
  assert.equal(controller.emptyStateTarget.innerHTML, slotMarkup)
  assert.match(controller.resultsTarget.innerHTML, /Homepage Hero/)
})

function element() {
  return {
    innerHTML: '',
    textContent: '',
    className: '',
    classList: classList(),
    attributes: {},
    events: [],
    setAttribute(name, value) { this.attributes[name] = String(value) },
    removeAttribute(name) { delete this.attributes[name] },
    querySelector() { return null },
    querySelectorAll() { return [] },
    insertAdjacentHTML(_position, markup) { this.innerHTML += markup },
    dispatchEvent(event) { this.events.push(event) }
  }
}

function item(id, label) {
  return { id, kind: 'file', label, name: label, icon: 'document-text' }
}

function loadPicker() {
  const root = path.join(__dirname, '..', '..')
  const remoteSource = fs.readFileSync(path.join(root, 'app/javascript/flat_pack/remote_query.js'), 'utf8')
    .replace('export function createRemoteQuery', 'function createRemoteQuery')
  const controllerSource = fs.readFileSync(path.join(root, 'app/javascript/flat_pack/controllers/picker_controller.js'), 'utf8')
    .replace('import { Controller } from "@hotwired/stimulus"', 'class Controller {}')
    .replace('import { flatPackCopy } from "flat_pack/copy"', '')
    .replace('import { createRemoteQuery } from "flat_pack/remote_query"', '')
    .replace('export default class extends Controller', 'class PickerController extends Controller')
  const copySource = `
    function flatPackCopy(key, vars = {}) {
      const templates = { "picker.results_loaded": "%{count} loaded", "picker.untitled": "Untitled" }
      return String(templates[key] || key).replace(/%\\{(\\w+)\\}/g, (_, name) => vars[name] == null ? "" : String(vars[name]))
    }
  `
  const requests = []
  const context = {
    module: { exports: {} },
    requests,
    URL,
    AbortController,
    CustomEvent,
    setTimeout,
    clearTimeout,
    window: { location: { origin: 'http://example.test' } }
  }
  context.HTMLInputElement = class HTMLInputElement {}
  context.HTMLElement = class HTMLElement {}
  context.IntersectionObserver = class IntersectionObserver {
    constructor(callback, options) {
      this.callback = callback
      this.options = options
      this.observed = []
      context.lastObserver = this
    }
    observe(node) { this.observed.push(node) }
    unobserve() {}
    disconnect() { this.disconnected = true }
    intersect() {
      this.callback(this.observed.map((target) => ({ isIntersecting: true, target })))
    }
  }
  context.fetch = (url, options) => {
    let settled = false
    const record = { url: String(url), options }
    requests.push(record)
    return new Promise((resolve, reject) => {
      options.signal.addEventListener('abort', () => {
        if (settled) return
        settled = true
        const error = new Error('aborted')
        error.name = 'AbortError'
        reject(error)
      })
      record.respond = (body, { jsonDelay = 0, ok = true } = {}) => {
        if (settled) return
        settled = true
        resolve({
          ok,
          status: ok ? 200 : 500,
          json: () => new Promise((done) => setTimeout(() => done(body), jsonDelay))
        })
      }
      record.reject = (error) => {
        if (settled) return
        settled = true
        reject(error || Object.assign(new Error('network'), { name: 'TypeError' }))
      }
    })
  }
  vm.runInNewContext(
    `${copySource}\n${remoteSource}\n${controllerSource}\nmodule.exports = PickerController\n`,
    context,
    { filename: 'picker_controller.js' }
  )
  return { Controller: context.module.exports, context, requests }
}

function build({ mode = 'remote', items = [], kinds = [] } = {}) {
  const loaded = loadPicker()
  const region = element()
  const results = element()
  const empty = element()
  empty.textContent = 'No assets found'
  empty.classList.add('hidden')
  const error = element()
  error.textContent = 'Unable to load items'
  error.classList.add('hidden')
  const loading = element()
  loading.classList.add('hidden')
  const sentinel = element()
  const status = element()
  const root = element()
  root.querySelector = (selector) => selector === '[data-flat-pack-picker-items-region]' ? region : null

  const controller = Object.assign(new loaded.Controller(), {
    element: root,
    pickerIdValue: 'picker',
    itemsValue: items,
    selectionModeValue: 'multiple',
    modalValue: false,
    autoConfirmValue: false,
    acceptedKindsValue: kinds,
    searchableValue: true,
    searchModeValue: mode,
    searchEndpointValue: '/demo/picker_results',
    hasSearchEndpointValue: true,
    searchParamValue: 'q',
    outputModeValue: 'event',
    hasOutputTargetValue: false,
    outputTargetValue: '',
    formValue: {},
    hasFormValue: false,
    contextValue: {},
    emptyTextValue: 'No assets found',
    resultsLayoutValue: 'list',
    hasResultsTarget: true,
    resultsTarget: results,
    hasEmptyStateTarget: true,
    emptyStateTarget: empty,
    hasErrorStateTarget: mode === 'remote',
    errorStateTarget: error,
    hasOutputFieldTarget: false,
    hasFormFieldsTarget: false,
    hasLoadingTarget: mode === 'remote',
    loadingTarget: loading,
    hasSentinelTarget: mode === 'remote',
    sentinelTarget: sentinel,
    hasStatusTarget: mode === 'remote',
    statusTarget: status
  })

  return { controller, requests: loaded.requests, context: loaded.context, region, results, empty, error, loading, status, root }
}

function wait(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms))
}

function selectionIds(harness) {
  return JSON.parse(JSON.stringify(harness.root.events.at(-1).detail.selection.map((entry) => entry.id)))
}

async function settle() {
  await wait(30)
}

test('a new query replaces the list and a later page appends', async () => {
  const harness = build()
  harness.controller.connect()

  assert.equal(harness.requests.length, 1)
  assert.match(harness.requests[0].url, /[?&]page=1(?:&|$)/)
  assert.match(harness.requests[0].url, /[?&]q=(&|$)/)
  assert.equal(harness.context.lastObserver.options.root, harness.region)
  assert.equal(harness.loading.classList.contains('hidden'), false)

  harness.requests[0].respond({
    items: [item('a', 'Alpha'), item('b', 'Beta')],
    pagination: { next_page: 2 }
  })
  await settle()

  assert.match(harness.results.innerHTML, /Alpha/)
  assert.match(harness.results.innerHTML, /Beta/)
  assert.equal(harness.status.textContent, '2 loaded')
  assert.equal(harness.empty.classList.contains('hidden'), true)
  assert.equal(harness.loading.classList.contains('hidden'), true)

  harness.context.lastObserver.intersect()
  assert.equal(harness.requests.length, 2)
  assert.match(harness.requests[1].url, /[?&]page=2(?:&|$)/)
  assert.equal(harness.loading.classList.contains('hidden'), false)

  harness.requests[1].respond({
    items: [item('c', 'Gamma')],
    pagination: { next_page: null }
  })
  await settle()

  assert.match(harness.results.innerHTML, /Alpha/)
  assert.match(harness.results.innerHTML, /Gamma/)
  assert.equal(harness.status.textContent, '3 loaded')

  harness.controller.search({ target: { value: 'beta' } })
  await wait(320)
  const queryRequest = harness.requests.at(-1)
  assert.match(queryRequest.url, /[?&]page=1(?:&|$)/)
  assert.match(queryRequest.url, /[?&]q=beta(?:&|$)/)
  queryRequest.respond({
    items: [item('b', 'Beta only')],
    pagination: { next_page: null }
  })
  await settle()

  assert.doesNotMatch(harness.results.innerHTML, /Alpha/)
  assert.match(harness.results.innerHTML, /Beta only/)

  harness.controller.search({ target: { value: '' } })
  await wait(320)
  const cleared = harness.requests.at(-1)
  assert.match(cleared.url, /[?&]page=1(?:&|$)/)
  assert.match(cleared.url, /[?&]q=(&|$)/)
  cleared.respond({
    items: [item('all', 'Everything')],
    pagination: { next_page: null }
  })
  await settle()

  assert.doesNotMatch(harness.results.innerHTML, /Beta only/)
  assert.match(harness.results.innerHTML, /Everything/)
})

test('paging stops when next_page is null or pagination is absent', async () => {
  const harness = build()
  harness.controller.connect()
  harness.requests[0].respond({
    items: [item('a', 'Alpha')],
    pagination: { next_page: null }
  })
  await settle()

  const count = harness.requests.length
  harness.context.lastObserver.intersect()
  assert.equal(harness.requests.length, count)

  const missing = build()
  missing.controller.connect()
  missing.requests[0].respond({ items: [item('a', 'Alpha')] })
  await settle()
  missing.context.lastObserver.intersect()
  assert.equal(missing.requests.length, 1)
})

test('a stale response does not replace the latest query', async () => {
  const harness = build()
  harness.controller.connect()
  harness.requests[0].respond({
    items: [item('a', 'Alpha')],
    pagination: { next_page: null }
  })
  await settle()

  harness.controller.search({ target: { value: 'slow' } })
  await wait(320)
  const slow = harness.requests.at(-1)
  slow.respond({
    items: [item('slow', 'Slow result')],
    pagination: { next_page: 2 }
  }, { jsonDelay: 80 })

  harness.controller.search({ target: { value: 'fast' } })
  await wait(320)
  const fast = harness.requests.at(-1)
  fast.respond({
    items: [item('fast', 'Fast result')],
    pagination: { next_page: null }
  })
  await wait(120)

  assert.match(harness.results.innerHTML, /Fast result/)
  assert.doesNotMatch(harness.results.innerHTML, /Slow result/)
  harness.context.lastObserver.intersect()
  assert.equal(harness.requests.at(-1), fast)
})

test('confirm keeps selections from an earlier page and an earlier query', async () => {
  const harness = build()
  harness.controller.connect()
  harness.requests[0].respond({
    items: [item('a', 'Alpha'), item('b', 'Beta')],
    pagination: { next_page: 2 }
  })
  await settle()

  const first = new harness.context.HTMLInputElement()
  first.dataset = { itemId: 'a' }
  first.checked = true
  harness.controller.handleSelectionChange({ target: first })

  harness.context.lastObserver.intersect()
  harness.requests.at(-1).respond({
    items: [item('c', 'Gamma')],
    pagination: { next_page: null }
  })
  await settle()

  harness.controller.confirmSelection()
  assert.deepEqual(selectionIds(harness), ['a'])

  harness.controller.search({ target: { value: 'other' } })
  await wait(320)
  harness.requests.at(-1).respond({
    items: [item('z', 'Zed')],
    pagination: { next_page: null }
  })
  await settle()

  harness.controller.confirmSelection()
  assert.deepEqual(selectionIds(harness), ['a'])

  const later = new harness.context.HTMLInputElement()
  later.dataset = { itemId: 'z' }
  later.checked = true
  harness.controller.handleSelectionChange({ target: later })
  harness.controller.confirmSelection()

  assert.deepEqual(selectionIds(harness), ['a', 'z'])
  assert.equal(JSON.parse(JSON.stringify(harness.root.events.at(-1).detail.selection[0].label)), 'Alpha')
})

test('an empty remote page still shows the empty state', async () => {
  const harness = build()
  harness.controller.connect()
  harness.requests[0].respond({ items: [], pagination: { next_page: null } })
  await settle()

  assert.equal(harness.results.innerHTML, '')
  assert.equal(harness.empty.classList.contains('hidden'), false)
  assert.equal(harness.empty.classList.contains('flex'), true)
  assert.equal(harness.empty.textContent, 'No assets found')
  harness.context.lastObserver.intersect()
  assert.equal(harness.requests.length, 1)
})

test('a non-OK response shows the error slot and the next query clears it', async () => {
  const harness = build()
  const slot = '<p data-picker-error-copy>Library down</p>'
  harness.error.innerHTML = slot
  harness.error.textContent = 'Library down'
  harness.controller.connect()

  harness.requests[0].respond({}, { ok: false })
  await settle()

  assert.equal(harness.results.innerHTML, '')
  assert.equal(harness.error.classList.contains('hidden'), false)
  assert.equal(harness.error.classList.contains('flex'), true)
  assert.equal(harness.error.innerHTML, slot)
  assert.equal(harness.empty.classList.contains('hidden'), true)
  assert.equal(harness.status.textContent, 'Library down')
  assert.equal(harness.loading.classList.contains('hidden'), true)

  harness.controller.search({ target: { value: 'hero' } })
  await wait(320)
  harness.requests.at(-1).respond({
    items: [item('hero', 'Homepage Hero')],
    pagination: { next_page: null }
  })
  await settle()

  assert.match(harness.results.innerHTML, /Homepage Hero/)
  assert.equal(harness.error.classList.contains('hidden'), true)
  assert.equal(harness.error.classList.contains('flex'), false)
  assert.equal(harness.error.innerHTML, slot)
  assert.equal(harness.status.textContent, '1 loaded')
})

test('a rejected fetch shows the error slot instead of the empty slot', async () => {
  const harness = build()
  harness.controller.connect()
  harness.requests[0].reject()
  await settle()

  assert.equal(harness.results.innerHTML, '')
  assert.equal(harness.error.classList.contains('hidden'), false)
  assert.equal(harness.error.textContent, 'Unable to load items')
  assert.equal(harness.empty.classList.contains('hidden'), true)
  assert.equal(harness.status.textContent, 'Unable to load items')
})

test('a failed later page keeps the list and the next scroll tries again', async () => {
  const harness = build()
  harness.controller.connect()
  harness.requests[0].respond({
    items: [item('a', 'Alpha')],
    pagination: { next_page: 2 }
  })
  await settle()

  harness.context.lastObserver.intersect()
  assert.match(harness.requests.at(-1).url, /[?&]page=2(?:&|$)/)
  harness.requests.at(-1).respond({}, { ok: false })
  await settle()

  assert.match(harness.results.innerHTML, /Alpha/)
  assert.equal(harness.error.classList.contains('hidden'), false)
  assert.equal(harness.empty.classList.contains('hidden'), true)
  assert.equal(harness.status.textContent, 'Unable to load items')

  const before = harness.requests.length
  harness.context.lastObserver.intersect()
  assert.equal(harness.requests.length, before + 1)
  assert.match(harness.requests.at(-1).url, /[?&]page=2(?:&|$)/)

  harness.requests.at(-1).respond({
    items: [item('c', 'Gamma')],
    pagination: { next_page: null }
  })
  await settle()

  assert.match(harness.results.innerHTML, /Alpha/)
  assert.match(harness.results.innerHTML, /Gamma/)
  assert.equal(harness.error.classList.contains('hidden'), true)
  assert.equal(harness.status.textContent, '2 loaded')
})

test('an aborted request does not show the error slot', async () => {
  const harness = build()
  harness.controller.connect()
  harness.controller.search({ target: { value: 'next' } })
  await wait(320)

  assert.equal(harness.error.classList.contains('hidden'), true)
  harness.requests.at(-1).respond({
    items: [item('n', 'Next')],
    pagination: { next_page: null }
  })
  await settle()

  assert.match(harness.results.innerHTML, /Next/)
  assert.equal(harness.error.classList.contains('hidden'), true)
  assert.equal(harness.empty.classList.contains('hidden'), true)
})

test('local confirm still returns the selected item', () => {
  const harness = build({
    mode: 'local',
    items: [item('local', 'Local file')]
  })
  harness.controller.connect()

  assert.equal(harness.requests.length, 0)
  assert.match(harness.results.innerHTML, /Local file/)

  const input = new harness.context.HTMLInputElement()
  input.dataset = { itemId: 'local' }
  input.checked = true
  harness.controller.handleSelectionChange({ target: input })
  harness.controller.confirmSelection()

  assert.deepEqual(selectionIds(harness), ['local'])
})
