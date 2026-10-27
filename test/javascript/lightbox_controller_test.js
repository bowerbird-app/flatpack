const test = require("node:test")
const assert = require("node:assert/strict")
const fs = require("node:fs")
const path = require("node:path")
const vm = require("node:vm")

function loadController() {
  const filePath = path.join(__dirname, "..", "..", "app", "javascript", "flat_pack", "controllers", "lightbox_controller.js")
  const source = fs.readFileSync(filePath, "utf8")
    .replace('import { Controller } from "@hotwired/stimulus"', "class Controller {}")
    .replace(
      'import { prefersReducedMotion, motionDuration, motionTransition } from "controllers/flat_pack/reduced_motion"',
      "function prefersReducedMotion() { return globalThis.__reduceMotion === true }\nfunction motionDuration() { return globalThis.__reduceMotion ? 0 : 200 }\nfunction motionTransition() { return \"opacity 200ms\" }"
    )
    .replace(/import \{[^}]+\} from "flat_pack\/click_outside"\n/, "")
    .replace("export default class extends Controller", "class LightboxController extends Controller")
    + "\nmodule.exports = LightboxController\n"
  const clickOutsidePath = path.join(__dirname, "..", "..", "app", "javascript", "flat_pack", "click_outside.js")
  const clickOutsideSource = fs.readFileSync(clickOutsidePath, "utf8")
    .replaceAll("export function ", "function ")
  const script = clickOutsideSource + "\n" + source

  const listeners = new Map()
  const document = {
    body: { classList: classList() },
    addEventListener(type, handler) {
      listeners.set(type, handler)
    },
    removeEventListener(type) {
      listeners.delete(type)
    },
    dispatchEvent(event) {
      listeners.get(event.type)?.(event)
      return true
    },
    contains() { return true }
  }

  const context = {
    module: { exports: {} },
    document,
    window: {
      requestAnimationFrame(fn) { fn(); return 1 },
      setTimeout(fn) { fn(); return 1 },
      clearTimeout() {},
      getComputedStyle() { return { direction: "ltr" } }
    },
    CSS: { escape(value) { return value } },
    HTMLElement: function HTMLElement() {},
    CustomEvent: class CustomEvent {
      constructor(type, init = {}) {
        this.type = type
        this.detail = init.detail
        this.bubbles = init.bubbles
      }
    }
  }
  context.globalThis = context
  vm.runInNewContext(script, context, { filename: filePath })
  return { Controller: context.module.exports, document, context }
}

function classList() {
  const names = new Set()
  return {
    add(name) { names.add(name) },
    remove(name) { names.delete(name) },
    contains(name) { return names.has(name) }
  }
}

function element(tag, HTMLElement) {
  const node = new HTMLElement()
  node.tag = tag
  node.hidden = false
  node.open = false
  node.dataset = {}
  node.style = {}
  node.classList = classList()
  node.listeners = {}
  node.children = []
  node.contains = (target) => target === node || node.children.some((child) => child === target || child.contains?.(target))
  node.closest = () => null
  node.querySelector = (selector) => {
    if (selector.includes("lightbox-stage")) return node.stage || null
    if (selector.includes("viewport")) return node.viewport || null
    if (selector === "button") return node.closeButton || null
    return null
  }
  node.addEventListener = (type, handler) => { node.listeners[type] = handler }
  node.removeEventListener = (type) => { delete node.listeners[type] }
  node.showModal = () => { node.open = true }
  node.close = () => {
    node.open = false
    node.listeners.close?.()
  }
  node.focus = () => { node.focused = true }
  return node
}

function mount(options = {}) {
  const loaded = loadController()
  loaded.context.__reduceMotion = options.reduceMotion === true
  const { Controller, document } = loaded
  const HTMLElement = loaded.context.HTMLElement
  const dialog = element("dialog", HTMLElement)
  dialog.hidden = true
  dialog.groupValue = "wall"
  const viewport = element("viewport", HTMLElement)
  const stage = element("stage", HTMLElement)
  stage.flatPackCarousel = {
    moved: null,
    to(index) { this.moved = index },
    next() { this.moved = "next" },
    prev() { this.moved = "prev" }
  }
  dialog.stage = stage
  dialog.viewport = viewport
  dialog.children = [stage, viewport]
  const controller = new Controller()
  controller.element = dialog
  controller.groupValue = "wall"
  controller.connect()
  dialog.addEventListener("close", () => controller.closed())
  return { controller, dialog, document, viewport, stage, HTMLElement }
}

test("opens the dialog on the clicked index and returns focus to the trigger", () => {
  const { controller, dialog, document, viewport, stage, HTMLElement } = mount()
  const trigger = element("button", HTMLElement)
  trigger.dataset.flatPackLightboxGroup = "wall"
  trigger.dataset.flatPackLightboxIndex = "2"
  trigger.focus = function focus() { this.focused = true }

  document.dispatchEvent({
    type: "click",
    button: 0,
    target: {
      closest(selector) {
        return selector === "[data-flat-pack-lightbox-group]" ? trigger : null
      }
    },
    preventDefault() { this.defaulted = true }
  })

  assert.equal(dialog.open, true)
  assert.equal(dialog.hidden, false)
  assert.equal(stage.flatPackCarousel.moved, 2)
  assert.equal(viewport.focused, true)
  assert.equal(document.body.classList.contains("overflow-hidden"), true)

  controller.requestClose()
  assert.equal(dialog.open, false)
  assert.equal(dialog.hidden, true)
  assert.equal(trigger.focused, true)
  assert.equal(document.body.classList.contains("overflow-hidden"), false)
})

