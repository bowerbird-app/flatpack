const test = require("node:test")
const assert = require("node:assert/strict")
const fs = require("node:fs")
const path = require("node:path")
const vm = require("node:vm")

function loadController() {
  const filePath = path.join(__dirname, "..", "..", "app", "javascript", "flat_pack", "controllers", "carousel_controller.js")
  const source = fs.readFileSync(filePath, "utf8")
    .replace('import { Controller } from "@hotwired/stimulus"', "class Controller {}")
    .replace(
      'import { prefersReducedMotion } from "controllers/flat_pack/reduced_motion"',
      "function prefersReducedMotion() { return globalThis.__reduceMotion === true }"
    )
    .replace("export default class extends Controller", "class CarouselController extends Controller")
    + "\nmodule.exports = CarouselController\n"

  const listeners = new Map()
  const opens = []
  const document = {
    body: {},
    activeElement: null,
    addEventListener(type, handler) {
      const list = listeners.get(type) || []
      list.push(handler)
      listeners.set(type, list)
    },
    removeEventListener(type, handler) {
      listeners.set(type, (listeners.get(type) || []).filter((item) => item !== handler))
    },
    dispatchEvent(event) {
      if (event.type === "flat-pack:lightbox:open") opens.push(event)
      ;(listeners.get(event.type) || []).slice().forEach((handler) => handler(event))
      return true
    },
    querySelector() { return {} }
  }

  const intervals = new Map()
  let intervalId = 0
  const windowListeners = new Map()
  const context = {
    module: { exports: {} },
    document,
    window: {
      innerWidth: 1280,
      requestAnimationFrame(fn) { fn(); return 1 },
      cancelAnimationFrame() {},
      setInterval(fn, ms) {
        const id = ++intervalId
        intervals.set(id, { fn, ms })
        return id
      },
      clearInterval(id) { intervals.delete(id) },
      addEventListener(type, handler) {
        windowListeners.set(type, handler)
      },
      removeEventListener(type) { windowListeners.delete(type) },
      dispatchEvent(event) {
        windowListeners.get(event.type)?.(event)
        return true
      },
      getComputedStyle() {
        return { direction: "ltr", getPropertyValue() { return "" } }
      }
    },
    CSS: { escape(value) { return value } },
    HTMLElement: function HTMLElement() {},
    Event: class Event {
      constructor(type) { this.type = type }
    },
    CustomEvent: class CustomEvent {
      constructor(type, init = {}) {
        this.type = type
        this.detail = init.detail
        this.bubbles = init.bubbles
      }
    }
  }
  context.globalThis = context
  vm.runInNewContext(source, context, { filename: filePath })
  return { Controller: context.module.exports, document, context, opens, intervals }
}

function classList() {
  const names = new Set()
  return {
    add(name) { names.add(name) },
    remove(name) { names.delete(name) },
    toggle(name, force) {
      if (force === false || (force !== true && names.has(name))) names.delete(name)
      else names.add(name)
    },
    contains(name) { return names.has(name) }
  }
}

function bus() {
  const listeners = new Map()
  return {
    addEventListener(type, handler) {
      const list = listeners.get(type) || []
      list.push(handler)
      listeners.set(type, list)
    },
    removeEventListener(type, handler) {
      listeners.set(type, (listeners.get(type) || []).filter((item) => item !== handler))
    },
    dispatchEvent(event) {
      ;(listeners.get(event.type) || []).slice().forEach((handler) => handler(event))
      return true
    }
  }
}

function slide(index, options = {}) {
  const enabled = options.enabled !== false
  return {
    dataset: {
      lightboxEnabled: enabled ? "true" : "false",
      lightboxSrc: enabled ? (options.src || `https://images.example.com/${index}.jpg`) : "",
      lightboxIndex: enabled ? String(options.lightboxIndex ?? index) : "",
      caption: ""
    },
    classList: classList(),
    style: {},
    hidden: false,
    setAttribute() {}
  }
}

function clickTarget({ slide: slideNode = null, control = null } = {}) {
  return {
    closest(selector) {
      if (String(selector).includes("carousel-target")) return slideNode
      if (String(selector).startsWith("button")) return control
      return null
    }
  }
}

function mount(options = {}) {
  const loaded = loadController()
  const { Controller, document, context, opens, intervals } = loaded
  const root = bus()
  root.dataset = { flatPackLightboxGroup: options.group || "wall" }
  const viewport = bus()
  viewport.classList = classList()
  viewport.clientWidth = 400
  viewport.contains = () => false
  viewport.setPointerCapture = () => {}
  viewport.releasePointerCapture = () => {}
  viewport.hasPointerCapture = () => false
  const slides = options.slides || [slide(0), slide(1), slide(2)]
  root.contains = (node) => slides.includes(node)

  const controller = new Controller()
  controller.element = root
  controller.viewportTarget = viewport
  controller.hasViewportTarget = true
  controller.slideTargets = slides
  controller.indicatorTargets = []
  controller.thumbTargets = []
  controller.hasLightboxToggleTarget = false
  controller.initialIndexValue = options.initialIndex || 0
  controller.loopValue = true
  controller.autoplayValue = options.autoplay === true
  controller.autoplayIntervalValue = 5000
  controller.pauseOnHoverValue = false
  controller.pauseOnFocusValue = false
  controller.touchSwipeValue = options.touchSwipe !== false
  controller.transitionValue = "slide"
  controller.variantValue = "default"
  controller.itemsPerViewMobileValue = 1
  controller.itemsPerViewTabletValue = 1
  controller.itemsPerViewDesktopValue = 1
  controller.sidePreviewValue = false
  controller.logicalSlideCountValue = 0
  controller.connect()

  return { controller, root, viewport, slides, document, context, opens, intervals }
}

