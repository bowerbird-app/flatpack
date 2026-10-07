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

function buildButton(classNames = [], pressed = 'false', fpStyle = '') {
  const classes = new Set(classNames)
  const attributes = { 'aria-pressed': pressed }

  return {
    dataset: { fpStyle },
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

test('segmented buttons click sets data-fp-style and swaps the press class', () => {
  const SegmentedButtonsDemoController = loadController()
  const controller = new SegmentedButtonsDemoController()
  const dayButton = buildButton(['fp-button-flat'], 'true', 'ghost')
  const weekButton = buildButton(['fp-button-raised'], 'false', 'primary')

  controller.buttonTargets = [dayButton, weekButton]
  controller.activeStyleValue = 'primary'
  controller.inactiveStyleValue = 'secondary'
  controller.activePressClassValue = 'fp-button-raised'
  controller.inactivePressClassValue = 'fp-button-flat'
  controller.connect()

  assert.equal(dayButton.dataset.fpStyle, 'primary')
  assert.equal(dayButton.classList.contains('fp-button-raised'), true)
  assert.equal(dayButton.classList.contains('fp-button-flat'), false)
  assert.equal(weekButton.dataset.fpStyle, 'secondary')
  assert.equal(weekButton.classList.contains('fp-button-flat'), true)
  assert.equal(weekButton.classList.contains('fp-button-raised'), false)

  controller.activate({ currentTarget: weekButton })

  assert.equal(weekButton.dataset.fpStyle, 'primary')
  assert.equal(weekButton.classList.contains('fp-button-raised'), true)
  assert.equal(weekButton.classList.contains('fp-button-flat'), false)
  assert.equal(weekButton.getAttribute('aria-pressed'), 'true')

  assert.equal(dayButton.dataset.fpStyle, 'secondary')
  assert.equal(dayButton.classList.contains('fp-button-flat'), true)
  assert.equal(dayButton.classList.contains('fp-button-raised'), false)
  assert.equal(dayButton.getAttribute('aria-pressed'), 'false')
})
