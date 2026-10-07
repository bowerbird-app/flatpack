const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

class FakeElement {
  constructor(tagName, attributes = {}) {
    this.tagName = tagName.toUpperCase()
    this.name = attributes.name || ''
    this.type = attributes.type || (this.tagName === 'TEXTAREA' ? 'textarea' : '')
    this.value = attributes.value || ''
    this.checked = Boolean(attributes.checked)
    this.disabled = Boolean(attributes.disabled)
    this.multiple = Boolean(attributes.multiple)
    this.files = attributes.files
    this.selectedOptions = attributes.selectedOptions
    this.attributes = {}
    this.listeners = {}
  }

  setAttribute(name, value) {
    this.attributes[name] = String(value)
  }

  getAttribute(name) {
    return Object.prototype.hasOwnProperty.call(this.attributes, name) ? this.attributes[name] : null
  }

  addEventListener(type, handler) {
    this.listeners[type] = this.listeners[type] || []
    this.listeners[type].push(handler)
  }

  removeEventListener(type, handler) {
    this.listeners[type] = (this.listeners[type] || []).filter((candidate) => candidate !== handler)
  }

  dispatchEvent(event) {
    ;(this.listeners[event.type] || []).forEach((handler) => handler(event))
    return true
  }
}

function loadController(options = {}) {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'unsaved_changes_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformedSource = source
    .replace('import { Controller } from "@hotwired/stimulus"', 'class Controller {}')
    .replace('export default class extends Controller', 'class UnsavedChangesController extends Controller') + '\nmodule.exports = UnsavedChangesController\n'

  const context = {
    module: { exports: {} },
    exports: {},
    queueMicrotask,
    encodeURIComponent
  }

  if (options.animationFrames) {
    context.requestAnimationFrame = (callback) => {
      options.nextFrameId = (options.nextFrameId || 0) + 1
      const id = options.nextFrameId
      options.animationFrames.push({ id, callback })
      return id
    }
    context.cancelAnimationFrame = (id) => {
      const index = options.animationFrames.findIndex((frame) => frame.id === id)
      if (index >= 0) options.animationFrames.splice(index, 1)
    }
  }

  vm.runInNewContext(transformedSource, context, { filename: filePath })
  return context.module.exports
}

function field(tagName, attributes) {
  return new FakeElement(tagName, attributes)
}

function buildForm(extraFields = [], options = {}) {
  const name = field('input', { name: 'profile[name]', type: 'text', value: 'Ada' })
  const description = field('textarea', { name: 'profile[description]', value: 'Notes' })
  const category = field('select', { name: 'profile[category]', type: 'select-one', value: 'people' })
  const enabled = field('input', { name: 'profile[enabled]', type: 'checkbox', value: '1', checked: true })
  const token = field('input', { name: 'authenticity_token', type: 'hidden', value: 'token' })
  const method = field('input', { name: '_method', type: 'hidden', value: 'patch' })
  const utf8 = field('input', { name: 'utf8', type: 'hidden', value: '✓' })
  const save = field('button', { type: 'submit' })
  const saveAgain = field('button', { type: 'submit' })
  save.setAttribute('data-fp-style', 'default')
  saveAgain.setAttribute('data-fp-style', 'default')

  const elements = [name, description, category, enabled, token, method, utf8, ...extraFields]
  const form = new FakeElement('form')
  form.elements = elements

  const ControllerClass = loadController(options)
  const controller = new ControllerClass()
  controller.element = form
  controller.submitTargets = [save, saveAgain]
  controller.savedStyleValue = 'default'
  controller.unsavedStyleValue = 'primary'

  return { controller, form, name, description, category, enabled, token, save, saveAgain }
}

function settle() {
  return new Promise((resolve) => {
    queueMicrotask(() => {
      if (typeof requestAnimationFrame === 'function') {
        requestAnimationFrame(() => resolve())
      } else {
        resolve()
      }
    })
  })
}

test('a new form is saved and both submit targets use the default style', async () => {
  const { controller, save, saveAgain } = buildForm()
  controller.connect()
  await settle()

  assert.equal(save.getAttribute('data-fp-style'), 'default')
  assert.equal(saveAgain.getAttribute('data-fp-style'), 'default')
})

test('editing a text field marks the form unsaved and restoring it marks the form saved', async () => {
  const { controller, form, name, save, saveAgain } = buildForm()
  controller.connect()
  await settle()

  name.value = 'Ada Lovelace'
  form.dispatchEvent(new Event('input'))

  assert.equal(save.getAttribute('data-fp-style'), 'primary')
  assert.equal(saveAgain.getAttribute('data-fp-style'), 'primary')

  name.value = 'Ada'
  form.dispatchEvent(new Event('input'))

  assert.equal(save.getAttribute('data-fp-style'), 'default')
  assert.equal(saveAgain.getAttribute('data-fp-style'), 'default')
})

test('checkbox and select changes are unsaved until each control returns to its saved value', async () => {
  const { controller, form, category, enabled, save } = buildForm()
  controller.connect()
  await settle()

  enabled.checked = false
  form.dispatchEvent(new Event('change'))
  assert.equal(save.getAttribute('data-fp-style'), 'primary')

  enabled.checked = true
  form.dispatchEvent(new Event('change'))
  assert.equal(save.getAttribute('data-fp-style'), 'default')

  category.value = 'places'
  form.dispatchEvent(new Event('change'))
  assert.equal(save.getAttribute('data-fp-style'), 'primary')

  category.value = 'people'
  form.dispatchEvent(new Event('change'))
  assert.equal(save.getAttribute('data-fp-style'), 'default')
})

