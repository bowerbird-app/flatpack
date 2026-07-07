const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

class FakeElement {
  constructor(tagName) {
    this.tagName = tagName
    this.children = []
    this.dataset = {}
    this.listeners = {}
    this.hidden = false
    this.checked = false
    this.indeterminate = false
    this.attributes = {}
  }

  set innerHTML(_value) {
    this.children = []
  }

  appendChild(child) {
    this.children.push(child)
    child.parentNode = this
    return child
  }

  replaceChildren(...children) {
    this.children = []
    children.forEach((child) => this.appendChild(child))
  }

  addEventListener(type, listener) {
    this.listeners[type] = listener
  }

  dispatchEvent(event) {
    this.listeners[event.type]({
      ...event,
      currentTarget: this,
      target: this
    })
  }

  querySelector(selector) {
    return flatten(this).find((element) => {
      if (selector.includes(':not([data-child-id])') && element.dataset.childId !== undefined) {
        return false
      }

      const parentMatch = selector.match(/\[data-parent-id="([^"]+)"\]/)
      return parentMatch ? element.dataset.parentId === parentMatch[1] : false
    }) || null
  }
}

function flatten(element) {
  return [element, ...element.children.flatMap((child) => flatten(child))]
}

function loadController() {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'nested_multiselect_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformedSource = source
    .replace('import { Controller } from "@hotwired/stimulus"', 'class Controller {}')
    .replace('export default class extends Controller', 'class NestedMultiselectController extends Controller') + '\nmodule.exports = NestedMultiselectController\n'

  const context = {
    module: { exports: {} },
    exports: {},
    document: {
      createElement(tagName) {
        return new FakeElement(tagName)
      }
    },
    CSS: {
      escape(value) {
        return String(value)
      }
    },
    Math
  }

  vm.runInNewContext(transformedSource, context, { filename: filePath })

  return context.module.exports
}

function buildController(selected = []) {
  const ControllerClass = loadController()
  const controller = new ControllerClass()
  controller.element = new FakeElement('div')
  controller.optionsValue = [
    {
      id: 'australia',
      label: 'Australia',
      children: [
        { id: 'vic', label: 'VIC' },
        { id: 'nsw', label: 'NSW' }
      ]
    },
    {
      id: 'malaysia',
      label: 'Malaysia',
      children: [
        { id: 'penang', label: 'Penang' },
        { id: 'selangor', label: 'Selangor' }
      ]
    }
  ]
  controller.hasOptionsValue = true
  controller.selectedValue = selected
  controller.inputNameValue = 'locations[]'
  controller.hasInputNameValue = true
  controller.instanceId = 'test'
  controller.connect()

  return controller
}

function checkbox(controller, dataset) {
  return flatten(controller.element).find((element) => (
    element.tagName === 'input' &&
    Object.entries(dataset).every(([key, value]) => element.dataset[key] === value)
  ))
}

function hiddenValues(controller) {
  return controller.hiddenInputsElement.children.map((input) => input.value)
}

function selectedValues(controller) {
  return Array.from(controller.selectedValues())
}

test('selecting a parent selects the parent and all children for form submission', () => {
  const controller = buildController()
  const australia = checkbox(controller, { parentId: 'australia' })

  australia.checked = true
  australia.dispatchEvent({ type: 'change' })

  assert.deepEqual(selectedValues(controller), ['australia', 'vic', 'nsw'])
  assert.deepEqual(hiddenValues(controller), ['australia', 'vic', 'nsw'])
  assert.equal(checkbox(controller, { parentId: 'australia' }).checked, true)
  assert.equal(checkbox(controller, { parentId: 'australia', childId: 'vic' }).checked, true)
})

test('deselecting a parent deselects all children', () => {
  const controller = buildController(['australia'])
  const australia = checkbox(controller, { parentId: 'australia' })

  australia.checked = false
  australia.dispatchEvent({ type: 'change' })

  assert.deepEqual(selectedValues(controller), [])
  assert.deepEqual(hiddenValues(controller), [])
})

test('partial child selection makes the parent indeterminate and omits parent value', () => {
  const controller = buildController()
  const vic = checkbox(controller, { parentId: 'australia', childId: 'vic' })

  vic.checked = true
  vic.dispatchEvent({ type: 'change' })

  const australia = checkbox(controller, { parentId: 'australia' })
  assert.equal(australia.checked, false)
  assert.equal(australia.indeterminate, true)
  assert.deepEqual(selectedValues(controller), ['vic'])
  assert.deepEqual(hiddenValues(controller), ['vic'])
})

test('selecting all children selects the parent automatically', () => {
  const controller = buildController()

  let vic = checkbox(controller, { parentId: 'australia', childId: 'vic' })
  vic.checked = true
  vic.dispatchEvent({ type: 'change' })

  const nsw = checkbox(controller, { parentId: 'australia', childId: 'nsw' })
  nsw.checked = true
  nsw.dispatchEvent({ type: 'change' })

  const australia = checkbox(controller, { parentId: 'australia' })
  assert.equal(australia.checked, true)
  assert.equal(australia.indeterminate, false)
  assert.deepEqual(selectedValues(controller), ['australia', 'vic', 'nsw'])
})

test('initial parent selections expand to include child values', () => {
  const controller = buildController(['malaysia'])

  assert.deepEqual(selectedValues(controller), ['malaysia', 'penang', 'selangor'])
  assert.equal(checkbox(controller, { parentId: 'malaysia' }).checked, true)
  assert.equal(checkbox(controller, { parentId: 'malaysia', childId: 'penang' }).checked, true)
})
