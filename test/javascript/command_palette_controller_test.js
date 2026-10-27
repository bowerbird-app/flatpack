const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

function loadCommandPaletteController(documentStub) {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'command_palette_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformedSource = source
    .replace('import { Controller } from "@hotwired/stimulus"', 'class Controller {}')
    .replace(
      'import { prefersReducedMotion, motionDuration, motionTransition } from "controllers/flat_pack/reduced_motion"',
      'function prefersReducedMotion() { return false }\nfunction motionDuration() { return 0 }\nfunction motionTransition() { return "" }'
    )
    .replace(
      'import { trapTab as trapTabWithin } from "flat_pack/focus_trap"',
      'const trapTabWithin = trapTab'
    )
    .replace(/import \{[^}]+\} from "flat_pack\/click_outside"\n/, "")
    .replace('export default class extends Controller', 'class CommandPaletteController extends Controller') + '\nmodule.exports = CommandPaletteController\n'
  const focusTrapPath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'focus_trap.js')
  const focusTrapSource = fs.readFileSync(focusTrapPath, 'utf8')
    .replaceAll('export function ', 'function ')
    .replaceAll('export const ', 'const ')
  const clickOutsidePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'click_outside.js')
  const clickOutsideSource = fs.readFileSync(clickOutsidePath, 'utf8')
    .replaceAll('export function ', 'function ')

  const context = {
    module: { exports: {} },
    exports: {},
    document: documentStub,
    window: {},
    requestAnimationFrame(callback) { callback() },
    setTimeout(callback) { callback(); return 0 },
    clearTimeout() {}
  }

  vm.runInNewContext(clickOutsideSource + '\n' + focusTrapSource + '\n' + transformedSource, context, { filename: filePath })
  return context.module.exports
}

function focusable(id) {
  return {
    id,
    focused: false,
    focus() { this.focused = true }
  }
}

function buildController() {
  const documentStub = { activeElement: null }
  const CommandPaletteController = loadCommandPaletteController(documentStub)
  const dialog = { querySelectorAll() { return [] } }
  const controller = Object.assign(new CommandPaletteController(), {
    hasDialogTarget: true,
    dialogTarget: dialog
  })
  return { controller, dialog, documentStub }
}

test('tab on the last dialog control wraps to the first', () => {
  const { controller, dialog, documentStub } = buildController()
  const nodes = [focusable('first'), focusable('last')]
  dialog.querySelectorAll = () => nodes
  documentStub.activeElement = nodes[1]
  const event = { key: 'Tab', shiftKey: false, prevented: false, preventDefault() { this.prevented = true } }

  controller.trapTab(event)

  assert.equal(event.prevented, true)
  assert.equal(nodes[0].focused, true)
  assert.equal(nodes[1].focused, false)
})

test('shift+tab on the first dialog control wraps to the last', () => {
  const { controller, dialog, documentStub } = buildController()
  const nodes = [focusable('first'), focusable('last')]
  dialog.querySelectorAll = () => nodes
  documentStub.activeElement = nodes[0]
  const event = { key: 'Tab', shiftKey: true, prevented: false, preventDefault() { this.prevented = true } }

  controller.trapTab(event)

  assert.equal(event.prevented, true)
  assert.equal(nodes[1].focused, true)
  assert.equal(nodes[0].focused, false)
})

test('tab in the middle and an empty dialog do not wrap', () => {
  const { controller, dialog, documentStub } = buildController()
  const nodes = [focusable('first'), focusable('middle'), focusable('last')]
  dialog.querySelectorAll = () => nodes
  documentStub.activeElement = nodes[1]
  const middle = { key: 'Tab', shiftKey: false, prevented: false, preventDefault() { this.prevented = true } }

  controller.trapTab(middle)

  assert.equal(middle.prevented, false)
  assert.equal(nodes.some((node) => node.focused), false)

  dialog.querySelectorAll = () => []
  const empty = { key: 'Tab', shiftKey: false, prevented: false, preventDefault() { this.prevented = true } }
  controller.trapTab(empty)
  assert.equal(empty.prevented, false)
})
