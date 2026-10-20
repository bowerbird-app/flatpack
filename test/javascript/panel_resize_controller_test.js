const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

function loadPanelResizeController() {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'panel_resize_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')
    .replace('import { Controller } from "@hotwired/stimulus"', 'class Controller {}')
    .replace('export default class extends Controller', 'class PanelResizeController extends Controller') + '\nmodule.exports = PanelResizeController\n'

  const localMemory = new Map()
  const env = {
    min: '12rem',
    max: '20rem',
    defaultWidth: '16rem',
    fontSize: '16px',
    measured: 200,
    boxWidth: 256
  }
  const documentElement = {}
  const context = {
    module: { exports: {} },
    exports: {},
    window: {
      innerWidth: 1280,
      addEventListener() {},
      removeEventListener() {}
    },
    document: { documentElement },
    localStorage: {
      getItem(key) { return localMemory.has(key) ? localMemory.get(key) : null },
      setItem(key, value) { localMemory.set(key, String(value)) },
      removeItem(key) { localMemory.delete(key) }
    },
    CustomEvent,
    getComputedStyle(node) {
      if (node === documentElement) {
        return { fontSize: env.fontSize, getPropertyValue() { return '' } }
      }
      return {
        getPropertyValue(name) {
          if (name === '--fp-panel-min') return env.min
          if (name === '--fp-panel-max') return env.max
          if (name === '--fp-panel-default') return env.defaultWidth
          return ''
        }
      }
    }
  }

  vm.runInNewContext(source, context, { filename: filePath })
  return { Controller: context.module.exports, storage: localMemory, window: context.window, env, document: context.document }
}

function mount({
  side = 'left',
  collapses = true,
  storageKey = 'app-shell:rail:width',
  boxWidth = 256
} = {}) {
  const loaded = loadPanelResizeController()
  loaded.env.boxWidth = boxWidth
  const styleProps = {}
  const listeners = {}
  const handle = {
    attrs: {},
    dataset: {},
    blur() {},
    listeners,
    setAttribute(name, value) { this.attrs[name] = String(value) },
    addEventListener(type, fn) { (listeners[type] ||= []).push(fn) },
    removeEventListener(type, fn) {
      listeners[type] = (listeners[type] || []).filter((item) => item !== fn)
    },
    setPointerCapture() {},
    releasePointerCapture() {}
  }
  const columnListeners = {}
  const column = {
    dataset: { mobileDrawerSide: side },
    style: {
      setProperty(name, value, priority) { styleProps[name] = { value, priority: priority || '' } },
      getPropertyValue(name) { return styleProps[name] ? styleProps[name].value : '' },
      getPropertyPriority(name) { return styleProps[name] ? styleProps[name].priority : '' },
      removeProperty(name) { delete styleProps[name] }
    },
    getBoundingClientRect() {
      if (styleProps.width) return { width: loaded.env.measured }
      if (styleProps['--fp-panel-width']) return { width: parseFloat(styleProps['--fp-panel-width'].value) }
      return { width: loaded.env.boxWidth }
    },
    addEventListener(type, fn) { (columnListeners[type] ||= []).push(fn) },
    removeEventListener() {},
    dispatchEvent(event) {
      ;(columnListeners[event.type] || []).forEach((fn) => fn(event))
      return true
    }
  }
  const controller = new loaded.Controller()
  controller.element = column
  controller.handleTarget = handle
  controller.hasHandleTarget = true
  controller.collapsesValue = collapses
  controller.storageKeyValue = storageKey || ''
  controller.hasStorageKeyValue = storageKey != null

  return { ...loaded, controller, column, handle, styleProps }
}

function pointerDown(handle, clientX) {
  return { button: 0, clientX, pointerId: 1, currentTarget: handle, preventDefault() {} }
}

test('a stored integer is clamped and painted on connect', () => {
  const { controller, column, handle, storage } = mount()
  storage.set('app-shell:rail:width', '400')
  controller.connect()

  assert.equal(column.style.getPropertyValue('--fp-panel-width'), '320px')
  assert.equal(column.dataset.flatPackPanelResized, 'true')
  assert.equal(handle.attrs['aria-valuenow'], '320')
  assert.equal(handle.attrs['aria-valuemin'], '192')
  assert.equal(handle.attrs['aria-valuemax'], '320')
  assert.equal(storage.get('app-shell:rail:width'), '400')
})

