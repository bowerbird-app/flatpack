const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

function classListStub(initial = []) {
  const names = new Set(initial)
  return {
    names,
    contains(name) { return names.has(name) },
    add(...added) { added.forEach((name) => names.add(name)) },
    remove(...removed) { removed.forEach((name) => names.delete(name)) },
    toggle(name, force) {
      if (force === true) names.add(name)
      else if (force === false) names.delete(name)
      else if (names.has(name)) names.delete(name)
      else names.add(name)
      return names.has(name)
    }
  }
}

function loadController({ reducedMotion = false, motionMs = 200, extras = {} } = {}) {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'slide_indicator_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformedSource = source
    .replace('import { Controller } from "@hotwired/stimulus"', 'class Controller {}')
    .replace(
      'import { prefersReducedMotion, motionDuration, motionTransition } from "controllers/flat_pack/reduced_motion"',
      `function prefersReducedMotion() { return ${reducedMotion} }\nfunction motionDuration() { return ${reducedMotion ? 0 : motionMs} }\nfunction motionTransition() { return "transform var(--duration-base) var(--easing-standard)" }`
    )
    .replace('export default class extends Controller', 'class SlideIndicatorController extends Controller') + '\nmodule.exports = SlideIndicatorController\n'

  const context = {
    module: { exports: {} },
    exports: {},
    requestAnimationFrame: extras.requestAnimationFrame || ((fn) => { fn(); return 1 }),
    cancelAnimationFrame: extras.cancelAnimationFrame || (() => {}),
    setTimeout: extras.setTimeout || ((fn) => { fn(); return 1 }),
    clearTimeout: extras.clearTimeout || (() => {}),
    MutationObserver: extras.MutationObserver,
    ResizeObserver: extras.ResizeObserver,
    document: extras.document,
    ...(extras.globalThis || {})
  }

  vm.runInNewContext(transformedSource, context, { filename: filePath })
  return context.module.exports
}

function buildItem({
  left = 10,
  top = 4,
  width = 80,
  height = 32,
  role = 'tab',
  tagName = 'BUTTON',
  selected = false,
  current = false,
  href = '',
  target = '',
  classNames = [],
  activeClasses = '',
  inactiveClasses = ''
} = {}) {
  const attributes = {}
  if (selected) attributes['aria-selected'] = 'true'
  if (current) attributes['aria-current'] = 'page'
  const dataset = {
    flatPackSlideIndicatorActiveClasses: activeClasses,
    flatPackSlideIndicatorInactiveClasses: inactiveClasses
  }
  const item = {
    tagName,
    href,
    target,
    dataset,
    classList: classListStub(classNames),
    getAttribute(name) {
      if (name === 'role') return role
      if (name === 'href') return href
      if (name === 'download') return attributes.download
      return attributes[name] || null
    },
    setAttribute(name, value) { attributes[name] = String(value) },
    removeAttribute(name) { delete attributes[name] },
    hasAttribute(name) { return Object.prototype.hasOwnProperty.call(attributes, name) },
    contains(node) { return node === item },
    getBoundingClientRect() {
      return { left, top, width, height, right: left + width, bottom: top + height }
    }
  }
  return item
}

