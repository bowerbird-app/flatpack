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

  insertBefore(child, anchor) {
    child.parentNode = this
    const index = this.children.indexOf(anchor)
    if (index === -1) this.children.push(child)
    else this.children.splice(index, 0, child)
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

let pendingTimers = []

function loadController({ fetchImpl, deferTimers = false } = {}) {
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
    .replace(/import \{[^}]+\} from "flat_pack\/remote_query"\n/, "")
    .replace('export default class extends Controller', 'class ComboboxController extends Controller') + '\nmodule.exports = ComboboxController\n'
  const clickOutsidePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'click_outside.js')
  const clickOutsideSource = fs.readFileSync(clickOutsidePath, 'utf8').replaceAll('export function ', 'function ')
  const remoteQueryPath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'remote_query.js')
  const remoteQuerySource = fs.readFileSync(remoteQueryPath, 'utf8').replaceAll('export function ', 'function ')

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
    fetch: fetchImpl || (async () => ({ ok: true, json: async () => ({ items: [] }) })),
    setTimeout(fn) {
      if (!deferTimers) {
        fn()
        return 1
      }

      pendingTimers.push(fn)
      return pendingTimers.length
    },
    clearTimeout(id) {
      if (!deferTimers || id == null) return
      pendingTimers[id - 1] = null
    }
  }

  vm.runInNewContext(clickOutsideSource + '\n' + remoteQuerySource + '\n' + transformedSource, context, { filename: filePath })

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
  controller.hasValueTarget = true
  controller.hasEmptyTarget = true
  controller.hasEmptyActionTarget = false
  controller.emptyTextValue = 'No matches'
  controller.errorTextValue = 'Search failed'
  controller.searchParamsValue = {}
  controller.searchModeValue = 'local'
  controller.searchEndpointValue = ''
  controller.searchParamValue = 'q'
  controller.minSearchLengthValue = 2
  controller.debounceValue = 0
  controller.connect()

  return controller
}

