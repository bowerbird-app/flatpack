const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

function loadSidebarLayoutController({ prefersReduced = false, duration = 300, extras = {} } = {}) {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'sidebar_layout_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformedSource = source
    .replace('import { Controller } from "@hotwired/stimulus"', 'class Controller {}')
    .replace(
      'import { prefersReducedMotion, motionDuration } from "controllers/flat_pack/reduced_motion"',
      `function prefersReducedMotion() { return ${prefersReduced ? 'true' : 'false'} }\nfunction motionDuration() { return ${duration} }`
    )
    .replace('export default class extends Controller', 'class SidebarLayoutController extends Controller') + '\nmodule.exports = SidebarLayoutController\n'

  const timeouts = []
  const memory = new Map()
  const context = {
    module: { exports: {} },
    exports: {},
    window: { innerWidth: 1280, addEventListener() {}, removeEventListener() {} },
    document: extras.document || {
      addEventListener() {},
      removeEventListener() {}
    },
    sessionStorage: {
      getItem(key) { return memory.has(key) ? memory.get(key) : null },
      setItem(key, value) { memory.set(key, String(value)) }
    },
    setTimeout(callback, ms) {
      timeouts.push({ callback, ms })
      return timeouts.length
    },
    clearTimeout() {},
    requestAnimationFrame(callback) { callback() },
    ...extras
  }

  vm.runInNewContext(transformedSource, context, { filename: filePath })

  return { Controller: context.module.exports, timeouts }
}

function classListStub(initial = []) {
  const names = new Set(initial)
  return {
    contains(name) { return names.has(name) },
    add(...added) { added.forEach((name) => names.add(name)) },
    remove(...removed) { removed.forEach((name) => names.delete(name)) },
    toggle(name, force) {
      if (force === true) names.add(name)
      else if (force === false) names.delete(name)
      else if (names.has(name)) names.delete(name)
      else names.add(name)
    }
  }
}

function buildDesktopController({ prefersReduced = false, duration = 300 } = {}) {
  const listeners = []
  const label = {
    classList: classListStub([]),
    dataset: {}
  }
  const item = {
    classList: classListStub(['px-4'])
  }
  const brand = {
    classList: classListStub([])
  }
  const aside = {
    style: {},
    dataset: {},
    addEventListener(type, fn) { listeners.push({ target: 'aside', type, fn }) },
    removeEventListener(type, fn) {
      const index = listeners.findIndex((entry) => entry.target === 'aside' && entry.type === type && entry.fn === fn)
      if (index >= 0) listeners.splice(index, 1)
    }
  }
  const sidebarTarget = {
    style: {},
    dataset: {},
    querySelector(selector) { return selector === 'aside' ? aside : null },
    querySelectorAll(selector) {
      const value = String(selector)
      if (value.includes('headerBrand')) return [brand]
      if (value.includes('fp-sidebar-label') || value.includes('span.flex-1')) return [label]
      if (value.includes('flat-pack-sidebar-item')) return [item]
      return []
    },
    addEventListener(type, fn) { listeners.push({ target: 'sidebar', type, fn }) },
    removeEventListener(type, fn) {
      const index = listeners.findIndex((entry) => entry.target === 'sidebar' && entry.type === type && entry.fn === fn)
      if (index >= 0) listeners.splice(index, 1)
    }
  }
  const desktopToggleTarget = {
    classList: classListStub([]),
    setAttribute() {},
    querySelector() { return { style: {} } }
  }
  const collapsedToggleTarget = {
    classList: classListStub(['hidden']),
    setAttribute() {}
  }

  const { Controller, timeouts } = loadSidebarLayoutController({ prefersReduced, duration })
  const controller = Object.assign(new Controller(), {
    isMobile: false,
    collapsed: false,
    hasSidebarTarget: true,
    sidebarTarget,
    hasDesktopToggleTarget: true,
    desktopToggleTarget,
    hasCollapsedToggleTarget: true,
    collapsedToggleTarget,
    hasStorageKeyValue: false,
    element: sidebarTarget,
    currentScrollContainer() { return null }
  })

  return { controller, label, item, brand, aside, sidebarTarget, desktopToggleTarget, collapsedToggleTarget, timeouts, listeners }
}

test('collapse shows the hamburger and hides the brand mark at click time', () => {
  const { controller, brand, collapsedToggleTarget, desktopToggleTarget } = buildDesktopController()

  controller.toggleDesktop()

  assert.equal(brand.classList.contains('hidden'), true)
  assert.equal(collapsedToggleTarget.classList.contains('hidden'), false)
  assert.equal(collapsedToggleTarget.classList.contains('flex'), true)
  assert.equal(desktopToggleTarget.classList.contains('hidden'), true)
})

