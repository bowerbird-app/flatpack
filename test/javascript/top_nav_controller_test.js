const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

function loadTopNavController(globals) {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'top_nav_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformedSource = source
    .replace('import { Controller } from "@hotwired/stimulus"', 'class Controller {}')
    .replace('export default class extends Controller', 'class TopNavController extends Controller') + '\nmodule.exports = TopNavController\n'

  const context = {
    module: {exports: {}},
    exports: {},
    Node: {TEXT_NODE: 3, ELEMENT_NODE: 1},
    ...globals
  }

  vm.runInNewContext(transformedSource, context, {filename: filePath})

  return context.module.exports
}

function buildFrostController({
  windowScrollY = 0,
  siblingOverflow = null,
  siblingScrollTop = 0
} = {}) {
  const listeners = []
  const dataset = {}
  const sibling = siblingOverflow
    ? {
      nodeType: 1,
      scrollTop: siblingScrollTop,
      addEventListener(type, fn) {
        listeners.push({target: this, type, fn})
      },
      removeEventListener(type, fn) {
        const index = listeners.findIndex((entry) => entry.target === this && entry.type === type && entry.fn === fn)
        if (index >= 0) listeners.splice(index, 1)
      }
    }
    : null

  const parent = {
    nodeType: 1,
    parentElement: null
  }

  const element = {
    dataset,
    nextElementSibling: sibling,
    parentElement: parent
  }

  const windowStub = {
    scrollY: windowScrollY,
    addEventListener(type, fn) {
      listeners.push({target: 'window', type, fn})
    },
    removeEventListener(type, fn) {
      const index = listeners.findIndex((entry) => entry.target === 'window' && entry.type === type && entry.fn === fn)
      if (index >= 0) listeners.splice(index, 1)
    },
    getComputedStyle(node) {
      if (node === sibling) return {overflowY: siblingOverflow}
      return {overflowY: 'visible'}
    }
  }

  const documentStub = {
    body: {},
    documentElement: {scrollTop: 0},
    addEventListener() {},
    removeEventListener() {}
  }

  const TopNavController = loadTopNavController({window: windowStub, document: documentStub})
  const controller = Object.assign(new TopNavController(), {
    hasPanelTarget: false,
    hasMenuTarget: false,
    hasToggleTarget: false,
    element,
    sectionTargets: []
  })

  return {controller, dataset, listeners, windowStub, sibling}
}

test('frost stays off at rest', () => {
  const {controller, dataset} = buildFrostController()

  controller.connect()

  assert.equal(dataset.scrolled, 'false')
})

test('window scroll turns frost on', () => {
  const {controller, dataset, listeners, windowStub} = buildFrostController()

  controller.connect()
  windowStub.scrollY = 24
  const scroll = listeners.find((entry) => entry.target === 'window' && entry.type === 'scroll')
  scroll.fn()

  assert.equal(dataset.scrolled, 'true')
})

test('a sibling overflow pane frosts the bar when window has not scrolled', () => {
  const {controller, dataset, listeners, sibling} = buildFrostController({
    siblingOverflow: 'auto',
    siblingScrollTop: 0
  })

  controller.connect()
  sibling.scrollTop = 40
  const scroll = listeners.find((entry) => entry.target === sibling && entry.type === 'scroll')
  scroll.fn()

  assert.equal(dataset.scrolled, 'true')
})

test('page scroll listens only to the window', () => {
  const {controller, listeners, sibling} = buildFrostController({
    siblingOverflow: 'auto',
    siblingScrollTop: 12
  })
  controller.element.closest = () => ({ dataset: { flatPackLayoutScroll: 'page' } })

  controller.connect()

  assert.equal(listeners.length, 1)
  assert.equal(listeners[0].target, 'window')
  assert.equal(listeners[0].type, 'scroll')
  assert.equal(listeners.some((entry) => entry.target === sibling), false)
})

test('disconnect removes scroll listeners', () => {
  const {controller, listeners} = buildFrostController({siblingOverflow: 'auto'})

  controller.connect()
  assert.ok(listeners.length > 0)

  controller.disconnect()

  assert.equal(listeners.length, 0)
})

