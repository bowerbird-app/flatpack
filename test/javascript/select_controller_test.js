const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

class FakeClassList {
  constructor(classes = []) {
    this.classes = new Set(classes)
  }

  add(...classes) {
    classes.forEach((klass) => this.classes.add(klass))
  }

  remove(...classes) {
    classes.forEach((klass) => this.classes.delete(klass))
  }

  toggle(klass, force) {
    if (force === true) {
      this.classes.add(klass)
      return true
    }

    if (force === false) {
      this.classes.delete(klass)
      return false
    }

    if (this.classes.has(klass)) {
      this.classes.delete(klass)
      return false
    }

    this.classes.add(klass)
    return true
  }

  contains(klass) {
    return this.classes.has(klass)
  }
}

class FakeElement {
  constructor(tagName) {
    this.tagName = tagName
    this.children = []
    this.dataset = {}
    this.attributes = {}
    this.style = {}
    this.classList = new FakeClassList()
    this.listeners = {}
    this.checked = false
    this.indeterminate = false
    this.value = ''
    this.textContent = ''
  }

  set innerHTML(_value) {
    this.children = []
  }

  appendChild(child) {
    this.children.push(child)
    child.parentNode = this
    return child
  }

  setAttribute(name, value) {
    this.attributes[name] = String(value)
  }

  addEventListener(type, listener) {
    this.listeners[type] = listener
  }

  dispatchEvent(event) {
    if (this.listeners[event.type]) {
      this.listeners[event.type]({
        ...event,
        currentTarget: this,
        target: this
      })
    }
  }

  querySelector(selector) {
    return this.querySelectorAll(selector)[0] || null
  }

  querySelectorAll(selector) {
    return flatten(this).filter((element) => matchesSelector(element, selector))
  }
}

function flatten(element) {
  return [element, ...element.children.flatMap((child) => flatten(child))]
}

function matchesSelector(element, selector) {
  if (selector === 'span') {
    return element.tagName === 'span'
  }

  if (selector === "[role='option']") {
    return element.attributes.role === 'option'
  }

  if (selector === "input[type='hidden']") {
    return element.tagName === 'input' && element.type === 'hidden'
  }

  if (selector === "input[type='checkbox']") {
    return element.tagName === 'input' && element.type === 'checkbox'
  }

  const valueMatch = selector.match(/\[data-value='([^']*)'\]/)
  if (valueMatch) {
    return element.dataset.value === valueMatch[1]
  }

  const targetMatch = selector.match(/\[data-flat-pack--select-target='([^']+)'\]/)
  if (targetMatch) {
    return element.dataset.flatPackSelectTarget === targetMatch[1]
  }

  return false
}

function loadController() {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'select_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformedSource = source
    .replace('import { Controller } from "@hotwired/stimulus"', 'class Controller {}')
    .replace('export default class extends Controller', 'class SelectController extends Controller') + '\nmodule.exports = SelectController\n'

  const context = {
    module: { exports: {} },
    exports: {},
    document: {
      addEventListener() {},
      removeEventListener() {},
      createElement(tagName) {
        return new FakeElement(tagName)
      }
    },
    CSS: {
      escape(value) {
        return String(value)
      }
    },
    Event: class {
      constructor(type, options = {}) {
        this.type = type
        this.bubbles = options.bubbles
      }
    }
  }

  vm.runInNewContext(transformedSource, context, { filename: filePath })

  return context.module.exports
}

function buildOption({ value, label, parentValue = value, optionType = 'parent', disabled = false }) {
  const option = new FakeElement('div')
  option.dataset.value = value
  option.dataset.label = label
  option.dataset.parentValue = parentValue
  option.dataset.optionType = optionType
  option.dataset.disabled = String(disabled)
  option.attributes.role = 'option'

  const checkbox = new FakeElement('input')
  checkbox.type = 'checkbox'
  option.appendChild(checkbox)

  return option
}

