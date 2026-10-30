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

const controllerContexts = new Map()

function loadController(fileName, className) {
  const helperPath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'reorder_items.js')
  const helperSource = fs.readFileSync(helperPath, 'utf8')
    .replace('export function buildItems', 'function buildItems')
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', fileName)
  const source = helperSource + '\n' + fs.readFileSync(filePath, 'utf8')
    .replace('import { buildItems } from "flat_pack/reorder_items"\n', '')
    .replace('import { Controller } from "@hotwired/stimulus"', 'class Controller {}')
    .replace('export default class extends Controller', `class ${className} extends Controller`)
    + `\nmodule.exports = ${className}\n`

  const context = {
    module: { exports: {} },
    exports: {},
    CustomEvent: FakeCustomEvent,
    JSON,
    document: {
      querySelector(selector) {
        if (selector === "meta[name='csrf-token']") return { content: 'csrf-token' }
        return null
      }
    },
    fetch(url, options) {
      if (typeof context.fetchImpl !== 'function') {
        throw new Error('fetch was not stubbed')
      }
      return context.fetchImpl(url, options)
    }
  }

  vm.runInNewContext(source, context, { filename: filePath })
  controllerContexts.set(className, context)
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

      // Stimulus target lists follow DOM order. Keep the source array in step
      // so currentOrder() sees the drop the way a real target list would.
      const sourceFrom = elements.indexOf(node)
      if (sourceFrom !== -1) {
        elements.splice(sourceFrom, 1)
        const sourceIndex = reference ? elements.indexOf(reference) : elements.length
        elements.splice(sourceIndex, 0, node)
      }
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

function recordEvents(controller) {
  const events = []
  controller.element = {
    dispatchEvent(event) { events.push(event) }
  }
  return events
}

function enableReorder(controller) {
  controller.reorderUrlValue = '/demo/tables/reorder'
  controller.hasReorderUrlValue = true
  controller.resourceValue = 'demo_table_rows'
  controller.strategyValue = 'dense_integer'
  controller.scopeValue = { list_key: 'users' }
  controller.versionValue = '1739990000.12'
}

function captureFetches(className) {
  const calls = []
  controllerContexts.get(className).fetchImpl = (url, options) => {
    calls.push({ url, body: JSON.parse(options.body) })
    return {
      ok: true,
      status: 200,
      json: async () => ({ ok: true, version: '2' })
    }
  }
  return calls
}

async function dropOnto(dragged, target) {
  dragged.invoke('dragstart', dragStartEvent(dragged))
  target.invoke('dragenter', { currentTarget: target })
  target.invoke('drop', {
    currentTarget: target,
    stopPropagation() {}
  })
  await new Promise((resolve) => setImmediate(resolve))
}

async function assertReorderKeepsIds(Controller, className, targetKey, connectedName, tagName, ids, eventName) {
  const { controller, targets } = connectSortable(Controller, targetKey, connectedName, ids, tagName)
  const events = recordEvents(controller)
  controller.dispatch = () => {}
  enableReorder(controller)
  const calls = captureFetches(className)

  await dropOnto(targets[0], targets[1])

  const expectedIds = [ids[1], ids[0]]
  const expectedItems = expectedIds.map((id, index) => ({ id, position: index + 1 }))

  assert.equal(calls.length, 1)
  assert.equal(calls[0].url, '/demo/tables/reorder')
  assert.deepEqual(calls[0].body.reorder.items, expectedItems)
  assert.deepEqual(calls[0].body.reorder.items.map((item) => typeof item.id), ['string', 'string'])
  assert.equal(calls[0].body.reorder.resource, 'demo_table_rows')
  assert.equal(calls[0].body.reorder.strategy, 'dense_integer')
  assert.deepEqual(calls[0].body.reorder.scope, { list_key: 'users' })
  assert.equal(calls[0].body.reorder.version, '1739990000.12')
  assert.equal(events.length, 1)
  assert.equal(events[0].type, eventName)
  assert.deepEqual(events[0].detail.orderedIds, expectedIds)
  assert.deepEqual(JSON.parse(JSON.stringify(events[0].detail.items)), expectedItems)
  assert.equal(JSON.stringify(calls[0].body).includes('NaN'), false)
}

test('table reorder sends uuid ids intact and keeps integer ids as strings', async () => {
  const uuids = [
    '6f1e1a4a-1c2b-4d3e-8f90-111111111111',
    '6f1e1a4a-1c2b-4d3e-8f90-222222222222'
  ]
  await assertReorderKeepsIds(
    TableSortableController,
    'TableSortableController',
    'rowTargets',
    'rowTargetConnected',
    'TR',
    uuids,
    'table:reordered'
  )
  await assertReorderKeepsIds(
    TableSortableController,
    'TableSortableController',
    'rowTargets',
    'rowTargetConnected',
    'TR',
    ['7', '4'],
    'table:reordered'
  )
})

test('grid reorder sends uuid ids intact and keeps integer ids as strings', async () => {
  const uuids = [
    '6f1e1a4a-1c2b-4d3e-8f90-333333333333',
    '6f1e1a4a-1c2b-4d3e-8f90-444444444444'
  ]
  await assertReorderKeepsIds(
    GridSortableController,
    'GridSortableController',
    'itemTargets',
    'itemTargetConnected',
    'DIV',
    uuids,
    'grid:reordered'
  )
  await assertReorderKeepsIds(
    GridSortableController,
    'GridSortableController',
    'itemTargets',
    'itemTargetConnected',
    'DIV',
    ['7', '4'],
    'grid:reordered'
  )
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
