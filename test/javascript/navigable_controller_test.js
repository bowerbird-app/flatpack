const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

class FakeClassList {
  constructor(initial = []) {
    this.names = new Set(initial)
  }

  contains(name) { return this.names.has(name) }
  add(...added) { added.forEach((name) => this.names.add(name)) }
  remove(...removed) { removed.forEach((name) => this.names.delete(name)) }
}

class FakeNode {
  constructor(tagName = 'div', attributes = {}) {
    this.tagName = tagName.toUpperCase()
    this.attributes = {...attributes}
    this.children = []
    this.childNodes = this.children
    this.parentNode = null
    this.hidden = Boolean(attributes.hidden)
    this.disabled = Boolean(attributes.disabled)
    this.dataset = attributes.dataset || {}
    this.listeners = {}
    this.focused = false
    this.src = attributes.src || ''
  }

  getAttribute(name) {
    if (name === 'src') return this.src || this.attributes.src || null
    if (Object.prototype.hasOwnProperty.call(this.attributes, name)) return this.attributes[name]
    return null
  }

  setAttribute(name, value) {
    this.attributes[name] = String(value)
    if (name === 'src') this.src = String(value)
  }

  removeAttribute(name) {
    delete this.attributes[name]
    if (name === 'src') this.src = ''
  }

  hasAttribute(name) {
    return Object.prototype.hasOwnProperty.call(this.attributes, name)
  }

  appendChild(node) {
    node.parentNode = this
    this.children.push(node)
    return node
  }

  replaceChildren(...nodes) {
    this.children.splice(0, this.children.length, ...nodes)
    this.children.forEach((node) => { node.parentNode = this })
  }

  querySelector(selector) {
    return this.querySelectorAll(selector)[0] || null
  }

  querySelectorAll(selector) {
    const matches = []
    const visit = (node) => {
      if (node.matches && node.matches(selector)) matches.push(node)
      ;(node.children || []).forEach(visit)
    }
    ;(this.children || []).forEach(visit)
    return matches
  }

  matches(selector) {
    if (selector === '[data-fp-nav]') return Boolean(this.dataset.fpNav || this.attributes['data-fp-nav'])
    if (selector === '[data-fp-screen]') return Boolean(this.dataset.fpScreen || this.attributes['data-fp-screen'])
    if (selector === '[data-fp-screen-header-actions]' || selector === '[data-fp-screen-header-actions]') {
      return this.hasAttribute('data-fp-screen-header-actions')
    }
    if (selector === '[data-fp-screen-footer]') return this.hasAttribute('data-fp-screen-footer')
    if (selector.startsWith('[data-fp-nav=')) {
      const nav = selector.match(/data-fp-nav="([^"]+)"/)[1]
      const hrefMatch = selector.match(/href="([^"]+)"/)
      if (this.dataset.fpNav !== nav) return false
      if (hrefMatch) return this.getAttribute('href') === hrefMatch[1]
      return true
    }
    if (selector.startsWith('[href=')) {
      const href = selector.match(/href="([^"]+)"/)[1]
      return this.getAttribute('href') === href
    }
    if (selector.includes('button') && this.tagName === 'BUTTON') return true
    if (selector.includes('[data-fp-nav=\'retry\']') && this.dataset.fpNav === 'retry') return true
    if (selector.startsWith('a[href]') && this.tagName === 'A' && this.getAttribute('href')) return true
    return false
  }

  closest(selector) {
    let node = this
    while (node) {
      if (node.matches && node.matches(selector)) return node
      node = node.parentNode
    }
    return null
  }

  contains(node) {
    let current = node
    while (current) {
      if (current === this) return true
      current = current.parentNode
    }
    return false
  }

  focus() { this.focused = true }

  addEventListener(type, handler) {
    this.listeners[type] = this.listeners[type] || []
    this.listeners[type].push(handler)
  }

  dispatchEvent(event) {
    ;(this.listeners[event.type] || []).forEach((handler) => handler(event))
    return true
  }
}

