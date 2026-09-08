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
    document: documentStub
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

function buildController({ buttons, hidden = false } = {}) {
  const documentStub = { activeElement: null }
  const ModalController = loadModalController(documentStub)
  const focusable = buttons || [button('first'), button('middle'), button('last')]
  const dialog = {
    contains(node) { return focusable.includes(node) },
    focus() { this.focused = true },
    querySelectorAll() { return focusable }
  }

  const controller = Object.assign(new ModalController(), {
    hasDialogTarget: true,
    dialogTarget: dialog,
    element: { classList: { contains: (name) => hidden && name === 'hidden' } }
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
