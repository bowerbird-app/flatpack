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
  assert.match(source, /#syncEmptyState/)
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
  controller.element = { querySelectorAll() { return [] } }
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