test('reverting one of several edited fields keeps the form unsaved', async () => {
  const { controller, form, name, description, enabled, save } = buildForm()
  controller.connect()
  await settle()

  name.value = 'Grace'
  description.value = 'More notes'
  enabled.checked = false
  form.dispatchEvent(new Event('input'))
  assert.equal(save.getAttribute('data-fp-style'), 'primary')

  name.value = 'Ada'
  form.dispatchEvent(new Event('input'))
  assert.equal(save.getAttribute('data-fp-style'), 'primary')

  description.value = 'Notes'
  enabled.checked = true
  form.dispatchEvent(new Event('change'))
  assert.equal(save.getAttribute('data-fp-style'), 'default')
})

test('a radio change is unsaved until the original radio is selected again', async () => {
  const day = field('input', { name: 'profile[shift]', type: 'radio', value: 'day', checked: true })
  const night = field('input', { name: 'profile[shift]', type: 'radio', value: 'night', checked: false })
  const { controller, form, save } = buildForm([day, night])
  controller.connect()
  await settle()

  day.checked = false
  night.checked = true
  form.dispatchEvent(new Event('change'))
  assert.equal(save.getAttribute('data-fp-style'), 'primary')

  night.checked = false
  day.checked = true
  form.dispatchEvent(new Event('change'))
  assert.equal(save.getAttribute('data-fp-style'), 'default')
})

test('a hidden field that represents an editable control is part of the comparison', async () => {
  const hidden = field('input', { name: 'profile[category_id]', type: 'hidden', value: '7' })
  const { controller, form, save } = buildForm([hidden])
  controller.connect()
  await settle()

  hidden.value = '8'
  form.dispatchEvent(new Event('change'))
  assert.equal(save.getAttribute('data-fp-style'), 'primary')

  hidden.value = '7'
  form.dispatchEvent(new Event('change'))
  assert.equal(save.getAttribute('data-fp-style'), 'default')
})

test('rails bookkeeping fields do not mark the form unsaved', async () => {
  const { controller, form, token, save } = buildForm()
  controller.connect()
  await settle()

  token.value = 'rotated'
  form.dispatchEvent(new Event('input'))
  assert.equal(save.getAttribute('data-fp-style'), 'default')
})

test('form reset restores the saved style after the values revert', async () => {
  const { controller, form, name, enabled, save } = buildForm()
  form.addEventListener('reset', () => {
    name.value = 'Ada'
    enabled.checked = true
  })
  controller.connect()
  await settle()

  name.value = 'Grace'
  enabled.checked = false
  form.dispatchEvent(new Event('input'))
  assert.equal(save.getAttribute('data-fp-style'), 'primary')

  form.dispatchEvent(new Event('reset'))
  await new Promise((resolve) => queueMicrotask(resolve))
  assert.equal(save.getAttribute('data-fp-style'), 'default')
})

test('a reset that restores values on the next frame returns the saved style', async () => {
  const animationFrames = []
  const { controller, form, name, enabled, save } = buildForm([], { animationFrames })
  controller.connect()
  await settle()

  name.value = 'Grace'
  enabled.checked = false
  form.dispatchEvent(new Event('input'))
  assert.equal(save.getAttribute('data-fp-style'), 'primary')

  form.dispatchEvent(new Event('reset'))
  await new Promise((resolve) => queueMicrotask(resolve))
  assert.equal(name.value, 'Grace')
  assert.equal(enabled.checked, false)
  assert.equal(save.getAttribute('data-fp-style'), 'primary')

  name.value = 'Ada'
  enabled.checked = true
  animationFrames.splice(0, animationFrames.length).forEach((frame) => frame.callback())
  assert.equal(save.getAttribute('data-fp-style'), 'default')
})

test('a failed submission keeps the unsaved baseline', async () => {
  const { controller, form, name, save } = buildForm()
  controller.connect()
  await settle()

  name.value = 'Grace'
  form.dispatchEvent(new Event('input'))
  form.dispatchEvent(new CustomEvent('turbo:submit-end', { detail: { success: false } }))
  assert.equal(save.getAttribute('data-fp-style'), 'primary')

  name.value = 'Ada'
  form.dispatchEvent(new Event('input'))
  assert.equal(save.getAttribute('data-fp-style'), 'default')
})

test('a successful same-element submission adopts the current values as the saved baseline', async () => {
  const { controller, form, name, save } = buildForm()
  controller.connect()
  await settle()

  name.value = 'Grace'
  form.dispatchEvent(new Event('input'))
  assert.equal(save.getAttribute('data-fp-style'), 'primary')

  form.dispatchEvent(new CustomEvent('turbo:submit-end', { detail: { success: true } }))
  assert.equal(save.getAttribute('data-fp-style'), 'default')

  name.value = 'Ada'
  form.dispatchEvent(new Event('input'))
  assert.equal(save.getAttribute('data-fp-style'), 'primary')
})

test('style values replace the default and primary styles', async () => {
  const { controller, form, name, save } = buildForm()
  controller.savedStyleValue = 'secondary'
  controller.unsavedStyleValue = 'danger'
  controller.connect()
  await settle()

  assert.equal(save.getAttribute('data-fp-style'), 'secondary')

  name.value = 'Grace'
  form.dispatchEvent(new Event('input'))
  assert.equal(save.getAttribute('data-fp-style'), 'danger')
})
