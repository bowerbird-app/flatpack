const test = require("node:test")
const assert = require("node:assert/strict")
const fs = require("node:fs")
const path = require("node:path")
const vm = require("node:vm")

function loadDropdownController(globals) {
  const root = path.join(__dirname, "..", "..", "app", "javascript", "flat_pack")
  const helper = (name) => fs.readFileSync(path.join(root, name), "utf8").replaceAll("export function ", "function ")
  const source = fs.readFileSync(path.join(root, "controllers", "button_dropdown_controller.js"), "utf8")
    .replace('import { Controller } from "@hotwired/stimulus"', "class Controller {}")
    .replace(
      'import { prefersReducedMotion, motionDuration, motionTransition } from "controllers/flat_pack/reduced_motion"',
      `function prefersReducedMotion() { return false }
       function motionDuration() { return 0 }
       function motionTransition() { return "none" }`
    )
    .replace('import { onClickOutside } from "flat_pack/click_outside"\n', "")
    .replace('import { place, readEdgeOffset, watchViewport } from "flat_pack/positioning"\n', "")
    .replace("export default class extends Controller", "class ButtonDropdownController extends Controller")

  const context = {
    module: { exports: {} },
    exports: {},
    window: globals.window,
    document: globals.document,
    getComputedStyle: globals.getComputedStyle
  }
  vm.runInNewContext(
    `${helper("click_outside.js")}\n${helper("positioning.js")}\n${source}\nmodule.exports = ButtonDropdownController\n`,
    context,
    { filename: "button_dropdown_controller.js" }
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
  placement = "bottom_right",
  anchor,
  menu = { width: 100, height: 80 },
  viewport = { width: 400, height: 400 },
  edge = "8px"
} = {}) {
  const windowEvents = events()
  const windowStub = {
    innerWidth: viewport.width,
    innerHeight: viewport.height,
    addEventListener: windowEvents.addEventListener.bind(windowEvents),
    removeEventListener: windowEvents.removeEventListener.bind(windowEvents),
    dispatch: windowEvents.dispatch.bind(windowEvents),
    setTimeout() { return 0 },
    clearTimeout() {}
  }
  const trigger = {
    rect: anchor,
    getBoundingClientRect() { return this.rect },
    setAttribute() {},
    focus() {}
  }
  const menuElement = {
    style: {},
    offsetWidth: menu.width,
    offsetHeight: menu.height,
    parentNode: { appendChild() {}, insertBefore() {} },
    addEventListener() {},
    removeEventListener() {},
    contains() { return false },
    classList: { add() {}, remove() {}, contains() { return false } },
    setAttribute() {},
    querySelectorAll() { return [] }
  }
  const ButtonDropdownController = loadDropdownController({
    window: windowStub,
    document: {
      body: {},
      addEventListener() {},
      removeEventListener() {}
    },
    getComputedStyle() {
      return { getPropertyValue() { return edge } }
    }
  })
  const controller = new ButtonDropdownController()
  controller.element = {
    getAttribute() { return "" },
    parentElement: null
  }
  controller.menuTarget = menuElement
  controller.triggerTarget = trigger
  controller.placementValue = placement
  controller.hasChevronTarget = false
  controller.connect()
  controller.positionMenu()
  return { controller, menuElement, trigger, windowStub, windowEvents }
}

const triggerRect = { top: 100, right: 220, bottom: 140, left: 180, width: 40, height: 40 }

test("bottom_right aligns the menu to the trigger's end and does not flip", () => {
  const { menuElement } = mount({
    anchor: { top: 300, right: 220, bottom: 340, left: 180, width: 40, height: 40 }
  })

  assert.equal(menuElement.style.top, "312px")
  assert.equal(menuElement.style.left, "120px")
  assert.equal(menuElement.style.transformOrigin, "top right")
})

test("corner placements keep their origin", () => {
  const bottomLeft = mount({ placement: "bottom_left", anchor: triggerRect })
  const topLeft = mount({ placement: "top_left", anchor: triggerRect })
  const topRight = mount({ placement: "top_right", anchor: triggerRect })

  assert.equal(bottomLeft.menuElement.style.top, "148px")
  assert.equal(bottomLeft.menuElement.style.left, "180px")
  assert.equal(bottomLeft.menuElement.style.transformOrigin, "top left")
  assert.equal(topLeft.menuElement.style.top, "12px")
  assert.equal(topLeft.menuElement.style.left, "180px")
  assert.equal(topLeft.menuElement.style.transformOrigin, "bottom left")
  assert.equal(topRight.menuElement.style.top, "12px")
  assert.equal(topRight.menuElement.style.left, "120px")
  assert.equal(topRight.menuElement.style.transformOrigin, "bottom right")
})

test("an unknown placement stays bottom_right", () => {
  const { menuElement } = mount({ placement: "middle", anchor: triggerRect })

  assert.equal(menuElement.style.top, "148px")
  assert.equal(menuElement.style.left, "120px")
  assert.equal(menuElement.style.transformOrigin, "top right")
})

test("an oversized menu sticks to the edge offset", () => {
  const { menuElement } = mount({
    anchor: { top: 10, right: 80, bottom: 30, left: 40, width: 40, height: 20 },
    menu: { width: 300, height: 500 },
    viewport: { width: 200, height: 120 },
    edge: "16px"
  })

  assert.equal(menuElement.style.top, "16px")
  assert.equal(menuElement.style.left, "16px")
})

test("the gap stays 8px when the edge offset changes", () => {
  const { menuElement } = mount({
    placement: "bottom_left",
    anchor: triggerRect,
    edge: "20px"
  })

  assert.equal(menuElement.style.top, "148px")
  assert.equal(menuElement.style.left, "180px")
})

test("scroll and resize reposition, and disconnect removes those listeners", () => {
  const mounted = mount({ anchor: { ...triggerRect } })
  const { controller, menuElement, trigger, windowStub, windowEvents } = mounted
  let moves = 0
  const positionMenu = controller.positionMenu.bind(controller)
  controller.positionMenu = () => {
    moves += 1
    positionMenu()
  }
  controller.isOpen = true
  controller.addListeners()
  controller.addListeners()

  assert.equal(windowEvents.entries.filter((entry) => entry.type === "scroll" && entry.capture).length, 1)
  assert.equal(windowEvents.entries.filter((entry) => entry.type === "resize" && !entry.capture).length, 1)

  trigger.rect = { ...triggerRect, top: 130, bottom: 170 }
  moves = 0
  windowStub.dispatch("scroll")
  assert.equal(moves, 1)
  assert.equal(menuElement.style.top, "178px")

  trigger.rect = { ...triggerRect, top: 150, bottom: 190 }
  windowStub.dispatch("resize")
  assert.equal(menuElement.style.top, "198px")

  controller.disconnect()
  assert.equal(windowEvents.entries.length, 0)

  trigger.rect = { ...triggerRect, top: 180, bottom: 220 }
  windowStub.dispatch("scroll")
  windowStub.dispatch("resize")
  assert.equal(menuElement.style.top, "198px")
  assert.equal(moves, 2)
})