function buildFitController({clientWidth, scrollWidth, viewportNarrow = false}) {
  const child = {nodeType: 1, dataset: {}, childNodes: []}
  const sectionChildren = [child]
  const section = {
    dataset: {flatPackTopNavCollapsible: 'true'},
    childNodes: sectionChildren,
    classList: {toggle() {}, remove() {}},
    insertBefore(node, before) {
      node.parentNode = section
      sectionChildren.splice(sectionChildren.indexOf(before), 0, node)
    },
    replaceChild(node, placeholder) {
      if (node.parentNode && node.parentNode.removeChild) node.parentNode.removeChild(node)
      sectionChildren.splice(sectionChildren.indexOf(placeholder), 1, node)
      node.parentNode = section
    }
  }
  const panelChildren = []
  const panel = {
    children: panelChildren,
    hidden: true,
    appendChild(node) {
      const index = sectionChildren.indexOf(node)
      if (index >= 0) sectionChildren.splice(index, 1)
      node.parentNode = panel
      panelChildren.push(node)
    },
    removeChild(node) {
      const index = panelChildren.indexOf(node)
      if (index >= 0) panelChildren.splice(index, 1)
    }
  }
  const menu = {classList: {toggle() {}}}
  const bar = {clientWidth, scrollWidth, dataset: {}}
  const TopNavController = loadTopNavController({
    window: {},
    document: {createComment() { return {nodeType: 8} }},
    Node: {TEXT_NODE: 3, ELEMENT_NODE: 1}
  })

  return {
    bar,
    child,
    sectionChildren,
    panelChildren,
    controller: Object.assign(new TopNavController(), {
      element: bar,
      mediaQuery: {matches: viewportNarrow},
      hasPanelTarget: true,
      hasMenuTarget: true,
      hasToggleTarget: false,
      sectionTargets: [section],
      panelTarget: panel,
      menuTarget: menu,
      movedNodes: [],
      breakpointValue: 768,
      fitting: false,
      menuOpen: false
    })
  }
}

test('a wide window keeps the row even when the bar is narrow', () => {
  const {controller, panelChildren, sectionChildren, child} = buildFitController({
    clientWidth: 400,
    scrollWidth: 640
  })

  controller.applyLayout()

  assert.equal(panelChildren.length, 0)
  assert.equal(sectionChildren[0], child)
})

test('a phone folds a collapsible section into the menu', () => {
  const {controller, panelChildren, sectionChildren, child} = buildFitController({
    clientWidth: 390,
    scrollWidth: 640,
    viewportNarrow: true
  })

  controller.applyLayout()

  assert.equal(panelChildren.length, 1)
  assert.equal(panelChildren[0], child)
  assert.equal(sectionChildren.includes(child), false)
})

test('a phone discloses a dropdown in place and restores it', () => {
  const {controller, doc, sectionChildren, publish, publishTrigger, publishMenu, moreMenu, publishNow, duplicate} = buildMenuTree()

  controller.applyLayout()

  assert.equal(publish.dataset.flatPackTopNavDisclosure, 'true')
  assert.equal(publish.dataset.flatPackTopNavExpanded, 'false')
  assert.equal(publishTrigger.getAttribute('aria-expanded'), 'false')
  assert.equal(publishTrigger.getAttribute('aria-controls'), publishMenu.id)
  assert.equal(publishMenu.getAttribute('role'), 'group')
  assert.equal(publishMenu.getAttribute('aria-hidden'), 'true')
  assert.equal(publishMenu.children.includes(publishNow), true)
  assert.equal(moreMenu.children.includes(duplicate), true)

  publishTrigger.click()
  assert.equal(publishTrigger.getAttribute('aria-expanded'), 'true')
  assert.equal(publish.dataset.flatPackTopNavExpanded, 'true')
  assert.equal(publishMenu.getAttribute('aria-hidden'), 'false')
  assert.equal(publishMenu.children.includes(publishNow), true)

  doc.activeElement = publishNow
  publishTrigger.click()
  assert.equal(publishTrigger.getAttribute('aria-expanded'), 'false')
  assert.equal(publishMenu.getAttribute('aria-hidden'), 'true')
  assert.equal(publishTrigger.focused, true)

  publishTrigger.click()
  controller.closeMenu()
  assert.equal(publish.dataset.flatPackTopNavExpanded, 'false')

  controller.mediaQuery.matches = false
  controller.applyLayout()

  assert.equal(publish.dataset.flatPackTopNavDisclosure, undefined)
  assert.equal(publishMenu.getAttribute('role'), 'menu')
  assert.equal(publishMenu.getAttribute('aria-hidden'), 'true')
  assert.equal(publishTrigger.getAttribute('aria-controls'), null)
  assert.equal(publishTrigger.listeners.length, 0)
  assert.deepEqual(publishMenu.children.map((node) => node.text), ['Publish now', 'Schedule'])
  assert.equal(sectionChildren[0].nodeName, 'page-nav')
})

