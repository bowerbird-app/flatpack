const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

function loadController(overrides = {}) {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'flatpack_date_picker_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformedSource = source
    .replace('import { Controller } from "@hotwired/stimulus"', `class Controller {
  dispatch(eventName, { target = this.element, detail = {}, prefix = this.identifier, bubbles = true } = {}) {
    const type = prefix ? \`\${prefix}:\${eventName}\` : eventName
    const event = new CustomEvent(type, { detail, bubbles })
    target.dispatchEvent(event)
    return event
  }
}`)
    .replace('import { flatPackCopy } from "flat_pack/copy"', 'function flatPackCopy(key) { return ({ "date_picker.summary": "Select a date from calendar or use a quick range preset." })[key] || key }')
    .replace(
      'import { playOverlayEnter, playOverlayExit, cancelOverlayHide } from "controllers/flat_pack/reduced_motion"',
      `function playOverlayEnter(element, options = {}) { element.classList.remove("hidden"); options.beforeAnimate?.() }
function playOverlayExit(element, options = {}) { element.classList.add("hidden"); options.onHidden?.(); return 0 }
function cancelOverlayHide() {}`
    )
    .replace(/import \{[^}]+\} from "flat_pack\/click_outside"\n/, "")
    .replace(/import \{[^}]+\} from "flat_pack\/positioning"\n/, "")
    .replace('export default class extends Controller', 'class FlatpackDatePickerController extends Controller') + '\nmodule.exports = FlatpackDatePickerController\n'
  const flatPackRoot = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack')
  const helperSource = (name) => fs.readFileSync(path.join(flatPackRoot, name), 'utf8').replaceAll('export function ', 'function ')
  const clickOutsideSource = helperSource('click_outside.js')
  const positioningSource = helperSource('positioning.js')

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
    Element: class Element {
      closest(selector) {
        if (selector === '[data-flat-pack-date-picker-command]' && this.dataset?.flatPackDatePickerCommand) {
          return this
        }

        return null
      }

      hasAttribute(name) {
        return name === 'data-flat-pack-date-picker-command' && !!this.dataset?.flatPackDatePickerCommand
      }
    },
    Event: class Event {
      constructor(type, init = {}) {
        this.type = type
        this.bubbles = !!init.bubbles
      }
    },
    CustomEvent: class CustomEvent {
      constructor(type, init = {}) {
        this.type = type
        this.bubbles = !!init.bubbles
        this.detail = init.detail
      }
    },
    clearTimeout() {},
    ...overrides
  }

  vm.runInNewContext(`${clickOutsideSource}\n${positioningSource}\n${transformedSource}`, context, { filename: filePath })

  const ControllerClass = context.module.exports
  ControllerClass.Element = context.Element
  return ControllerClass
}

