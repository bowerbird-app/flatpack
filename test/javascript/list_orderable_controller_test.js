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
      clearTimeout() {},
      requestAnimationFrame(callback) { callback(); return 0 }
    },
    document: {
      createElement(tagName) {
        const classNames = new Set()
        return {
          tagName,
          className: '',
          classList: {
            add(...tokens) { tokens.forEach((token) => classNames.add(token)) },
            contains(token) { return classNames.has(token) }
          },
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
          },
          get classNames() { return classNames }
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

  const Controller = context.module.exports
  Controller.Element = context.Element
  return Controller
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

function pressEvent(item, pointerId = 1) {
  return {
    button: 0,
    pointerId,
    clientX: 4,
    clientY: 8,
    target: {},
    currentTarget: item
  }
}

test('pointerdown presses the row and release before drag clears it', () => {
  const items = [buildItem('uuid-1')]
  const parent = buildParent(items)
  items.forEach((item) => { item.parentNode = parent })

  const controller = new (loadController())()
  controller.element = buildElement(parent)
  controller.connect()

  items[0].listeners.pointerdown(pressEvent(items[0]))

  assert.equal(items[0].classNames.has('is-pressing'), true)
  assert.equal(controller.layoutWidth, 100)
  assert.equal(controller.layoutHeight, 40)

  controller.handleWindowPointerUp({pointerId: 1})

  assert.equal(items[0].classNames.has('is-pressing'), false)
  assert.equal(controller.dragging, false)
})

test('reduced motion skips the press scale class', () => {
  const items = [buildItem('uuid-1')]
  const parent = buildParent(items)
  items.forEach((item) => { item.parentNode = parent })

  const controller = new (loadController({}, {prefersReducedMotion: true}))()
  controller.element = buildElement(parent)
  controller.connect()

  items[0].listeners.pointerdown(pressEvent(items[0]))

  assert.equal(items[0].classNames.has('is-pressing'), false)
})

test('activateDrag lifts the row and reveals the landing slot', () => {
  const items = [buildItem('uuid-1'), buildItem('uuid-2')]
  const parent = buildParent(items)
  items.forEach((item) => { item.parentNode = parent })

  const controller = new (loadController())()
  controller.element = buildElement(parent)
  controller.connect()
  controller.draggedItem = items[0]
  controller.pointerId = 1
  controller.layoutLeft = 10
  controller.layoutTop = 20
  controller.layoutWidth = 120
  controller.layoutHeight = 48
  const row = items[0]
  row.classList.add('is-pressing')

  controller.activateDrag({clientX: 18, clientY: 36})

  assert.equal(row.classNames.has('is-pressing'), false)
  assert.equal(row.classNames.has('is-lifted'), true)
  assert.equal(row.classNames.has('is-dragging'), true)
  assert.equal(row.style.left, '10px')
  assert.equal(row.style.top, '20px')
  assert.equal(row.style.width, '120px')
  assert.equal(row.style.transform, 'translate3d(0px, 0px, 0)')
  assert.match(row.style.transition, /scale var\(--duration-fast\)/)
  assert.equal(controller.placeholder.style.height, '48px')
  assert.equal(controller.placeholder.classNames.has('is-visible'), true)
  assert.equal(controller.element.classNames.has('is-reordering'), true)
})

test('reduced motion lift skips the scale transition', () => {
  const items = [buildItem('uuid-1')]
  const parent = buildParent(items)
  items.forEach((item) => { item.parentNode = parent })

  const controller = new (loadController({}, {prefersReducedMotion: true}))()
  controller.element = buildElement(parent)
  controller.connect()
  controller.draggedItem = items[0]
  controller.pointerId = 1
  controller.layoutLeft = 0
  controller.layoutTop = 0
  controller.layoutWidth = 100
  controller.layoutHeight = 40

  const row = items[0]
  controller.activateDrag({clientX: 8, clientY: 12})

  assert.equal(row.classNames.has('is-lifted'), true)
  assert.equal(row.style.transition, '')
})

test('settle lands on the slot and drops the lift', async () => {
  const items = [buildItem('uuid-1')]
  const parent = buildParent(items)
  items[0].parentNode = parent
  items[0].style.transform = 'translate3d(0px, 40px, 0)'
  items[0].classList.add('is-lifted')

  const controller = new (loadController())()
  controller.element = buildElement(parent)
  controller.draggedItem = items[0]
  controller.originX = 0
  controller.originY = 0
  controller.placeholder = {
    getBoundingClientRect() {
      return {left: 0, top: 0, width: 100, height: 40}
    }
  }

  await controller.settleDraggedItem()

  assert.equal(items[0].classNames.has('is-lifted'), false)
  assert.equal(items[0].style.scale, '1')
  assert.equal(items[0].style.transform, 'translate3d(0px, 0px, 0)')
  assert.match(items[0].style.transition, /--easing-spring-snappy/)
})

test('reduced motion settle does not scale the row', async () => {
  const items = [buildItem('uuid-1')]
  const parent = buildParent(items)
  items[0].parentNode = parent
  items[0].classList.add('is-lifted')

  const controller = new (loadController({}, {prefersReducedMotion: true}))()
  controller.element = buildElement(parent)
  controller.draggedItem = items[0]
  controller.placeholder = {
    getBoundingClientRect() {
      return {left: 0, top: 80, width: 100, height: 40}
    }
  }

  await controller.settleDraggedItem()

  assert.equal(items[0].style.scale, undefined)
  assert.equal(items[0].classNames.has('is-lifted'), true)
})

function handleNode(Controller, selector) {
  const node = Object.create(Controller.Element.prototype)
  node.closest = (candidate) => candidate === selector ? node : null
  return node
}

test('handle selector ignores pointerdown outside the handle', () => {
  const Controller = loadController()
  const items = [buildItem('uuid-1'), buildItem('uuid-2')]
  const parent = buildParent(items)
  items.forEach((item) => { item.parentNode = parent })
  const controller = new Controller()
  controller.element = buildElement(parent)
  controller.handleSelectorValue = '[data-collection-editor-handle]'
  controller.connect()

  controller.handlePointerDown({
    button: 0,
    pointerId: 1,
    clientX: 1,
    clientY: 1,
    target: handleNode(Controller, 'input'),
    currentTarget: items[0]
  })

  assert.equal(controller.dragging, false)
})

test('handle selector starts a drag from the handle', () => {
  const Controller = loadController()
  const items = [buildItem('uuid-1')]
  const parent = buildParent(items)
  items[0].parentNode = parent
  const controller = new Controller()
  controller.element = buildElement(parent)
  controller.handleSelectorValue = '[data-collection-editor-handle]'
  controller.connect()

  controller.handlePointerDown({
    button: 0,
    pointerId: 1,
    clientX: 1,
    clientY: 1,
    target: handleNode(Controller, '[data-collection-editor-handle]'),
    currentTarget: items[0]
  })

  assert.equal(controller.dragging, true)
})

test('unsaved rows reorder in the DOM and do not send a request', async () => {
  const fetchCalls = []
  const items = [buildItem('uuid-1'), buildItem('new_row')]
  const parent = buildParent(items)
  items.forEach((item) => { item.parentNode = parent })
  items[1].dataset.orderableUnsaved = 'true'

  const controller = new (loadController({
    fetch: async (url, options) => {
      fetchCalls.push({url, options})
      return {ok: true, json: async () => ({ok: true})}
    }
  }))()
  controller.element = buildElement(parent)
  controller.orderableUrlValue = '/demo/collection_editor/1/reorder'
  controller.hasOrderableUrlValue = true
  controller.paramUuidNameValue = 'moving_recording_id'
  controller.paramTargetPositionNameValue = 'target_position'
  controller.connect()

  controller.draggedItem = items[1]
  await controller.commitReorderTo(items[0])

  assert.equal(parent.children.map((item) => item.id).join(','), 'new_row,uuid-1')
  assert.equal(fetchCalls.length, 0)
})

test('saved reorder position ignores unsaved rows', async () => {
  const fetchCalls = []
  const items = [buildItem('new-row'), buildItem('13'), buildItem('12')]
  const parent = buildParent(items)
  items.forEach((item) => { item.parentNode = parent })
  items[0].dataset.orderableUnsaved = 'true'

  const controller = new (loadController({
    fetch: async (url, options) => {
      fetchCalls.push({url, options})
      return {ok: true, json: async () => ({ok: true})}
    }
  }))()
  controller.element = buildElement(parent)
  controller.orderableUrlValue = '/demo/collection_editor/1/reorder'
  controller.hasOrderableUrlValue = true
  controller.paramUuidNameValue = 'moving_recording_id'
  controller.paramTargetPositionNameValue = 'target_position'
  controller.connect()

  controller.draggedItem = items[1]
  await controller.saveOrder()

  assert.equal(fetchCalls.length, 1)
  assert.equal(fetchCalls[0].options.body, 'moving_recording_id=13&target_position=1')
  assert.equal(controller.currentPosition(items[1]), 2)
})

test('destroyed collection rows are left out of the order', () => {
  const items = [buildItem('uuid-1'), buildItem('uuid-2'), buildItem('uuid-3')]
  const parent = buildParent(items)
  items.forEach((item) => { item.parentNode = parent })
  items[1].dataset.collectionEditorDestroyed = 'true'
  const controller = new (loadController())()
  controller.element = buildElement(parent)

  assert.equal(controller.listItems().map((item) => String(item.id)).join(","), "uuid-1,uuid-3")
})

test('arrow keys on the handle move a row', async () => {
  const items = [buildItem('uuid-1'), buildItem('uuid-2'), buildItem('uuid-3')]
  const parent = buildParent(items)
  items.forEach((item) => { item.parentNode = parent })
  const Controller = loadController()
  const controller = new Controller()
  controller.element = buildElement(parent)
  controller.handleSelectorValue = '[data-collection-editor-handle]'
  controller.hasOrderableUrlValue = false
  controller.connect()

  items[0].nextSibling = items[1]
  items[1].nextSibling = items[2]
  items[2].nextSibling = null
  const event = {
    key: 'ArrowDown',
    target: handleNode(Controller, '[data-collection-editor-handle]'),
    currentTarget: items[0],
    preventDefault() { this.defaultPrevented = true }
  }
  await controller.handleKeyDown(event)

  assert.equal(event.defaultPrevented, true)
  assert.equal(parent.children.map((item) => item.id).join(','), 'uuid-2,uuid-1,uuid-3')
})

test('controller source uses spring tokens and reduced motion helper', () => {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'list_orderable_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')

  assert.match(source, /prefersReducedMotion/)
  assert.match(source, /--easing-spring/)
  assert.match(source, /--easing-spring-snappy/)
  assert.match(source, /touchAction/)
  assert.match(source, /transitionend/)
  assert.match(source, /is-lifted/)
  assert.match(source, /is-pressing/)
  assert.match(source, /is-visible/)
  assert.doesNotMatch(source, /--fp-list-drag-x/)
  assert.doesNotMatch(source, /--fp-list-drag-y/)
  assert.doesNotMatch(source, /updateSpotlight/)
  assert.doesNotMatch(source, /opacity-70/)
  assert.doesNotMatch(source, /draggable/)
})
