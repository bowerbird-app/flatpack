const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

function loadController(overrides = {}) {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'form_validation_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformedSource = source
    .replace('import { Controller } from "@hotwired/stimulus"', 'class Controller {}')
    .replace('export default class extends Controller', 'class FormValidationController extends Controller') + '\nmodule.exports = FormValidationController\n'

  const context = {
    module: { exports: {} },
    exports: {},
    ...overrides
  }

  vm.runInNewContext(transformedSource, context, { filename: filePath })

  return context.module.exports
}

function buildController() {
  const HTMLElementClass = class {}
  const nodeClasses = new Set(["hidden"])
  let errorClassName = ""
  let createdErrorNode = null
  const errorNode = {
    id: "username_error",
    textContent: "",
    get className() {
      return errorClassName
    },
    set className(value) {
      errorClassName = value
    },
    classList: {
      add(...tokens) {
        tokens.forEach((token) => nodeClasses.add(token))
      },
      remove(...tokens) {
        tokens.forEach((token) => nodeClasses.delete(token))
      }
    }
  }

  const parentElement = {
    appendedNode: null,
    appendChild(node) {
      this.appendedNode = node
    }
  }

  const element = new HTMLElementClass()
  Object.assign(element, {
    type: "text",
    required: true,
    value: "",
    style: { borderColor: "" },
    dataset: {},
    attributes: { "aria-describedby": "help-text" },
    classList: {
      classes: new Set(),
      add(...tokens) {
        tokens.forEach((token) => this.classes.add(token))
      },
      remove(...tokens) {
        tokens.forEach((token) => this.classes.delete(token))
      }
    },
    parentElement,
    getAttribute(name) {
      return this.attributes[name] || null
    },
    setAttribute(name, value) {
      this.attributes[name] = value
    },
    removeAttribute(name) {
      delete this.attributes[name]
    }
  })

  const document = {
    createElement(tagName) {
      assert.equal(tagName, "p")
      createdErrorNode = errorNode
      return errorNode
    },
    getElementById(id) {
      return id === "username_error" ? createdErrorNode : null
    }
  }

  const FormValidationController = loadController({ document, HTMLElement: HTMLElementClass })
  const controller = new FormValidationController()
  controller.element = element
  controller.initialDescribedBy = "help-text"
  controller.initialBorderColor = "rgb(1, 2, 3)"
  controller.hasErrorIdValue = true
  controller.errorIdValue = "username_error"

  return { controller, element, errorNode, nodeClasses, document }
}

test('showError uses the semantic warning token classes', () => {
  const { controller, element, errorNode, nodeClasses, document } = buildController()

  controller.showError('Username is invalid')

  assert.equal(element.classList.classes.has('border-[var(--color-warning)]'), true)
  assert.equal(element.style.borderColor, 'var(--color-warning)')
  assert.equal(element.attributes['aria-invalid'], 'true')
  assert.equal(element.attributes['aria-describedby'], 'help-text username_error')
  assert.equal(errorNode.textContent, 'Username is invalid')
  assert.equal(errorNode.className, 'mt-1 text-sm text-[var(--color-warning)] hidden')
  assert.equal(nodeClasses.has('hidden'), false)
})

test('clearError removes the semantic warning token classes', () => {
  const { controller, element, errorNode, nodeClasses, document } = buildController()

  controller.showError('Username is invalid')
  controller.clearError()

  assert.equal(element.classList.classes.has('border-[var(--color-warning)]'), false)
  assert.equal(element.style.borderColor, 'rgb(1, 2, 3)')
  assert.equal(element.attributes['aria-invalid'], undefined)
  assert.equal(element.attributes['aria-describedby'], 'help-text')
  assert.equal(errorNode.textContent, '')
  assert.equal(nodeClasses.has('hidden'), true)
})
