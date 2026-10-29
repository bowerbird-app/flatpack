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

class FakeCustomEvent {
  constructor(type, options = {}) {
    this.type = type
    this.bubbles = options.bubbles || false
    this.cancelable = options.cancelable || false
    this.detail = options.detail
    this.defaultPrevented = false
  }

  preventDefault() {
    if (this.cancelable) this.defaultPrevented = true
  }
}

class FakeElement {
  constructor(tagName) {
    this.tagName = tagName
    this.children = []
    this.dataset = {}
    this.attributes = {}
    this.style = {}
    this.classList = new FakeClassList()
    this.listeners = {}
    this.value = ''
    this.textContent = ''
    this.id = ''
    this.parentNode = null
  }

  set className(value) {
    this.classList = new FakeClassList(String(value).split(/\s+/).filter(Boolean))
  }

  setAttribute(name, value) {
    this.attributes[name] = String(value)
    if (name.startsWith('data-')) {
      const key = name.slice(5).replace(/-([a-z])/g, (_, letter) => letter.toUpperCase())
      this.dataset[key] = String(value)
    }
  }

  getAttribute(name) {
    return this.attributes[name]
  }

  removeAttribute(name) {
    delete this.attributes[name]
  }

  scrollIntoView() {}

  contains(node) {
    if (node === this) return true
    return this.children.some((child) => child === node || child.contains?.(node))
  }

  appendChild(child) {
    child.parentNode = this
    this.children.push(child)
    return child
  }

  querySelectorAll(selector) {
    const matches = []
    const walk = (node) => {
      node.children.forEach((child) => {
        if (matchesSelector(child, selector)) matches.push(child)
        walk(child)
      })
    }
    walk(this)
    return matches
  }

  remove() {
    if (!this.parentNode) return
    this.parentNode.children = this.parentNode.children.filter((child) => child !== this)
    this.parentNode = null
  }

  addEventListener(type, listener) {
    this.listeners[type] = this.listeners[type] || []
    this.listeners[type].push(listener)
  }

  dispatchEvent(event) {
    ;(this.listeners[event.type] || []).forEach((listener) => listener(event))
    return !event.defaultPrevented
  }

  focus() {}
}

function matchesSelector(node, selector) {
  if (selector === '[role="option"]') return node.attributes.role === 'option'
  return false
}

function loadController({ fetchImpl } = {}) {
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
    },
    createElement(tagName) {
      return new FakeElement(tagName)
    }
  }

  const context = {
    module: { exports: {} },
    exports: {},
    document: activeDocument,
    window: { location: { origin: 'http://example.test' } },
    URL,
    CustomEvent: FakeCustomEvent,
    Event: FakeCustomEvent,
    AbortController,
    fetch: fetchImpl || (async () => ({ ok: true, json: async () => ({ options: [] }) })),
    setTimeout(fn) {
      fn()
      return 1
    },
    clearTimeout() {}
  }

  vm.runInNewContext(clickOutsideSource + '\n' + transformedSource, context, { filename: filePath })

  return context.module.exports
}

function buildController() {
  const ControllerClass = loadController()
  const controller = new ControllerClass()
  const option = new FakeElement('li')
  option.dataset.label = 'Melbourne'
  option.dataset.value = 'melbourne'
  option.setAttribute('role', 'option')
  option.id = 'city-option-0'

  controller.element = new FakeElement('div')
  controller.inputTarget = new FakeElement('input')
  controller.valueTarget = new FakeElement('input')
  controller.listTarget = new FakeElement('ul')
  controller.listTarget.id = 'city-list'
  controller.emptyTarget = new FakeElement('li')
  controller.optionTargets = [option]
  controller.listTarget.appendChild(option)
  controller.listTarget.appendChild(controller.emptyTarget)
  controller.listTarget.classList.add('hidden')
  controller.hasHintTarget = false
  controller.hasLoadingTarget = false
  controller.loaderValue = false
  controller.searchEndpointValue = ''
  controller.searchParamValue = 'q'
  controller.minSearchLengthValue = 2
  controller.debounceValue = 0
  controller.connect()

  return controller
}

function buildRemoteController({ fetchImpl, loader = false } = {}) {
  const ControllerClass = loadController({ fetchImpl })
  const controller = new ControllerClass()
  controller.element = new FakeElement('div')
  controller.inputTarget = new FakeElement('input')
  controller.valueTarget = new FakeElement('input')
  controller.listTarget = new FakeElement('ul')
  controller.listTarget.id = 'place-list'
  controller.emptyTarget = new FakeElement('li')
  controller.emptyTarget.classList.add('hidden')
  controller.hintTarget = new FakeElement('li')
  controller.hintTarget.classList.add('hidden')
  controller.loadingTarget = new FakeElement('li')
  controller.loadingTarget.classList.add('hidden')
  controller.listTarget.appendChild(controller.hintTarget)
  controller.listTarget.appendChild(controller.loadingTarget)
  controller.listTarget.appendChild(controller.emptyTarget)
  controller.listTarget.classList.add('hidden')
  controller.hasHintTarget = true
  controller.hasLoadingTarget = true
  controller.loaderValue = loader
  controller.searchEndpointValue = loader ? '' : '/demo/forms/combobox/options'
  controller.searchParamValue = 'q'
  controller.minSearchLengthValue = 3
  controller.debounceValue = 0
  controller.connect()
  return controller
}

