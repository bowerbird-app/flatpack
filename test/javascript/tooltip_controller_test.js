const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

function loadTooltipController() {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'controllers', 'tooltip_controller.js')
  const source = fs.readFileSync(filePath, 'utf8')
  const transformedSource = source
    .replace('import { Controller } from "@hotwired/stimulus"', 'class Controller {}')
    .replace(
      /import \{[\s\S]*?\} from "controllers\/flat_pack\/reduced_motion"/,
      `function prefersReducedMotion() { return false }
       function motionDuration() { return 0 }
       function motionTransition() { return "none" }
       function overlayOrigin() { return "center" }
       function overlayEnterOffset() { return "none" }`
    )
    .replace('export default class extends Controller', 'class TooltipController extends Controller') + '\nmodule.exports = TooltipController\n'

  const context = { module: { exports: {} }, exports: {} }
  vm.runInNewContext(transformedSource, context, { filename: filePath })
  return context.module.exports
}

function label(classes) {
  return {
    classList: { contains(name) { return classes.includes(name) } }
  }
}

function controllerFor({ collapsedOnly = true, sidebar = undefined, classes = [] } = {}) {
  const Controller = loadTooltipController()
  const element = {
    querySelector() { return classes.length ? label(classes) : null },
    closest() { return sidebar }
  }
  const controller = new Controller()
  controller.element = element
  controller.collapsedOnlyValue = collapsedOnly
  return controller
}

test('a closed rail shows the icon tooltip without sr-only', () => {
  const controller = controllerFor({
    sidebar: { dataset: { flatPackSidebarCollapsed: 'true' } },
    classes: ['flex-1', 'fp-sidebar-label']
  })

  assert.equal(controller.shouldShowTooltip(), true)
})

test('an open rail hides the collapsed-only tooltip', () => {
  const controller = controllerFor({
    sidebar: { dataset: { flatPackSidebarCollapsed: 'false' } },
    classes: ['flex-1', 'fp-sidebar-label', 'sr-only']
  })

  assert.equal(controller.shouldShowTooltip(), false)
})

test('a static collapsed item still tips from sr-only', () => {
  const controller = controllerFor({ classes: ['flex-1', 'sr-only'] })

  assert.equal(controller.shouldShowTooltip(), true)
})

test('a static expanded item does not tip', () => {
  const controller = controllerFor({ classes: ['flex-1'] })

  assert.equal(controller.shouldShowTooltip(), false)
})

test('tooltips that are not collapsed-only always show', () => {
  const controller = controllerFor({
    collapsedOnly: false,
    sidebar: { dataset: { flatPackSidebarCollapsed: 'false' } },
    classes: ['flex-1']
  })

  assert.equal(controller.shouldShowTooltip(), true)
})