function loadController() {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'navigable_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformedSource = source
    .replace('import { Controller } from "@hotwired/stimulus"', 'class Controller {}')
    .replace('export default class extends Controller', 'class NavigableController extends Controller') + '\nmodule.exports = NavigableController\n'

  const context = {
    module: { exports: {} },
    exports: {},
    window: { location: { origin: 'http://example.test' } },
    URL,
    CustomEvent,
    MutationObserver: class {
      observe() {}
      disconnect() {}
    }
  }

  vm.runInNewContext(transformedSource, context, { filename: filePath })
  return context.module.exports
}

function buildController() {
  const NavigableController = loadController()
  const frame = new FakeNode('turbo-frame', {id: 'gallery-editor-screen', src: '/gallery'})
  const title = new FakeNode('h2')
  title.textContent = 'Gallery'
  const backButton = new FakeNode('button', {hidden: true, disabled: true})
  const headerActions = new FakeNode('div')
  const footer = new FakeNode('div', {hidden: true})
  const loading = new FakeNode('div', {hidden: true})
  const error = new FakeNode('div', {hidden: true})
  const retry = new FakeNode('button', {dataset: {fpNav: 'retry'}})
  error.appendChild(retry)
  const liveRegion = new FakeNode('div')
  const element = new FakeNode('div')
  element.attributes['aria-hidden'] = 'true'
  element.classList = new FakeClassList(['hidden'])
  element.appendChild(frame)
  element.appendChild(title)
  element.appendChild(backButton)
  element.appendChild(headerActions)
  element.appendChild(footer)
  element.appendChild(loading)
  element.appendChild(error)
  element.appendChild(liveRegion)

  const historyCalls = []
  const originalPush = globalThis.history && globalThis.history.pushState
  if (typeof globalThis.history === 'object') {
    globalThis.history.pushState = (...args) => { historyCalls.push(args) }
  }

  const controller = Object.assign(new NavigableController(), {
    hasFrameTarget: true,
    frameTarget: frame,
    hasTitleTarget: true,
    titleTarget: title,
    hasBackButtonTarget: true,
    backButtonTarget: backButton,
    hasHeaderActionsTarget: true,
    headerActionsTarget: headerActions,
    hasFooterTarget: true,
    footerTarget: footer,
    hasLoadingTarget: true,
    loadingTarget: loading,
    hasErrorTarget: true,
    errorTarget: error,
    hasLiveRegionTarget: true,
    liveRegionTarget: liveRegion,
    srcValue: '/gallery',
    element,
    application: null
  })

  controller.connect()

  return {controller, frame, title, backButton, loading, error, footer, liveRegion, element, historyCalls, originalPush}
}

function screenNode(title, options = {}) {
  const screen = new FakeNode('div')
  screen.dataset.fpScreen = true
  screen.attributes['data-fp-screen'] = 'true'
  screen.setAttribute('data-title', title)
  screen.getAttribute = (name) => {
    if (name === 'data-title') return title
    if (name === 'data-fp-screen') return 'true'
    return FakeNode.prototype.getAttribute.call(screen, name)
  }

  if (options.footer) {
    const footer = new FakeNode('div')
    footer.setAttribute('data-fp-screen-footer', 'true')
    footer.appendChild(options.footer)
    screen.appendChild(footer)
  }
  return screen
}

test('push records history, shows the back button, and skips duplicate consecutive urls', () => {
  const {controller, backButton} = buildController()

  controller.applyHistory('/gallery/1', 'push')
  assert.equal(controller.stack.length, 1)
  assert.equal(controller.currentUrl, '/gallery/1')
  assert.equal(backButton.hidden, false)
  assert.equal(backButton.disabled, false)

  controller.applyHistory('/gallery/1', 'push')
  assert.equal(controller.stack.length, 1)

  controller.applyHistory('/gallery/1/photographer', 'push')
  assert.equal(controller.stack.length, 2)
  assert.equal(controller.currentUrl, '/gallery/1/photographer')
})