async function flush() {
  await new Promise((resolve) => setImmediate(resolve))
  await new Promise((resolve) => setImmediate(resolve))
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

test('local filter hides non-matching options and shows empty', () => {
  const controller = buildController()
  const other = new FakeElement('li')
  other.dataset.label = 'Sydney'
  other.dataset.value = 'sydney'
  other.setAttribute('role', 'option')
  controller.listTarget.appendChild(other)
  controller.open()

  controller.inputTarget.value = 'syd'
  controller.filter()

  assert.equal(controller.listTarget.children[0].classList.contains('hidden'), true)
  assert.equal(other.classList.contains('hidden'), false)
  assert.equal(controller.emptyTarget.classList.contains('hidden'), true)
  assert.equal(controller.valueTarget.value, '')
})

test('remote fetch paints options from json and keeps keyboard selection', async () => {
  const fetchCalls = []
  const controller = buildRemoteController({
    fetchImpl: async (url, options) => {
      fetchCalls.push({ url, options })
      return {
        ok: true,
        json: async () => ({
          options: [
            { value: 'fed-square', label: 'Federation Square', subtitle: 'Melbourne VIC' }
          ]
        })
      }
    }
  })

  controller.inputTarget.value = 'mel'
  controller.filter()
  await flush()

  assert.equal(fetchCalls.length, 1)
  assert.equal(fetchCalls[0].url, 'http://example.test/demo/forms/combobox/options?q=mel')
  assert.equal(fetchCalls[0].options.headers.Accept, 'application/json')
  assert.equal(controller.inputTarget.attributes['aria-expanded'], 'true')
  assert.equal(controller.loadingTarget.classList.contains('hidden'), true)

  const option = controller.listTarget.querySelectorAll('[role="option"]')[0]
  assert.equal(option.dataset.value, 'fed-square')
  assert.equal(option.dataset.label, 'Federation Square')
  assert.equal(option.dataset.subtitle, 'Melbourne VIC')
  assert.equal(controller.inputTarget.attributes['aria-activedescendant'], option.id)

  controller.keydown({ key: 'Enter', preventDefault() {} })
  assert.equal(controller.valueTarget.value, 'fed-square')
  assert.equal(controller.inputTarget.value, 'Federation Square')
  assert.equal(controller.openList, false)
})

test('remote search shows a hint before min characters and skips fetch', async () => {
  let fetched = false
  const controller = buildRemoteController({
    fetchImpl: async () => {
      fetched = true
      return { ok: true, json: async () => ({ options: [] }) }
    }
  })

  controller.inputTarget.value = 'me'
  controller.filter()
  await flush()

  assert.equal(fetched, false)
  assert.equal(controller.hintTarget.classList.contains('hidden'), false)
  assert.equal(controller.loadingTarget.classList.contains('hidden'), true)
})

test('remote empty json shows the empty row', async () => {
  const controller = buildRemoteController({
    fetchImpl: async () => ({ ok: true, json: async () => ({ options: [] }) })
  })

  controller.inputTarget.value = 'zzz'
  controller.filter()
  await flush()

  assert.equal(controller.emptyTarget.classList.contains('hidden'), false)
  assert.equal(controller.listTarget.querySelectorAll('[role="option"]').length, 0)
})

test('failed fetch shows the empty row', async () => {
  const controller = buildRemoteController({
    fetchImpl: async () => ({ ok: false, json: async () => ({}) })
  })

  controller.inputTarget.value = 'mel'
  controller.filter()
  await flush()

  assert.equal(controller.emptyTarget.classList.contains('hidden'), false)
})

test('results arrays and id keys normalize into options', async () => {
  const controller = buildRemoteController({
    fetchImpl: async () => ({
      ok: true,
      json: async () => ({
        results: [{ id: 'opera-house', name: 'Sydney Opera House' }]
      })
    })
  })

  controller.inputTarget.value = 'syd'
  controller.filter()
  await flush()

  const option = controller.listTarget.querySelectorAll('[role="option"]')[0]
  assert.equal(option.dataset.value, 'opera-house')
  assert.equal(option.dataset.label, 'Sydney Opera House')
})

test('loader hook can supply options without a fetch url', async () => {
  const controller = buildRemoteController({ loader: true })
  controller.element.addEventListener('flat-pack:combobox:load', (event) => {
    event.preventDefault()
    event.detail.options = [{ value: 'manual', label: 'Add address', subtitle: 'Type it in' }]
  })

  controller.inputTarget.value = 'add'
  controller.filter()
  await flush()

  const option = controller.listTarget.querySelectorAll('[role="option"]')[0]
  assert.equal(option.dataset.value, 'manual')
  assert.equal(option.dataset.label, 'Add address')
})