function buildRemoteController({ fetchImpl, deferTimers = false } = {}) {
  pendingTimers = []
  const ControllerClass = loadController({ fetchImpl, deferTimers })
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
  controller.hasValueTarget = true
  controller.hasEmptyTarget = true
  controller.hasEmptyActionTarget = false
  controller.emptyTextValue = 'No matches'
  controller.errorTextValue = 'Search failed'
  controller.searchParamsValue = {}
  controller.searchModeValue = 'remote'
  controller.searchEndpointValue = '/demo/forms/combobox/options'
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
          items: [
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

test('a query change aborts the in-flight search so a late response cannot render', async () => {
  let firstSignal
  let resolveLate
  const fetches = []
  const controller = buildRemoteController({
    deferTimers: true,
    fetchImpl: (_url, options) => {
      fetches.push(options.signal)
      if (fetches.length === 1) {
        firstSignal = options.signal
        return new Promise((resolve, reject) => {
          resolveLate = () => resolve({
            ok: true,
            json: async () => ({ items: [{ value: 'fed-square', label: 'Federation Square' }] })
          })
          options.signal.addEventListener('abort', () => {
            const error = new Error('aborted')
            error.name = 'AbortError'
            reject(error)
          })
        })
      }

      return {
        ok: true,
        json: async () => ({ items: [{ value: 'opera-house', label: 'Sydney Opera House' }] })
      }
    }
  })

  controller.debounceValue = 300
  controller.open()
  controller.inputTarget.value = 'mel'
  controller.filter()
  pendingTimers.shift()()
  await flush()

  assert.equal(firstSignal.aborted, false)

  controller.inputTarget.value = 'me'
  controller.filter()
  await flush()

  assert.equal(firstSignal.aborted, true)
  assert.equal(controller.hintTarget.classList.contains('hidden'), false)
  assert.equal(controller.listTarget.querySelectorAll('[role="option"]').length, 0)

  resolveLate()
  await flush()

  assert.equal(controller.listTarget.querySelectorAll('[role="option"]').length, 0)
  assert.equal(controller.valueTarget.value, '')
  assert.equal(fetches.length, 1)
})

test('remote search shows a hint before min characters and skips fetch', async () => {
  let fetched = false
  const controller = buildRemoteController({
    fetchImpl: async () => {
      fetched = true
      return { ok: true, json: async () => ({ items: [] }) }
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
    fetchImpl: async () => ({ ok: true, json: async () => ({ items: [] }) })
  })

  controller.inputTarget.value = 'zzz'
  controller.filter()
  await flush()

  assert.equal(controller.emptyTarget.classList.contains('hidden'), false)
  assert.equal(controller.listTarget.querySelectorAll('[role="option"]').length, 0)
})

test('failed fetch shows the error text and dispatches the error event', async () => {
  const controller = buildRemoteController({
    fetchImpl: async () => ({ ok: false, status: 502, json: async () => ({}) })
  })
  const errors = []
  controller.element.addEventListener('flat-pack:combobox:error', (event) => errors.push(event.detail))

  controller.inputTarget.value = 'mel'
  controller.filter()
  await flush()

  assert.equal(controller.emptyTarget.classList.contains('hidden'), false)
  assert.equal(controller.emptyTarget.textContent, 'Search failed')
  assert.equal(errors.length, 1)
  assert.equal(errors[0].status, 502)
})

test('a network error dispatches status null and does not treat abort as an error', async () => {
  const controller = buildRemoteController({
    fetchImpl: async () => {
      throw new Error('offline')
    }
  })
  const errors = []
  controller.element.addEventListener('flat-pack:combobox:error', (event) => errors.push(event.detail))

  controller.inputTarget.value = 'mel'
  controller.filter()
  await flush()

  assert.equal(errors.length, 1)
  assert.equal(errors[0].status, null)
  assert.equal(controller.emptyTarget.textContent, 'Search failed')

  const aborted = buildRemoteController({
    fetchImpl: async () => {
      const error = new Error('aborted')
      error.name = 'AbortError'
      throw error
    }
  })
  const abortedErrors = []
  aborted.element.addEventListener('flat-pack:combobox:error', (event) => abortedErrors.push(event.detail))
  aborted.inputTarget.value = 'mel'
  aborted.filter()
  await flush()

  assert.deepEqual(abortedErrors, [])
})

test('a top-level array uses the same items contract as Select', async () => {
  const controller = buildRemoteController({
    fetchImpl: async () => ({
      ok: true,
      json: async () => [{ value: 'opera-house', label: 'Sydney Opera House' }]
    })
  })

  controller.inputTarget.value = 'syd'
  controller.filter()
  await flush()

  const option = controller.listTarget.querySelectorAll('[role="option"]')[0]
  assert.equal(option.dataset.value, 'opera-house')
  assert.equal(option.dataset.label, 'Sydney Opera House')
})

test('items that omit value or label are dropped', async () => {
  const controller = buildRemoteController({
    fetchImpl: async () => ({
      ok: true,
      json: async () => ({ items: [{ id: 'opera-house', name: 'Sydney Opera House' }] })
    })
  })

  controller.inputTarget.value = 'syd'
  controller.filter()
  await flush()

  assert.equal(controller.listTarget.querySelectorAll('[role="option"]').length, 0)
  assert.equal(controller.emptyTarget.classList.contains('hidden'), false)
})

test('one click selects a remote option once', async () => {
  const controller = buildRemoteController({
    fetchImpl: async () => ({
      ok: true,
      json: async () => ({ items: [{ value: 'fed-square', label: 'Federation Square' }] })
    })
  })

  controller.inputTarget.value = 'fed'
  controller.filter()
  await flush()

  const option = controller.listTarget.querySelectorAll('[role="option"]')[0]
  let selections = 0
  const select = controller.select.bind(controller)
  controller.select = (chosen) => {
    selections += 1
    select(chosen)
  }

  const event = { preventDefault() {}, currentTarget: option, target: option }
  ;(option.listeners.mousedown || []).forEach((listener) => listener(event))
  if (String(option.getAttribute('data-action') || '').includes('mousedown->flat-pack--combobox#choose')) {
    controller.choose(event)
  }

  assert.equal(selections, 1)
  assert.equal(controller.valueTarget.value, 'fed-square')
  assert.equal(controller.inputTarget.value, 'Federation Square')
})

test('remote search sends search params and dispatches the current results payload', async () => {
  const payload = {
    items: [
      { value: 'fed-square', label: 'Federation Square', subtitle: 'Melbourne VIC', data: { city: 'melbourne', nested: { skip: true } } },
      { label: 'Missing value' }
    ],
    page: 1
  }
  const fetchCalls = []
  const controller = buildRemoteController({
    fetchImpl: async (url) => {
      fetchCalls.push(String(url))
      return { ok: true, json: async () => payload }
    }
  })
  controller.searchParamsValue = { region: 'au', limit: 5 }
  const results = []
  controller.element.addEventListener('flat-pack:combobox:results', (event) => results.push(event.detail))

  controller.inputTarget.value = 'mel'
  controller.filter()
  await flush()

  assert.equal(fetchCalls[0], 'http://example.test/demo/forms/combobox/options?q=mel&region=au&limit=5')
  const option = controller.listTarget.querySelectorAll('[role="option"]')[0]
  assert.equal(option.dataset.optionData, JSON.stringify({ city: 'melbourne' }))
  assert.equal(results.length, 1)
  assert.equal(results[0].query, 'mel')
  assert.equal(results[0].payload, payload)
  assert.equal(Object.hasOwn(results[0], 'meta'), false)
  assert.equal(JSON.stringify(results[0].items), JSON.stringify([{
    value: 'fed-square',
    label: 'Federation Square',
    subtitle: 'Melbourne VIC',
    data: { city: 'melbourne' }
  }]))
})

test('a stale remote response does not dispatch results', async () => {
  let finishFirst
  let calls = 0
  const controller = buildRemoteController({
    fetchImpl: () => new Promise((resolve) => {
      calls += 1
      if (calls === 1) {
        finishFirst = () => resolve({
          ok: true,
          json: async () => ({ items: [{ value: 'fed-square', label: 'Federation Square' }] })
        })
      }
    })
  })
  const results = []
  controller.element.addEventListener('flat-pack:combobox:results', (event) => results.push(event.detail))

  controller.inputTarget.value = 'mel'
  controller.filter()
  await flush()
  controller.inputTarget.value = 'melbourne'
  controller.filter()
  finishFirst()
  await flush()

  assert.deepEqual(results, [])
  assert.equal(controller.listTarget.querySelectorAll('[role="option"]').length, 0)
})

test('selecting an option includes its data and does not use innerHTML', async () => {
  const controller = buildRemoteController({
    fetchImpl: async () => ({
      ok: true,
      json: async () => ({
        items: [{ value: 'fed-square', label: 'Federation Square', data: { city: 'melbourne' } }]
      })
    })
  })
  const selected = []
  controller.element.addEventListener('flat-pack:combobox:selected', (event) => selected.push(event.detail))

  controller.inputTarget.value = 'fed'
  controller.filter()
  await flush()
  controller.keydown({ key: 'Enter', preventDefault() {} })

  assert.equal(JSON.stringify(selected), JSON.stringify([{
    value: 'fed-square',
    label: 'Federation Square',
    subtitle: null,
    data: { city: 'melbourne' }
  }]))
  const option = controller.listTarget.querySelectorAll('[role="option"]')[0]
  assert.equal(option.innerHTML, undefined)
  assert.equal(option.textContent, 'Federation Square')
})

function addEmptyAction(controller) {
  const action = new FakeElement('li')
  action.id = 'place-empty-action'
  action.dataset.emptyAction = 'true'
  action.dataset.value = 'add-place'
  action.textContent = 'Add a place'
  action.setAttribute('role', 'option')
  action.classList.add('hidden')
  controller.emptyActionTarget = action
  controller.hasEmptyActionTarget = true
  controller.listTarget.appendChild(action)
  return action
}

test('arrow keys and Enter reach the empty action without setting the hidden value', async () => {
  const controller = buildRemoteController({
    fetchImpl: async () => ({ ok: true, json: async () => ({ items: [] }) })
  })
  addEmptyAction(controller)
  const actions = []
  const changes = []
  controller.element.addEventListener('flat-pack:combobox:empty-action', (event) => actions.push(event.detail))
  controller.valueTarget.addEventListener('change', () => changes.push(controller.valueTarget.value))
  controller.valueTarget.value = 'keep-me'

  controller.inputTarget.value = 'zzz'
  controller.filter()
  await flush()
  controller.valueTarget.value = 'keep-me'

  const action = controller.emptyActionTarget
  assert.equal(action.classList.contains('hidden'), false)
  assert.equal(controller.inputTarget.attributes['aria-activedescendant'], action.id)

  controller.keydown({ key: 'ArrowDown', preventDefault() {} })
  controller.keydown({ key: 'Enter', preventDefault() {} })

  assert.equal(JSON.stringify(actions), JSON.stringify([{ query: 'zzz', value: 'add-place' }]))
  assert.equal(controller.valueTarget.value, 'keep-me')
  assert.equal(controller.inputTarget.value, 'zzz')
  assert.deepEqual(changes, [])
  assert.equal(controller.openList, false)
})

test('a click on the empty action dispatches the event and leaves the hidden value', () => {
  const controller = buildController()
  const action = addEmptyAction(controller)
  const actions = []
  controller.element.addEventListener('flat-pack:combobox:empty-action', (event) => actions.push(event.detail))
  controller.inputTarget.value = 'zzz'
  controller.open()
  controller.valueTarget.value = 'melbourne'
  action.classList.remove('hidden')

  controller.choose({ preventDefault() {}, currentTarget: action })

  assert.equal(JSON.stringify(actions), JSON.stringify([{ query: 'zzz', value: 'add-place' }]))
  assert.equal(controller.valueTarget.value, 'melbourne')
  assert.equal(controller.inputTarget.value, 'zzz')
})

test('an error still offers the empty action', async () => {
  const controller = buildRemoteController({
    fetchImpl: async () => ({ ok: false, status: 500, json: async () => ({}) })
  })
  addEmptyAction(controller)

  controller.inputTarget.value = 'mel'
  controller.filter()
  await flush()

  assert.equal(controller.emptyTarget.textContent, 'Search failed')
  assert.equal(controller.emptyActionTarget.classList.contains('hidden'), false)
  assert.equal(controller.inputTarget.attributes['aria-activedescendant'], controller.emptyActionTarget.id)
})

test('clear and setSelection update the field without a selected event', () => {
  const controller = buildController()
  controller.open()
  const selected = []
  const cleared = []
  const changes = []
  controller.element.addEventListener('flat-pack:combobox:selected', (event) => selected.push(event.detail))
  controller.element.addEventListener('flat-pack:combobox:cleared', () => cleared.push(true))
  controller.valueTarget.addEventListener('change', () => changes.push(controller.valueTarget.value))

  controller.setSelection({ value: 'sydney', label: 'Sydney' })

  assert.equal(controller.valueTarget.value, 'sydney')
  assert.equal(controller.inputTarget.value, 'Sydney')
  assert.equal(controller.openList, true)
  assert.deepEqual(selected, [])
  assert.deepEqual(changes, ['sydney'])

  controller.clear()

  assert.equal(controller.inputTarget.value, '')
  assert.equal(controller.valueTarget.value, '')
  assert.equal(controller.openList, false)
  assert.deepEqual(cleared, [true])
  assert.deepEqual(changes, ['sydney', ''])
})

test('clearing the input text clears the hidden value and dispatches cleared', () => {
  const controller = buildController()
  controller.valueTarget.value = 'melbourne'
  controller.inputTarget.value = 'Melbourne'
  const cleared = []
  const changes = []
  controller.element.addEventListener('flat-pack:combobox:cleared', () => cleared.push(true))
  controller.valueTarget.addEventListener('change', () => changes.push(controller.valueTarget.value))
  controller.open()

  controller.inputTarget.value = 'Mel'
  controller.filter()

  assert.equal(controller.valueTarget.value, '')
  assert.deepEqual(cleared, [])

  controller.valueTarget.value = 'melbourne'
  controller.inputTarget.value = ''
  controller.filter()

  assert.equal(controller.valueTarget.value, '')
  assert.deepEqual(cleared, [true])
  assert.deepEqual(changes, [''])
})

test('clear and select work when the hidden field is missing', async () => {
  const controller = buildRemoteController({
    fetchImpl: async () => ({
      ok: true,
      json: async () => ({ items: [{ value: 'fed-square', label: 'Federation Square' }] })
    })
  })
  controller.hasValueTarget = false
  controller.valueTarget = undefined
  const cleared = []
  controller.element.addEventListener('flat-pack:combobox:cleared', () => cleared.push(true))

  controller.clear()
  assert.equal(controller.inputTarget.value, '')
  assert.deepEqual(cleared, [true])

  controller.inputTarget.value = 'fed'
  controller.filter()
  await flush()
  controller.keydown({ key: 'Enter', preventDefault() {} })

  assert.equal(controller.inputTarget.value, 'Federation Square')
})
