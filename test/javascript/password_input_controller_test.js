const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

class FakeClassList {
  constructor(classes = []) {
    this.classes = new Set(classes)
  }

  add(name) { this.classes.add(name) }
  remove(name) { this.classes.delete(name) }
  contains(name) { return this.classes.has(name) }
}

function loadController() {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'password_input_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformedSource = source
    .replace('import { Controller } from "@hotwired/stimulus"', 'class Controller {}')
    .replace('export default class extends Controller', 'class PasswordInputController extends Controller') + '\nmodule.exports = PasswordInputController\n'

  const context = {
    module: { exports: {} },
    exports: {}
  }

  vm.runInNewContext(transformedSource, context, { filename: filePath })

  return context.module.exports
}

function buildController({ type = 'password' } = {}) {
  const ControllerClass = loadController()
  const controller = new ControllerClass()
  const attributes = {
    'aria-pressed': type === 'password' ? 'false' : 'true',
    'aria-label': type === 'password' ? 'Show password' : 'Hide password'
  }

  controller.inputTarget = { type }
  controller.toggleTarget = {
    attributes,
    classList: new FakeClassList(),
    setAttribute(name, value) { attributes[name] = String(value) }
  }
  controller.eyeIconTarget = { classList: new FakeClassList() }
  controller.eyeOffIconTarget = { classList: new FakeClassList() }

  return controller
}

test('toggle shows the password and presses the control', () => {
  const controller = buildController()

  controller.toggle({ preventDefault() {} })

  assert.equal(controller.inputTarget.type, 'text')
  assert.equal(controller.toggleTarget.attributes['aria-pressed'], 'true')
  assert.equal(controller.toggleTarget.attributes['aria-label'], 'Hide password')
  assert.equal(controller.eyeIconTarget.classList.contains('hidden'), false)
  assert.equal(controller.eyeOffIconTarget.classList.contains('hidden'), false)
})

test('toggle hides the password again', () => {
  const controller = buildController({ type: 'text' })

  controller.toggle({ preventDefault() {} })

  assert.equal(controller.inputTarget.type, 'password')
  assert.equal(controller.toggleTarget.attributes['aria-pressed'], 'false')
  assert.equal(controller.toggleTarget.attributes['aria-label'], 'Show password')
})
