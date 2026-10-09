const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

function loadFabController(documentStub, windowStub, { reduced = false } = {}) {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'fab_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformedSource = source
    .replace('import { Controller } from "@hotwired/stimulus"', 'class Controller {}')
    .replace(
      'import { prefersReducedMotion, motionDuration, motionTransition } from "controllers/flat_pack/reduced_motion"',
      `function prefersReducedMotion() { return ${reduced} }\nfunction motionDuration() { return ${reduced ? 0 : 150} }\nfunction motionTransition() { return "opacity 150ms linear" }`
    )
    .replace('export default class extends Controller', 'class FabController extends Controller') + '\nmodule.exports = FabController\n'

  const context = {
    module: { exports: {} },
    exports: {},
    document: documentStub,
    window: windowStub,
    requestAnimationFrame: (fn) => fn()
  }

  vm.runInNewContext(transformedSource, context, { filename: filePath })
  return context.module.exports
}

function classListStub(initial = []) {
  const names = new Set(initial)
  return {
    contains(name) { return names.has(name) },
    add(name) { names.add(name) },
    remove(name) { names.delete(name) }
  }
}

function actionStub() {
  return {
    tabIndex: -1,
    focused: false,
    style: {},
    focus() { this.focused = true }
  }
}

function buildController({ reduced = false, hideOnScroll = false, contained = false } = {}) {
  const actions = [actionStub(), actionStub(), actionStub()]
  const trigger = {
    attributes: { 'aria-expanded': 'false' },
    focused: false,
    setAttribute(name, value) { this.attributes[name] = value },
    focus() { this.focused = true }
  }
  const menu = {
    hidden: true,
    attributes: {},
    setAttribute(name, value) { this.attributes[name] = value },
    removeAttribute(name) { delete this.attributes[name] },
    addEventListener() {},
    removeEventListener() {}
  }
  const backdrop = { style: {}, dataset: {} }
  const nav = { getBoundingClientRect() { return { height: 64 } } }
  const documentStub = {
    activeElement: null,
    addEventListener() {},
    removeEventListener() {},
    querySelector(selector) { return selector === '.fp-bottom-nav' ? nav : null }
  }
  const windowStub = {
    scrollY: 0,
    setTimeout(fn) { fn(); return 1 },
    clearTimeout() {}
  }
  const FabController = loadFabController(documentStub, windowStub, { reduced })
  const element = {
    dataset: { fpPosition: 'bottom_right' },
    style: {
      props: {},
      setProperty(name, value) { this.props[name] = value },
      removeProperty(name) { delete this.props[name] }
    },
    classList: classListStub(contained ? ['fp-fab--contained'] : ['fp-fab--viewport']),
    offsetParent: { querySelector(selector) { return selector === '.fp-bottom-nav' ? nav : null } },
    contains() { return false }
  }

  const controller = Object.assign(new FabController(), {
    element,
    hasMenuTarget: true,
    hasBackdropTarget: true,
    triggerTarget: trigger,
    menuTarget: menu,
    backdropTarget: backdrop,
    actionTargets: actions,
    layoutValue: 'stack',
    hideOnScrollValue: hideOnScroll
  })

  return { controller, trigger, menu, actions, backdrop, documentStub, element, windowStub }
}

test('connect measures bottom nav offset and collapses actions', () => {
  const { controller, actions, element } = buildController()
  controller.connect()

  assert.equal(element.style.props['--fp-fab-nav-offset'], '64px')
  actions.forEach((action) => {
    assert.equal(action.tabIndex, -1)
    assert.equal(action.style.opacity, '0')
    assert.equal(action.style.transform, 'translateY(12px) scale(0.8)')
  })
})

test('connect without a menu does not throw', () => {
  const { controller } = buildController()
  controller.hasMenuTarget = false

  assert.doesNotThrow(() => controller.connect())
})

test('top corners hide actions downward and skip nav offset', () => {
  const { controller, actions, element } = buildController()
  element.dataset.fpPosition = 'top_left'
  controller.connect()

  assert.equal(element.style.props['--fp-fab-nav-offset'], undefined)
  assert.equal(actions[0].style.transform, 'translateY(-12px) scale(0.8)')
})

test('close from a DOM event still restores focus', () => {
  const { controller, trigger } = buildController()
  controller.connect()
  controller.open()
  trigger.focused = false
  controller.close({ type: 'click' })

  assert.equal(controller.openState, false)
  assert.equal(trigger.focused, true)
})

test('open expands, focuses the first action, and shows the backdrop', () => {
  const { controller, trigger, menu, actions, backdrop } = buildController()
  controller.connect()
  controller.open()

  assert.equal(controller.openState, true)
  assert.equal(trigger.attributes['aria-expanded'], 'true')
  assert.equal(menu.hidden, false)
  assert.equal(actions[0].focused, true)
  assert.equal(actions[0].tabIndex, 0)
  assert.equal(actions[0].style.opacity, '1')
  assert.equal(backdrop.style.opacity, '1')
  assert.equal(actions[1].style.transitionDelay, '30ms')
})

test('close reverses and restores focus to the trigger', () => {
  const { controller, trigger, menu, actions } = buildController()
  controller.connect()
  controller.open()
  controller.close()

  assert.equal(controller.openState, false)
  assert.equal(trigger.attributes['aria-expanded'], 'false')
  assert.equal(trigger.focused, true)
  assert.equal(menu.hidden, true)
  assert.equal(actions[0].tabIndex, -1)
  assert.equal(actions[0].style.transitionDelay, '60ms')
})

test('choose closes without restoring focus', () => {
  const { controller, trigger } = buildController()
  controller.connect()
  controller.open()
  trigger.focused = false
  controller.choose()

  assert.equal(controller.openState, false)
  assert.equal(trigger.focused, false)
})

test('arrow keys move between actions', () => {
  const { controller, actions, documentStub } = buildController()
  controller.connect()
  controller.open()
  documentStub.activeElement = actions[0]
  controller.handleMenuKeydown({ key: 'ArrowDown', preventDefault() { this.prevented = true } })

  assert.equal(actions[1].focused, true)
})

test('shift-tab on the first action returns to the trigger', () => {
  const { controller, actions, trigger, documentStub } = buildController()
  controller.connect()
  controller.open()
  documentStub.activeElement = actions[0]
  const event = { key: 'Tab', shiftKey: true, preventDefault() { this.prevented = true } }
  controller.handleMenuKeydown(event)

  assert.equal(event.prevented, true)
  assert.equal(trigger.focused, true)
})

test('reduced motion skips action travel', () => {
  const { controller, actions } = buildController({ reduced: true })
  controller.connect()
  controller.open()

  assert.equal(actions[0].style.transform, 'none')
  assert.equal(actions[1].style.transitionDelay, '0ms')
})

test('scroll down hides and scroll up shows', () => {
  const { controller, element, windowStub } = buildController({ hideOnScroll: true })
  controller.connect()

  windowStub.scrollY = 40
  controller.onScroll()
  assert.equal(element.dataset.fpScrollHidden, 'true')

  windowStub.scrollY = 10
  controller.onScroll()
  assert.equal(element.dataset.fpScrollHidden, undefined)
})
