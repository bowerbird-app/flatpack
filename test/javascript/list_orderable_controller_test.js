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

function loadController(overrides = {}) {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'list_orderable_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformedSource = source
    .replace('import { Controller } from "@hotwired/stimulus"', 'class Controller {}')
    .replace('export default class extends Controller', 'class ListOrderableController extends Controller') + '\nmodule.exports = ListOrderableController\n'

  const context = {
    module: { exports: {} },
    exports: {},
    URL,
    URLSearchParams,
    CustomEvent: FakeCustomEvent,
    ...overrides
  }

  vm.runInNewContext(transformedSource, context, {filename: filePath})

  return context.module.exports
}

function buildItem(id) {
  const listeners = {}
  const classNames = new Set()

  return {
    id,
    dataset: {id},
    classList: {
      add(...tokens) { tokens.forEach((token) => classNames.add(token)) },
      remove(...tokens) { tokens.forEach((token) => classNames.delete(token)) }
    },
    setAttribute() {},
    removeAttribute() {},
    addEventListener(eventName, handler) { listeners[eventName] = handler },
    removeEventListener(eventName, handler) {
      if (listeners[eventName] === handler) delete listeners[eventName]
    },
    get listeners() { return listeners },
    get classNames() { return classNames }
  }
}

test('drop reorders a list item and sends its UUID plus position', async () => {
  const fetchCalls = []
  const items = [buildItem('uuid-1'), buildItem('uuid-2'), buildItem('uuid-3')]
  const dispatchedEvents = []

  const controller = new (loadController({
    fetch: async (url, options) => {
      fetchCalls.push({url, options})
      return {
        ok: true,
        json: async () => ({ok: true})
      }
    },
    document: {
      querySelector(selector) {
        if (selector === "meta[name='csrf-token']") return {content: 'csrf-token'}
        return null
      }
    }
  }))()

  const element = {
    querySelectorAll() {
      return parent.children
    },
    dispatchEvent(event) {
      dispatchedEvents.push(event)
    }
  }

  const parent = {
    children: items,
    insertBefore(node, referenceNode) {
      const fromIndex = this.children.indexOf(node)
      if (fromIndex !== -1) this.children.splice(fromIndex, 1)

      const referenceIndex = referenceNode ? this.children.indexOf(referenceNode) : -1
      if (referenceIndex === -1) {
        this.children.push(node)
      } else {
        this.children.splice(referenceIndex, 0, node)
      }
    }
  }

  items.forEach((item) => {
    item.parentNode = parent
  })

  controller.element = element
  controller.orderablePathValue = '/demo/list/reorder'
  controller.orderableMethodValue = 'PATCH'
  controller.paramUuidNameValue = 'moving_recording_id'
  controller.paramTargetPositionNameValue = 'target_position'
  controller.hasOrderablePathValue = true
  controller.hasParamUuidNameValue = true
  controller.hasParamTargetPositionNameValue = true
  controller.connect()

  controller.draggedItem = items[2]
  controller.dragOverItem = items[0]

  await controller.handleDrop({currentTarget: items[0], stopPropagation() {}})

  assert.equal(parent.children.map((item) => item.id).join(','), 'uuid-3,uuid-1,uuid-2')
  assert.equal(fetchCalls.length, 1)
  assert.equal(fetchCalls[0].url, '/demo/list/reorder')
  assert.equal(fetchCalls[0].options.method, 'PATCH')
  assert.equal(fetchCalls[0].options.headers['Content-Type'], 'application/x-www-form-urlencoded; charset=UTF-8')
  assert.equal(fetchCalls[0].options.headers['X-CSRF-Token'], 'csrf-token')

  assert.equal(fetchCalls[0].options.body, 'moving_recording_id=uuid-3&target_position=1')

  assert.equal(dispatchedEvents.length, 2)
  assert.equal(dispatchedEvents[0].type, 'list:reordered')
  assert.equal(dispatchedEvents[0].detail.id, 'uuid-3')
  assert.equal(dispatchedEvents[0].detail.position, 1)
  assert.equal(dispatchedEvents[1].type, 'list:saved')
})

test('custom param names are rendered into the request body', async () => {
  const fetchCalls = []
  const items = [buildItem('uuid-1'), buildItem('uuid-2')]

  const controller = new (loadController({
    fetch: async (url, options) => {
      fetchCalls.push({url, options})
      return {
        ok: true,
        json: async () => ({ok: true})
      }
    },
    document: {
      querySelector(selector) {
        if (selector === "meta[name='csrf-token']") return {content: 'csrf-token'}
        return null
      }
    }
  }))()

  const element = {
    querySelectorAll() {
      return parent.children
    },
    dispatchEvent() {}
  }

  const parent = {
    children: items,
    insertBefore(node, referenceNode) {
      const fromIndex = this.children.indexOf(node)
      if (fromIndex !== -1) this.children.splice(fromIndex, 1)

      const referenceIndex = referenceNode ? this.children.indexOf(referenceNode) : -1
      if (referenceIndex === -1) {
        this.children.push(node)
      } else {
        this.children.splice(referenceIndex, 0, node)
      }
    }
  }

  items.forEach((item) => {
    item.parentNode = parent
  })

  controller.element = element
  controller.orderablePathValue = '/demo/list/reorder'
  controller.orderableMethodValue = 'PATCH'
  controller.paramUuidNameValue = 'moving_recording_id'
  controller.paramTargetPositionNameValue = 'target_position'
  controller.hasOrderablePathValue = true
  controller.connect()

  controller.draggedItem = items[1]
  controller.dragOverItem = items[0]

  await controller.handleDrop({currentTarget: items[0], stopPropagation() {}})

  assert.equal(fetchCalls[0].options.body, 'moving_recording_id=uuid-2&target_position=1')
})

test('drag highlight applies and removes an inset ring', () => {
  const items = [buildItem('uuid-1'), buildItem('uuid-2')]
  const controller = new (loadController())()
  controller.element = {
    querySelectorAll() {
      return items
    }
  }
  controller.draggedItem = items[0]

  controller.handleDragEnter({currentTarget: items[1]})

  assert.equal(items[1].classNames.has('ring-2'), true)
  assert.equal(items[1].classNames.has('ring-inset'), true)
  assert.equal(items[1].classNames.has('ring-[var(--color-primary)]'), true)

  controller.handleDragLeave({currentTarget: items[1]})

  assert.equal(items[1].classNames.has('ring-2'), false)
  assert.equal(items[1].classNames.has('ring-inset'), false)
  assert.equal(items[1].classNames.has('ring-[var(--color-primary)]'), false)
})