function click(root, target, extras = {}) {
  const event = {
    type: "click",
    button: 0,
    target,
    preventDefault() { this.defaulted = true },
    stopPropagation() { this.stopped = true },
    ...extras
  }
  root.dispatchEvent(event)
  return event
}

test("clicking a slide opens the lightbox at the current item for several indexes", () => {
  const { controller, root, slides, opens } = mount({ autoplay: true })

  ;[0, 1, 2].forEach((index) => {
    controller.currentIndex = index
    const event = click(root, clickTarget({ slide: slides[0] }))
    assert.equal(event.defaulted, true)
    assert.equal(opens.at(-1).detail.group, "wall")
    assert.equal(opens.at(-1).detail.index, index)
  })
  assert.equal(opens.length, 3)
})

test("a mixed gallery opens the lightbox index of the current slide", () => {
  const slides = [
    slide(0, { lightboxIndex: 0 }),
    slide(1, { enabled: false }),
    slide(2, { lightboxIndex: 1, src: "https://videos.example.com/two.mp4" })
  ]
  const { controller, root, opens } = mount({ slides })

  controller.currentIndex = 2
  click(root, clickTarget({ slide: slides[0] }))
  assert.equal(opens.length, 1)
  assert.equal(opens[0].detail.index, 1)

  click(root, clickTarget({ slide: slides[1] }))
  assert.equal(opens.length, 1)
})

test("carousel controls do not open the lightbox", () => {
  const { root, slides, opens } = mount()
  const prev = clickTarget({ control: { name: "prev" } })
  const next = clickTarget({ control: { name: "next" } })
  const indicator = clickTarget({ control: { name: "indicator" } })
  const autoplay = clickTarget({ control: { name: "autoplay" } })
  const video = clickTarget({ slide: slides[1], control: { name: "video" } })

  ;[prev, next, indicator, autoplay, video].forEach((target) => {
    click(root, target)
  })

  click(root, clickTarget({ slide: slides[1] }), { metaKey: true })
  assert.equal(opens.length, 0)
})

test("the expand control opens the current item and a following root click does not open a second time", () => {
  const { controller, root, slides, opens } = mount()
  const toggle = clickTarget({ control: { name: "expand" } })
  controller.hasLightboxToggleTarget = true
  controller.lightboxToggleTarget = toggle.closest("button")
  controller.currentIndex = 1

  const event = {
    type: "click",
    button: 0,
    target: toggle,
    preventDefault() { this.defaulted = true },
    stopPropagation() { this.stopped = true }
  }
  controller.openLightbox(event)
  assert.equal(opens.length, 1)
  assert.equal(opens[0].detail.index, 1)
  assert.equal(event.stopped, true)

  root.dispatchEvent(event)
  assert.equal(opens.length, 1)
})

test("autoplay pauses while the lightbox is open and resumes on close", () => {
  const { controller, root, slides, document, context, opens, intervals } = mount({ autoplay: true })
  assert.equal(intervals.size, 1)

  controller.currentIndex = 2
  click(root, clickTarget({ slide: slides[2] }))
  assert.equal(intervals.size, 0)
  assert.equal(controller.pauseReasons.has("lightbox"), true)
  assert.equal(opens.length, 1)
  assert.equal(opens[0].detail.index, 2)

  controller.handleKeydown({ key: " ", preventDefault() {} })
  assert.equal(intervals.size, 0)
  assert.equal(opens.length, 1)

  root.dispatchEvent({ type: "carousel:change", detail: { index: 0, trigger: "next" } })
  assert.equal(opens.length, 1)
  assert.equal(controller.currentIndex, 2)

  document.dispatchEvent(new context.CustomEvent("flat-pack:lightbox:close", {
    detail: { group: "wall" }
  }))
  assert.equal(controller.pauseReasons.has("lightbox"), false)
  assert.equal(intervals.size, 1)
  assert.equal(opens.length, 1)

  document.dispatchEvent(new context.CustomEvent("flat-pack:lightbox:close", {
    detail: { group: "other" }
  }))
  assert.equal(intervals.size, 1)
})

test("a swipe does not open the lightbox and later navigation does not loop", () => {
  const { controller, root, viewport, slides, opens } = mount({ autoplay: true })
  const image = clickTarget({ slide: slides[0] })

  controller.pointerDownHandler({
    pointerId: 1,
    pointerType: "mouse",
    button: 0,
    isPrimary: true,
    clientX: 300,
    clientY: 20,
    target: image
  })
  controller.pointerUpHandler({
    pointerId: 1,
    clientX: 20,
    clientY: 20
  })

  assert.equal(controller.currentIndex, 1)
  assert.equal(controller.suppressLightboxClick, true)
  click(root, image)
  assert.equal(opens.length, 0)
  assert.equal(controller.suppressLightboxClick, false)
  assert.equal(controller.currentIndex, 1)

  controller.next()
  root.dispatchEvent({ type: "carousel:change", detail: { index: controller.currentIndex, trigger: "next" } })
  assert.equal(opens.length, 0)
  assert.equal(viewport.clientWidth, 400)
})

test("disconnect removes the click and close listeners", () => {
  const { controller, root, document, context, opens } = mount()
  controller.disconnect()
  root.dispatchEvent({
    type: "click",
    button: 0,
    target: clickTarget({ slide: controller.slideTargets[0] }),
    preventDefault() {},
    stopPropagation() {}
  })
  document.dispatchEvent(new context.CustomEvent("flat-pack:lightbox:close", {
    detail: { group: "wall" }
  }))
  assert.equal(opens.length, 0)
})
