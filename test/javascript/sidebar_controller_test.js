const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

function loadSidebarController() {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'sidebar_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformedSource = source
    .replace('import { Controller } from "@hotwired/stimulus"', 'class Controller {}')
    .replace('export default class extends Controller', 'class SidebarController extends Controller') + '\nmodule.exports = SidebarController\n'

  const context = { module: { exports: {} }, exports: {} }
  vm.runInNewContext(transformedSource, context, { filename: filePath })
  return context.module.exports
}

function button() {
  const attrs = {}
  return {
    attrs,
    setAttribute(name, value) { attrs[name] = String(value) },
    getAttribute(name) { return attrs[name] }
  }
}

function buildMenu({ columnCollapsed = null, ownCollapsed = null, column = true } = {}) {
  const listeners = []
  const columnNode = {
    listeners,
    getAttribute(name) {
      if (name === 'data-flat-pack-sidebar-collapsed') return columnCollapsed
      return null
    },
    addEventListener(type, fn) { listeners.push({ type, fn }) },
    removeEventListener(type, fn) {
      const index = listeners.findIndex((entry) => entry.type === type && entry.fn === fn)
      if (index >= 0) listeners.splice(index, 1)
    }
  }
  const element = {
    getAttribute(name) {
      if (name === 'data-flat-pack-sidebar-collapsed') return ownCollapsed
      return null
    },
    closest(selector) {
      const value = String(selector)
      if (value.includes('sidebar-layout-target')) return column ? columnNode : null
      if (value.includes('data-flat-pack-sidebar-collapsed')) {
        if (ownCollapsed !== null) return element
        if (column && columnCollapsed !== null) return columnNode
        return null
      }
      return null
    }
  }
  const collapse = button()
  const expand = button()
  const Controller = loadSidebarController()
  const controller = Object.assign(new Controller(), {
    element,
    collapseTargets: [collapse],
    expandTargets: [expand]
  })

  return { controller, collapse, expand, columnNode }
}

test('aria follows the column attribute and the collapse event', () => {
  const { controller, collapse, expand, columnNode } = buildMenu({ columnCollapsed: 'true' })

  controller.connect()

  assert.equal(collapse.attrs['aria-expanded'], 'false')
  assert.equal(expand.attrs['aria-expanded'], 'false')
  assert.equal(columnNode.listeners.length, 1)
  assert.equal(columnNode.listeners[0].type, 'flat-pack--sidebar-layout:collapse')

  columnNode.listeners[0].fn({ detail: { collapsed: false } })

  assert.equal(collapse.attrs['aria-expanded'], 'true')
  assert.equal(expand.attrs['aria-expanded'], 'true')

  controller.disconnect()
  assert.equal(columnNode.listeners.length, 0)
})

test('a standalone menu reads its own collapsed attribute', () => {
  const { controller, collapse, expand, columnNode } = buildMenu({
    column: false,
    ownCollapsed: 'true'
  })

  controller.connect()

  assert.equal(collapse.attrs['aria-expanded'], 'false')
  assert.equal(expand.attrs['aria-expanded'], 'false')
  assert.equal(columnNode.listeners.length, 0)

  controller.disconnect()
  assert.equal(columnNode.listeners.length, 0)
})

test('a menu with no collapsed attribute starts expanded', () => {
  const { controller, collapse, expand } = buildMenu({ column: false, ownCollapsed: null })

  controller.connect()

  assert.equal(collapse.attrs['aria-expanded'], 'true')
  assert.equal(expand.attrs['aria-expanded'], 'true')
})
