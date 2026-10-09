const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

function loadController() {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'trash_button_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformedSource = source
    .replace('import { Controller } from "@hotwired/stimulus"', 'class Controller {}')
    .replace(
      'import { prefersReducedMotion, motionTransition } from "controllers/flat_pack/reduced_motion"',
      'function prefersReducedMotion() { return Boolean(globalThis.__reducedMotion) }\nfunction motionTransition(property) { return property + " 200ms var(--easing-standard)" }'
    )
    .replace('export default class extends Controller', 'class TrashButtonController extends Controller') + '\nmodule.exports = TrashButtonController\n'

  const listeners = { pointerdown: new Set(), keydown: new Set() }
  const document = {
    addEventListener(type, handler) {
      listeners[type]?.add(handler)
    },
    removeEventListener(type, handler) {
      listeners[type]?.delete(handler)
    }
  }

  const context = {
    module: { exports: {} },
    exports: {},
    document,
    CustomEvent: class {
      constructor(type, options = {}) {
        this.type = type
        this.bubbles = options.bubbles || false
        this.cancelable = options.cancelable || false
        this.detail = options.detail
        this.defaultPrevented = false
      }
      preventDefault() { this.defaultPrevented = true }
    },
    setTimeout,
    clearTimeout,
    requestAnimationFrame: (fn) => setTimeout(fn, 0),
    cancelAnimationFrame: (id) => clearTimeout(id),
    __reducedMotion: false
  }
  context.globalThis = context

  vm.runInNewContext(transformedSource, context, { filename: filePath })

  return { ControllerClass: context.module.exports, listeners, context }
}

function fakeButton() {
  const attributes = {}
  return {
    attributes,
    focused: false,
    style: {},
    offsetWidth: 40,
    getBoundingClientRect() { return { width: this.offsetWidth || 40 } },
    setAttribute(name, value) { attributes[name] = String(value) },
    removeAttribute(name) { delete attributes[name] },
    getAttribute(name) { return attributes[name] ?? null },
    focus() { this.focused = true },
    addEventListener() {},
    removeEventListener() {}
  }
}

function fakeNode({ offsetWidth = 40 } = {}) {
  const attributes = {}
  return {
    attributes,
    offsetWidth,
    style: {},
    contains() { return false },
    setAttribute(name, value) { attributes[name] = String(value) },
    removeAttribute(name) { delete attributes[name] },
    getAttribute(name) { return attributes[name] ?? null },
    getBoundingClientRect() { return { width: this.offsetWidth } },
    addEventListener() {},
    removeEventListener() {},
    querySelector() { return null }
  }
}

function buildController({ armed = false, timeout = 0, reducedMotion = false } = {}) {
  const { ControllerClass, listeners, context } = loadController()
  context.__reducedMotion = reducedMotion
  const controller = new ControllerClass()
  const events = []
  const arm = fakeButton()
  const confirm = fakeButton()
  const cancel = fakeButton()
  const rest = fakeNode()
  const armedNode = fakeNode()
  const cancelSlot = fakeNode()
  const live = { textContent: '' }
  const primary = fakeNode({ offsetWidth: armed ? 90 : 40 })
  const element = fakeNode()
  element.contains = (target) => target === arm || target === confirm || target === cancel
  element.dispatchEvent = (event) => { events.push(event); return true }
  const setAttribute = element.setAttribute.bind(element)
  element.setAttribute = (name, value) => {
    setAttribute(name, value)
    if (name === 'data-fp-armed') primary.offsetWidth = value === 'true' ? 90 : 40
  }

  controller.element = element
  controller.armTarget = arm
  controller.confirmTarget = confirm
  controller.cancelTarget = cancel
  controller.restTarget = rest
  controller.armedTarget = armedNode
  controller.cancelSlotTarget = cancelSlot
  controller.liveTarget = live
  controller.primaryTarget = primary
  controller.hasArmTarget = true
  controller.hasConfirmTarget = true
  controller.hasCancelTarget = true
  controller.hasRestTarget = true
  controller.hasArmedTarget = true
  controller.hasCancelSlotTarget = true
  controller.hasLiveTarget = true
  controller.hasPrimaryTarget = true
  controller.hasFormTarget = false
  controller.timeoutValue = timeout
  controller.expandValue = 'right'
  controller.armedAnnouncementValue = 'Confirm to delete'
  controller.restoredAnnouncementValue = 'Delete cancelled'
  controller.initialize()

  let armedValue = armed
  let skipping = true
  Object.defineProperty(controller, 'armedValue', {
    get() { return armedValue },
    set(value) {
      const previous = armedValue
      armedValue = value
      if (!skipping) controller.armedValueChanged(armedValue, previous)
    },
    configurable: true
  })
  controller.armedValueChanged(armedValue, undefined)
  skipping = false

  return { controller, arm, confirm, rest, armedNode, cancelSlot, live, primary, element, events, listeners }
}

