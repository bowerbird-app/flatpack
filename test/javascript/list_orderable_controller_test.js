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

function loadController(overrides = {}, { prefersReducedMotion = false } = {}) {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'list_orderable_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformedSource = source
    .replace('import { Controller } from "@hotwired/stimulus"', 'class Controller {}')
    .replace(
      'import { prefersReducedMotion } from "controllers/flat_pack/reduced_motion"',
      `function prefersReducedMotion() { return ${prefersReducedMotion ? 'true' : 'false'} }`
    )
    .replace('export default class extends Controller', 'class ListOrderableController extends Controller') + '\nmodule.exports = ListOrderableController\n'

  const context = {
    module: { exports: {} },
    exports: {},
    URL,
    URLSearchParams,
    CustomEvent: FakeCustomEvent,
    Element: class Element {},
    window: {
      addEventListener() {},
      removeEventListener() {},
      setTimeout(callback) { callback(); return 0 },
      clearTimeout() {}
    },
    document: {
      createElement(tagName) {
        return {
          tagName,
          className: '',
          style: {
            setProperty() {},
            removeProperty() {}
          },
          setAttribute() {},
          innerHTML: '',
          remove() {
            if (this.parentNode) {
              const index = this.parentNode.children.indexOf(this)
              if (index !== -1) this.parentNode.children.splice(index, 1)
              this.parentNode = null
            }
          }
        }
      },
      querySelector(selector) {
        if (selector === "meta[name='csrf-token']") return {content: 'csrf-token'}
        return null
      }
    },
    ...overrides
  }

  vm.runInNewContext(transformedSource, context, {filename: filePath})

  return context.module.exports
}

function buildItem(id) {
  const listeners = {}
  const classNames = new Set()
  const style = {
    touchAction: '',
    width: '',
    height: '',
    position: '',
    left: '',
    top: '',
    zIndex: '',
    margin: '',
    pointerEvents: '',
    userSelect: '',
    willChange: '',
    transform: '',
    transition: '',
    setProperty() {},
    removeProperty() {}
  }

  return {
    id,
    dataset: {id},
    classList: {
      add(...tokens) { tokens.forEach((token) => classNames.add(token)) },
      remove(...tokens) { tokens.forEach((token) => classNames.delete(token)) },
      contains(token) { return classNames.has(token) }
    },
    style,
    setAttribute() {},
    removeAttribute() {},
    addEventListener(eventName, handler) { listeners[eventName] = handler },
    removeEventListener(eventName, handler) {
      if (listeners[eventName] === handler) delete listeners[eventName]
    },
    querySelector() { return null },
    prepend() {},
    matches(selector) { return selector === "li[role='listitem']" },
    getBoundingClientRect() {
      return {left: 0, top: 0, width: 100, height: 40, right: 100, bottom: 40}
    },
    get listeners() { return listeners },
    get classNames() { return classNames }
  }
}

function buildParent(items) {
  return {
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

      node.parentNode = this
    },
    appendChild(node) {
      const fromIndex = this.children.indexOf(node)
      if (fromIndex !== -1) this.children.splice(fromIndex, 1)
      this.children.push(node)
      node.parentNode = this
    }
  }
}

function buildElement(parent) {
  const classNames = new Set()
  return {
    classList: {
      add(...tokens) { tokens.forEach((token) => classNames.add(token)) },
      remove(...tokens) { tokens.forEach((token) => classNames.delete(token)) }
    },
    querySelectorAll() {
      return parent.children.filter((child) => child.matches?.("li[role='listitem']"))
    },
    dispatchEvent(event) {
      this.events.push(event)
    },
    events: [],
    get classNames() { return classNames }
  }
}

