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
  const context = {
    module: { exports: {} },
    exports: {},
    window: { innerWidth: 1280, addEventListener() {}, removeEventListener() {} },
    document: extras.document || {
      addEventListener() {},
      removeEventListener() {}
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
    add(name) { names.add(name) },
    remove(name) { names.delete(name) },
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
      if (String(selector).includes('fp-sidebar-label') || String(selector).includes('span.flex-1')) {
        return [label]
      }
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

  return { controller, label, aside, sidebarTarget, desktopToggleTarget, collapsedToggleTarget, timeouts, listeners }
}

test('collapse does not sr-only labels or center icons at click time', () => {
  const { controller, label, sidebarTarget, timeouts } = buildDesktopController()

  controller.toggleDesktop()

  assert.equal(sidebarTarget.dataset.flatPackSidebarCollapsed, 'true')
  assert.equal(label.classList.contains('sr-only'), false)
  assert.equal(label.dataset.flatPackSidebarRestHidden, undefined)
  assert.ok(timeouts.length > 0)
})

test('collapse rest state sr-onlys labels after the width transition', () => {
  const { controller, label, timeouts } = buildDesktopController()

  controller.toggleDesktop()
  timeouts[0].callback()

  assert.equal(label.classList.contains('sr-only'), true)
  assert.equal(label.dataset.flatPackSidebarRestHidden, 'true')
})

test('expand restores labels before the rail opens', () => {
  const { controller, label, sidebarTarget } = buildDesktopController({ prefersReduced: true, duration: 0 })

  controller.toggleDesktop()
  assert.equal(label.classList.contains('sr-only'), true)

  controller.toggleDesktop()
  assert.equal(sidebarTarget.dataset.flatPackSidebarCollapsed, 'false')
  assert.equal(label.classList.contains('sr-only'), false)
})

test('reduced motion applies rest state immediately', () => {
  const { controller, label, timeouts } = buildDesktopController({ prefersReduced: true, duration: 0 })

  controller.toggleDesktop()

  assert.equal(label.classList.contains('sr-only'), true)
  assert.equal(timeouts.length, 0)
})

test('controller source no longer reflows labels at click time', () => {
  const source = fs.readFileSync(
    path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'sidebar_layout_controller.js'),
    'utf8'
  )

  assert.equal(source.includes('delayContentReveal'), false)
  assert.equal(source.includes('justify-center'), false)
  assert.equal(source.includes('setDesktopExpandedContentVisible'), false)
  assert.equal(/setTimeout\(\s*\(\)\s*=>\s*\{[\s\S]*?\},\s*300\s*\)/.test(source), false)
})