test('back pops history, re-visits the previous url, and hides the back button at the root', () => {
  const {controller, frame, backButton} = buildController()
  controller.applyHistory('/gallery/1', 'push')
  controller.applyHistory('/gallery/1/photographer', 'push')

  controller.back()

  assert.equal(controller.stack.length, 1)
  assert.equal(controller.currentUrl, '/gallery/1')
  assert.equal(frame.src, '/gallery/1')
  assert.equal(backButton.hidden, false)

  controller.back()
  assert.equal(controller.stack.length, 0)
  assert.equal(controller.currentUrl, '/gallery')
  assert.equal(frame.src, '/gallery')
  assert.equal(backButton.hidden, true)
})

test('close and onClosed clear history and reset the frame to src', () => {
  const {controller, frame, backButton} = buildController()
  controller.applyHistory('/gallery/1', 'push')

  controller.onClosed()

  assert.equal(controller.stack.length, 0)
  assert.equal(controller.currentUrl, '/gallery')
  assert.equal(backButton.hidden, true)
  assert.equal(frame.getAttribute('src'), '/gallery')
  assert.equal(frame.hasAttribute('complete'), false)
})

test('title, live region, and footer update from the current screen', () => {
  const {controller, frame, title, liveRegion, footer} = buildController()
  const save = new FakeNode('button')
  save.textContent = 'Save'
  frame.appendChild(screenNode('Edit image', {footer: save}))

  controller.applyScreenChrome()

  assert.equal(title.textContent, 'Edit image')
  assert.equal(liveRegion.textContent, 'Edit image')
  assert.equal(footer.hidden, false)
  assert.equal(footer.children[0], save)
})

test('failed responses and missing frames show the error state', () => {
  const {controller, error, loading, frame} = buildController()
  frame.attributes.id = 'gallery-editor-screen'

  controller.onBeforeFetchResponse({
    target: frame,
    preventDefault() { this.prevented = true },
    detail: {
      fetchOptions: {headers: {'Turbo-Frame': 'gallery-editor-screen'}},
      fetchResponse: {response: {ok: false, status: 500}}
    }
  })

  assert.equal(error.hidden, false)
  assert.equal(loading.hidden, true)

  controller.hideError()
  controller.onFrameMissing({target: frame, preventDefault() { this.prevented = true }})
  assert.equal(error.hidden, false)
})

test('replace and reset do not grow the stack', () => {
  const {controller} = buildController()
  controller.applyHistory('/gallery/1', 'push')
  controller.applyHistory('/gallery/1?updated=1', 'replace')
  assert.equal(controller.stack.length, 1)
  assert.equal(controller.currentUrl, '/gallery/1?updated=1')

  controller.applyHistory('/gallery', 'reset')
  assert.equal(controller.stack.length, 0)
  assert.equal(controller.currentUrl, '/gallery')
})

test('clicking push preventDefaults and visits without pushState', () => {
  const {controller, frame, element} = buildController()
  const link = new FakeNode('a', {dataset: {fpNav: 'push'}})
  link.setAttribute('href', '/gallery/1')
  link.dataset.fpNav = 'push'
  frame.appendChild(link)

  const event = {
    target: link,
    prevented: false,
    preventDefault() { this.prevented = true }
  }

  const source = fs.readFileSync(path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'navigable_controller.js'), 'utf8')
  assert.equal(source.includes('pushState'), false)
  assert.equal(source.includes('replaceState'), false)

  controller.onClick(event)
  assert.equal(event.prevented, true)
  assert.equal(frame.src, '/gallery/1')
  assert.equal(element.contains(link), true)
})

test('before-visit can cancel navigation', () => {
  const {controller, frame} = buildController()
  controller.element.addEventListener('flat-pack:navigable:before-visit', (event) => event.preventDefault())

  controller.navigate('/gallery/1', 'push')
  assert.equal(frame.src, '/gallery')
  assert.equal(controller.stack.length, 0)
})
