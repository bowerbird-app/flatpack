const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

function loadSidebarLayoutController({ prefersReduced = false, extras = {} } = {}) {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'sidebar_layout_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformedSource = source
    .replace(
      'import { prefersReducedMotion } from "controllers/flat_pack/reduced_motion"\n',
      'function prefersReducedMotion() { const media = window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)"); return Boolean(media && media.matches) }\n'
    )
    .replace('import { Controller } from "@hotwired/stimulus"', `class Controller {
      dispatch(name, options = {}) {
        const event = {
          type: 'flat-pack--sidebar-layout:' + name,
          detail: options.detail,
          bubbles: true,
          target: options.target
        }
        this.collapseEvents = this.collapseEvents || []
        this.collapseEvents.push(event)
      }
    }`)
    .replace('export default class extends Controller', 'class SidebarLayoutController extends Controller') + '\nmodule.exports = SidebarLayoutController\n'

  const timeouts = []
  const memory = new Map()
  const localMemory = new Map()
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
    localStorage: {
      getItem(key) { return localMemory.has(key) ? localMemory.get(key) : null },
      setItem(key, value) { localMemory.set(key, String(value)) },
      removeItem(key) { localMemory.delete(key) }
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

  return { Controller: context.module.exports, timeouts, localStorage: context.localStorage }
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
    dataset: {},
    closest() { return null }
  }
  const sectionLabel = {
    classList: classListStub([]),
    dataset: {},
    closest(selector) {
      return String(selector).includes('flat-pack-sidebar-section-title') ? { dataset: {} } : null
    }
  }
  const item = {
    classList: classListStub(['px-[var(--sidebar-item-padding-x)]'])
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
      if (value.includes('fp-sidebar-label') || value.includes('span.flex-1')) return [label, sectionLabel]
      if (value.includes('flat-pack-sidebar-item="true"]') && value.startsWith('a')) return [item]
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

  const { Controller, timeouts, localStorage } = loadSidebarLayoutController({ prefersReduced, duration })
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

  return { controller, label, sectionLabel, item, brand, aside, sidebarTarget, desktopToggleTarget, collapsedToggleTarget, timeouts, listeners, localStorage }
}

test('collapse writes the column attribute, storage, and one collapse event', () => {
  const { controller, sidebarTarget, localStorage } = buildDesktopController()
  controller.hasStorageKeyValue = true
  controller.storageKeyValue = 'app-shell'

  controller.toggleDesktop()

  assert.equal(sidebarTarget.dataset.flatPackSidebarCollapsed, 'true')
  assert.equal(localStorage.getItem('app-shell'), 'true')
  assert.equal(controller.collapseEvents.length, 1)
  assert.equal(controller.collapseEvents[0].type, 'flat-pack--sidebar-layout:collapse')
  assert.equal(controller.collapseEvents[0].detail.collapsed, true)
  assert.equal(controller.collapseEvents[0].target, sidebarTarget)
  assert.equal(controller.collapseEvents[0].bubbles, true)
})

test('collapse does not restyle labels or icons at click time', () => {
  const { controller, label, item, sidebarTarget, timeouts } = buildDesktopController()

  controller.toggleDesktop()

  assert.equal(sidebarTarget.dataset.flatPackSidebarCollapsed, 'true')
  assert.equal(label.classList.contains('sr-only'), false)
  assert.equal(label.dataset.flatPackSidebarRestHidden, undefined)
  assert.equal(item.classList.contains('justify-center'), false)
  assert.equal(item.classList.contains('px-[var(--sidebar-item-padding-x)]'), true)
  assert.equal(timeouts.length, 0)
})

test('width end does not restyle icons or labels', () => {
  const { controller, label, item, timeouts } = buildDesktopController()

  controller.toggleDesktop()

  assert.equal(timeouts.length, 0)
  assert.equal(label.classList.contains('sr-only'), false)
  assert.equal(item.classList.contains('justify-center'), false)
  assert.equal(item.classList.contains('px-[var(--sidebar-item-padding-x)]'), true)
})

test('expand writes the open column attribute and a collapse event', () => {
  const { controller, label, item, sidebarTarget } = buildDesktopController({ prefersReduced: true, duration: 0 })
  controller.hasStorageKeyValue = true
  controller.storageKeyValue = 'app-shell'

  controller.toggleDesktop()
  assert.equal(label.classList.contains('sr-only'), false)
  assert.equal(item.classList.contains('justify-center'), false)

  controller.toggleDesktop()
  assert.equal(sidebarTarget.dataset.flatPackSidebarCollapsed, 'false')
  assert.equal(controller.collapsed, false)
  assert.equal(controller.collapseEvents.at(-1).detail.collapsed, false)
  assert.equal(label.classList.contains('sr-only'), false)
  assert.equal(item.classList.contains('justify-center'), false)
})

test('reduced motion does not schedule a layout restyle', () => {
  const { controller, label, item, timeouts } = buildDesktopController({ prefersReduced: true, duration: 0 })

  controller.toggleDesktop()

  assert.equal(label.classList.contains('sr-only'), false)
  assert.equal(item.classList.contains('justify-center'), false)
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

test('collapse does not sr-only section titles', () => {
  const { controller, label, sectionLabel } = buildDesktopController()

  controller.toggleDesktop()

  assert.equal(label.classList.contains('sr-only'), false)
  assert.equal(sectionLabel.classList.contains('sr-only'), false)
})

function navLinkStub({ current = false } = {}) {
  const icon = {
    classList: classListStub([
      current ? 'text-[var(--sidebar-item-active-icon-color)]' : 'text-[var(--sidebar-item-icon-color)]'
    ])
  }
  const classes = current
    ? [
      'bg-[var(--sidebar-item-active-background-color)]',
      'text-[var(--sidebar-item-active-text-color)]'
    ]
    : [
      'text-[var(--sidebar-item-text-color)]',
      'hover:bg-[var(--sidebar-item-hover-background-color)]',
      'hover:text-[var(--sidebar-item-hover-text-color)]'
    ]
  const attrs = {}
  if (current) attrs['aria-current'] = 'page'

  return {
    classList: classListStub(classes),
    href: '/demo/cards',
    target: '',
    setAttribute(name, value) { attrs[name] = value },
    removeAttribute(name) { delete attrs[name] },
    getAttribute(name) { return attrs[name] },
    matches(selector) { return String(selector).includes('sidebar-item') },
    querySelector(selector) {
      return String(selector).includes('sidebar-item-icon') ? icon : null
    },
    getBoundingClientRect() { return rect(220, 260) },
    icon
  }
}

test('clicking a sidebar item marks it current before the page renders', () => {
  const { controller, sidebarTarget } = buildDesktopController()
  const previous = navLinkStub({ current: true })
  const next = navLinkStub({ current: false })
  const scrollContainer = {
    scrollTop: 40,
    getBoundingClientRect() { return rect(100, 500) }
  }

  sidebarTarget.contains = () => true
  const originalQuery = sidebarTarget.querySelectorAll.bind(sidebarTarget)
  sidebarTarget.querySelectorAll = (selector) => {
    const value = String(selector)
    if (value.startsWith('a[') && value.includes('sidebar-item')) return [previous, next]
    return originalQuery(selector)
  }

  controller.hasScrollContainerTarget = true
  controller.scrollContainerTarget = scrollContainer
  controller.currentScrollContainer = () => scrollContainer
  controller.hasStorageKeyValue = true
  controller.storageKeyValue = 'test-shell'
  controller.hasSideValue = true
  controller.sideValue = 'left'
  controller.normalizePath = () => '/demo/cards'

  controller.handleSidebarLinkClick({
    target: { closest() { return next } },
    defaultPrevented: false,
    button: 0,
    metaKey: false,
    ctrlKey: false,
    shiftKey: false,
    altKey: false
  })

  assert.equal(next.getAttribute('aria-current'), 'page')
  assert.equal(previous.getAttribute('aria-current'), undefined)
  assert.equal(next.classList.contains('bg-[var(--sidebar-item-active-background-color)]'), true)
  assert.equal(previous.classList.contains('bg-[var(--sidebar-item-active-background-color)]'), false)
  assert.equal(next.icon.classList.contains('text-[var(--sidebar-item-active-icon-color)]'), true)
  assert.equal(previous.icon.classList.contains('text-[var(--sidebar-item-icon-color)]'), true)
})

test('modifier-click does not mark a sidebar item current', () => {
  const { controller, sidebarTarget } = buildDesktopController()
  const next = navLinkStub({ current: false })
  sidebarTarget.contains = () => true

  controller.handleSidebarLinkClick({
    target: { closest() { return next } },
    defaultPrevented: false,
    button: 0,
    metaKey: true,
    ctrlKey: false,
    shiftKey: false,
    altKey: false
  })

  assert.equal(next.getAttribute('aria-current'), undefined)
  assert.equal(next.classList.contains('bg-[var(--sidebar-item-active-background-color)]'), false)
})

test('turbo load restores persisted scroll after groups apply', () => {
  const { controller } = buildDesktopController()
  const scrollContainer = {
    scrollTop: 0,
    dataset: { flatPackScrollPreRestored: 'true' },
    getBoundingClientRect() { return rect(100, 500) }
  }

  controller.hasScrollContainerTarget = true
  controller.scrollContainerTarget = scrollContainer
  controller.currentScrollContainer = () => scrollContainer
  controller.hasStorageKeyValue = true
  controller.storageKeyValue = 'test-shell'
  controller.hasSideValue = true
  controller.sideValue = 'left'
  controller.element = { querySelector() { return null } }
  controller.writeScrollState({ scrollTop: 640, anchorPath: null, anchorOffset: null })

  controller.handleTurboLoad()

  assert.equal(scrollContainer.scrollTop, 640)
  assert.equal(scrollContainer.dataset.flatPackScrollPreRestored, undefined)
})

test('controller source restores scroll after groups and skips section-title sr-only', () => {
  const source = fs.readFileSync(
    path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'sidebar_layout_controller.js'),
    'utf8'
  )

  assert.equal(source.includes('scheduleScrollRestore'), true)
  assert.equal(source.includes('markItemCurrent'), true)
  assert.equal(source.includes('isSectionTitleLabel'), false)
  assert.equal(source.includes('labelNodes'), false)
  assert.equal(source.includes('querySelector("aside")'), false)
  assert.equal(source.includes('clearCollapsedRestState'), false)
  assert.equal(source.includes('this.scrollActiveItemIntoView()'), true)
  assert.equal(source.includes('syncFloatingTopNavClearance'), true)
})

test('wrapped floating top nav raises the clearance and one row does not', () => {
  const { Controller } = loadSidebarLayoutController()
  const controller = new Controller()
  const column = {
    property: '',
    style: {
      setProperty(name, value) { column.property = `${name}:${value}` },
      removeProperty() { column.property = '' }
    }
  }

  controller.applyFloatingTopNavClearance(column, 130, 68)
  assert.equal(column.property, '--top-nav-float-clearance:130px')

  controller.applyFloatingTopNavClearance(column, 72, 68)
  assert.equal(column.property, '')
})

test('page scroll writes clearance on the document element', () => {
  const root = {
    property: '',
    style: {
      setProperty(name, value) { root.property = `${name}:${value}` },
      removeProperty() { root.property = '' },
      getPropertyValue() { return '' }
    }
  }
  const { Controller } = loadSidebarLayoutController({
    extras: {
      document: {
        documentElement: root,
        addEventListener() {},
        removeEventListener() {}
      }
    }
  })
  const controller = new Controller()
  controller.element = { dataset: { flatPackLayoutScroll: 'page' } }
  const column = {
    property: '',
    style: {
      setProperty(name, value) { column.property = `${name}:${value}` },
      removeProperty() { column.property = '' },
      getPropertyValue() { return '' }
    }
  }

  controller.applyFloatingTopNavClearance(column, 130, 68)
  assert.equal(root.property, '--top-nav-float-clearance:130px')
  assert.equal(column.property, '')

  controller.applyFloatingTopNavClearance(column, 72, 68)
  assert.equal(root.property, '')
  assert.equal(column.property, '')
})

function storageStub(seed = {}) {
  const memory = new Map(Object.entries(seed))
  const writes = []
  return {
    memory,
    writes,
    getItem(key) { return memory.has(key) ? memory.get(key) : null },
    setItem(key, value) {
      memory.set(key, String(value))
      writes.push([key, String(value)])
    },
    removeItem(key) { memory.delete(key) }
  }
}

function drawerPanel(side) {
  const attrs = {}
  const panel = {
    style: { pointerEvents: '' },
    dataset: { mobileDrawerSide: side },
    classList: classListStub([side === 'right' ? 'translate-x-full' : '-translate-x-full']),
    focused: 0,
    hasAttribute(name) { return Object.prototype.hasOwnProperty.call(attrs, name) },
    getAttribute(name) { return attrs[name] },
    setAttribute(name, value) { attrs[name] = String(value) },
    removeAttribute(name) { delete attrs[name] },
    focus() { panel.focused += 1 },
    querySelector() { return { style: {}, dataset: {} } },
    querySelectorAll() { return [] },
    addEventListener() {},
    removeEventListener() {},
    attrs
  }
  return panel
}

function buttonStub() {
  const attrs = {}
  const button = {
    attrs,
    focused: 0,
    setAttribute(name, value) { attrs[name] = value },
    getAttribute(name) { return attrs[name] },
    focus() { button.focused += 1 }
  }
  return button
}

function backdropStub() {
  const attrs = { 'aria-hidden': 'true' }
  return {
    attrs,
    classList: classListStub(['pointer-events-none', 'opacity-0']),
    setAttribute(name, value) { attrs[name] = value },
    getAttribute(name) { return attrs[name] }
  }
}

function buildShell({
  mobile = false,
  asideOpen = true,
  storageKey = 'app-shell:aside',
  stored,
  withSidebar = false,
  prefersReduced = false
} = {}) {
  const seed = stored === undefined || !storageKey ? {} : { [storageKey]: stored }
  const localStorage = storageStub(seed)
  const opener = buttonStub()
  const listeners = []
  const doc = {
    body: { style: { overflow: '' }, dataset: {} },
    activeElement: opener,
    listeners,
    addEventListener(type, fn) { listeners.push({ type, fn }) },
    removeEventListener(type, fn) {
      const index = listeners.findIndex((entry) => entry.type === type && entry.fn === fn)
      if (index >= 0) listeners.splice(index, 1)
    }
  }
  const aside = drawerPanel('right')
  aside.dataset.flatPackAsideOpen = asideOpen ? 'true' : 'false'
  const sidebar = drawerPanel('left')
  const toggle = buttonStub()
  const backdrop = backdropStub()
  const element = {
    addEventListener() {},
    removeEventListener() {},
    querySelector() { return null }
  }
  const windowStub = {
    innerWidth: mobile ? 390 : 1280,
    addEventListener() {},
    removeEventListener() {},
    matchMedia() { return { matches: prefersReduced } }
  }
  const { Controller } = loadSidebarLayoutController({
    extras: { localStorage, document: doc, window: windowStub }
  })
  const controller = Object.assign(new Controller(), {
    element,
    hasSidebarTarget: withSidebar,
    sidebarTarget: sidebar,
    hasAsideTarget: true,
    asideTarget: aside,
    hasAsideToggleTarget: true,
    asideToggleTargets: [toggle],
    hasAsideOpenValue: true,
    asideOpenValue: asideOpen,
    hasAsideStorageKeyValue: !!storageKey,
    asideStorageKeyValue: storageKey || '',
    hasBackdropTarget: true,
    backdropTarget: backdrop,
    hasStorageKeyValue: false,
    hasSideValue: true,
    sideValue: 'left',
    hasDesktopToggleTarget: false,
    hasCollapsedToggleTarget: false,
    currentScrollContainer() { return null }
  })

  return { controller, aside, sidebar, toggle, opener, doc, localStorage, backdrop, windowStub }
}

test('a missing aside key keeps the server closed state', () => {
  const { controller, aside, toggle, localStorage } = buildShell({ asideOpen: false })

  controller.connect()

  assert.equal(aside.dataset.flatPackAsideOpen, 'false')
  assert.equal(aside.attrs.inert, '')
  assert.equal(toggle.attrs['aria-expanded'], 'false')
  assert.equal(localStorage.writes.length, 0)
})

test('aside storage uses open polarity', () => {
  const closedServer = buildShell({ asideOpen: false, stored: 'true' })
  closedServer.controller.connect()
  assert.equal(closedServer.aside.dataset.flatPackAsideOpen, 'true')
  assert.equal(closedServer.aside.attrs.inert, undefined)

  const openServer = buildShell({ asideOpen: true, stored: 'false' })
  openServer.controller.connect()
  assert.equal(openServer.aside.dataset.flatPackAsideOpen, 'false')
  assert.equal(openServer.aside.attrs.inert, '')
})

test('desktop aside open and close persist and a repeat call does not', () => {
  const { controller, aside, toggle, localStorage } = buildShell({ asideOpen: true })

  controller.connect()
  controller.openAside()
  assert.equal(localStorage.writes.length, 0)

  controller.toggleAside()
  assert.equal(aside.dataset.flatPackAsideOpen, 'false')
  assert.equal(toggle.attrs['aria-expanded'], 'false')
  assert.deepEqual(localStorage.writes.at(-1), ['app-shell:aside', 'false'])

  const writes = localStorage.writes.length
  controller.closeAside()
  assert.equal(localStorage.writes.length, writes)

  controller.openAside()
  assert.deepEqual(localStorage.writes.at(-1), ['app-shell:aside', 'true'])
  assert.equal(aside.attrs.inert, undefined)
  controller.openAside()
  assert.equal(localStorage.writes.length, 2)
})

test('desktop aside toggle does not lock body scroll', () => {
  const { controller, doc } = buildShell()

  controller.connect()
  controller.toggleAside()

  assert.equal(doc.body.dataset.flatPackModalLockCount, undefined)
  assert.equal(doc.body.style.overflow, '')
})

test('mobile aside drawer ignores the desktop open key', () => {
  const { controller, aside, toggle, localStorage, backdrop, doc, opener } = buildShell({
    mobile: true,
    asideOpen: true,
    stored: 'false'
  })

  controller.connect()

  assert.equal(aside.dataset.flatPackAsideOpen, 'true')
  assert.equal(aside.attrs.inert, '')
  assert.equal(aside.style.pointerEvents, 'none')
  assert.equal(aside.classList.contains('translate-x-full'), true)
  assert.equal(toggle.attrs['aria-expanded'], 'false')
  assert.equal(localStorage.writes.length, 0)

  controller.toggleAside()

  assert.equal(localStorage.writes.length, 0)
  assert.equal(aside.dataset.flatPackAsideOpen, 'true')
  assert.equal(aside.attrs.inert, undefined)
  assert.equal(aside.classList.contains('translate-x-full'), false)
  assert.equal(aside.focused, 1)
  assert.equal(toggle.attrs['aria-expanded'], 'true')
  assert.equal(backdrop.attrs['aria-hidden'], 'false')
  assert.equal(backdrop.classList.contains('opacity-100'), true)
  assert.equal(backdrop.classList.contains('pointer-events-none'), false)
  assert.equal(doc.body.dataset.flatPackModalLockCount, '1')
  assert.equal(doc.body.style.overflow, 'hidden')

  const escape = doc.listeners.find((entry) => entry.type === 'keydown')
  escape.fn({ key: 'Escape' })

  assert.equal(aside.classList.contains('translate-x-full'), true)
  assert.equal(aside.attrs.inert, '')
  assert.equal(opener.focused, 1)
  assert.equal(doc.body.dataset.flatPackModalLockCount, undefined)
  assert.equal(doc.body.style.overflow, '')
  assert.equal(backdrop.attrs['aria-hidden'], 'true')
  assert.equal(toggle.attrs['aria-expanded'], 'false')
})

test('one shell drawer is open and the body lock is held once', () => {
  const { controller, aside, sidebar, doc, opener } = buildShell({ mobile: true, withSidebar: true })

  controller.connect()
  doc.activeElement = opener
  controller.openMobile()
  assert.equal(sidebar.classList.contains('-translate-x-full'), false)
  assert.equal(doc.body.dataset.flatPackModalLockCount, '1')

  const details = buttonStub()
  doc.activeElement = details
  controller.openAside()

  assert.equal(sidebar.classList.contains('-translate-x-full'), true)
  assert.equal(aside.classList.contains('translate-x-full'), false)
  assert.equal(opener.focused, 0)
  assert.equal(doc.body.dataset.flatPackModalLockCount, '1')
  assert.equal(doc.body.style.overflow, 'hidden')

  controller.closeMobile()

  assert.equal(aside.classList.contains('translate-x-full'), true)
  assert.equal(sidebar.classList.contains('-translate-x-full'), true)
  assert.equal(doc.body.dataset.flatPackModalLockCount, undefined)
})

test('a shell drawer joins an existing body lock', () => {
  const { controller, doc } = buildShell({ mobile: true })
  doc.body.dataset.flatPackModalLockCount = '1'
  doc.body.style.overflow = 'hidden'

  controller.connect()
  controller.openAside()
  assert.equal(doc.body.dataset.flatPackModalLockCount, '2')
  assert.equal(doc.body.style.overflow, 'hidden')

  controller.closeAside()
  assert.equal(doc.body.dataset.flatPackModalLockCount, '1')
  assert.equal(doc.body.style.overflow, 'hidden')
})

test('crossing the mobile breakpoint does not write the aside key', () => {
  const { controller, aside, localStorage, windowStub } = buildShell({ asideOpen: true })

  controller.connect()
  windowStub.innerWidth = 390
  controller.handleResize()

  assert.equal(localStorage.writes.length, 0)
  assert.equal(aside.attrs.inert, '')
  assert.equal(aside.dataset.flatPackAsideOpen, 'true')

  windowStub.innerWidth = 1280
  controller.handleResize()

  assert.equal(localStorage.writes.length, 0)
  assert.equal(aside.dataset.flatPackAsideOpen, 'true')
  assert.equal(aside.attrs.inert, undefined)
})

test('a missing rail key keeps the server open value', () => {
  const closed = buildShell({ withSidebar: true, storageKey: null })
  closed.controller.hasStorageKeyValue = true
  closed.controller.storageKeyValue = 'flatpack-dummy-shell-collapsed'
  closed.controller.hasOpenValue = true
  closed.controller.openValue = false
  closed.controller.collapsed = false

  closed.controller.loadDesktopState()

  assert.equal(closed.controller.collapsed, true)
  assert.equal(closed.localStorage.writes.length, 0)

  const storedOpen = buildShell({ withSidebar: true, storageKey: null })
  storedOpen.localStorage.setItem('flatpack-dummy-shell-collapsed', 'false')
  storedOpen.controller.hasStorageKeyValue = true
  storedOpen.controller.storageKeyValue = 'flatpack-dummy-shell-collapsed'
  storedOpen.controller.hasOpenValue = true
  storedOpen.controller.openValue = false
  storedOpen.controller.collapsed = true

  storedOpen.controller.loadDesktopState()

  assert.equal(storedOpen.controller.collapsed, false)
})

test('a resize collapse uses the rail collapse path and leaves width storage alone', () => {
  const { controller, sidebar, localStorage } = buildShell({ withSidebar: true, storageKey: null })
  controller.hasStorageKeyValue = true
  controller.storageKeyValue = 'app-shell'
  controller.isMobile = false
  controller.collapsed = false
  controller.openDrawers = []

  controller.collapseRailFromResize()

  assert.equal(controller.collapsed, true)
  assert.equal(sidebar.dataset.flatPackSidebarCollapsed, 'true')
  assert.equal(localStorage.memory.get('app-shell'), 'true')
  assert.equal(localStorage.memory.has('app-shell:rail:width'), false)

  const writes = localStorage.writes.length
  controller.collapseRailFromResize()
  assert.equal(localStorage.writes.length, writes)

  controller.collapsed = false
  controller.isMobile = true
  controller.collapseRailFromResize()
  assert.equal(controller.collapsed, false)
})

test('mobile menu toggle exposes expanded and controls', () => {
  const { controller, sidebar } = buildShell({ mobile: true, withSidebar: true })
  const menu = buttonStub()
  controller.hasMobileToggleTarget = true
  controller.mobileToggleTargets = [menu]
  sidebar.id = 'flat-pack-rail-test'

  controller.connect()

  assert.equal(menu.attrs['aria-expanded'], 'false')
  assert.equal(menu.attrs['aria-controls'], 'flat-pack-rail-test')

  controller.openMobile()
  assert.equal(menu.attrs['aria-expanded'], 'true')
  assert.equal(menu.attrs['aria-controls'], 'flat-pack-rail-test')

  controller.closeMobile()
  assert.equal(menu.attrs['aria-expanded'], 'false')
})

test('mobile drawer transitions translate and transform', () => {
  const { controller, sidebar, aside } = buildShell({ mobile: true, withSidebar: true })

  controller.connect()

  assert.equal(sidebar.style.transitionProperty, 'translate, transform')
  assert.equal(aside.style.transitionProperty, 'translate, transform')
})

test('reduced motion snaps the mobile drawer', () => {
  const { controller, sidebar, aside } = buildShell({
    mobile: true,
    withSidebar: true,
    prefersReduced: true
  })

  controller.connect()

  assert.equal(sidebar.style.transitionProperty, 'none')
  assert.equal(aside.style.transitionProperty, 'none')
})

test('stacked aside stays in flow on a phone', () => {
  const { controller, aside, toggle, localStorage } = buildShell({ mobile: true, asideOpen: true })
  controller.asideMobileValue = 'stack'

  controller.connect()

  assert.equal(aside.classList.contains('translate-x-full'), false)
  assert.equal(aside.attrs.inert, undefined)
  assert.equal(aside.style.pointerEvents, '')
  assert.equal(toggle.attrs['aria-expanded'], 'true')
  assert.equal(toggle.attrs['aria-controls'], aside.id)

  controller.toggleAside()
  controller.openAside()
  controller.closeAside()

  assert.equal(localStorage.writes.length, 0)
  assert.equal(aside.classList.contains('translate-x-full'), false)
  assert.equal(docOpen(controller), false)
})

function docOpen(controller) {
  return controller.openDrawers.includes(controller.asideTarget)
}