function buildController() {
  const ControllerClass = loadController()
  const controller = new ControllerClass()
  controller.identifier = 'flat-pack--flatpack-date-picker'
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
  controller.elementEvents = []
  controller.element = {
    dispatchEvent(event) {
      controller.elementEvents.push(event)
      return true
    }
  }

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

test('apply dispatches bubbling change on hidden fields and a custom apply event', () => {
  const controller = buildController()
  const startField = { value: '', events: [], dispatchEvent(event) { this.events.push(event); return true } }
  const endField = { value: '', events: [], dispatchEvent(event) { this.events.push(event); return true } }
  const presetField = { value: '', events: [], dispatchEvent(event) { this.events.push(event); return true } }

  controller.today = new Date(2026, 5, 18)
  controller.draft = {
    start: new Date(2026, 5, 17),
    end: new Date(2026, 5, 17)
  }
  controller.draftPresetKey = null
  controller.hasRangeStartFieldTarget = true
  controller.hasRangeEndFieldTarget = true
  controller.hasPresetKeyFieldTarget = true
  controller.rangeStartFieldTarget = startField
  controller.rangeEndFieldTarget = endField
  controller.presetKeyFieldTarget = presetField

  controller.apply({ preventDefault() {} })

  assert.equal(startField.value, '2026-06-17')
  assert.equal(endField.value, '2026-06-17')
  assert.equal(presetField.value, 'yesterday')
  assert.equal(startField.events.length, 1)
  assert.equal(startField.events[0].type, 'change')
  assert.equal(startField.events[0].bubbles, true)
  assert.equal(endField.events[0].type, 'change')
  assert.equal(presetField.events[0].type, 'change')

  const applyEvent = controller.elementEvents.find((event) => event.type === 'flat-pack--flatpack-date-picker:apply')
  assert.ok(applyEvent)
  assert.equal(applyEvent.bubbles, true)
  assert.equal(applyEvent.detail.start, '2026-06-17')
  assert.equal(applyEvent.detail.end, '2026-06-17')
  assert.equal(applyEvent.detail.preset, 'yesterday')
})

test('clear dispatches the same bubbling events as apply', () => {
  const controller = buildController()
  const startField = { value: '2026-06-17', events: [], dispatchEvent(event) { this.events.push(event); return true } }
  const endField = { value: '2026-06-17', events: [], dispatchEvent(event) { this.events.push(event); return true } }
  const presetField = { value: 'yesterday', events: [], dispatchEvent(event) { this.events.push(event); return true } }

  controller.committed = {
    start: new Date(2026, 5, 17),
    end: new Date(2026, 5, 17)
  }
  controller.committedPresetKey = 'yesterday'
  controller.hasRangeStartFieldTarget = true
  controller.hasRangeEndFieldTarget = true
  controller.hasPresetKeyFieldTarget = true
  controller.rangeStartFieldTarget = startField
  controller.rangeEndFieldTarget = endField
  controller.presetKeyFieldTarget = presetField

  controller.clear({ preventDefault() {} })

  assert.equal(startField.value, '')
  assert.equal(endField.value, '')
  assert.equal(presetField.value, '')
  assert.equal(startField.events.length, 1)
  assert.equal(startField.events[0].type, 'change')
  assert.equal(startField.events[0].bubbles, true)
  assert.equal(endField.events[0].type, 'change')
  assert.equal(presetField.events[0].type, 'change')

  const applyEvent = controller.elementEvents.find((event) => event.type === 'flat-pack--flatpack-date-picker:apply')
  assert.ok(applyEvent)
  assert.equal(applyEvent.bubbles, true)
  assert.equal(applyEvent.detail.start, null)
  assert.equal(applyEvent.detail.end, null)
  assert.equal(applyEvent.detail.preset, null)
})

test('click on data-flat-pack-date-picker-command=clear reaches clear', () => {
  const controller = buildController()
  const calls = []
  controller.clear = (event) => { calls.push(event) }

  const commandElement = new controller.constructor.Element()
  commandElement.dataset = { flatPackDatePickerCommand: 'clear' }

  controller.handlePanelClick({ target: commandElement })

  assert.equal(calls.length, 1)
  assert.equal(calls[0].target, commandElement)
})

test('computePresetRange returns rolling 4-week range for last_4_weeks', () => {
  const controller = buildController()
  controller.today = new Date(2026, 5, 18)

  const range = controller.computePresetRange('last_4_weeks')

  assert.equal(range.start.getTime(), new Date(2026, 4, 22).getTime())
  assert.equal(range.end.getTime(), new Date(2026, 5, 18).getTime())
})

test('computePresetRange returns rolling 30-day range for last_30_days', () => {
  const controller = buildController()
  controller.today = new Date(2026, 5, 18)

  const range = controller.computePresetRange('last_30_days')

  assert.equal(range.start.getTime(), new Date(2026, 4, 20).getTime())
  assert.equal(range.end.getTime(), new Date(2026, 5, 18).getTime())
})

test('computePresetRange prefers supplied custom ranges', () => {
  const controller = buildController()
  controller.today = new Date(2026, 5, 18)
  controller.hasPresetRangesValue = true
  controller.presetRangesValue = {
    last_45_days: { start: '2026-04-04', end: '2026-05-18' }
  }

  const range = controller.computePresetRange('last_45_days')

  assert.equal(range.start.getTime(), new Date(2026, 3, 4).getTime())
  assert.equal(range.end.getTime(), new Date(2026, 4, 18).getTime())
})

test('applyPreset fills the draft from a named last_30_days range', () => {
  const controller = buildController()
  controller.today = new Date(2026, 5, 18)
  controller.clipRange = (range) => range
  controller.render = () => {}

  controller.applyPreset('last_30_days')

  assert.equal(controller.draft.start.getTime(), new Date(2026, 4, 20).getTime())
  assert.equal(controller.draft.end.getTime(), new Date(2026, 5, 18).getTime())
  assert.equal(controller.draftPresetKey, 'last_30_days')
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
