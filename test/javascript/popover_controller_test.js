const test = require("node:test")
const assert = require("node:assert/strict")
const fs = require("node:fs")
const path = require("node:path")
const vm = require("node:vm")

function loadPopoverController(globals) {
  const root = path.join(__dirname, "..", "..", "app", "javascript", "flat_pack")
  const helper = (name) => fs.readFileSync(path.join(root, name), "utf8").replaceAll("export function ", "function ")
  const source = fs.readFileSync(path.join(root, "controllers", "popover_controller.js"), "utf8")
    .replace('import { Controller } from "@hotwired/stimulus"', "class Controller {}")
    .replace(
      /import \{[\s\S]*?\} from "controllers\/flat_pack\/reduced_motion"/,
      `function prefersReducedMotion() { return false }
       function motionDuration() { return 0 }
       function motionTransition() { return "none" }
       function overlayOrigin(placement) { return placement }
       function overlayEnterOffset() { return "none" }`
    )
    .replace('import { onClickOutside } from "flat_pack/click_outside"\n', "")
    .replace('import { applyFixedPosition, place, readEdgeOffset, watchViewport } from "flat_pack/positioning"\n', "")
    .replace("export default class extends Controller", "class PopoverController extends Controller")

  const context = {
    module: { exports: {} },
    exports: {},
    window: globals.window,
    document: globals.document,
    getComputedStyle: globals.getComputedStyle
  }
  vm.runInNewContext(
    `${helper("click_outside.js")}\n${helper("positioning.js")}\n${source}\nmodule.exports = PopoverController\n`,
    context,
    { filename: "popover_controller.js" }
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
    dispatch(type) {
      entries.filter((entry) => entry.type === type).forEach((entry) => entry.listener())
    }
  }
}

function mount({
  placement = "bottom",
  anchor,
  panel,
  viewport = { width: 400, height: 400 },
  edge = "8px"
} = {}) {
  const windowEvents = events()
  const windowStub = {
    innerWidth: viewport.width,
    innerHeight: viewport.height,
    addEventListener: windowEvents.addEventListener.bind(windowEvents),
    removeEventListener: windowEvents.removeEventListener.bind(windowEvents),
    dispatch: windowEvents.dispatch.bind(windowEvents)
  }
  const trigger = {
    id: "account-trigger",
    rect: anchor,
    getBoundingClientRect() { return this.rect },
    addEventListener() {},
    removeEventListener() {},
    setAttribute() {}
  }
  const element = {
    id: "",
    style: {},
    rect: panel,
    offsetHeight: panel.height,
    getBoundingClientRect() { return this.rect },
    setAttribute() {},
    classList: { add() {}, remove() {}, contains() { return false } }
  }
  const PopoverController = loadPopoverController({
    window: windowStub,
    document: {
      getElementById(id) { return id === trigger.id ? trigger : null },
      addEventListener() {},
      removeEventListener() {}
    },
    getComputedStyle() {
      return { getPropertyValue() { return edge } }
    }
  })
  const controller = new PopoverController()
  controller.element = element
  controller.placementValue = placement
  controller.triggerIdValue = trigger.id
  controller.connect()
  controller.position()
  return { controller, element, trigger, windowStub, windowEvents }
}

const fittedAnchor = { top: 100, right: 220, bottom: 140, left: 180, width: 40, height: 40 }
const fittedPanel = { top: 0, right: 100, bottom: 80, left: 0, width: 100, height: 80 }

test("bottom placement centers the panel under the trigger", () => {
  const { element, controller } = mount({ anchor: fittedAnchor, panel: fittedPanel })

  assert.equal(controller.resolvedPlacement, "bottom")
  assert.equal(element.style.position, "fixed")
  assert.equal(element.style.top, "152px")
  assert.equal(element.style.left, "150px")
  assert.equal(element.style.transformOrigin, "bottom")
})

test("bottom flips to top when the panel overflows the viewport", () => {
  const { element, controller } = mount({
    anchor: { top: 300, right: 220, bottom: 340, left: 180, width: 40, height: 40 },
    panel: fittedPanel
  })

  assert.equal(controller.resolvedPlacement, "top")
  assert.equal(element.style.top, "208px")
  assert.equal(element.style.left, "150px")
  assert.equal(element.style.transformOrigin, "top")
})

test("left flips to right when it does not fit", () => {
  const { element, controller } = mount({
    placement: "left",
    anchor: { top: 100, right: 50, bottom: 140, left: 10, width: 40, height: 40 },
    panel: fittedPanel
  })

  assert.equal(controller.resolvedPlacement, "right")
  assert.equal(element.style.left, "62px")
  assert.equal(element.style.top, "80px")
})

test("clamp uses the edge offset token and keeps the 12px gap", () => {
  const { element } = mount({
    anchor: { top: 100, right: 30, bottom: 120, left: 0, width: 30, height: 20 },
    panel: { top: 0, right: 80, bottom: 20, left: 0, width: 80, height: 20 },
    edge: "16px"
  })

  assert.equal(element.style.top, "132px")
  assert.equal(element.style.left, "16px")
})

test("scroll and resize reposition, and disconnect removes those listeners", () => {
  const mounted = mount({ anchor: { ...fittedAnchor }, panel: fittedPanel })
  const { controller, element, trigger, windowStub, windowEvents } = mounted
  let moves = 0
  const position = controller.position.bind(controller)
  controller.position = () => {
    moves += 1
    position()
  }
  controller.isOpen = true
  controller.addListeners()
  controller.addListeners()

  assert.equal(windowEvents.entries.filter((entry) => entry.type === "scroll" && entry.capture).length, 1)
  assert.equal(windowEvents.entries.filter((entry) => entry.type === "resize" && !entry.capture).length, 1)

  trigger.rect = { ...fittedAnchor, top: 130, bottom: 170 }
  moves = 0
  windowStub.dispatch("scroll")
  assert.equal(moves, 1)
  assert.equal(element.style.top, "182px")

  trigger.rect = { ...fittedAnchor, top: 150, bottom: 190 }
  windowStub.dispatch("resize")
  assert.equal(element.style.top, "202px")

  controller.disconnect()
  assert.equal(windowEvents.entries.length, 0)

  trigger.rect = { ...fittedAnchor, top: 180, bottom: 220 }
  windowStub.dispatch("scroll")
  windowStub.dispatch("resize")
  assert.equal(element.style.top, "202px")
  assert.equal(moves, 2)
})
