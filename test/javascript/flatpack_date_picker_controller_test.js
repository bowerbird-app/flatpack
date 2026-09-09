const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

function loadController(overrides = {}) {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'flatpack_date_picker_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformedSource = source
    .replace('import { Controller } from "@hotwired/stimulus"', 'class Controller {}')
    .replace(
      'import { playOverlayEnter, playOverlayExit } from "controllers/flat_pack/reduced_motion"',
      `function playOverlayEnter(element, options = {}) { element.classList.remove("hidden"); options.beforeAnimate?.() }
function playOverlayExit(element, options = {}) { element.classList.add("hidden"); options.onHidden?.(); return 0 }`
    )
    .replace('export default class extends Controller', 'class FlatpackDatePickerController extends Controller') + '\nmodule.exports = FlatpackDatePickerController\n'

  const context = {
    module: { exports: {} },
    exports: {},
    document: {
      activeElement: null,
      addEventListener() {},
      removeEventListener() {},
      body: { appendChild() {} }
    },
    window: {
      addEventListener() {},
      removeEventListener() {},
      matchMedia: () => ({ matches: false })
    },
    clearTimeout() {},
    ...overrides
  }

  vm.runInNewContext(transformedSource, context, { filename: filePath })

  return context.module.exports
}

function buildController() {
  const ControllerClass = loadController()
  const controller = new ControllerClass()
  controller.rangeValue = true
  controller.hasPresetLabelsValue = true
  controller.presetLabelsValue = {
    last_week: 'Last week',
    today: 'Today',
    yesterday: 'Yesterday'
  }
  controller.hasTriggerTarget = true
  controller.triggerTarget = { value: '' }
  controller.isOpen = false
  controller.committedPresetKey = null
  controller.draftPresetKey = null

  return controller
}

test('displayValue prefers preset label when preset key is provided', () => {
  const controller = buildController()
  const state = {
    start: new Date(2026, 4, 5),
    end: new Date(2026, 4, 11)
  }

  assert.equal(controller.displayValue(state, 'last_week'), 'Last week')
})

test('displayValue falls back to iso date range for custom selections', () => {
  const controller = buildController()
  const state = {
    start: new Date(2026, 4, 10),
    end: new Date(2026, 4, 20)
  }

  assert.equal(controller.displayValue(state, null), '2026-05-10 to 2026-05-20')
})

test('syncTriggerValue uses committed preset when picker is closed', () => {
  const controller = buildController()
  controller.committedPresetKey = 'today'

  controller.syncTriggerValue({
    start: new Date(2026, 5, 12),
    end: new Date(2026, 5, 12)
  })

  assert.equal(controller.triggerTarget.value, 'Today')
})

test('syncTriggerValue keeps committed value when picker is open before apply', () => {
  const controller = buildController()
  controller.isOpen = true
  controller.committedPresetKey = 'today'
  controller.draftPresetKey = 'last_week'

  controller.syncTriggerValue({
    start: new Date(2026, 5, 12),
    end: new Date(2026, 5, 12)
  })

  assert.equal(controller.triggerTarget.value, 'Today')
})

test('apply infers preset label for matching calendar-selected range', () => {
  const controller = buildController()
  controller.today = new Date(2026, 5, 18)
  controller.draft = {
    start: new Date(2026, 5, 17),
    end: new Date(2026, 5, 17)
  }
  controller.draftPresetKey = null

  controller.apply({ preventDefault() {} })

  assert.equal(controller.committedPresetKey, 'yesterday')
  assert.equal(controller.triggerTarget.value, 'Yesterday')
})

test('computePresetRange returns rolling 4-week range for last_4_weeks', () => {
  const controller = buildController()
  controller.today = new Date(2026, 5, 18)

  const range = controller.computePresetRange('last_4_weeks')

  assert.equal(range.start.getTime(), new Date(2026, 4, 22).getTime())
  assert.equal(range.end.getTime(), new Date(2026, 5, 18).getTime())
})

function overlayPanel() {
  const classes = new Set(['hidden'])

  return {
    classList: {
      add(name) { classes.add(name) },
      remove(name) { classes.delete(name) },
      contains(name) { return classes.has(name) }
    },
    style: { display: 'none' },
    attributes: {},
    setAttribute(name, value) { this.attributes[name] = String(value) },
    contains() { return false }
  }
}

function pickerWithPanel() {
  const controller = buildController()
  controller.panelElement = overlayPanel()
  controller.mountPanelToBody = () => {}
  controller.setPanelInteractivity = () => {}
  controller.addGlobalListeners = () => {}
  controller.removeGlobalListeners = () => {}
  controller.render = () => {}
  controller.positionPanel = () => {}
  controller.restorePanelParent = () => {}
  controller.defaultViewMode = () => 'calendar'
  controller.committed = {}
  controller.hideTimeout = null
  controller.triggerTarget = {
    value: '',
    attributes: {},
    setAttribute(name, value) { this.attributes[name] = String(value) },
    focus() {}
  }

  return controller
}

test('open unhides the panel and close hides it after overlay exit', () => {
  const controller = pickerWithPanel()

  controller.open()

  assert.equal(controller.panelElement.classList.contains('hidden'), false)
  assert.equal(controller.panelElement.style.display, '')
  assert.equal(controller.panelElement.attributes['aria-hidden'], 'false')
  assert.equal(controller.isOpen, true)

  controller.close()

  assert.equal(controller.panelElement.classList.contains('hidden'), true)
  assert.equal(controller.panelElement.style.display, 'none')
  assert.equal(controller.panelElement.attributes['aria-hidden'], 'true')
  assert.equal(controller.isOpen, false)
})

test('close is a no-op when the panel is already closed', () => {
  const controller = pickerWithPanel()

  controller.close()

  assert.equal(controller.panelElement.classList.contains('hidden'), true)
  assert.equal(controller.panelElement.style.display, 'none')
  assert.equal(controller.isOpen, false)
})
