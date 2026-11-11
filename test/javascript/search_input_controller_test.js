const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

function loadController() {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'search_input_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformedSource = source
    .replace('import { Controller } from "@hotwired/stimulus"', 'class Controller {}')
    .replace('export default class extends Controller', 'class SearchInputController extends Controller') + '\nmodule.exports = SearchInputController\n'

  const context = {
    module: { exports: {} },
    exports: {},
    Event
  }
  context.globalThis = context

  vm.runInNewContext(transformedSource, context, { filename: filePath })

  return context.module.exports
}

function fakeClassList() {
  const classes = new Set()
  return {
    classes,
    add(name) { classes.add(name) },
    remove(name) { classes.delete(name) },
    contains(name) { return classes.has(name) }
  }
}

function buildController({ value = 'lamps', submitOnClear = false, form = null } = {}) {
  const ControllerClass = loadController()
  const controller = new ControllerClass()
  const events = []
  const input = {
    value,
    focused: false,
    form,
    focus() { this.focused = true },
    dispatchEvent(event) {
      events.push(event)
      return true
    }
  }
  const clearButton = {
    classList: fakeClassList()
  }

  controller.inputTarget = input
  controller.clearButtonTarget = clearButton
  controller.hasClearButtonTarget = true
  controller.submitOnClearValue = submitOnClear

  return { controller, input, clearButton, events }
}

test('clear empties the field, keeps focus, and dispatches input', () => {
  const { controller, input, clearButton, events } = buildController()

  controller.clear({ preventDefault() {} })

  assert.equal(input.value, '')
  assert.equal(input.focused, true)
  assert.equal(clearButton.classList.contains('hidden'), true)
  assert.equal(events.length, 1)
  assert.equal(events[0].type, 'input')
  assert.equal(events[0].bubbles, true)
})

test('clear does not submit when the flag is off', () => {
  let submitted = 0
  const form = { requestSubmit() { submitted += 1 } }
  const { controller } = buildController({ submitOnClear: false, form })

  controller.clear({ preventDefault() {} })

  assert.equal(submitted, 0)
})

test('clear submits the enclosing form when the flag is on', () => {
  let submitted = 0
  const form = { requestSubmit() { submitted += 1 } }
  const { controller, input } = buildController({ submitOnClear: true, form })

  controller.clear({ preventDefault() {} })

  assert.equal(input.value, '')
  assert.equal(submitted, 1)
})

test('clear skips submit when the input has no form', () => {
  const { controller } = buildController({ submitOnClear: true, form: null })

  assert.doesNotThrow(() => controller.clear({ preventDefault() {} }))
})

test('emptying the field by hand does not submit', () => {
  let submitted = 0
  const form = { requestSubmit() { submitted += 1 } }
  const { controller, input } = buildController({ submitOnClear: true, form, value: 'lamps' })

  input.value = ''
  controller.toggleClearButton()

  assert.equal(submitted, 0)
})