test('a non integer width key is ignored', () => {
  const { controller, column, storage } = mount()
  storage.set('app-shell:rail:width', '300px')
  controller.connect()

  assert.equal(column.style.getPropertyValue('--fp-panel-width'), '')
  assert.equal(column.dataset.flatPackPanelResized, undefined)
})

test('drag clamps to the max and persists the rounded width', () => {
  const { controller, column, handle, storage } = mount()
  controller.connect()
  controller.start(pointerDown(handle, 100))
  handle.listeners.pointermove[0]({ clientX: 400, pointerId: 1 })

  assert.equal(column.style.getPropertyValue('--fp-panel-width'), '320px')
  assert.equal(column.style.getPropertyValue('transition-property'), 'none')
  assert.equal(column.style.getPropertyPriority('transition-property'), 'important')
  assert.equal(column.dataset.flatPackPanelResized, 'true')

  handle.listeners.pointerup[0]({ pointerId: 1 })
  assert.equal(storage.get('app-shell:rail:width'), '320')
  assert.equal(column.style.getPropertyValue('transition-property'), '')
  assert.equal(column.style.getPropertyValue('width'), '')
})

test('an aside drag below the floor clamps and does not collapse', () => {
  const { controller, column, handle, storage } = mount({
    side: 'right',
    collapses: false,
    storageKey: 'app-shell:aside:width'
  })
  let collapsed = 0
  column.addEventListener('flat-pack:collapse-rail', () => { collapsed += 1 })
  controller.connect()
  controller.start(pointerDown(handle, 100))
  handle.listeners.pointermove[0]({ clientX: 400, pointerId: 1 })
  handle.listeners.pointerup[0]({ pointerId: 1 })

  assert.equal(column.style.getPropertyValue('--fp-panel-width'), '192px')
  assert.equal(storage.get('app-shell:aside:width'), '192')
  assert.equal(collapsed, 0)
})

test('a rail drag below the floor collapses and leaves width storage alone', () => {
  const { controller, column, handle, storage } = mount()
  storage.set('app-shell:rail:width', '300')
  let collapsed = 0
  column.addEventListener('flat-pack:collapse-rail', () => { collapsed += 1 })
  controller.connect()
  assert.equal(column.style.getPropertyValue('--fp-panel-width'), '300px')

  controller.start(pointerDown(handle, 300))
  handle.listeners.pointermove[0]({ clientX: 40, pointerId: 1 })

  assert.equal(collapsed, 1)
  assert.equal(storage.get('app-shell:rail:width'), '300')
  assert.equal(column.style.getPropertyValue('--fp-panel-width'), '300px')
  assert.equal(column.dataset.flatPackPanelResized, 'true')
  assert.equal(column.style.getPropertyValue('transition-property'), '')
})

test('a rail with no saved width collapses back to the token', () => {
  const { controller, column, handle, storage } = mount()
  let collapsed = 0
  column.addEventListener('flat-pack:collapse-rail', () => { collapsed += 1 })
  controller.connect()
  controller.start(pointerDown(handle, 200))
  handle.listeners.pointermove[0]({ clientX: 20, pointerId: 1 })

  assert.equal(collapsed, 1)
  assert.equal(storage.has('app-shell:rail:width'), false)
  assert.equal(column.style.getPropertyValue('--fp-panel-width'), '')
  assert.equal(column.dataset.flatPackPanelResized, undefined)
})

test('arrow keys grow a left panel and shrink a right panel', () => {
  const left = mount()
  left.controller.connect()
  left.controller.nudge({ key: 'ArrowRight', preventDefault() {} })
  assert.equal(left.column.style.getPropertyValue('--fp-panel-width'), '272px')
  assert.equal(left.storage.get('app-shell:rail:width'), '272')

  left.controller.nudge({ key: 'ArrowLeft', preventDefault() {} })
  assert.equal(left.storage.get('app-shell:rail:width'), '256')

  const right = mount({ side: 'right', collapses: false, storageKey: 'app-shell:aside:width' })
  right.controller.connect()
  right.controller.nudge({ key: 'ArrowRight', preventDefault() {} })
  assert.equal(right.column.style.getPropertyValue('--fp-panel-width'), '240px')
  assert.equal(right.storage.get('app-shell:aside:width'), '240')
})

test('a rail arrow below the floor collapses and does not write a width', () => {
  const { controller, column, storage, env } = mount()
  env.boxWidth = 200
  let collapsed = 0
  column.addEventListener('flat-pack:collapse-rail', () => { collapsed += 1 })
  controller.connect()
  controller.nudge({ key: 'ArrowLeft', preventDefault() {} })

  assert.equal(collapsed, 1)
  assert.equal(storage.has('app-shell:rail:width'), false)
  assert.equal(column.style.getPropertyValue('--fp-panel-width'), '')
})

