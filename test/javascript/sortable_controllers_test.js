const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

const DRAG_EVENTS = ['dragstart', 'dragend', 'dragover', 'drop', 'dragenter', 'dragleave']

class FakeCustomEvent {
  constructor(type, options = {}) {
    this.type = type
    this.bubbles = options.bubbles || false
    this.detail = options.detail
  }
}

function loadController(fileName, className) {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', fileName)
  const source = fs.readFileSync(filePath, 'utf8')
    .replace('import { Controller } from "@hotwired/stimulus"', 'class Controller {}')
    .replace('export default class extends Controller', `class ${className} extends Controller`)
    + `\nmodule.exports = ${className}\n`

  const context = {
    module: { exports: {} },
    exports: {},
    CustomEvent: FakeCustomEvent,
    document: {
      querySelector(selector) {
        if (selector === "meta[name='csrf-token']") return { content: 'csrf-token' }
        return null
      }
    }
  }

  vm.runInNewContext(source, context, { filename: filePath })
  return context.module.exports
}

function trackable(id, tagName) {
  const listeners = new Map()
  const attributes = {}
  const classNames = new Set()

  return {
    id: String(id),
    dataset: { id: String(id) },
    tagName,
    style: {},
    innerHTML: '',
    parentNode: null,
    classList: {
      add(...tokens) { tokens.forEach((token) => classNames.add(token)) },
      remove(...tokens) { tokens.forEach((token) => classNames.delete(token)) },
      contains(token) { return classNames.has(token) }
    },
    setAttribute(name, value) { attributes[name] = String(value) },
    removeAttribute(name) { delete attributes[name] },
    getAttribute(name) { return attributes[name] },
    addEventListener(name, handler) {
      const list = listeners.get(name) || []
      list.push(handler)
      listeners.set(name, list)
    },
    removeEventListener(name, handler) {
      const list = listeners.get(name) || []
      const index = list.indexOf(handler)
      if (index !== -1) list.splice(index, 1)
    },
    listenerCount(name) {
      return (listeners.get(name) || []).length
    },
    invoke(name, event) {
      ;(listeners.get(name) || []).forEach((handler) => handler(event))
    },
    get previousElementSibling() {
      if (!this.parentNode) return null
      const index = this.parentNode.children.indexOf(this)
      return index > 0 ? this.parentNode.children[index - 1] : null
    },
    get nextElementSibling() {
      if (!this.parentNode) return null
      const index = this.parentNode.children.indexOf(this)
      return index === -1 ? null : this.parentNode.children[index + 1] || null
    }
  }
}

function linkParent(elements) {
  const parent = {
    children: elements.slice(),
    insertBefore(node, reference) {
      const from = this.children.indexOf(node)
      if (from !== -1) this.children.splice(from, 1)
      const index = reference ? this.children.indexOf(reference) : this.children.length
      this.children.splice(index, 0, node)
      node.parentNode = this
    }
  }
  elements.forEach((element) => { element.parentNode = parent })
  return parent
}

function assertOneListenerSet(element) {
  for (const eventName of DRAG_EVENTS) {
    assert.equal(element.listenerCount(eventName), 1, `${element.id} ${eventName}`)
  }
}

function connectSortable(Controller, targetKey, connectedName, ids, tagName) {
  const targets = ids.map((id) => trackable(id, tagName))
  linkParent(targets)
  const controller = new Controller()
  controller.element = { dispatchEvent() {} }
  controller[targetKey] = targets
  if (typeof controller[connectedName] === 'function') {
    targets.forEach((target) => controller[connectedName](target))
  }
  controller.connect()
  return { controller, targets }
}

function disconnectSortable(controller, targets, disconnectedName) {
  controller.disconnect()
  if (typeof controller[disconnectedName] === 'function') {
    targets.forEach((target) => controller[disconnectedName](target))
  }
}

function dragStartEvent(element) {
  return {
    currentTarget: element,
    dataTransfer: {
      effectAllowed: '',
      setData() {}
    }
  }
}

const TableSortableController = loadController('table_sortable_controller.js', 'TableSortableController')
const GridSortableController = loadController('grid_sortable_controller.js', 'GridSortableController')

test('appended table rows are draggable', () => {
  const { controller, targets } = connectSortable(TableSortableController, 'rowTargets', 'rowTargetConnected', ['1'], 'TR')
  const added = trackable('2', 'TR')
  added.parentNode = targets[0].parentNode
  targets.push(added)
  controller.rowTargets = targets
  if (typeof controller.rowTargetConnected === 'function') controller.rowTargetConnected(added)

  assert.equal(added.getAttribute('draggable'), 'true')
  added.invoke('dragstart', dragStartEvent(added))
  assert.equal(added.style.opacity, '0.5')
  assertOneListenerSet(added)
})

