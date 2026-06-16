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
    .replace('export default class extends Controller', 'class FlatpackDatePickerController extends Controller') + '\nmodule.exports = FlatpackDatePickerController\n'

  const context = {
    module: { exports: {} },
    exports: {},
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
    last_month: 'Last month',
    today: 'Today'
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

test('manual calendar range matching a preset displays the preset label after apply', () => {
  const controller = buildController()
  controller.today = new Date(2026, 5, 16)
  controller.draft = {
    start: new Date(2026, 4, 1),
    end: new Date(2026, 4, 31)
  }
  controller.syncFormFields = () => {}
  controller.close = () => {}

  controller.apply({ preventDefault() {} })

  assert.equal(controller.committedPresetKey, 'last_month')
  assert.equal(controller.triggerTarget.value, 'Last month')
})

test('manual calendar range that does not match a preset keeps explicit dates after apply', () => {
  const controller = buildController()
  controller.today = new Date(2026, 5, 16)
  controller.draft = {
    start: new Date(2026, 4, 2),
    end: new Date(2026, 4, 30)
  }
  controller.syncFormFields = () => {}
  controller.close = () => {}

  controller.apply({ preventDefault() {} })

  assert.equal(controller.committedPresetKey, null)
  assert.equal(controller.triggerTarget.value, '2026-05-02 to 2026-05-30')
})

test('partial manual range keeps unfinished summary text', () => {
  const controller = buildController()
  const state = {
    start: new Date(2026, 4, 1),
    end: null
  }

  assert.equal(controller.displayValue(state, controller.resolvedPresetKeyForState(state)), '2026-05-01 to …')
})

test('automatic calendar preset matching is range only', () => {
  const controller = buildController()
  controller.rangeValue = false
  const state = {
    start: new Date(2026, 5, 16),
    end: null
  }

  assert.equal(controller.resolvedPresetKeyForState(state), null)
})

test('renderListOptionSelection highlights preset buttons only', () => {
  const controller = buildController()
  const selectedButton = buildOptionButton('last_week')
  const unselectedButton = buildOptionButton('today', ['bg-[var(--button-primary-background-color)]'])
  controller.panelElement = {
    querySelectorAll(selector) {
      assert.equal(selector, '[data-flat-pack-date-picker-command="preset"]')
      return [selectedButton, unselectedButton]
    }
  }
  controller.draftPresetKey = 'last_week'

  controller.renderListOptionSelection()

  assert.equal(selectedButton.classes.has('bg-[var(--button-primary-background-color)]'), true)
  assert.equal(selectedButton.classes.has('text-[var(--button-primary-text-color)]'), true)
  assert.equal(unselectedButton.classes.has('bg-[var(--button-primary-background-color)]'), false)
})

function buildOptionButton(preset, initialClasses = []) {
  const classes = new Set(initialClasses)

  return {
    classes,
    dataset: {
      flatPackDatePickerCommand: 'preset',
      flatPackDatePickerPreset: preset
    },
    classList: {
      toggle(className, selected) {
        if (selected) {
          classes.add(className)
        } else {
          classes.delete(className)
        }
      }
    }
  }
}