function buildController(options = {}) {
  const items = options.items || [
    buildItem({ selected: true, left: 8, width: 60 }),
    buildItem({ left: 76, width: 90 })
  ]
  const indicator = {
    classList: classListStub(),
    style: {},
    offsetWidth: 1
  }
  const listeners = { add: [], remove: [] }
  const observedResize = []
  const observedMutations = []
  const ResizeObserver = options.ResizeObserver || function (callback) {
    this.callback = callback
    this.observe = (node) => observedResize.push(node)
    this.disconnect = () => { this.disconnected = true }
  }
  const MutationObserver = options.MutationObserver || function (callback) {
    this.callback = callback
    this.observe = (node, init) => observedMutations.push({ node, init })
    this.disconnect = () => { this.disconnected = true }
  }

  const element = {
    classList: classListStub(),
    scrollLeft: options.scrollLeft || 0,
    scrollTop: options.scrollTop || 0,
    getBoundingClientRect() {
      return options.listRect || { left: 0, top: 0, width: 200, height: 40, right: 200, bottom: 40 }
    },
    addEventListener(type, handler, init) { listeners.add.push({ type, handler, init }) },
    removeEventListener(type, handler) { listeners.remove.push({ type, handler }) }
  }

  const globalThis = {
    Turbo: options.Turbo,
    location: options.location || { href: '' },
    document: options.document
  }

  const SlideIndicatorController = loadController({
    reducedMotion: options.reducedMotion,
    motionMs: options.motionMs,
    extras: {
      globalThis,
      ResizeObserver,
      MutationObserver,
      document: options.document,
      setTimeout: options.setTimeout,
      clearTimeout: options.clearTimeout,
      requestAnimationFrame: options.requestAnimationFrame,
      cancelAnimationFrame: options.cancelAnimationFrame
    }
  })

  const controller = Object.assign(new SlideIndicatorController(), {
    indicatorTarget: indicator,
    hasIndicatorTarget: true,
    itemTargets: items,
    kindValue: options.kind || 'pill',
    element
  })

  return { controller, indicator, items, element, listeners, observedResize, observedMutations, globalThis }
}

test('first sync is instant, writes geometry, and marks ready', () => {
  const { controller, indicator, element } = buildController({ kind: 'pill' })

  controller.sync({ animate: false })

  assert.equal(indicator.style.width, '60px')
  assert.equal(indicator.style.height, '32px')
  assert.equal(indicator.style.transform, 'translate(8px, 4px)')
  assert.equal(indicator.style.transition, 'none')
  assert.equal(indicator.classList.contains('is-ready'), true)
  assert.equal(element.classList.contains('is-ready'), true)
  assert.equal(indicator.classList.contains('is-instant'), true)
})

test('underline kind uses a 2px bar at the item bottom', () => {
  const { controller, indicator } = buildController({ kind: 'underline' })

  controller.sync({ animate: false })

  assert.equal(indicator.style.height, '2px')
  assert.equal(indicator.style.transform, 'translate(8px, 34px)')
})

test('later sync animates with the motion transition', () => {
  const { controller, indicator, items } = buildController({ kind: 'pill' })
  controller.sync({ animate: false })
  controller.sync({ animate: true, item: items[1] })

  assert.equal(indicator.style.transform, 'translate(76px, 4px)')
  assert.equal(indicator.style.width, '90px')
  assert.equal(indicator.style.transition, 'transform var(--duration-base) var(--easing-standard)')
  assert.equal(indicator.classList.contains('is-instant'), false)
})

test('reduced motion keeps later moves instant', () => {
  const { controller, indicator, items } = buildController({ kind: 'pill', reducedMotion: true })
  controller.sync({ animate: false })
  controller.sync({ animate: true, item: items[1] })

  assert.equal(indicator.style.transition, 'none')
  assert.equal(indicator.classList.contains('is-instant'), true)
})

test('measure includes list scroll offsets', () => {
  const { controller } = buildController({
    kind: 'pill',
    scrollLeft: 12,
    scrollTop: 5,
    listRect: { left: 2, top: 1, width: 200, height: 40 }
  })
  const box = controller.measure(controller.itemTargets[0])

  assert.equal(box.left, 18)
  assert.equal(box.top, 8)
})

test('tab clicks move the indicator and do not intercept', () => {
  const { controller, items, indicator } = buildController({ kind: 'underline' })
  controller.sync({ animate: false })
  let prevented = false

  controller.onClick({
    currentTarget: items[1],
    target: items[1],
    composedPath() { return [items[1]] },
    preventDefault() { prevented = true },
    button: 0
  })

  assert.equal(prevented, false)
  assert.equal(indicator.style.transform, 'translate(76px, 34px)')
})