test("escape cancels the native close and still dismisses", () => {
  const { controller, dialog } = mount()
  controller.openAt(0, null)
  let prevented = false
  controller.cancel({ preventDefault() { prevented = true } })
  assert.equal(prevented, true)
  assert.equal(dialog.open, false)
})

test("a click inside the stage does not close", () => {
  const { controller, dialog } = mount()
  controller.openAt(1, null)
  const stage = dialog.stage
  controller.clickBackdrop({
    target: {
      closest(selector) {
        if (selector.includes("stage")) return stage
        return null
      }
    }
  })
  assert.equal(dialog.open, true)
})

test("a click on the shell closes and a click on a control does not", () => {
  const { controller, dialog } = mount()
  controller.openAt(0, null)
  controller.clickBackdrop({
    target: {
      closest(selector) {
        return selector.includes("button") ? { tag: "button" } : null
      }
    }
  })
  assert.equal(dialog.open, true)

  controller.clickBackdrop({
    target: { closest() { return null } }
  })
  assert.equal(dialog.open, false)
})

test("ignores a trigger for a different group", () => {
  const { dialog, document, HTMLElement } = mount()
  const trigger = element("button", HTMLElement)
  trigger.dataset.flatPackLightboxGroup = "other"
  trigger.dataset.flatPackLightboxIndex = "0"
  document.dispatchEvent({
    type: "click",
    button: 0,
    target: { closest() { return trigger } },
    preventDefault() {}
  })
  assert.equal(dialog.open, false)
})

test("a carousel root is not a lightbox click target", () => {
  const { dialog, document, HTMLElement, stage } = mount()
  const carousel = element("section", HTMLElement)
  carousel.dataset.controller = "flat-pack--carousel"
  carousel.dataset.flatPackLightboxGroup = "wall"

  function click(target) {
    document.dispatchEvent({
      type: "click",
      button: 0,
      target,
      preventDefault() { this.defaulted = true }
    })
  }

  click({
    closest(selector) {
      return selector === "[data-flat-pack-lightbox-group]" ? carousel : null
    }
  })
  assert.equal(dialog.open, false)
  assert.equal(stage.flatPackCarousel.moved, null)

  ;["prev", "next", "indicator", "autoplay"].forEach((kind) => {
    click({
      kind,
      closest(selector) {
        return selector === "[data-flat-pack-lightbox-group]" ? carousel : null
      }
    })
  })
  assert.equal(dialog.open, false)
  assert.equal(stage.flatPackCarousel.moved, null)
})

test("a trigger inside a carousel still opens on its own index", () => {
  const { dialog, document, HTMLElement, stage } = mount()
  const trigger = element("button", HTMLElement)
  trigger.dataset.flatPackLightboxGroup = "wall"
  trigger.dataset.flatPackLightboxIndex = "1"
  trigger.dataset.controller = "flat-pack--button"

  document.dispatchEvent({
    type: "click",
    button: 0,
    target: {
      closest() { return trigger }
    },
    preventDefault() {}
  })

  assert.equal(dialog.open, true)
  assert.equal(stage.flatPackCarousel.moved, 1)
})

test("lightbox navigation does not open the dialog again", () => {
  const { controller, dialog, document, HTMLElement, stage } = mount()
  const trigger = element("button", HTMLElement)
  trigger.dataset.flatPackLightboxGroup = "wall"
  trigger.dataset.flatPackLightboxIndex = "2"
  document.dispatchEvent({
    type: "click",
    button: 0,
    target: { closest() { return trigger } },
    preventDefault() {}
  })
  assert.equal(stage.flatPackCarousel.moved, 2)

  const dialogCarousel = element("div", HTMLElement)
  dialogCarousel.dataset.controller = "flat-pack--carousel"
  dialogCarousel.dataset.flatPackLightboxGroup = "wall"
  dialog.children.push(dialogCarousel)

  document.dispatchEvent({
    type: "click",
    button: 0,
    target: {
      closest(selector) {
        return selector === "[data-flat-pack-lightbox-group]" ? dialogCarousel : null
      }
    },
    preventDefault() {}
  })
  document.dispatchEvent({
    type: "carousel:change",
    detail: { index: 0, trigger: "next" }
  })
  controller.element.dispatchEvent?.({ type: "carousel:change", detail: { index: 1 } })

  assert.equal(dialog.open, true)
  assert.equal(stage.flatPackCarousel.moved, 2)
})

test("reduced motion closes without waiting on a transform", () => {
  const { controller, dialog } = mount({ reduceMotion: true })
  controller.openAt(0, null)
  assert.equal(dialog.style.opacity, "1")
  assert.equal(dialog.style.scale, "1")
  controller.requestClose()
  assert.equal(dialog.open, false)
})
