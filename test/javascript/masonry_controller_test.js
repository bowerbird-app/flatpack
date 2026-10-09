const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

function loadController() {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'masonry_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformedSource = source
    .replace('import { Controller } from "@hotwired/stimulus"', 'class Controller {}')
    .replace('export default class extends Controller', 'class MasonryController extends Controller') + '\nmodule.exports = MasonryController\n'

  const context = {
    module: { exports: {} },
    exports: {},
    CSS: { supports() { return false } },
    window: {
      addEventListener() {},
      removeEventListener() {},
      getComputedStyle() { return { rowGap: '16px', gap: '16px' } }
    },
    requestAnimationFrame(fn) { fn(); return 1 },
    cancelAnimationFrame() {}
  }
  context.window.CSS = context.CSS
  context.window.getComputedStyle = context.window.getComputedStyle

  vm.runInNewContext(transformedSource, context, { filename: filePath })
  return context.module.exports
}

function buildItem(height) {
  const child = {
    getBoundingClientRect() { return { top: 0, bottom: height, height } }
  }
  return {
    style: { gridRowEnd: '' },
    children: [child],
    firstElementChild: child,
    lastElementChild: child,
    scrollHeight: height,
    getBoundingClientRect() { return { height } }
  }
}

function buildController({ items, native = false, rowHeight = 8 } = {}) {
  const MasonryController = loadController()
  const dataset = {}
  const listeners = { add: [], remove: [] }
  const controller = Object.assign(new MasonryController(), {
    itemTargets: items,
    hasItemTarget: items.length > 0,
    rowHeightValue: rowHeight,
    element: {
      dataset,
      children: items,
      addEventListener(type, handler, options) { listeners.add.push({ type, handler, options }) },
      removeEventListener(type, handler, options) { listeners.remove.push({ type, handler, options }) }
    },
    supportsNativeMasonry() { return native }
  })

  return { controller, dataset, listeners }
}

test('layout sets grid-row span from measured height and gap', () => {
  const items = [buildItem(40), buildItem(80)]
  const { controller, dataset } = buildController({ items })

  controller.layout()

  assert.equal(dataset.fpMasonryReady, 'true')
  assert.equal(items[0].style.gridRowEnd, 'span 3')
  assert.equal(items[1].style.gridRowEnd, 'span 4')
})

test('layout skips measurement when native masonry is supported', () => {
  const items = [buildItem(40)]
  const { controller, dataset } = buildController({ items, native: true })

  controller.layout()

  assert.equal(dataset.fpMasonryNative, 'true')
  assert.equal(dataset.fpMasonryReady, undefined)
  assert.equal(items[0].style.gridRowEnd, '')
})

test('connect marks native masonry and does not observe', () => {
  const items = [buildItem(40)]
  const { controller, dataset, listeners } = buildController({ items, native: true })

  controller.connect()

  assert.equal(dataset.fpMasonryNative, 'true')
  assert.equal(listeners.add.length, 0)
})

test('layout is idempotent when spans already match', () => {
  const items = [buildItem(40)]
  const { controller } = buildController({ items })

  controller.layout()
  const firstSpan = items[0].style.gridRowEnd
  controller.layout()

  assert.equal(items[0].style.gridRowEnd, firstSpan)
  assert.equal(items[0].style.gridRowEnd, 'span 3')
})

test('disconnect removes load and resize listeners', () => {
  const items = [buildItem(40)]
  const { controller, listeners } = buildController({ items })
  controller.frame = 7

  controller.disconnect()

  assert.equal(listeners.remove.some((entry) => entry.type === 'load'), true)
  assert.equal(controller.frame, null)
})