test('collapse does not sr-only labels or center icons at click time', () => {
  const { controller, label, item, sidebarTarget, timeouts } = buildDesktopController()

  controller.toggleDesktop()

  assert.equal(sidebarTarget.dataset.flatPackSidebarCollapsed, 'true')
  assert.equal(label.classList.contains('sr-only'), false)
  assert.equal(label.dataset.flatPackSidebarRestHidden, undefined)
  assert.equal(item.classList.contains('justify-center'), false)
  assert.equal(item.classList.contains('px-4'), true)
  assert.ok(timeouts.length > 0)
})

test('collapse rest state compact-centers icons after the width transition', () => {
  const { controller, label, item, timeouts } = buildDesktopController()

  controller.toggleDesktop()
  timeouts[0].callback()

  assert.equal(label.classList.contains('sr-only'), true)
  assert.equal(label.dataset.flatPackSidebarRestHidden, 'true')
  assert.equal(item.classList.contains('justify-center'), true)
  assert.equal(item.classList.contains('px-1'), true)
  assert.equal(item.classList.contains('px-4'), false)
})

test('expand restores labels before the rail opens', () => {
  const { controller, label, item, brand, sidebarTarget, collapsedToggleTarget } = buildDesktopController({ prefersReduced: true, duration: 0 })

  controller.toggleDesktop()
  assert.equal(label.classList.contains('sr-only'), true)
  assert.equal(item.classList.contains('justify-center'), true)

  controller.toggleDesktop()
  assert.equal(sidebarTarget.dataset.flatPackSidebarCollapsed, 'false')
  assert.equal(label.classList.contains('sr-only'), false)
  assert.equal(item.classList.contains('justify-center'), false)
  assert.equal(item.classList.contains('px-4'), true)
  assert.equal(brand.classList.contains('hidden'), false)
  assert.equal(collapsedToggleTarget.classList.contains('hidden'), true)
})

test('reduced motion applies rest state immediately', () => {
  const { controller, label, item, timeouts } = buildDesktopController({ prefersReduced: true, duration: 0 })

  controller.toggleDesktop()

  assert.equal(label.classList.contains('sr-only'), true)
  assert.equal(item.classList.contains('justify-center'), true)
  assert.equal(timeouts.length, 0)
})

test('controller source no longer reflows labels at click time', () => {
  const source = fs.readFileSync(
    path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'sidebar_layout_controller.js'),
    'utf8'
  )

  assert.equal(source.includes('delayContentReveal'), false)
  assert.equal(source.includes('setDesktopExpandedContentVisible'), false)
  assert.equal(/setTimeout\(\s*\(\)\s*=>\s*\{[\s\S]*?\},\s*300\s*\)/.test(source), false)
})

function rect(top, bottom) {
  return { top, bottom, left: 0, right: 64, height: bottom - top, width: 64 }
}

function buildScrollController({ itemTop, itemBottom, scrollTop = 80 } = {}) {
  const { controller, sidebarTarget } = buildDesktopController()
  const scrollContainer = {
    scrollTop,
    getBoundingClientRect() { return rect(100, 500) }
  }
  const activeItem = {
    getBoundingClientRect() { return rect(itemTop, itemBottom) }
  }

  controller.hasScrollContainerTarget = true
  controller.scrollContainerTarget = scrollContainer
  controller.currentScrollContainer = () => scrollContainer
  controller.element = {
    querySelector(selector) {
      if (String(selector).includes('aria-current="page"')) return activeItem
      return sidebarTarget.querySelector(selector)
    }
  }

  return { controller, scrollContainer, activeItem }
}

test('visible current item does not move the sidebar scroll', () => {
  const { controller, scrollContainer } = buildScrollController({ itemTop: 220, itemBottom: 260, scrollTop: 80 })

  controller.scrollActiveItemIntoView()

  assert.equal(scrollContainer.scrollTop, 80)
})

test('current item above the rail nudges just enough to show it', () => {
  const { controller, scrollContainer } = buildScrollController({ itemTop: 40, itemBottom: 80, scrollTop: 80 })

  controller.scrollActiveItemIntoView()

  assert.equal(scrollContainer.scrollTop, 20)
})

test('current item below the rail nudges just enough to show it', () => {
  const { controller, scrollContainer } = buildScrollController({ itemTop: 520, itemBottom: 560, scrollTop: 80 })

  controller.scrollActiveItemIntoView()

  assert.equal(scrollContainer.scrollTop, 140)
})

test('current item in the middle is not pinned to the top', () => {
  const { controller, scrollContainer } = buildScrollController({ itemTop: 250, itemBottom: 290, scrollTop: 80 })

  controller.scrollActiveItemIntoView()

  assert.equal(scrollContainer.scrollTop, 80)
  assert.notEqual(scrollContainer.scrollTop, 80 + (250 - 100))
})
