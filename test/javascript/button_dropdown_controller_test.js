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
    getComputedStyle: globals.getComputedStyle,
    requestAnimationFrame: globals.requestAnimationFrame || ((fn) => fn())
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
  const menuListeners = []
  const menuElement = {
    style: {},
    role: "menu",
    tabStops: [],
    offsetWidth: menu.width,
    offsetHeight: menu.height,
    parentNode: { appendChild() {}, insertBefore() {} },
    addEventListener(type, listener) { menuListeners.push({ type, listener }) },
    removeEventListener(type, listener) {
      const index = menuListeners.findIndex((entry) => entry.type === type && entry.listener === listener)
      if (index >= 0) menuListeners.splice(index, 1)
    },
    contains() { return false },
    classList: { add() {}, remove() {}, contains() { return false } },
    setAttribute() {},
    getAttribute(name) { return name === "role" ? this.role : null },
    querySelectorAll() { return this.tabStops }
  }
  const documentStub = {
    body: {},
    activeElement: null,
    addEventListener() {},
    removeEventListener() {}
  }
  const ButtonDropdownController = loadDropdownController({
    window: windowStub,
    document: documentStub,
    getComputedStyle() {
      return { getPropertyValue() { return edge } }
    }
  })
  const controller = new ButtonDropdownController()
  controller.element = {
    getAttribute() { return "" },
    parentElement: null,
    contains() { return false }
  }
  controller.menuTarget = menuElement
  controller.triggerTarget = trigger
  controller.placementValue = placement
  controller.hasChevronTarget = false
  controller.connect()
  controller.positionMenu()
  return { controller, menuElement, trigger, windowStub, windowEvents, documentStub, menuListeners }
}

