const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

function loadChatLayoutController(overrides = {}) {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'chat_layout_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformedSource = source
    .replace('import { Controller } from "@hotwired/stimulus"', 'class Controller {}')
    .replace('export default class extends Controller', 'class ChatLayoutController extends Controller') + '\nmodule.exports = ChatLayoutController\n'

  const context = {
    module: { exports: {} },
    exports: {},
    ...overrides
  }

  vm.runInNewContext(transformedSource, context, { filename: filePath })

  return context.module.exports
}

function buildClassList(initialClasses = []) {
  const classes = new Set(initialClasses)

  return {
    add(...classNames) {
      classNames.forEach((className) => classes.add(className))
    },
    remove(...classNames) {
      classNames.forEach((className) => classes.delete(className))
    },
    contains(className) {
      return classes.has(className)
    }
  }
}

function buildController({ desktop = false, legacyMediaQuery = false, breakpoint = 640 } = {}) {
  const listeners = []
  const mediaQuery = {
    matches: desktop,
    addEventListener: legacyMediaQuery ? undefined : (eventName, listener) => listeners.push({ eventName, listener }),
    removeEventListener: legacyMediaQuery ? undefined : (eventName, listener) => {
      const index = listeners.findIndex((entry) => entry.eventName === eventName && entry.listener === listener)
      if (index >= 0) listeners.splice(index, 1)
    },
    addListener: legacyMediaQuery ? (listener) => listeners.push({ eventName: 'change', listener }) : undefined,
    removeListener: legacyMediaQuery ? (listener) => {
      const index = listeners.findIndex((entry) => entry.listener === listener)
      if (index >= 0) listeners.splice(index, 1)
    } : undefined
  }

  const messages = {
    scrollHeight: 320,
    scrollTop: 0
  }

  const sidebarTrigger = {}
  const sidebar = {
    classList: buildClassList(),
    contains(element) {
      return element === sidebarTrigger
    }
  }

  const panel = {
    classList: buildClassList(['hidden']),
    querySelector(selector) {
      if (selector === "[data-flat-pack--chat-scroll-target='messages']") return messages

      return null
    }
  }

  const mediaQueries = []
  const window = {
    matchMedia(query) {
      mediaQueries.push(query)
      return mediaQuery
    },
    requestAnimationFrame(callback) {
      callback()
    }
  }

  const ChatLayoutController = loadChatLayoutController({ window })
  const controller = new ChatLayoutController()
  controller.breakpointValue = breakpoint
  controller.sidebarTarget = sidebar
  controller.panelTarget = panel
  controller.hasSidebarTarget = true
  controller.hasPanelTarget = true

  return { controller, listeners, mediaQueries, mediaQuery, messages, panel, sidebar, sidebarTrigger }
}

test('declares a stimulus default for the split breakpoint', () => {
  const ChatLayoutController = loadChatLayoutController()

  assert.equal(ChatLayoutController.values.breakpoint.type.name, 'Number')
  assert.equal(ChatLayoutController.values.breakpoint.default, 640)
})

test('connect watches the default split breakpoint', () => {
  const { controller, mediaQueries } = buildController()

  controller.connect()

  assert.deepEqual(mediaQueries, ['(min-width: 640px)'])
})

test('connect watches the breakpoint value the component passes in', () => {
  const { controller, mediaQueries } = buildController({ breakpoint: 1024 })

  controller.connect()

  assert.deepEqual(mediaQueries, ['(min-width: 1024px)'])
})

test('connect defaults mobile split layouts to the sidebar view', () => {
  const { controller, panel, sidebar } = buildController()

  controller.connect()

  assert.equal(controller.mobileView, 'sidebar')
  assert.equal(sidebar.classList.contains('hidden'), false)
  assert.equal(panel.classList.contains('hidden'), true)
  assert.equal(panel.classList.contains('flex'), false)
})

test('clicking a sidebar trigger opens the panel and scrolls messages on mobile', () => {
  const { controller, messages, panel, sidebar, sidebarTrigger } = buildController()
  controller.connect()

  controller.openPanel({
    target: {
      closest(selector) {
        assert.equal(selector, "a, button, [role='button']")
        return sidebarTrigger
      }
    }
  })

  assert.equal(controller.mobileView, 'panel')
  assert.equal(sidebar.classList.contains('hidden'), true)
  assert.equal(panel.classList.contains('hidden'), false)
  assert.equal(panel.classList.contains('flex'), true)
  assert.equal(messages.scrollTop, messages.scrollHeight)
})

test('sidebar clicks that are not interactive triggers keep the sidebar visible', () => {
  const { controller, panel, sidebar } = buildController()
  controller.connect()

  controller.openPanel({
    target: {
      closest() {
        return null
      }
    }
  })

  assert.equal(controller.mobileView, 'sidebar')
  assert.equal(sidebar.classList.contains('hidden'), false)
  assert.equal(panel.classList.contains('hidden'), true)
})

test('desktop view shows both sidebar and panel without switching mobile state', () => {
  const { controller, mediaQuery, panel, sidebar, sidebarTrigger } = buildController({ desktop: true })
  controller.connect()

  controller.openPanel({
    target: {
      closest() {
        return sidebarTrigger
      }
    }
  })

  assert.equal(mediaQuery.matches, true)
  assert.equal(controller.mobileView, 'sidebar')
  assert.equal(sidebar.classList.contains('hidden'), false)
  assert.equal(panel.classList.contains('hidden'), false)
  assert.equal(panel.classList.contains('flex'), true)
})

test('viewport changes preserve the selected mobile panel after returning from desktop', () => {
  const { controller, mediaQuery, panel, sidebar, sidebarTrigger } = buildController()
  controller.connect()
  controller.openPanel({ target: { closest: () => sidebarTrigger } })

  mediaQuery.matches = true
  controller.handleViewportChange()
  mediaQuery.matches = false
  controller.handleViewportChange()

  assert.equal(controller.mobileView, 'panel')
  assert.equal(sidebar.classList.contains('hidden'), true)
  assert.equal(panel.classList.contains('hidden'), false)
  assert.equal(panel.classList.contains('flex'), true)
})

test('disconnect removes the registered media query listener', () => {
  const { controller, listeners } = buildController({ legacyMediaQuery: true })

  controller.connect()
  assert.equal(listeners.length, 1)

  controller.disconnect()
  assert.equal(listeners.length, 0)
})