test('a connected table row has exactly one drag listener set', () => {
  const { targets } = connectSortable(TableSortableController, 'rowTargets', 'rowTargetConnected', ['1', '2'], 'TR')
  targets.forEach((row) => {
    assert.equal(row.getAttribute('draggable'), 'true')
    assertOneListenerSet(row)
  })
})

test('removed table rows lose drag listeners', () => {
  const { controller, targets } = connectSortable(TableSortableController, 'rowTargets', 'rowTargetConnected', ['1', '2'], 'TR')
  const removed = targets.pop()
  controller.rowTargets = targets
  if (typeof controller.rowTargetDisconnected === 'function') controller.rowTargetDisconnected(removed)

  for (const eventName of DRAG_EVENTS) {
    assert.equal(removed.listenerCount(eventName), 0, eventName)
  }
  assert.equal(removed.getAttribute('draggable'), undefined)
})

test('reconnecting a table does not duplicate drag listeners', () => {
  const { controller, targets } = connectSortable(TableSortableController, 'rowTargets', 'rowTargetConnected', ['1'], 'TR')
  disconnectSortable(controller, targets, 'rowTargetDisconnected')
  if (typeof controller.rowTargetConnected === 'function') {
    targets.forEach((row) => controller.rowTargetConnected(row))
  }
  controller.connect()

  assert.equal(targets[0].getAttribute('draggable'), 'true')
  assertOneListenerSet(targets[0])
})

test('table moveUp and moveDown reorder rows', () => {
  const { controller, targets } = connectSortable(TableSortableController, 'rowTargets', 'rowTargetConnected', ['1', '2'], 'TR')
  const [first, second] = targets
  const parent = first.parentNode
  const buttonFor = (row) => ({ closest() { return row }, focus() {} })

  controller.moveDown({ currentTarget: buttonFor(first) })
  assert.deepEqual(parent.children.map((row) => row.id), ['2', '1'])

  controller.moveUp({ currentTarget: buttonFor(first) })
  assert.deepEqual(parent.children.map((row) => row.id), ['1', '2'])
  assert.equal(second, parent.children[1])
})

test('appended grid items are draggable', () => {
  const { controller, targets } = connectSortable(GridSortableController, 'itemTargets', 'itemTargetConnected', ['1'], 'DIV')
  const added = trackable('2', 'DIV')
  added.parentNode = targets[0].parentNode
  targets.push(added)
  controller.itemTargets = targets
  if (typeof controller.itemTargetConnected === 'function') controller.itemTargetConnected(added)

  assert.equal(added.getAttribute('draggable'), 'true')
  added.invoke('dragstart', dragStartEvent(added))
  assert.equal(added.classList.contains('opacity-70'), true)
  assertOneListenerSet(added)
})

test('a connected grid item has exactly one drag listener set', () => {
  const { targets } = connectSortable(GridSortableController, 'itemTargets', 'itemTargetConnected', ['1', '2'], 'DIV')
  targets.forEach((item) => {
    assert.equal(item.getAttribute('draggable'), 'true')
    assertOneListenerSet(item)
  })
})

test('removed grid items lose drag listeners', () => {
  const { controller, targets } = connectSortable(GridSortableController, 'itemTargets', 'itemTargetConnected', ['1', '2'], 'DIV')
  const removed = targets.pop()
  controller.itemTargets = targets
  if (typeof controller.itemTargetDisconnected === 'function') controller.itemTargetDisconnected(removed)

  for (const eventName of DRAG_EVENTS) {
    assert.equal(removed.listenerCount(eventName), 0, eventName)
  }
  assert.equal(removed.getAttribute('draggable'), undefined)
})

test('reconnecting a grid does not duplicate drag listeners', () => {
  const { controller, targets } = connectSortable(GridSortableController, 'itemTargets', 'itemTargetConnected', ['1'], 'DIV')
  disconnectSortable(controller, targets, 'itemTargetDisconnected')
  if (typeof controller.itemTargetConnected === 'function') {
    targets.forEach((item) => controller.itemTargetConnected(item))
  }
  controller.connect()

  assert.equal(targets[0].getAttribute('draggable'), 'true')
  assertOneListenerSet(targets[0])
})