function buildController({ selected = [], nested = true } = {}) {
  const ControllerClass = loadController()
  const controller = new ControllerClass()
  const trigger = new FakeElement('button')
  const triggerLabel = new FakeElement('span')
  const dropdown = new FakeElement('div')
  const chevron = new FakeElement('span')
  const hiddenInputs = new FakeElement('div')
  const optionsList = new FakeElement('div')
  const element = new FakeElement('div')

  triggerLabel.textContent = 'Select locations...'
  trigger.appendChild(triggerLabel)

  const options = [
    {
      value: 'australia',
      label: 'Australia',
      children: [
        { value: 'vic', label: 'VIC' },
        { value: 'nsw', label: 'NSW' }
      ]
    },
    {
      value: 'malaysia',
      label: 'Malaysia',
      children: [
        { value: 'penang', label: 'Penang' },
        { value: 'selangor', label: 'Selangor' }
      ]
    }
  ]

  if (nested) {
    options.forEach((parent) => {
      optionsList.appendChild(buildOption({ value: parent.value, label: parent.label }))
      parent.children.forEach((child) => {
        optionsList.appendChild(buildOption({ value: child.value, label: child.label, parentValue: parent.value, optionType: 'child' }))
      })
    })
  } else {
    optionsList.appendChild(buildOption({ value: 'rails', label: 'Rails' }))
    optionsList.appendChild(buildOption({ value: 'hotwire', label: 'Hotwire' }))
  }

  selected.forEach((value) => {
    const input = new FakeElement('input')
    input.type = 'hidden'
    input.value = value
    hiddenInputs.appendChild(input)
  })

  element.appendChild(trigger)
  element.appendChild(dropdown)
  element.appendChild(hiddenInputs)
  element.appendChild(optionsList)

  controller.element = element
  controller.triggerTarget = trigger
  controller.dropdownTarget = dropdown
  controller.chevronTarget = chevron
  controller.hiddenInputsTarget = hiddenInputs
  controller.optionsListTarget = optionsList
  controller.hasHiddenInputsTarget = true
  controller.hasOptionsListTarget = true
  controller.hasHiddenInputTarget = false
  controller.hasSearchInputTarget = false
  controller.hasSearchStatusTarget = false
  controller.hasSearchHintTarget = false
  controller.hasLoadingStateTarget = false
  controller.hasEmptyStateTarget = false
  controller.hasPlaceholderTarget = false
  controller.hasChipsContainerTarget = false
  controller.multipleValue = true
  controller.nestedValue = nested
  controller.optionsValue = options
  controller.hasOptionsValue = nested
  controller.searchModeValue = 'local'
  controller.inputNameValue = 'locations[]'
  controller.connect()

  return controller
}

function option(controller, value) {
  return controller.optionsListTarget.querySelector(`[data-value='${value}']`)
}

function hiddenValues(controller) {
  return controller.hiddenInputsTarget.children.map((input) => input.value)
}

test('nested select parent selection selects parent and children', () => {
  const controller = buildController()

  controller.selectNestedOption({ currentTarget: option(controller, 'australia') })

  assert.deepEqual(hiddenValues(controller), ['australia', 'vic', 'nsw'])
  assert.equal(option(controller, 'australia').querySelector("input[type='checkbox']").checked, true)
  assert.equal(option(controller, 'vic').querySelector("input[type='checkbox']").checked, true)
})

test('nested select parent deselection clears children', () => {
  const controller = buildController({ selected: ['australia'] })

  controller.selectNestedOption({ currentTarget: option(controller, 'australia') })

  assert.deepEqual(hiddenValues(controller), [''])
})

test('nested select marks parent indeterminate when one child is selected', () => {
  const controller = buildController()

  controller.selectNestedOption({ currentTarget: option(controller, 'vic') })

  const checkbox = option(controller, 'australia').querySelector("input[type='checkbox']")
  assert.equal(checkbox.checked, false)
  assert.equal(checkbox.indeterminate, true)
  assert.deepEqual(hiddenValues(controller), ['vic'])
})

test('nested select selects parent when all children are selected', () => {
  const controller = buildController()

  controller.selectNestedOption({ currentTarget: option(controller, 'vic') })
  controller.selectNestedOption({ currentTarget: option(controller, 'nsw') })

  assert.deepEqual(hiddenValues(controller), ['australia', 'vic', 'nsw'])
  assert.equal(option(controller, 'australia').querySelector("input[type='checkbox']").checked, true)
})

test('nested select expands initial parent selection and orders hidden inputs', () => {
  const controller = buildController({ selected: ['malaysia', 'vic'] })

  assert.deepEqual(hiddenValues(controller), ['vic', 'malaysia', 'penang', 'selangor'])
})

test('nested select search keeps parent visible when child matches', () => {
  const controller = buildController()

  controller.search({ target: { value: 'penang' } })

  assert.equal(option(controller, 'malaysia').style.display, 'flex')
  assert.equal(option(controller, 'penang').style.display, 'flex')
  assert.equal(option(controller, 'selangor').style.display, 'none')
  assert.equal(option(controller, 'australia').style.display, 'none')
})

test('flat multiselect toggles one selected value unchanged', () => {
  const controller = buildController({ nested: false })

  controller.selectOption({ currentTarget: option(controller, 'rails') })
  controller.selectOption({ currentTarget: option(controller, 'hotwire') })
  controller.selectOption({ currentTarget: option(controller, 'rails') })

  assert.deepEqual(hiddenValues(controller), ['hotwire'])
}
)