test('an arrow that does not change the width does not write storage', () => {
  const { controller, storage } = mount({ collapses: false })
  storage.set('app-shell:rail:width', '320')
  controller.connect()
  controller.nudge({ key: 'ArrowRight', preventDefault() {} })

  assert.equal(storage.get('app-shell:rail:width'), '320')
})

test('double click resets to the default width', () => {
  const { controller, column, handle, storage } = mount()
  controller.connect()
  controller.start(pointerDown(handle, 100))
  handle.listeners.pointermove[0]({ clientX: 180, pointerId: 1 })
  handle.listeners.pointerup[0]({ pointerId: 1 })
  assert.equal(storage.get('app-shell:rail:width'), '320')

  controller.reset({ preventDefault() {} })
  assert.equal(storage.has('app-shell:rail:width'), false)
  assert.equal(column.style.getPropertyValue('--fp-panel-width'), '')
  assert.equal(column.dataset.flatPackPanelResized, undefined)
  assert.equal(handle.attrs['aria-valuenow'], '256')
})

test('mobile resize gestures do nothing', () => {
  const { controller, column, handle, storage, window } = mount()
  storage.set('app-shell:rail:width', '280')
  window.innerWidth = 500
  controller.connect()
  const painted = column.style.getPropertyValue('--fp-panel-width')

  controller.start(pointerDown(handle, 10))
  controller.nudge({ key: 'ArrowRight', preventDefault() {} })
  controller.reset({ preventDefault() {} })

  assert.equal(handle.listeners.pointermove, undefined)
  assert.equal(column.style.getPropertyValue('transition-property'), '')
  assert.equal(column.style.getPropertyValue('--fp-panel-width'), painted)
  assert.equal(storage.get('app-shell:rail:width'), '280')
})

test('a pointer drag marks pointer focus and blurs the handle on release', () => {
  const { controller, handle, document } = mount()
  let blurred = 0
  handle.blur = () => { blurred += 1 }
  controller.connect()
  document.activeElement = handle

  controller.start(pointerDown(handle, 100))
  assert.equal(handle.dataset.pointerFocus, 'true')

  handle.listeners.pointerup[0]({ pointerId: 1 })
  assert.equal(blurred, 1)
  assert.equal(handle.dataset.pointerFocus, undefined)
})

test('an arrow nudge does not mark pointer focus or blur the handle', () => {
  const { controller, handle, document } = mount()
  let blurred = 0
  handle.blur = () => { blurred += 1 }
  controller.connect()
  document.activeElement = handle

  controller.nudge({ key: 'ArrowRight', preventDefault() {} })

  assert.equal(handle.dataset.pointerFocus, undefined)
  assert.equal(blurred, 0)
})

test('a non primary button does not start a drag', () => {
  const { controller, column, handle } = mount()
  controller.connect()
  controller.start({ button: 1, clientX: 10, pointerId: 1, currentTarget: handle, preventDefault() {} })

  assert.equal(handle.listeners.pointermove, undefined)
  assert.equal(column.style.getPropertyValue('transition-property'), '')
})

test('var bounds are measured and then restored', () => {
  const { controller, column, handle, env } = mount({ collapses: false })
  env.min = 'var(--sidebar-content-min-width)'
  env.max = '320px'
  env.defaultWidth = '256px'
  env.measured = 200
  controller.connect()

  assert.equal(handle.attrs['aria-valuemin'], '200')
  assert.equal(column.style.getPropertyValue('width'), '')
  assert.equal(column.style.getPropertyValue('transition-property'), '')

  controller.start(pointerDown(handle, 100))
  handle.listeners.pointermove[0]({ clientX: 0, pointerId: 1 })
  assert.equal(column.style.getPropertyValue('--fp-panel-width'), '200px')
})

test('a column without a storage key still resizes and does not touch storage', () => {
  const { controller, column, handle, storage } = mount({ storageKey: null })
  controller.connect()
  controller.start(pointerDown(handle, 100))
  handle.listeners.pointermove[0]({ clientX: 140, pointerId: 1 })
  handle.listeners.pointerup[0]({ pointerId: 1 })

  assert.equal(column.style.getPropertyValue('--fp-panel-width'), '296px')
  assert.equal(storage.size, 0)
})
