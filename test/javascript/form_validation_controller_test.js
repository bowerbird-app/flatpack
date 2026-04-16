const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

class FakeClassList {
  constructor(node, initial = '') {
    this.node = node
    this.tokens = new Set(initial.split(/\s+/).filter(Boolean))
    this.sync()
  }

  add(...tokens) {
    tokens.forEach((token) => this.tokens.add(token))
    this.sync()
  }

  remove(...tokens) {
    tokens.forEach((token) => this.tokens.delete(token))
    this.sync()
  }

  contains(token) {
    return this.tokens.has(token)
  }

  sync() {
    this.node.className = Array.from(this.tokens).join(' ')
  }
}

class FakeHTMLElement {
  constructor(document, { id = '', className = '', textContent = '' } = {}) {
    this.ownerDocument = document
    this.id = id
    this.className = className
    this.classList = new FakeClassList(this, className)
    this.textContent = textContent
    this.parentElement = null
    this.children = []
  }

  appendChild(child) {
    child.parentElement = this
    this.children.push(child)
    if (child.id) {
      this.ownerDocument.registerElement(child)
    }
    return child
  }
}

class FakeDocument {
  constructor() {
    this.elementsById = new Map()
  }

  createElement() {
    return new FakeHTMLElement(this)
  }

  getElementById(id) {
    return this.elementsById.get(id) || null
  }

  registerElement(element) {
    if (element.id) {
      this.elementsById.set(element.id, element)
    }
  }
}

class FakeInputElement extends FakeHTMLElement {
  constructor(document, { value = '', className = '', attributes = {}, validity = {}, validationMessage = '', isValid = true } = {}) {
    super(document, { className })
    this.value = value
    this.attributes = { ...attributes }
    this.listeners = new Map()
    this.styleStore = {}
    this.style = {
      get borderColor() {
        return this._owner.styleStore.borderColor || ''
      },
      set borderColor(value) {
        this._owner.styleStore.borderColor = value
      },
      removeProperty: (name) => {
        if (name === 'border-color') {
          delete this.styleStore.borderColor
        }
      }
    }
    this.style._owner = this
    this.validity = validity
    this.validationMessage = validationMessage
    this.isValid = isValid
    this.type = 'text'
  }

  addEventListener(type, handler) {
    this.listeners.set(type, handler)
  }

  removeEventListener(type) {
    this.listeners.delete(type)
  }

  setCustomValidity() {}

  checkValidity() {
    return this.isValid
  }

  getAttribute(name) {
    return this.attributes[name] ?? null
  }

  setAttribute(name, value) {
    this.attributes[name] = String(value)
  }

  removeAttribute(name) {
    delete this.attributes[name]
  }
}

function loadController(overrides = {}) {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'form_validation_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformedSource = source
    .replace('import { Controller } from "@hotwired/stimulus"', 'class Controller {}')
    .replace('export default class extends Controller', 'class FormValidationController extends Controller') + '\nmodule.exports = FormValidationController\n'

  const context = {
    module: { exports: {} },
    exports: {},
    HTMLElement: FakeHTMLElement,
    ...overrides
  }

  vm.runInNewContext(transformedSource, context, { filename: filePath })
  return context.module.exports
}

function buildController({ value = '', className = '', attributes = {}, validity = {}, validationMessage = '', isValid = true, existingError = null } = {}) {
  const document = new FakeDocument()
  const parent = new FakeHTMLElement(document)
  const element = new FakeInputElement(document, { value, className, attributes, validity, validationMessage, isValid })
  parent.appendChild(element)

  if (existingError) {
    const errorNode = new FakeHTMLElement(document, {
      id: existingError.id,
      className: existingError.className,
      textContent: existingError.textContent
    })
    parent.appendChild(errorNode)
  }

  const FormValidationController = loadController({ document })
  const controller = new FormValidationController()
  controller.element = element
  controller.errorIdValue = attributes['data-flat-pack--form-validation-error-id-value']
  controller.hasErrorIdValue = Boolean(controller.errorIdValue)
  controller.connect()

  return { controller, document, element }
}

test('blur validation renders a warning message for an empty required field', () => {
  const { controller, document, element } = buildController({
    value: '',
    attributes: {
      required: 'required',
      'data-flat-pack--form-validation-error-id-value': 'username_error'
    },
    validity: { valueMissing: true },
    validationMessage: '',
    isValid: false
  })

  controller.validate()

  const errorNode = document.getElementById('username_error')
  assert.equal(errorNode.textContent, 'Please fill out this field.')
  assert.equal(errorNode.classList.contains('hidden'), false)
  assert.equal(errorNode.classList.contains('text-warning'), true)
  assert.equal(element.classList.contains('border-warning'), true)
  assert.equal(element.getAttribute('aria-invalid'), 'true')
  assert.equal(element.getAttribute('aria-describedby'), 'username_error')
})

test('initial server error clears after the user changes the value and it becomes valid', () => {
  const { controller, document, element } = buildController({
    value: 'john',
    className: 'flat-pack-input border-warning',
    attributes: {
      'aria-invalid': 'true',
      'aria-describedby': 'username_error',
      'data-flat-pack--form-validation-error-id-value': 'username_error'
    },
    validity: { valueMissing: false },
    validationMessage: '',
    isValid: true,
    existingError: {
      id: 'username_error',
      className: 'mt-1 text-sm text-warning',
      textContent: 'Username must be at least 5 characters'
    }
  })

  element.value = 'johnsmith'
  controller.validate()

  const errorNode = document.getElementById('username_error')
  assert.equal(errorNode.textContent, '')
  assert.equal(errorNode.classList.contains('hidden'), true)
  assert.equal(element.classList.contains('border-warning'), false)
  assert.equal(element.classList.contains('border-[var(--surface-border-color)]'), true)
  assert.equal(element.getAttribute('aria-invalid'), null)
  assert.equal(element.getAttribute('aria-describedby'), null)
})

test('initial server error is preserved while the original invalid value is unchanged', () => {
  const { controller, document, element } = buildController({
    value: 'john',
    className: 'flat-pack-input border-warning',
    attributes: {
      'aria-invalid': 'true',
      'aria-describedby': 'username_error',
      'data-flat-pack--form-validation-error-id-value': 'username_error'
    },
    validity: { valueMissing: false },
    validationMessage: '',
    isValid: true,
    existingError: {
      id: 'username_error',
      className: 'mt-1 text-sm text-warning',
      textContent: 'Username must be at least 5 characters'
    }
  })

  controller.validate()

  const errorNode = document.getElementById('username_error')
  assert.equal(errorNode.textContent, 'Username must be at least 5 characters')
  assert.equal(errorNode.classList.contains('hidden'), false)
  assert.equal(element.classList.contains('border-warning'), true)
  assert.equal(element.getAttribute('aria-invalid'), 'true')
  assert.equal(element.getAttribute('aria-describedby'), 'username_error')
})