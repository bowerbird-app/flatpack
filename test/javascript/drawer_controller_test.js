const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

function loadDrawerController(documentStub) {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'drawer_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformedSource = source
    .replace('import { Controller } from "@hotwired/stimulus"', 'class Controller {}')
    .replace(
      'import { prefersReducedMotion, motionDuration, motionTransition } from "controllers/flat_pack/reduced_motion"',
      'function prefersReducedMotion() { return false }\nfunction motionDuration() { return 0 }\nfunction motionTransition() { return "" }'
    )
    .replace('export default class extends Controller', 'class DrawerController extends Controller') + '\nmodule.exports = DrawerController\n'

  const context = {
    module: { exports: {} },
    exports: {},
    document: documentStub,
    window: { innerWidth: 800 },
    CSS: { escape(value) { return value } },
    requestAnimationFrame(callback) { callback() },
    setTimeout(callback) { callback(); return 0 },
    clearTimeout() {}
  }

  vm.runInNewContext(transformedSource, context, { filename: filePath })

  return context.module.exports
}

function classListStub(initial = ['hidden']) {
  const names = new Set(initial)
  return {
    contains(name) { return names.has(name) },
    add(name) { names.add(name) },
    remove(name) { names.delete(name) }
  }
}

function buildController() {
  const slots = []
  const originalParent = {
    name: 'original',
    insertBefore(node, sibling) {
      node.parentElement = this
      node.parentNode = this
      this.inserted = { method: 'insertBefore', node, sibling }
    },
    appendChild(node) {
      node.parentElement = this
      node.parentNode = this
      this.inserted = { method: 'appendChild', node }
    }
  }

  const body = {
    name: 'body',
    style: {},
    dataset: {},
    appendChild(node) {
      this.appended = node
      node.parentElement = this
      node.parentNode = this
    }
  }

  const documentStub = {
    body,
    activeElement: null,
    documentElement: { clientWidth: 800 },
    addEventListener() {},
    removeEventListener() {},
    createElement(tag) {
      const node = {
        tagName: tag.toUpperCase(),
        hidden: false,
        attributes: {},
        parentNode: null,
        parentElement: null,
        setAttribute(name, value) { this.attributes[name] = value },
        getAttribute(name) { return this.attributes[name] },
        remove() {
          this.removed = true
          this.parentNode = null
          this.parentElement = null
        }
      }
      if (tag === 'span') slots.push(node)
      return node
    },
    querySelector(selector) {
      const match = selector.match(/data-fp-drawer-slot="([^"]+)"/)
      if (!match) return null
      return slots.find((slot) => slot.attributes['data-fp-drawer-slot'] === match[1] && !slot.removed) || null
    }
  }

  const DrawerController = loadDrawerController(documentStub)
  const element = {
    id: 'filters-drawer',
    classList: classListStub(['hidden']),
    parentElement: originalParent,
    parentNode: originalParent,
    nextSibling: { id: 'next' },
    style: {},
    offsetHeight: 0,
    setAttribute() {}
  }

  const panel = {
    style: {},
    querySelectorAll() { return [] },
    setAttribute() {},
    focus() {}
  }

  const controller = Object.assign(new DrawerController(), {
    element,
    hasPanelTarget: true,
    panelTarget: panel,
    sideValue: 'left'
  })

  return { controller, element, body, originalParent, slots, documentStub }
}

test('open moves the overlay onto document.body and leaves a slot marker', () => {
  const { controller, element, body, originalParent, slots } = buildController()

  controller.connect()
  controller.open()

  assert.equal(element.parentElement, body)
  assert.equal(body.appended, element)
  assert.equal(slots[0].attributes['data-fp-drawer-slot'], 'filters-drawer')
  assert.equal(originalParent.inserted.node, slots[0])
})

test('close restores the overlay to the slot marker', () => {
  const { controller, element, originalParent, slots } = buildController()

  controller.connect()
  controller.open()
  controller.close()

  assert.equal(element.parentElement, originalParent)
  assert.equal(originalParent.inserted.sibling, slots[0])
  assert.equal(slots[0].removed, true)
})

test('disconnect during a move does not restore the overlay', () => {
  const { controller, element, body } = buildController()

  controller.connect()
  controller.open()
  controller.moving = true
  controller.disconnect()

  assert.equal(element.parentElement, body)
})