function clickTarget({ form = false, keepOpen = false, menuitem = true, submitButton = false } = {}) {
  const item = menuitem
    ? { matches() { return false }, dataset: { action: "" } }
    : null

  return {
    tagName: submitButton ? "BUTTON" : (form ? "INPUT" : "A"),
    isContentEditable: false,
    dataset: { action: "" },
    matches() { return false },
    closest(selector) {
      if (selector === '[role="menuitem"]') return item
      if (selector === "[data-flat-pack-dropdown-keep-open]") {
        if (keepOpen) return { tagName: "DIV" }
        return null
      }
      if (selector === "form") {
        if (form || submitButton) return { tagName: "FORM" }
        return null
      }
      if (selector === "a, button") {
        if (form && !submitButton) return null
        return this
      }
      return null
    }
  }
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

test("a menu item click still closes the menu", () => {
  const { controller, menuElement } = mount({ anchor: triggerRect })
  let closed = 0
  controller.close = () => {
    closed += 1
    controller.isOpen = false
  }
  controller.isOpen = true
  controller.dispatchDetachedActions = () => {}
  menuElement.contains = () => true

  controller.handleMenuItemClick({
    target: clickTarget(),
    defaultPrevented: false,
    detail: null,
    preventDefault() {},
    stopPropagation() {}
  })

  assert.equal(closed, 1)
})

test("a form inside the menu does not close it", () => {
  const { controller, menuElement } = mount({ anchor: triggerRect })
  let closed = 0
  controller.close = () => {
    closed += 1
    controller.isOpen = false
  }
  controller.isOpen = true
  menuElement.contains = () => true

  controller.handleMenuItemClick({
    target: clickTarget({ form: true, keepOpen: true, menuitem: false, submitButton: true }),
    defaultPrevented: false
  })

  assert.equal(closed, 0)
  assert.equal(controller.isOpen, true)
})

test("a form inside plain menu_html still closes the menu on click", () => {
  const { controller, menuElement } = mount({ anchor: triggerRect })
  let closed = 0
  controller.close = () => {
    closed += 1
    controller.isOpen = false
  }
  controller.isOpen = true
  menuElement.contains = () => true

  controller.handleMenuItemClick({
    target: clickTarget({ form: true, menuitem: false, submitButton: true }),
    defaultPrevented: false
  })

  assert.equal(closed, 1)
})

test("a keep-open item does not close the menu", () => {
  const { controller, menuElement } = mount({ anchor: triggerRect })
  let closed = 0
  controller.close = () => {
    closed += 1
    controller.isOpen = false
  }
  controller.isOpen = true
  menuElement.contains = () => true

  controller.handleMenuItemClick({
    target: clickTarget({ keepOpen: true }),
    defaultPrevented: false
  })

  assert.equal(closed, 0)
  assert.equal(controller.isOpen, true)
})

test("arrow keys in a form field do not move menu focus", () => {
  const { controller, menuElement } = mount({ anchor: triggerRect })
  let moved = 0
  controller.isOpen = true
  controller.focusNextItem = () => { moved += 1 }
  menuElement.contains = () => true

  controller.handleEscape({
    key: "ArrowDown",
    target: clickTarget({ form: true, keepOpen: true, menuitem: false }),
    preventDefault() {}
  })

  assert.equal(moved, 0)
})

test("tab in a form does not close the menu", () => {
  const { controller, menuElement } = mount({ anchor: triggerRect })
  let closed = 0
  controller.close = () => { closed += 1 }
  controller.isOpen = true
  menuElement.contains = () => true

  controller.handleEscape({
    key: "Tab",
    target: clickTarget({ form: true, keepOpen: true, menuitem: false }),
    preventDefault() {}
  })

  assert.equal(closed, 0)
})

test("tab into a keep-open node does not close the menu", () => {
  const { controller, menuElement } = mount({ anchor: triggerRect })
  let closed = 0
  controller.close = () => { closed += 1 }
  controller.isOpen = true
  const item = clickTarget()
  const field = clickTarget({ form: true, keepOpen: true, menuitem: false })
  menuElement.tabStops = [item, field]
  menuElement.contains = (node) => node === item || node === field

  controller.handleEscape({
    key: "Tab",
    shiftKey: false,
    target: item,
    preventDefault() {}
  })

  assert.equal(closed, 0)
  assert.equal(controller.isOpen, true)
})

test("tab on a keep-open control does not close the menu", () => {
  const { controller, menuElement } = mount({ anchor: triggerRect })
  let closed = 0
  controller.close = () => { closed += 1 }
  controller.isOpen = true
  menuElement.contains = () => true

  controller.handleEscape({
    key: "Tab",
    target: clickTarget({ keepOpen: true }),
    preventDefault() {}
  })

  assert.equal(closed, 0)
})

test("focusout inside a keep-open node does not close the menu", () => {
  const { controller, menuElement, menuListeners, documentStub } = mount({ anchor: triggerRect })
  let closed = 0
  controller.close = () => { closed += 1 }
  controller.isOpen = true
  controller.addListeners()
  const field = clickTarget({ form: true, keepOpen: true, menuitem: false })
  menuElement.contains = (node) => node === field
  documentStub.activeElement = field

  assert.equal(menuListeners.some((entry) => entry.type === "focusout"), true)

  controller.handleFocusOut({ relatedTarget: field })
  assert.equal(closed, 0)

  controller.handleFocusOut({ relatedTarget: null })
  assert.equal(closed, 0)
})

test("focusout leaves the menu when focus moves outside", () => {
  const { controller, menuElement, documentStub } = mount({ anchor: triggerRect })
  let closed = 0
  controller.close = ({ returnFocus } = {}) => {
    closed += 1
    controller.isOpen = false
    assert.equal(returnFocus, false)
  }
  controller.isOpen = true
  const outside = clickTarget()
  menuElement.contains = () => false
  documentStub.activeElement = outside

  controller.handleFocusOut({ relatedTarget: outside })
  assert.equal(closed, 1)

  controller.isOpen = true
  closed = 0
  documentStub.activeElement = outside
  controller.handleFocusOut({ relatedTarget: null })
  assert.equal(closed, 1)
})
