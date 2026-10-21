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

test('a wide viewport collapses the bar when its content overflows', () => {
  const {controller, panelChildren, sectionChildren, child, bar} = buildFitController({
    clientWidth: 400,
    scrollWidth: 640
  })

  controller.applyLayout()

  assert.equal(panelChildren.length, 1)
  assert.equal(sectionChildren.includes(child), false)

  bar.clientWidth = 800
  controller.applyLayout()

  assert.equal(panelChildren.length, 0)
  assert.equal(sectionChildren[0], child)
})

test('a bar that fits keeps its sections inline', () => {
  const {controller, panelChildren} = buildFitController({clientWidth: 800, scrollWidth: 640})

  controller.applyLayout()

  assert.equal(panelChildren.length, 0)
})

function matchesAny(accepted) {
  return (selector) => selector.split(',').some((part) => accepted.includes(part.trim()))
}

function elementNode({accepted = [], children = [], dataset = {}, text = ''} = {}) {
  const node = {
    nodeType: 1,
    dataset,
    textContent: text,
    innerText: text,
    parentNode: null,
    children,
    childNodes: children,
    classList: {toggle() {}, remove() {}},
    matches: matchesAny(accepted),
    querySelector(selector) {
      for (const child of children) {
        if (child.matches?.(selector)) return child
        const found = child.querySelector?.(selector)
        if (found) return found
      }
      return null
    },
    querySelectorAll() {
      return []
    }
  }
  children.forEach((child) => {
    child.parentNode = node
  })
  return node
}

function buildPhoneController({viewportNarrow}) {
  const backButton = elementNode({accepted: ["[data-flat-pack-page-nav='back']"]})
  const backWrap = elementNode({children: [backButton]})
  const sectionButton = elementNode({text: 'Section', accepted: ['button']})
  const publish = elementNode({
    text: 'Publish',
    accepted: ["[data-controller~='flat-pack--button-dropdown']"],
    children: [elementNode({accepted: ["[data-fp-style='primary']"]})]
  })
  const duplicate = elementNode({text: 'Duplicate'})
  const archive = elementNode({text: 'Archive'})
  const moreMenu = elementNode({
    children: [duplicate, archive],
    accepted: ["[role='menu']"]
  })
  const moreTrigger = elementNode({text: 'More'})
  const more = elementNode({
    text: 'More',
    accepted: ["[data-controller~='flat-pack--button-dropdown']"],
    children: [moreTrigger, moreMenu]
  })
  more.hidden = false
  more.querySelector = (selector) => {
    if (selector.includes('trigger')) return moreTrigger
    if (selector.includes("role='menu'")) return moreMenu
    return null
  }
  const rowChildren = [backWrap, sectionButton, publish, more]
  const row = elementNode({children: rowChildren, matches: () => false})
  const pageNav = elementNode({
    accepted: ['.flat-pack-page-nav'],
    children: [row]
  })
  pageNav.querySelector = (selector) => (selector.includes(':scope > div') ? row : null)
  const bell = elementNode({
    dataset: {flatPackUnread: 'true'},
    accepted: ['button']
  })
  const leftChildren = [pageNav]
  const rightChildren = [bell]
  const left = {
    dataset: {flatPackTopNavCollapsible: 'false'},
    childNodes: leftChildren,
    children: leftChildren,
    classList: {toggle() {}, remove() {}},
    insertBefore(node, before) {
      const list = leftChildren
      const index = list.indexOf(before)
      list.splice(index < 0 ? list.length : index, 0, node)
      node.parentNode = left
    }
  }
  const right = {
    dataset: {flatPackTopNavCollapsible: 'false'},
    childNodes: rightChildren,
    children: rightChildren,
    classList: {toggle() {}, remove() {}},
    insertBefore(node, before) {
      const index = rightChildren.indexOf(before)
      rightChildren.splice(index < 0 ? rightChildren.length : index, 0, node)
      node.parentNode = right
    }
  }
  row.insertBefore = (node, before) => {
    const index = rowChildren.indexOf(before)
    rowChildren.splice(index < 0 ? rowChildren.length : index, 0, node)
    node.parentNode = row
  }
  const panelChildren = []
  const panel = {
    children: panelChildren,
    childNodes: panelChildren,
    hidden: true,
    appendChild(node) {
      ;[leftChildren, rightChildren, rowChildren, panelChildren, moreMenu.children].forEach((list) => {
        const index = list.indexOf(node)
        if (index >= 0) list.splice(index, 1)
      })
      node.parentNode = panel
      panelChildren.push(node)
    },
    removeChild(node) {
      const index = panelChildren.indexOf(node)
      if (index >= 0) panelChildren.splice(index, 1)
    },
    insertBefore(node, before) {
      ;[leftChildren, rightChildren, rowChildren, panelChildren].forEach((list) => {
        const index = list.indexOf(node)
        if (index >= 0) list.splice(index, 1)
      })
      const at = panelChildren.indexOf(before)
      panelChildren.splice(at < 0 ? panelChildren.length : at, 0, node)
      node.parentNode = panel
    },
    querySelector(selector) {
      if (selector.includes('fp-red-dot') || selector.includes('flat-pack-unread')) return bell
      return null
    },
    querySelectorAll(selector) {
      if (selector.includes('button-dropdown')) return [more]
      return []
    }
  }
  const toggle = {
    attributes: {},
    setAttribute(name, value) { this.attributes[name] = value },
    removeAttribute(name) { delete this.attributes[name] }
  }
  const menu = {classList: {toggle() {}}}
  const bar = {
    clientWidth: 400,
    dataset: {},
    querySelectorAll() { return [] }
  }
  const TopNavController = loadTopNavController({
    window: {},
    document: {createComment(label) { return {nodeType: 8, label, remove() {}} }},
    Node: {TEXT_NODE: 3, ELEMENT_NODE: 1}
  })

  return {
    backWrap,
    sectionButton,
    publish,
    duplicate,
    archive,
    more,
    bell,
    rowChildren,
    panelChildren,
    toggle,
    controller: Object.assign(new TopNavController(), {
      element: bar,
      mediaQuery: {matches: viewportNarrow},
      hasPanelTarget: true,
      hasMenuTarget: true,
      hasToggleTarget: true,
      toggleTarget: toggle,
      sectionTargets: [left, right],
      panelTarget: panel,
      menuTarget: menu,
      movedNodes: [],
      flattenedMores: [],
      breakpointValue: 768,
      fitting: false,
      menuOpen: false
    })
  }
}

test('a phone keeps back in the bar and lists primary first', () => {
  const {controller, panelChildren, rowChildren, backWrap, publish, sectionButton, duplicate, bell, toggle} = buildPhoneController({
    viewportNarrow: true
  })

  controller.applyLayout()

  assert.equal(rowChildren.includes(backWrap), true)
  assert.equal(panelChildren[0], publish)
  assert.equal(panelChildren.includes(sectionButton), true)
  assert.equal(panelChildren.includes(duplicate), true)
  assert.equal(panelChildren.indexOf(sectionButton) < panelChildren.indexOf(bell), true)
  assert.equal(toggle.attributes['data-flat-pack-unread'], 'true')
})

test('a wide window keeps left actions when the bar is narrow', () => {
  const {controller, panelChildren, rowChildren, sectionButton, bell} = buildPhoneController({
    viewportNarrow: false
  })

  controller.applyLayout()

  assert.equal(panelChildren.length, 0)
  assert.equal(rowChildren.includes(sectionButton), true)
  assert.equal(bell.parentNode !== controller.panelTarget, true)
})
