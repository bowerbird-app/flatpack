const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

function loadModalController(documentStub) {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'modal_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformedSource = source
    .replace('import { Controller } from "@hotwired/stimulus"', 'class Controller {}')
    .replace(
      'import { prefersReducedMotion, motionDuration, motionTransition } from "controllers/flat_pack/reduced_motion"',
      'function prefersReducedMotion() { return false }\nfunction motionDuration() { return 0 }\nfunction motionTransition() { return "" }'
    )
    .replace('export default class extends Controller', 'class ModalController extends Controller') + '\nmodule.exports = ModalController\n'

  const context = {
    module: { exports: {} },
    exports: {},
    document: documentStub,
    window: { innerWidth: 1024 },
    requestAnimationFrame: (fn) => fn(),
    setTimeout: (fn) => 1,
    clearTimeout: () => {}
  }

  vm.runInNewContext(transformedSource, context, { filename: filePath })

  return context.module.exports
}

function button(id) {
  return {
    id,
    disabled: false,
    tabIndex: 0,
    getAttribute() { return null },
    focus() { this.focused = true }
  }
}

function classListStub(initial = []) {
  const names = new Set(initial)
  return {
    names,
    contains(name) { return names.has(name) },
    add(...added) { added.forEach((name) => names.add(name)) },
    remove(...removed) { removed.forEach((name) => names.delete(name)) }
  }
}

function buildController({ buttons, hidden = false } = {}) {
  const documentStub = {
    activeElement: null,
    body: {
      style: {
        overflow: "",
        paddingRight: "",
        overscrollBehavior: "",
        removeProperty(name) { this[name.replace(/-([a-z])/g, (_, c) => c.toUpperCase())] = "" }
      },
      dataset: {},
      addEventListener() {},
      removeEventListener() {}
    },
    documentElement: { clientWidth: 1024 },
    addEventListener() {},
    removeEventListener() {}
  }
  const ModalController = loadModalController(documentStub)
  const focusable = buttons || [button('first'), button('middle'), button('last')]
  const dialog = {
    style: {},
    contains(node) { return focusable.includes(node) },
    focus() { this.focused = true },
    querySelectorAll() { return focusable }
  }
  const classList = classListStub(hidden ? ['hidden'] : [])

  const controller = Object.assign(new ModalController(), {
    hasDialogTarget: true,
    dialogTarget: dialog,
    element: {
      classList,
      style: {},
      scrollTop: 40,
      attributes: { 'aria-hidden': hidden ? 'true' : 'false' },
      setAttribute(name, value) { this.attributes[name] = value },
      offsetHeight: 1
    }
  })

  return { controller, focusable, dialog, documentStub }
}

function tabEvent({ shiftKey = false } = {}) {
  return {
    key: 'Tab',
    shiftKey,
    prevented: false,
    preventDefault() { this.prevented = true }
  }
}

test('tab on the last focusable wraps to the first', () => {
  const { controller, focusable, documentStub } = buildController()
  documentStub.activeElement = focusable[2]
  const event = tabEvent()

  controller.handleKeydown(event)

  assert.equal(event.prevented, true)
  assert.equal(focusable[0].focused, true)
})

test('shift-tab on the first focusable wraps to the last', () => {
  const { controller, focusable, documentStub } = buildController()
  documentStub.activeElement = focusable[0]
  const event = tabEvent({ shiftKey: true })

  controller.handleKeydown(event)

  assert.equal(event.prevented, true)
  assert.equal(focusable[2].focused, true)
})

test('tab between first and last does not wrap', () => {
  const { controller, focusable, documentStub } = buildController()
  documentStub.activeElement = focusable[1]
  const event = tabEvent()

  controller.handleKeydown(event)

  assert.equal(event.prevented, false)
  assert.equal(focusable[0].focused, undefined)
  assert.equal(focusable[2].focused, undefined)
})

test('open writes the Tailwind v4 scale property and resets overlay scroll', () => {
  const { controller, dialog } = buildController({ hidden: true })

  controller.open()

  assert.equal(controller.element.scrollTop, 0)
  assert.equal(dialog.style.opacity, '1')
  assert.equal(dialog.style.scale, '1')
  assert.equal(dialog.style.transform, undefined)
})

test('close writes the Tailwind v4 scale property', () => {
  const { controller, dialog } = buildController({ hidden: false })

  controller.close()

  assert.equal(dialog.style.opacity, '0')
  assert.equal(dialog.style.scale, '0.95')
  assert.equal(dialog.style.transform, undefined)
})