test('arming swaps to confirm, focuses it, and announces', async () => {
  const { controller, arm, confirm, rest, armedNode, cancelSlot, live, element } = buildController()

  controller.arm({ preventDefault() {}, stopPropagation() {} })

  assert.equal(controller.armedValue, true)
  assert.equal(element.attributes['data-fp-armed'], 'true')
  assert.equal(rest.attributes.inert, '')
  assert.equal(armedNode.attributes.inert, undefined)
  assert.equal(cancelSlot.attributes.inert, undefined)
  assert.equal(confirm.focused, true)
  assert.equal(arm.attributes['aria-expanded'], 'true')
  assert.equal(controller.confirmBlocked, true)
  assert.equal(confirm.attributes['aria-disabled'], 'true')

  await new Promise((resolve) => setTimeout(resolve, 0))
  assert.equal(live.textContent, 'Confirm to delete')
})

test('confirm is ignored during the guard window', () => {
  const { controller, events } = buildController()
  controller.arm({ preventDefault() {}, stopPropagation() {} })

  let prevented = false
  controller.confirm({ preventDefault() { prevented = true } })

  assert.equal(prevented, true)
  assert.equal(events.length, 0)
})

test('confirm dispatches a cancelable event after the guard', async () => {
  const { controller, events } = buildController()
  controller.arm({ preventDefault() {}, stopPropagation() {} })

  await new Promise((resolve) => setTimeout(resolve, 310))

  let prevented = false
  controller.confirm({ preventDefault() { prevented = true } })

  assert.equal(prevented, false)
  assert.equal(events.length, 1)
  assert.equal(events[0].type, 'flat-pack:trash-button:confirm')
  assert.equal(events[0].cancelable, true)
})

test('preventing the confirm event blocks the native click', async () => {
  const { controller, element } = buildController()
  controller.arm({ preventDefault() {}, stopPropagation() {} })
  await new Promise((resolve) => setTimeout(resolve, 310))

  element.dispatchEvent = (event) => {
    event.preventDefault()
    return false
  }

  let prevented = false
  controller.confirm({ preventDefault() { prevented = true } })
  assert.equal(prevented, true)
})

test('cancel restores rest and focuses the trash button', async () => {
  const { controller, arm, live } = buildController()
  controller.arm({ preventDefault() {}, stopPropagation() {} })
  await new Promise((resolve) => setTimeout(resolve, 0))

  controller.cancel({ preventDefault() {} })

  assert.equal(controller.armedValue, false)
  assert.equal(arm.focused, true)
  assert.equal(arm.attributes['aria-expanded'], 'false')
  await new Promise((resolve) => setTimeout(resolve, 0))
  assert.equal(live.textContent, 'Delete cancelled')
})

test('escape and outside pointer restore rest', async () => {
  const { controller, arm, listeners } = buildController()
  controller.arm({ preventDefault() {}, stopPropagation() {} })
  await new Promise((resolve) => setTimeout(resolve, 0))
  arm.focused = false

  ;[...listeners.keydown].forEach((handler) => handler({ key: 'Escape', preventDefault() {} }))
  assert.equal(controller.armedValue, false)
  assert.equal(arm.focused, true)

  controller.arm({ preventDefault() {}, stopPropagation() {} })
  await new Promise((resolve) => setTimeout(resolve, 0))
  arm.focused = false

  ;[...listeners.pointerdown].forEach((handler) => handler({ target: {} }))
  assert.equal(controller.armedValue, false)
  assert.equal(arm.focused, true)
})

test('auto-revert disarms after the timeout', async () => {
  const { controller, arm } = buildController({ timeout: 20 })
  controller.arm({ preventDefault() {}, stopPropagation() {} })

  await new Promise((resolve) => setTimeout(resolve, 40))

  assert.equal(controller.armedValue, false)
  assert.equal(arm.focused, true)
})

test('reduced motion skips the width transition', () => {
  const { controller, primary } = buildController({ reducedMotion: true })
  primary.offsetWidth = 40
  controller.arm({ preventDefault() {}, stopPropagation() {} })

  assert.equal(primary.style.width, '')
  assert.equal(primary.style.transition, '')
})
