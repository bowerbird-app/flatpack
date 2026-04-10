const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

function loadController() {
  const filePath = path.join(__dirname, '..', 'dummy', 'app', 'javascript', 'controllers', 'chip_tag_input_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformedSource = source
    .replace('import { Controller } from "@hotwired/stimulus"', 'class Controller {}')
    .replace('export default class extends Controller', 'class ChipTagInputController extends Controller') + '\nmodule.exports = ChipTagInputController\n'

  const context = {
    module: { exports: {} },
    exports: {}
  }

  vm.runInNewContext(transformedSource, context, { filename: filePath })

  return context.module.exports
}

function buildController() {
  const insertions = []
  const chipsTarget = {
    existingValues: ['frontend'],
    querySelectorAll(selector) {
      if (selector !== '[data-flat-pack--chip-value-value]') {
        return []
      }

      return this.existingValues.map((value) => ({
        dataset: { flatPackChipValueValue: value }
      }))
    },
    insertAdjacentHTML(position, markup) {
      insertions.push({ position, markup })
      const valueMatch = markup.match(/data-flat-pack--chip-value-value="([^"]+)"/)
      if (valueMatch) {
        this.existingValues.push(valueMatch[1])
      }
    }
  }

  const ChipTagInputController = loadController()
  const controller = new ChipTagInputController()
  controller.inputTarget = { value: '' }
  controller.chipsTarget = chipsTarget
  controller.templateTarget = {
    innerHTML: '<span data-flat-pack--chip-value-value="__TAG_VALUE__">__TAG_TEXT__</span>'
  }

  return { controller, insertions }
}

test('pressing Enter adds a new chip from the input value', () => {
  const { controller, insertions } = buildController()
  let prevented = false

  controller.handleKeydown({
    key: 'Enter',
    target: { value: 'API Platform' },
    preventDefault() { prevented = true }
  })

  assert.equal(prevented, true)
  assert.equal(controller.inputTarget.value, '')
  assert.equal(insertions.length, 1)
  assert.equal(insertions[0].position, 'beforeend')
  assert.match(insertions[0].markup, /API Platform/)
  assert.match(insertions[0].markup, /api-platform/)
})

test('duplicate chip values are ignored', () => {
  const { controller, insertions } = buildController()

  controller.handleKeydown({
    key: 'Enter',
    target: { value: 'Frontend' },
    preventDefault() {}
  })

  assert.equal(insertions.length, 0)
})

test('non-Enter keys do nothing', () => {
  const { controller, insertions } = buildController()
  let prevented = false

  controller.handleKeydown({
    key: 'Tab',
    target: { value: 'Docs' },
    preventDefault() { prevented = true }
  })

  assert.equal(prevented, false)
  assert.equal(insertions.length, 0)
})