test('left click on a link intercepts and visits after the wait', () => {
  const visits = []
  const timers = []
  const billing = buildItem({
    tagName: 'A',
    role: null,
    href: '/demo/buttons/pills?slide=billing',
    left: 76,
    width: 90,
    current: false,
    activeClasses: 'text-active',
    inactiveClasses: 'text-idle',
    classNames: ['text-idle']
  })
  billing.href = '/demo/buttons/pills?slide=billing'
  const account = buildItem({
    tagName: 'A',
    role: null,
    href: '/demo/buttons/pills?slide=account',
    left: 8,
    width: 60,
    current: true,
    activeClasses: 'text-active',
    inactiveClasses: 'text-idle',
    classNames: ['text-active']
  })
  account.href = '/demo/buttons/pills?slide=account'

  const { controller } = buildController({
    items: [account, billing],
    Turbo: { visit(url) { visits.push(url) } },
    motionMs: 200,
    setTimeout: (fn, ms) => { timers.push(ms); fn(); return 1 }
  })
  controller.sync({ animate: false })

  let prevented = false
  controller.onClick({
    target: billing,
    composedPath() { return [billing] },
    preventDefault() { prevented = true },
    button: 0
  })

  assert.equal(prevented, true)
  assert.equal(billing.getAttribute('aria-current'), 'page')
  assert.equal(account.getAttribute('aria-current'), null)
  assert.deepEqual(visits, ['/demo/buttons/pills?slide=billing'])
  assert.deepEqual(timers, [200])
})

test('modifier clicks and target=_blank are not intercepted', () => {
  const visits = []
  const item = buildItem({ tagName: 'A', role: null, href: '/go', left: 8, width: 60 })
  item.href = '/go'
  const blank = buildItem({ tagName: 'A', role: null, href: '/go', target: '_blank', left: 76, width: 90 })
  blank.href = '/go'
  blank.target = '_blank'

  const { controller } = buildController({
    items: [item, blank],
    Turbo: { visit(url) { visits.push(url) } }
  })
  controller.sync({ animate: false })

  const clicks = [
    { target: item, metaKey: true },
    { target: item, ctrlKey: true },
    { target: item, shiftKey: true },
    { target: item, altKey: true },
    { target: item, button: 1 },
    { target: blank, button: 0 }
  ]

  clicks.forEach((extra) => {
    let prevented = false
    controller.onClick({
      composedPath() { return [extra.target] },
      preventDefault() { prevented = true },
      button: extra.button ?? 0,
      metaKey: extra.metaKey,
      ctrlKey: extra.ctrlKey,
      shiftKey: extra.shiftKey,
      altKey: extra.altKey,
      target: extra.target
    })
    assert.equal(prevented, false)
  })

  assert.deepEqual(visits, [])
})

test('falls back to location when Turbo is missing', () => {
  const location = { href: '/old' }
  const item = buildItem({ tagName: 'A', role: null, href: '/next', left: 8, width: 60, current: true })
  item.href = '/next'
  const other = buildItem({ tagName: 'A', role: null, href: '/other', left: 76, width: 90 })
  other.href = '/other'

  const { controller } = buildController({
    items: [item, other],
    location,
    reducedMotion: true
  })
  controller.sync({ animate: false })
  controller.onClick({
    target: other,
    composedPath() { return [other] },
    preventDefault() {},
    button: 0
  })

  assert.equal(location.href, '/other')
})

test('connect observes resize, mutations, click, and scroll', () => {
  const { controller, listeners, observedResize, observedMutations, items, element } = buildController({
    document: { fonts: { ready: Promise.resolve() } }
  })

  controller.connect()

  assert.equal(listeners.add.some((entry) => entry.type === 'click'), true)
  assert.equal(listeners.add.some((entry) => entry.type === 'scroll'), true)
  assert.equal(observedResize.includes(element), true)
  assert.equal(observedResize.includes(items[0]), true)
  assert.equal(observedMutations.length, items.length)
  assert.equal(element.classList.contains('is-ready'), true)
})

test('disconnect removes listeners and observers', () => {
  const { controller, listeners } = buildController()
  controller.visitTimer = 9
  controller.frame = 3
  controller.mutationObserver = { disconnect() { this.disconnected = true } }
  controller.resizeObserver = { disconnect() { this.disconnected = true } }

  controller.disconnect()

  assert.equal(listeners.remove.some((entry) => entry.type === 'click'), true)
  assert.equal(controller.mutationObserver.disconnected, true)
  assert.equal(controller.resizeObserver.disconnected, true)
  assert.equal(controller.visitTimer, null)
  assert.equal(controller.frame, null)
})
