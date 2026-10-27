const test = require("node:test")
const assert = require("node:assert/strict")
const fs = require("node:fs")
const path = require("node:path")
const vm = require("node:vm")

function loadController(globals) {
  const root = path.join(__dirname, "..", "..", "app", "javascript", "flat_pack")
  const helper = (name) => fs.readFileSync(path.join(root, name), "utf8").replaceAll("export function ", "function ")
  const source = fs.readFileSync(path.join(root, "controllers", "flatpack_date_picker_controller.js"), "utf8")
    .replace('import { Controller } from "@hotwired/stimulus"', "class Controller {}")
    .replace('import { flatPackCopy } from "flat_pack/copy"', "function flatPackCopy(key) { return key }")
    .replace(
      'import { playOverlayEnter, playOverlayExit, cancelOverlayHide } from "controllers/flat_pack/reduced_motion"',
      `function playOverlayEnter(element, options = {}) { element.classList.remove("hidden"); options.beforeAnimate?.() }
       function playOverlayExit(element, options = {}) { element.classList.add("hidden"); options.onHidden?.(); return 0 }
       function cancelOverlayHide() {}`
    )
    .replace(/import \{[^}]+\} from "flat_pack\/click_outside"\n/, "")
    .replace(/import \{[^}]+\} from "flat_pack\/positioning"\n/, "")
    .replace("export default class extends Controller", "class FlatpackDatePickerController extends Controller")

  const context = {
    module: { exports: {} },
    exports: {},
    window: globals.window,
    document: globals.document,
    getComputedStyle: globals.getComputedStyle
  }
  vm.runInNewContext(
    `${helper("click_outside.js")}\n${helper("positioning.js")}\n${source}\nmodule.exports = FlatpackDatePickerController\n`,
    context,
    { filename: "flatpack_date_picker_controller.js" }
  )
  return context.module.exports
}

function events() {
  const entries = []
  return {
    entries,
    addEventListener(type, listener, capture) {
      entries.push({ type, listener, capture: capture === true })
    },
    removeEventListener(type, listener, capture) {
      const flag = capture === true
      const index = entries.findIndex((entry) => {
        return entry.type === type && entry.listener === listener && entry.capture === flag
      })
      if (index >= 0) entries.splice(index, 1)
    },
    dispatch(type, event) {
      entries.filter((entry) => entry.type === type).forEach((entry) => entry.listener(event))
    }
  }
}

function mount({
  anchor,
  panel = { width: 280, height: 200 },
  viewport = { width: 800, height: 700 },
  edge = "8px"
} = {}) {
  const windowEvents = events()
  const documentEvents = events()
  const mode = { mobile: false }
  const body = {}
  const host = {
    appendChild(node) { node.parentNode = host },
    insertBefore(node) { node.parentNode = host }
  }
  let panelParent = host
  const classes = new Set(["hidden"])
  const panelElement = {
    style: { display: "none" },
    nextSibling: null,
    inert: true,
    classList: {
      add(name) { classes.add(name) },
      remove(name) { classes.delete(name) },
      contains(name) { return classes.has(name) },
      toggle(name, on) { if (on) classes.add(name); else classes.delete(name) }
    },
    setAttribute() {},
    querySelector() { return null },
    querySelectorAll() { return [] },
    contains(target) { return target === panelElement },
    addEventListener() {},
    removeEventListener() {},
    getBoundingClientRect() {
      return { top: 0, right: panel.width, bottom: panel.height, left: 0, width: panel.width, height: panel.height }
    }
  }
  Object.defineProperty(panelElement, "parentNode", {
    get() { return panelParent },
    set(value) { panelParent = value }
  })
  body.appendChild = (node) => {
    node.parentNode = body
  }

  const trigger = {
    rect: anchor,
    value: "",
    getBoundingClientRect() { return this.rect },
    setAttribute() {},
    focus() {},
    contains() { return false }
  }
  const element = { contains(target) { return target === element } }
  const windowStub = {
    innerWidth: viewport.width,
    innerHeight: viewport.height,
    addEventListener: windowEvents.addEventListener.bind(windowEvents),
    removeEventListener: windowEvents.removeEventListener.bind(windowEvents),
    dispatch: windowEvents.dispatch.bind(windowEvents),
    matchMedia() { return { matches: mode.mobile } }
  }
  const Controller = loadController({
    window: windowStub,
    document: {
      body,
      activeElement: null,
      addEventListener: documentEvents.addEventListener.bind(documentEvents),
      removeEventListener: documentEvents.removeEventListener.bind(documentEvents),
      dispatch: documentEvents.dispatch.bind(documentEvents)
    },
    getComputedStyle() {
      return { getPropertyValue() { return edge } }
    }
  })
  const controller = new Controller()
  controller.element = element
  controller.hasPanelTarget = true
  controller.panelTarget = panelElement
  controller.hasTriggerTarget = true
  controller.triggerTarget = trigger
  controller.hasMonthLabelTarget = false
  controller.hasCalendarGridTarget = false
  controller.hasSummaryTarget = false
  controller.hasListViewTarget = false
  controller.hasCalendarViewTarget = false
  controller.hasPresetKeyValue = false
  controller.hasPresetLabelsValue = false
  controller.hasSingleFieldTarget = false
  controller.rangeValue = false
  controller.panelIdValue = ""
  controller.valueValue = ""
  controller.startValue = ""
  controller.minValue = ""
  controller.maxValue = ""
  controller.connect()

  return { controller, panelElement, trigger, body, mode, windowEvents, documentEvents, windowStub }
}

const belowTrigger = { top: 40, right: 220, bottom: 80, left: 180, width: 40, height: 40 }