function element(name, {dataset = {}, text = ''} = {}) {
  const node = {
    nodeType: 1,
    nodeName: name,
    text,
    textContent: text,
    hidden: false,
    id: '',
    dataset,
    attributes: {},
    listeners: [],
    childNodes: [],
    getAttribute(name) {
      return Object.prototype.hasOwnProperty.call(this.attributes, name) ? this.attributes[name] : null
    },
    setAttribute(name, value) {
      this.attributes[name] = String(value)
    },
    removeAttribute(name) {
      delete this.attributes[name]
    },
    addEventListener(type, fn, capture) {
      this.listeners.push({type, fn, capture: !!capture})
    },
    removeEventListener(type, fn) {
      this.listeners = this.listeners.filter((listener) => listener.fn !== fn || listener.type !== type)
    },
    click() {
      const event = {
        preventDefault() {},
        stopPropagation() {},
        stopImmediatePropagation() {}
      }
      this.listeners.filter((listener) => listener.type === 'click' && listener.capture).forEach((listener) => listener.fn(event))
    },
    contains(other) {
      if (!other) return false
      if (other === this) return true
      return this.children.some((child) => typeof child.contains === 'function' && child.contains(other))
    },
    focus() {
      this.focused = true
    },
    get children() {
      return this.childNodes.filter((child) => child.nodeType === 1)
    },
    appendChild(child) {
      if (child.parentNode && child.parentNode.removeChild) child.parentNode.removeChild(child)
      child.parentNode = this
      this.childNodes.push(child)
      return child
    },
    insertBefore(child, before) {
      if (child.parentNode && child.parentNode.removeChild) child.parentNode.removeChild(child)
      child.parentNode = this
      const index = this.childNodes.indexOf(before)
      this.childNodes.splice(index < 0 ? this.childNodes.length : index, 0, child)
      return child
    },
    removeChild(child) {
      const index = this.childNodes.indexOf(child)
      if (index >= 0) this.childNodes.splice(index, 1)
      if (child.parentNode === this) child.parentNode = null
      return child
    },
    querySelector(selector) {
      return this.querySelectorAll(selector)[0] || null
    },
    querySelectorAll(selector) {
      const matches = []
      const walk = (current) => {
        current.children.forEach((child) => {
          if (selectorMatches(child, selector)) matches.push(child)
          walk(child)
        })
      }
      walk(this)
      return matches
    }
  }
  return node
}

function selectorMatches(node, selector) {
  if (selector === "[data-controller~='flat-pack--button-dropdown']") {
    return (node.dataset.controller || '').split(/\s+/).includes('flat-pack--button-dropdown')
  }
  if (selector === "[data-flat-pack--button-dropdown-target='trigger']") {
    return node.dataset.flatPackButtonDropdownTarget === 'trigger'
  }

  return node.dataset.flatPackButtonDropdownTarget === 'menu'
}