test('commitReorderTo reorders a list item and sends its UUID plus position', async () => {
  const fetchCalls = []
  const items = [buildItem('uuid-1'), buildItem('uuid-2'), buildItem('uuid-3')]
  const parent = buildParent(items)
  items.forEach((item) => { item.parentNode = parent })

  const controller = new (loadController({
    fetch: async (url, options) => {
      fetchCalls.push({url, options})
      return {
        ok: true,
        json: async () => ({ok: true})
      }
    }
  }))()

  const element = buildElement(parent)
  controller.element = element
  controller.orderableUrlValue = '/demo/list/reorder'
  controller.orderableMethodValue = 'PATCH'
  controller.paramUuidNameValue = 'moving_recording_id'
  controller.paramTargetPositionNameValue = 'target_position'
  controller.hasOrderableUrlValue = true
  controller.hasParamUuidNameValue = true
  controller.hasParamTargetPositionNameValue = true
  controller.connect()

  controller.draggedItem = items[2]
  await controller.commitReorderTo(items[0])

  assert.equal(parent.children.map((item) => item.id).join(','), 'uuid-3,uuid-1,uuid-2')
  assert.equal(fetchCalls.length, 1)
  assert.equal(fetchCalls[0].url, '/demo/list/reorder')
  assert.equal(fetchCalls[0].options.method, 'PATCH')
  assert.equal(fetchCalls[0].options.headers['Content-Type'], 'application/x-www-form-urlencoded; charset=UTF-8')
  assert.equal(fetchCalls[0].options.headers['X-CSRF-Token'], 'csrf-token')
  assert.equal(fetchCalls[0].options.body, 'moving_recording_id=uuid-3&target_position=1')

  assert.equal(element.events.length, 2)
  assert.equal(element.events[0].type, 'list:reordered')
  assert.equal(element.events[0].detail.id, 'uuid-3')
  assert.equal(element.events[0].detail.position, 1)
  assert.equal(element.events[1].type, 'list:saved')
})

test('custom param names are rendered into the request body', async () => {
  const fetchCalls = []
  const items = [buildItem('uuid-1'), buildItem('uuid-2')]
  const parent = buildParent(items)
  items.forEach((item) => { item.parentNode = parent })

  const controller = new (loadController({
    fetch: async (url, options) => {
      fetchCalls.push({url, options})
      return {
        ok: true,
        json: async () => ({ok: true})
      }
    }
  }))()

  controller.element = buildElement(parent)
  controller.orderableUrlValue = '/demo/list/reorder'
  controller.orderableMethodValue = 'PATCH'
  controller.paramUuidNameValue = 'moving_recording_id'
  controller.paramTargetPositionNameValue = 'target_position'
  controller.hasOrderableUrlValue = true
  controller.connect()

  controller.draggedItem = items[1]
  await controller.commitReorderTo(items[0])

  assert.equal(fetchCalls[0].options.body, 'moving_recording_id=uuid-2&target_position=1')
})

test('commitReorderTo reorders without persisting when orderableUrl is unset', async () => {
  const fetchCalls = []
  const items = [buildItem('uuid-1'), buildItem('uuid-2')]
  const parent = buildParent(items)
  items.forEach((item) => { item.parentNode = parent })

  const controller = new (loadController({
    fetch: async (url, options) => {
      fetchCalls.push({url, options})
      return {
        ok: true,
        json: async () => ({ok: true})
      }
    }
  }))()

  controller.element = buildElement(parent)
  controller.hasOrderableUrlValue = false
  controller.connect()

  controller.draggedItem = items[1]
  await controller.commitReorderTo(items[0])

  assert.equal(parent.children.map((item) => item.id).join(','), 'uuid-2,uuid-1')
  assert.equal(fetchCalls.length, 0)
})

test('connect binds pointerdown instead of HTML5 drag events', () => {
  const items = [buildItem('uuid-1'), buildItem('uuid-2')]
  const parent = buildParent(items)
  items.forEach((item) => { item.parentNode = parent })

  const controller = new (loadController())()
  controller.element = buildElement(parent)
  controller.connect()

  items.forEach((item) => {
    assert.equal(typeof item.listeners.pointerdown, 'function')
    assert.equal(item.listeners.dragstart, undefined)
  })
})

test('reduced motion skips sibling FLIP transforms', () => {
  const items = [buildItem('uuid-1'), buildItem('uuid-2'), buildItem('uuid-3')]
  const parent = buildParent(items)
  items.forEach((item) => { item.parentNode = parent })

  const controller = new (loadController({}, { prefersReducedMotion: true }))()
  controller.element = buildElement(parent)
  controller.connect()
  controller.draggedItem = items[0]
  controller.placeholder = {
    parentNode: parent,
    nextElementSibling: items[1],
    style: {},
    remove() {}
  }
  parent.children = [controller.placeholder, items[0], items[1], items[2]]

  controller.movePlaceholder(items[2])

  assert.equal(items[1].style.transform, '')
  assert.equal(items[2].style.transform, '')
})

test('controller source uses spring tokens and reduced motion helper', () => {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'list_orderable_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')

  assert.match(source, /prefersReducedMotion/)
  assert.match(source, /--easing-spring/)
  assert.match(source, /--easing-spring-snappy/)
  assert.match(source, /touchAction/)
  assert.doesNotMatch(source, /--fp-list-drag-x/)
  assert.doesNotMatch(source, /--fp-list-drag-y/)
  assert.doesNotMatch(source, /updateSpotlight/)
  assert.doesNotMatch(source, /opacity-70/)
  assert.doesNotMatch(source, /draggable/)
})