test("places the panel below the trigger and centers it", () => {
  const { controller, panelElement } = mount({ anchor: belowTrigger })
  controller.positionPanel()

  assert.equal(panelElement.style.position, "fixed")
  assert.equal(panelElement.style.top, "88px")
  assert.equal(panelElement.style.left, "60px")
  assert.equal(panelElement.style.width, "280px")
  assert.equal(panelElement.style.maxWidth, "784px")
  assert.equal(panelElement.style.inset, "")
})

test("places the panel above when below does not fit", () => {
  const { controller, panelElement } = mount({
    anchor: { top: 520, right: 220, bottom: 560, left: 180, width: 40, height: 40 },
    panel: { width: 280, height: 200 },
    viewport: { width: 800, height: 600 }
  })
  controller.positionPanel()

  assert.equal(panelElement.style.top, "312px")
  assert.equal(panelElement.style.left, "60px")
})

test("shrinks the width to the viewport and centers that width", () => {
  const { controller, panelElement } = mount({
    anchor: { top: 40, right: 70, bottom: 80, left: 30, width: 40, height: 40 },
    panel: { width: 300, height: 80 },
    viewport: { width: 120, height: 400 }
  })
  controller.positionPanel()

  assert.equal(panelElement.style.width, "104px")
  assert.equal(panelElement.style.maxWidth, "104px")
  assert.equal(panelElement.style.left, "8px")
  assert.equal(panelElement.style.top, "88px")
})

test("an edge token changes the clamp and the width cap, and the gap stays 8px", () => {
  const { controller, panelElement } = mount({
    anchor: { top: 20, right: 30, bottom: 40, left: 10, width: 20, height: 20 },
    panel: { width: 200, height: 100 },
    viewport: { width: 400, height: 400 },
    edge: "16px"
  })
  controller.positionPanel()

  assert.equal(panelElement.style.top, "48px")
  assert.equal(panelElement.style.left, "16px")
  assert.equal(panelElement.style.maxWidth, "368px")
  assert.equal(panelElement.style.width, "200px")
})

test("an oversized panel sticks to the edge", () => {
  const { controller, panelElement } = mount({
    anchor: { top: 20, right: 60, bottom: 40, left: 20, width: 40, height: 20 },
    panel: { width: 100, height: 500 },
    viewport: { width: 400, height: 200 }
  })
  controller.positionPanel()

  assert.equal(panelElement.style.top, "8px")
  assert.equal(panelElement.style.left, "8px")
})

test("a narrow viewport fills the screen, and a wide viewport clears that layout", () => {
  const { controller, panelElement, mode } = mount({ anchor: belowTrigger })
  mode.mobile = true
  controller.positionPanel()

  assert.equal(panelElement.style.position, "fixed")
  assert.equal(panelElement.style.inset, "0")
  assert.equal(panelElement.style.left, "0")
  assert.equal(panelElement.style.top, "0")
  assert.equal(panelElement.style.width, "100vw")
  assert.equal(panelElement.style.maxWidth, "100vw")
  assert.equal(panelElement.style.height, "100dvh")
  assert.equal(panelElement.style.maxHeight, "100dvh")

  mode.mobile = false
  controller.positionPanel()

  assert.equal(panelElement.style.inset, "")
  assert.equal(panelElement.style.height, "")
  assert.equal(panelElement.style.maxHeight, "")
  assert.equal(panelElement.style.top, "88px")
  assert.equal(panelElement.style.width, "280px")
})

test("a portaled panel stays on the trigger and a click inside it does not close", () => {
  const { controller, panelElement, body, documentEvents } = mount({ anchor: belowTrigger })
  controller.open()

  assert.equal(panelElement.parentNode, body)
  assert.equal(panelElement.style.top, "88px")
  assert.equal(controller.isOpen, true)

  documentEvents.dispatch("click", { target: panelElement })
  assert.equal(controller.isOpen, true)

  documentEvents.dispatch("click", { target: controller.element })
  assert.equal(controller.isOpen, true)

  documentEvents.dispatch("click", { target: {} })
  assert.equal(controller.isOpen, false)
})

test("scroll and resize while open reposition, a second listen is one pair, and disconnect removes both", () => {
  const { controller, panelElement, trigger, windowEvents } = mount({ anchor: belowTrigger })
  let viewRenders = 0
  const renderViewMode = controller.renderViewMode.bind(controller)
  controller.renderViewMode = function renderViewModeAndCount() {
    viewRenders += 1
    return renderViewMode()
  }
  controller.open()
  const rendersAfterOpen = viewRenders
  const positionsAfterOpen = panelElement.style.top

  trigger.rect = { top: 80, right: 220, bottom: 120, left: 180, width: 40, height: 40 }
  windowEvents.dispatch("resize")
  windowEvents.dispatch("scroll")

  assert.equal(panelElement.style.top, "128px")
  assert.equal(viewRenders, rendersAfterOpen + 2)
  assert.notEqual(panelElement.style.top, positionsAfterOpen)
  assert.equal(windowEvents.entries.filter((entry) => entry.type === "resize").length, 1)
  assert.equal(windowEvents.entries.filter((entry) => entry.type === "scroll" && entry.capture).length, 1)

  controller.addGlobalListeners()
  assert.equal(windowEvents.entries.filter((entry) => entry.type === "resize").length, 1)

  controller.disconnect()
  assert.equal(windowEvents.entries.filter((entry) => entry.type === "resize").length, 0)
  assert.equal(windowEvents.entries.filter((entry) => entry.type === "scroll").length, 0)
})

test("positionPanel returns when the panel or the trigger is missing", () => {
  const { controller, panelElement } = mount({ anchor: belowTrigger })
  controller.hasTriggerTarget = false
  controller.positionPanel()
  assert.equal(panelElement.style.top, undefined)

  controller.hasTriggerTarget = true
  controller.panelElement = null
  controller.positionPanel()
})
