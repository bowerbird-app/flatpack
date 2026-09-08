const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

function loadRangeInputController() {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'range_input_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformedSource = source
    .replace('import { Controller } from "@hotwired/stimulus"', 'class Controller {}')
    .replace('export default class extends Controller', 'class RangeInputController extends Controller') + '\nmodule.exports = RangeInputController\n'

  const context = {
    module: { exports: {} },
    exports: {},
    CustomEvent: class CustomEvent {
      constructor(type, options = {}) {
        this.type = type
        this.detail = options.detail
        this.bubbles = options.bubbles
      }
    }
  }

  vm.runInNewContext(transformedSource, context, { filename: filePath })

  return context.module.exports
}

function buildController({ min = '0', max = '100', value = '50' } = {}) {
  const properties = {}
  const input = {
    value,
    min,
    max,
    attributes: {},
    style: {
      setProperty(name, next) { properties[name] = next }
    },
    setAttribute(name, next) { this.attributes[name] = next }
  }
  const events = []
  const RangeInputController = loadRangeInputController()
  const controller = Object.assign(new RangeInputController(), {
    inputTarget: input,
    hasValueDisplayTarget: true,
    valueDisplayTarget: { textContent: '' },
    element: {
      dispatchEvent(event) { events.push(event) }
    }
  })

  return { controller, input, properties, events }
}

test('update paints --range-progress from the current value', () => {
  const { controller, properties } = buildController({ value: '25' })

  controller.update()

  assert.equal(properties['--range-progress'], '25%')
})

test('update paints --range-progress from a custom min and max', () => {
  const { controller, properties } = buildController({ min: '-20', max: '40', value: '20' })

  controller.update()

  assert.equal(Number.parseFloat(properties['--range-progress']).toFixed(4), '66.6667')
})

test('update clamps fill when the value is below min', () => {
  const { controller, properties } = buildController({ min: '10', max: '20', value: '0' })

  controller.update()

  assert.equal(properties['--range-progress'], '0%')
})

test('update keeps the value display and change event', () => {
  const { controller, events } = buildController({ value: '80' })

  controller.update()

  assert.equal(controller.valueDisplayTarget.textContent, '80')
  assert.equal(events[0].type, 'range-input:change')
  assert.equal(events[0].detail.value, 80)
})
