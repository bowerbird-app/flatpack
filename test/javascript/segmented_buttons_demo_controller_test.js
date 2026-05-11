const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

function loadController() {
  const filePath = path.join(__dirname, '..', '..', 'test', 'dummy', 'app', 'javascript', 'controllers', 'segmented_buttons_demo_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformedSource = source
    .replace('import { Controller } from "@hotwired/stimulus"', 'class Controller {}')
    .replace('export default class extends Controller', 'class SegmentedButtonsDemoController extends Controller') + '\nmodule.exports = SegmentedButtonsDemoController\n'

  const context = {
    module: { exports: {} },
    exports: {}
  }

  vm.runInNewContext(transformedSource, context, { filename: filePath })

  return context.module.exports
}

function buildButton(classNames = [], pressed = 'false') {
  const classes = new Set(classNames)
  const attributes = { 'aria-pressed': pressed }

  return {
    classList: {
      add(...tokens) {
        tokens.forEach((token) => classes.add(token))
      },
      remove(...tokens) {
        tokens.forEach((token) => classes.delete(token))
      },
      contains(token) {
        return classes.has(token)
      }
    },
    setAttribute(name, value) {
      attributes[name] = value
    },
    getAttribute(name) {
      return attributes[name]
    }
  }
}

test('segmented buttons click swaps active and inactive button classes', () => {
  const SegmentedButtonsDemoController = loadController()
  const controller = new SegmentedButtonsDemoController()
  const dayButton = buildButton(['bg-primary', 'text-primary'], 'true')
  const weekButton = buildButton(['bg-secondary', 'text-secondary'], 'false')

  controller.buttonTargets = [dayButton, weekButton]
  controller.activeClassesValue = 'bg-primary text-primary'
  controller.inactiveClassesValue = 'bg-secondary text-secondary'
  controller.connect()

  controller.activate({ currentTarget: weekButton })

  assert.equal(weekButton.classList.contains('bg-primary'), true)
  assert.equal(weekButton.classList.contains('text-primary'), true)
  assert.equal(weekButton.classList.contains('bg-secondary'), false)
  assert.equal(weekButton.getAttribute('aria-pressed'), 'true')

  assert.equal(dayButton.classList.contains('bg-primary'), false)
  assert.equal(dayButton.classList.contains('text-primary'), false)
  assert.equal(dayButton.classList.contains('bg-secondary'), true)
  assert.equal(dayButton.classList.contains('text-secondary'), true)
  assert.equal(dayButton.getAttribute('aria-pressed'), 'false')
})