function buildMenuTree() {
  const sectionButton = element('button', {text: 'Section'})
  const publishNow = element('button', {text: 'Publish now'})
  const schedule = element('button', {text: 'Schedule'})
  const duplicate = element('button', {text: 'Duplicate'})
  const archive = element('button', {text: 'Archive'})
  const publishMenu = element('div', {dataset: {flatPackButtonDropdownTarget: 'menu'}})
  publishMenu.setAttribute('role', 'menu')
  publishMenu.setAttribute('aria-hidden', 'true')
  publishMenu.appendChild(publishNow)
  publishMenu.appendChild(schedule)
  const publishTrigger = element('button', {text: 'Publish', dataset: {flatPackButtonDropdownTarget: 'trigger'}})
  const publish = element('div', {dataset: {controller: 'flat-pack--button-dropdown'}})
  publish.appendChild(publishTrigger)
  publish.appendChild(publishMenu)
  const moreMenu = element('div', {dataset: {flatPackButtonDropdownTarget: 'menu'}})
  moreMenu.setAttribute('role', 'menu')
  moreMenu.setAttribute('aria-hidden', 'true')
  moreMenu.appendChild(duplicate)
  moreMenu.appendChild(archive)
  const moreTrigger = element('button', {text: 'More', dataset: {flatPackButtonDropdownTarget: 'trigger'}})
  const more = element('div', {dataset: {controller: 'flat-pack--button-dropdown'}})
  more.appendChild(moreTrigger)
  more.appendChild(moreMenu)
  const row = element('div')
  row.appendChild(sectionButton)
  row.appendChild(publish)
  row.appendChild(more)
  const pageNav = element('page-nav')
  pageNav.appendChild(row)

  const sectionChildren = [pageNav]
  const section = {
    dataset: {flatPackTopNavCollapsible: 'true'},
    childNodes: sectionChildren,
    classList: {toggle() {}, remove() {}},
    insertBefore(node, before) {
      node.parentNode = section
      sectionChildren.splice(sectionChildren.indexOf(before), 0, node)
    },
    replaceChild(node, placeholder) {
      if (node.parentNode && node.parentNode.removeChild) node.parentNode.removeChild(node)
      sectionChildren.splice(sectionChildren.indexOf(placeholder), 1, node)
      node.parentNode = section
    }
  }
  const panelChildren = []
  const panel = element('div')
  panel.childrenPush = panel.appendChild
  panel.appendChild = (node) => {
    const index = sectionChildren.indexOf(node)
    if (index >= 0) sectionChildren.splice(index, 1)
    return panel.childrenPush(node)
  }
  const menu = {classList: {toggle() {}}}
  const doc = {createComment() { return {nodeType: 8, parentNode: null} }, activeElement: null}
  const TopNavController = loadTopNavController({
    window: {},
    document: doc,
    Node: {TEXT_NODE: 3, ELEMENT_NODE: 1}
  })

  return {
    panel,
    doc,
    sectionChildren,
    publish,
    publishTrigger,
    more,
    publishMenu,
    moreMenu,
    publishNow,
    schedule,
    duplicate,
    archive,
    controller: Object.assign(new TopNavController(), {
      element: {dataset: {}},
      mediaQuery: {matches: true},
      hasPanelTarget: true,
      hasMenuTarget: true,
      hasToggleTarget: false,
      sectionTargets: [section],
      panelTarget: panel,
      menuTarget: menu,
      movedNodes: [],
      breakpointValue: 768,
      fitting: false,
      menuOpen: false
    })
  }
}

test('a phone leaves the sidebar toggle in the bar', () => {
  const {controller, panelChildren, sectionChildren} = buildFitController({
    clientWidth: 390,
    scrollWidth: 640,
    viewportNarrow: true
  })
  const toggle = sectionChildren[0]
  toggle.matches = (selector) => selector.includes('mobileToggle')

  controller.applyLayout()

  assert.equal(panelChildren.length, 0)
  assert.equal(sectionChildren[0], toggle)
})

test('the open menu stays inside the viewport when an ancestor pins fixed positioning', () => {
  const style = {}
  const panel = {
    hidden: false,
    style,
    getBoundingClientRect() {
      const left = Number.parseFloat(style.left || '0')
      return {left: left - 96, width: 320, right: left - 96 + 320, top: 66, bottom: 290, height: 224}
    }
  }
  const toggle = {
    getBoundingClientRect() {
      return {bottom: 58, right: 278, left: 234, top: 14, width: 44, height: 44}
    }
  }
  const TopNavController = loadTopNavController({window: {innerWidth: 390}, document: {}})
  const controller = Object.assign(new TopNavController(), {
    menuOpen: true,
    hasPanelTarget: true,
    hasToggleTarget: true,
    panelTarget: panel,
    toggleTarget: toggle
  })

  controller.placeMenu()

  const viewportLeft = Number.parseFloat(style.left) - 96
  assert.equal(style.position, 'fixed')
  assert.equal(style.right, 'auto')
  assert.ok(viewportLeft >= 8)
  assert.ok(viewportLeft + 320 <= 382)
})
