const test = require("node:test")
const assert = require("node:assert/strict")
const fs = require("node:fs")
const path = require("node:path")
const vm = require("node:vm")

function loadDropdownController(globals) {
  const root = path.join(__dirname, "..", "..", "app", "javascript", "flat_pack")
  const helper = (name) => fs.readFileSync(path.join(root, name), "utf8").replaceAll("export function ", "function ")
  const focusTrap = fs.readFileSync(path.join(root, "focus_trap.js"), "utf8")
    .replaceAll("export function ", "function ")
    .replaceAll("export const ", "const ")
  const source = fs.readFileSync(path.join(root, "controllers", "button_dropdown_controller.js"), "utf8")
    .replace('import { Controller } from "@hotwired/stimulus"', "class Controller {}")
    .replace(
      'import { prefersReducedMotion, motionDuration, motionTransition } from "controllers/flat_pack/reduced_motion"',
      `function prefersReducedMotion() { return false }
       function motionDuration() { return 0 }
       function motionTransition() { return "none" }`
    )
    .replace('import { onClickOutside } from "flat_pack/click_outside"\n', "")
    .replace('import { focusableElements } from "flat_pack/focus_trap"\n', "")
    .replace('import { place, readEdgeOffset, watchViewport } from "flat_pack/positioning"\n', "")
    .replace("export default class extends Controller", "class ButtonDropdownController extends Controller")

  const context = {
    module: { exports: {} },
    exports: {},
    window: globals.window,
    document: globals.document,
    getComputedStyle: globals.getComputedStyle,
    requestAnimationFrame: globals.requestAnimationFrame || ((fn) => fn()),
    setTimeout: (...args) => globals.window.setTimeout(...args)
  }
  vm.runInNewContext(
    `${focusTrap}\n${helper("click_outside.js")}\n${helper("positioning.js")}\n${source}\nmodule.exports = ButtonDropdownController\n`,
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
  edge = "8px",
  role = "menu"
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
    role,
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

function mountDialog(options = {}) {
  return mount({ ...options, role: "dialog" })
}

function clickTarget({ form = false, keepOpen = false, menuitem = true, submitButton = false } = {}) {
  const item = menuitem
    ? { matches() { return false }, dataset: { action: "" } }
    : null

  return {
    tagName: submitButton ? "BUTTON" : (form ? "INPUT" : "A"),
    disabled: false,
    tabIndex: 0,
    isContentEditable: false,
    dataset: { action: "" },
    getAttribute() { return null },
    matches(selector) {
      if (selector === "[disabled], [aria-disabled='true']") return false
      if (selector === '[tabindex]:not([tabindex="-1"])') return false
      if (selector === "a[href]") return this.tagName === "A"
      if (selector === "button, select, textarea") return this.tagName === "BUTTON"
      if (selector === "input") return this.tagName === "INPUT"
      if (selector === '[type="hidden"]') return false
      return false
    },
    closest(selector) {
      if (
        selector === "[data-flat-pack-dropdown-item]" ||
        selector === '[role="menuitem"]' ||
        selector === '[data-flat-pack-dropdown-item], [role="menuitem"]'
      ) return item
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

function fieldNode({ tagName = "INPUT", hidden = false, disabled = false } = {}) {
  return {
    tagName,
    disabled,
    tabIndex: 0,
    isContentEditable: false,
    closest() { return null },
    getAttribute(name) {
      if (name === "type" && hidden) return "hidden"
      return null
    },
    matches(selector) {
      if (selector === '[tabindex]:not([tabindex="-1"])') return false
      if (selector === "a[href]") return tagName === "A"
      if (selector === "button, select, textarea") return tagName === "BUTTON" || tagName === "SELECT" || tagName === "TEXTAREA"
      if (selector === "input") return tagName === "INPUT"
      if (selector === '[type="hidden"]') return hidden
      return false
    }
  }
}

function triggerAction() {
  const source = fs.readFileSync(
    path.join(__dirname, "..", "..", "app", "components", "flat_pack", "button", "dropdown", "component.rb"),
    "utf8"
  )
  const match = source.match(/action: "([^"]+)"/)
  if (!match) throw new Error("dropdown trigger action is missing")
  return match[1]
}

function runTriggerAction(controller, action, eventName, event) {
  action.split(/\s+/).filter(Boolean).forEach((descriptor) => {
    const split = descriptor.match(/^([^->]+)->([^#]+)#(.+)$/)
    if (!split) return
    const [, eventPart, , methodName] = split
    const [name, filter] = eventPart.split(".")
    if (name !== eventName) return
    if (filter === "enter" && event.key !== "Enter") return
    if (filter === "space" && event.key !== " " && event.key !== "Spacebar") return
    controller[methodName](event)
  })
}

function keyEvent(key, { repeat = false } = {}) {
  return {
    key,
    repeat,
    defaultPrevented: false,
    preventDefault() { this.defaultPrevented = true },
    stopPropagation() {}
  }
}

// Chrome activates a <button> with a click after Enter and after Space.
// preventDefault on keydown is what stops that click.
function pressTriggerKey(controller, key) {
  const action = triggerAction()
  const keydown = keyEvent(key)
  runTriggerAction(controller, action, "keydown", keydown)
  if (!keydown.defaultPrevented) {
    runTriggerAction(controller, action, "click", {
      preventDefault() {},
      stopPropagation() {}
    })
  }
  return keydown.defaultPrevented
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
  const { controller, menuElement } = mountDialog({ anchor: triggerRect })
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
  const { controller, menuElement } = mountDialog({ anchor: triggerRect })
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
  const { controller, menuElement } = mountDialog({ anchor: triggerRect })
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

test("tab on a plain menuitem closes the menu and returns focus to the trigger", () => {
  const { controller, menuElement, trigger } = mount({ anchor: triggerRect })
  let focused = 0
  let prevented = 0
  trigger.focus = () => { focused += 1 }
  controller.isOpen = true
  const item = clickTarget({ keepOpen: true })
  menuElement.contains = () => true
  menuElement.tabStops = [item]

  controller.handleEscape({
    key: "Tab",
    shiftKey: false,
    target: item,
    preventDefault() { prevented += 1 }
  })

  assert.equal(controller.isOpen, false)
  assert.equal(focused, 1)
  assert.equal(prevented, 1)
})

test("tab in a dialog stays open when the next stop is inside the panel", () => {
  const { controller, menuElement } = mountDialog({ anchor: triggerRect })
  let closed = 0
  controller.close = () => { closed += 1 }
  controller.isOpen = true
  const first = clickTarget({ menuitem: false })
  const second = clickTarget({ menuitem: false })
  menuElement.tabStops = [first, second]
  menuElement.contains = (node) => node === first || node === second

  controller.handleEscape({
    key: "Tab",
    shiftKey: false,
    target: first,
    preventDefault() {}
  })

  assert.equal(closed, 0)
  assert.equal(controller.isOpen, true)
})

test("a dialog action dispatches without a menuitem role", () => {
  const { controller, menuElement } = mountDialog({ anchor: triggerRect })
  let dispatched = 0
  controller.dispatchDetachedActions = (menuItem) => {
    dispatched += 1
    assert.equal(menuItem.dataset.action, "click->lists--add-to-list#toggle")
  }
  controller.close = () => { controller.isOpen = false }
  controller.isOpen = true
  menuElement.contains = () => true
  const item = {
    dataset: { action: "click->lists--add-to-list#toggle" },
    matches() { return false },
    closest(selector) {
      if (selector === "[data-flat-pack-dropdown-item]") return this
      if (selector === '[data-flat-pack-dropdown-item], [role="menuitem"]') return this
      if (selector === '[role="menuitem"]') return null
      if (selector === "[data-flat-pack-dropdown-keep-open]") return null
      if (selector === "a, button") return this
      return null
    }
  }

  controller.handleMenuItemClick({
    target: item,
    defaultPrevented: false,
    detail: null,
    preventDefault() {},
    stopPropagation() {}
  })

  assert.equal(dispatched, 1)
})

test("a portaled menu_html menuitem without the item hook still dispatches its action", () => {
  const { controller, menuElement, documentStub } = mount({ anchor: triggerRect })
  let appended = 0
  let toggled = 0
  documentStub.body.appendChild = () => { appended += 1 }
  controller.ensureMenuInBody()
  assert.equal(appended, 1)

  const host = {}
  controller.contextControllerElements = [{ element: host, identifiers: ["lists--add-to-list"] }]
  controller.application = {
    getControllerForElementAndIdentifier(element, identifier) {
      if (element === host && identifier === "lists--add-to-list") {
        return { toggle() { toggled += 1 } }
      }
      return null
    }
  }
  controller.isOpen = true
  menuElement.contains = () => true
  const item = {
    dataset: { action: "click->lists--add-to-list#toggle" },
    matches() { return false },
    closest(selector) {
      if (selector === "[data-flat-pack-dropdown-item]") return null
      if (selector === '[data-flat-pack-dropdown-item], [role="menuitem"]') return this
      if (selector === "[data-flat-pack-dropdown-keep-open]") return null
      if (selector === "a, button") return this
      return null
    }
  }

  controller.handleMenuItemClick({
    target: item,
    defaultPrevented: false,
    detail: null,
    preventDefault() {},
    stopPropagation() {}
  })

  assert.equal(toggled, 1)
})

test("enter and space on the trigger action open the menu once and focus the first item", () => {
  const { controller, menuElement, windowStub, documentStub } = mount({ anchor: triggerRect })
  documentStub.body.appendChild = () => {}
  let focused = 0
  const item = {
    focus() { focused += 1 },
    closest() { return null },
    getAttribute() { return null }
  }
  menuElement.tabStops = [item]
  windowStub.setTimeout = (fn) => {
    fn()
    return 0
  }
  const action = triggerAction()
  assert.match(action, /keydown\.enter->flat-pack--button-dropdown#openFromKey/)
  assert.match(action, /keydown\.space->flat-pack--button-dropdown#openFromKey/)
  assert.match(action, /click->flat-pack--button-dropdown#toggle/)

  assert.equal(pressTriggerKey(controller, "Enter"), true)
  assert.equal(controller.isOpen, true)
  assert.equal(focused, 1)

  controller.close()
  assert.equal(controller.isOpen, false)

  focused = 0
  assert.equal(pressTriggerKey(controller, " "), true)
  assert.equal(controller.isOpen, true)
  assert.equal(focused, 1)
})

test("space keyup then the activation click leaves the menu open", () => {
  const { controller, documentStub, windowStub } = mount({ anchor: triggerRect })
  documentStub.body.appendChild = () => {}
  const timeouts = []
  windowStub.setTimeout = (fn) => {
    timeouts.push(fn)
    return timeouts.length
  }
  const action = triggerAction()
  assert.match(action, /keyup\.space->flat-pack--button-dropdown#releaseKey/)
  assert.match(action, /keyup\.enter->flat-pack--button-dropdown#releaseKey/)

  const keydown = keyEvent(" ")
  runTriggerAction(controller, action, "keydown", keydown)
  assert.equal(keydown.defaultPrevented, true)
  assert.equal(controller.isOpen, true)

  const keyup = keyEvent(" ")
  runTriggerAction(controller, action, "keyup", keyup)
  assert.equal(keyup.defaultPrevented, true)

  const click = { preventDefault() {}, stopPropagation() {} }
  runTriggerAction(controller, action, "click", click)
  assert.equal(controller.isOpen, true)

  timeouts.forEach((fn) => fn())
  runTriggerAction(controller, action, "click", { preventDefault() {}, stopPropagation() {} })
  assert.equal(controller.isOpen, false)
})

test("a repeated keydown or keyup does not open or close the menu", () => {
  const { controller, documentStub } = mount({ anchor: triggerRect })
  documentStub.body.appendChild = () => {}
  const action = triggerAction()

  const repeatedDown = keyEvent(" ", { repeat: true })
  runTriggerAction(controller, action, "keydown", repeatedDown)
  assert.equal(repeatedDown.defaultPrevented, true)
  assert.equal(controller.isOpen, false)

  assert.equal(pressTriggerKey(controller, "Enter"), true)
  assert.equal(controller.isOpen, true)

  const repeatedEnter = keyEvent("Enter", { repeat: true })
  runTriggerAction(controller, action, "keydown", repeatedEnter)
  assert.equal(repeatedEnter.defaultPrevented, true)
  assert.equal(controller.isOpen, true)

  const repeatedUp = keyEvent(" ", { repeat: true })
  runTriggerAction(controller, action, "keyup", repeatedUp)
  assert.equal(repeatedUp.defaultPrevented, true)
  assert.equal(controller.isOpen, true)
})

test("tabbing past the last stop in a dialog closes it and returns focus to the trigger", () => {
  const { controller, menuElement, trigger } = mountDialog({ anchor: triggerRect })
  let focused = 0
  let prevented = 0
  trigger.focus = () => { focused += 1 }
  controller.isOpen = true
  const only = clickTarget({ menuitem: false })
  menuElement.tabStops = [only]
  menuElement.contains = (node) => node === only

  controller.handleEscape({
    key: "Tab",
    shiftKey: false,
    target: only,
    preventDefault() { prevented += 1 }
  })

  assert.equal(controller.isOpen, false)
  assert.equal(focused, 1)
  assert.equal(prevented, 1)
})

test("a dialog focuses the first form field on open", () => {
  const { controller, menuElement, windowStub, documentStub } = mountDialog({ anchor: triggerRect })
  documentStub.body.appendChild = () => {}
  let inputFocused = 0
  let buttonFocused = 0
  const input = fieldNode()
  input.focus = () => { inputFocused += 1 }
  const button = fieldNode({ tagName: "BUTTON" })
  button.focus = () => { buttonFocused += 1 }
  menuElement.tabStops = [input, button]
  windowStub.setTimeout = (fn) => {
    fn()
    return 0
  }

  controller.open()

  assert.equal(inputFocused, 1)
  assert.equal(buttonFocused, 0)
  assert.equal(controller.isOpen, true)
})

test("a dialog skips a leading hidden input and focuses the first visible field", () => {
  const { controller, menuElement, windowStub, documentStub } = mountDialog({ anchor: triggerRect })
  documentStub.body.appendChild = () => {}
  let hiddenFocused = 0
  let visibleFocused = 0
  const hidden = fieldNode({ hidden: true })
  hidden.focus = () => { hiddenFocused += 1 }
  const visible = fieldNode()
  visible.focus = () => { visibleFocused += 1 }
  menuElement.tabStops = [hidden, visible]
  windowStub.setTimeout = (fn) => {
    fn()
    return 0
  }

  controller.open()

  assert.equal(hiddenFocused, 0)
  assert.equal(visibleFocused, 1)
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
