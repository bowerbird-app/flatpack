const test = require("node:test")
const assert = require("node:assert/strict")
const fs = require("node:fs")
const path = require("node:path")
const vm = require("node:vm")

function loadController(globals = {}) {
  const source = fs.readFileSync(
    path.join(__dirname, "..", "..", "app", "javascript", "flat_pack", "controllers", "floating_frame_controller.js"),
    "utf8"
  )
    .replace('import { Controller } from "@hotwired/stimulus"', "class Controller {}")
    .replace("export default class extends Controller", "class FloatingFrameController extends Controller")

  const context = {
    module: { exports: {} },
    document: globals.document,
    window: globals.window,
    MutationObserver: class {
      observe() {}
      disconnect() {}
    },
    requestAnimationFrame(callback) { callback() }
  }
  vm.runInNewContext(`${source}\nmodule.exports = FloatingFrameController\n`, context, {
    filename: "floating_frame_controller.js"
  })
  return context.module.exports
}

class Node {
  constructor(name, attrs = {}) {
    this.nodeName = name
    this.attrs = attrs
    this.children = []
    this.focusCount = 0
  }

  get childElementCount() {
    return this.children.length
  }

  setAttribute(name, value) {
    this.attrs[name] = String(value)
  }

  getAttribute(name) {
    return Object.prototype.hasOwnProperty.call(this.attrs, name) ? this.attrs[name] : null
  }

  querySelector(selector) {
    const found = []
    const walk = (node) => {
      if (node !== this && matches(node, selector)) found.push(node)
      node.children.forEach(walk)
    }
    walk(this)
    return found[0] || null
  }

  append(node) {
    if (node.nodeName === "#fragment") {
      node.children.splice(0).forEach((child) => this.append(child))
      return
    }
    this.children.push(node)
  }

  focus() {
    this.focusCount += 1
  }
}

function matches(node, selector) {
  const target = selector.match(/\[data-flat-pack--floating-frame-target='([^']+)'\]/)
  if (!target) return false
  return node.getAttribute("data-flat-pack--floating-frame-target") === target[1]
}

function mount() {
  const iframe = new Node("iframe", { src: "/notes" })
  const template = new Node("template", { "data-flat-pack--floating-frame-target": "source" })
  template.content = new Node("#fragment")
  template.content.children.push(iframe)

  const mountPoint = new Node("div", { "data-flat-pack--floating-frame-target": "mount" })
  const close = new Node("button", { "data-flat-pack--floating-frame-target": "close" })
  const trigger = new Node("button", {
    "data-flat-pack--floating-frame-target": "trigger",
    "aria-expanded": "false"
  })
  const root = new Node("div")
  root.children.push(trigger, template, mountPoint, close)

  const Controller = loadController()
  const controller = new Controller()
  controller.element = root
  controller.connect()
  return { controller, trigger, mountPoint, close, iframe }
}

test("the first open mounts the iframe and focuses the close button", () => {
  const { controller, trigger, mountPoint, close, iframe } = mount()

  assert.equal(mountPoint.childElementCount, 0)

  trigger.setAttribute("aria-expanded", "true")
  controller.onExpanded()

  assert.equal(mountPoint.children[0], iframe)
  assert.equal(close.focusCount, 1)
  assert.equal(trigger.focusCount, 0)
})

test("a later open does not mount a second iframe", () => {
  const { controller, trigger, mountPoint, close } = mount()

  trigger.setAttribute("aria-expanded", "true")
  controller.onExpanded()
  trigger.setAttribute("aria-expanded", "false")
  controller.onExpanded()

  assert.equal(trigger.focusCount, 0)
  assert.equal(mountPoint.childElementCount, 1)

  trigger.setAttribute("aria-expanded", "true")
  controller.onExpanded()

  assert.equal(mountPoint.childElementCount, 1)
  assert.equal(close.focusCount, 2)
})

test("focus returns to the launcher only when the close control asks", () => {
  const { controller, trigger } = mount()

  trigger.setAttribute("aria-expanded", "true")
  controller.onExpanded()
  trigger.setAttribute("aria-expanded", "false")
  controller.onExpanded()
  assert.equal(trigger.focusCount, 0)

  trigger.setAttribute("aria-expanded", "true")
  controller.onExpanded()
  controller.prepareRestore()
  trigger.setAttribute("aria-expanded", "false")
  controller.onExpanded()

  assert.equal(trigger.focusCount, 1)
})

test("escape inside a same-origin frame clicks close", () => {
  const { controller, trigger, close, iframe } = mount()
  iframe.addEventListener = () => {}
  iframe.contentWindow = {
    listeners: [],
    addEventListener(name, fn) { this.listeners.push([name, fn]) },
    removeEventListener() {}
  }
  trigger.setAttribute("aria-expanded", "true")
  controller.onExpanded()

  let clicks = 0
  close.click = () => { clicks += 1 }
  const keys = iframe.contentWindow.listeners.filter(([name]) => name === "keydown")
  assert.equal(keys.length, 2)
  keys.forEach(([, fn]) => fn({ key: "Escape", preventDefault() {}, stopPropagation() {} }))

  assert.equal(clicks, 1)
})

test("a cross-origin frame does not throw when binding keys", () => {
  const { controller, trigger, iframe } = mount()
  iframe.addEventListener = () => {}
  iframe.contentDocument = {}
  const win = {}
  Object.defineProperty(win, "addEventListener", {
    get() { throw new Error("SecurityError") }
  })
  iframe.contentWindow = win
  trigger.setAttribute("aria-expanded", "true")

  assert.doesNotThrow(() => controller.onExpanded())
  assert.equal(controller.boundWindow, null)
})

test("a null contentDocument does not touch the frame window", () => {
  const { controller, trigger, iframe } = mount()
  iframe.addEventListener = () => {}
  iframe.contentDocument = null
  let reads = 0
  const win = {}
  Object.defineProperty(win, "addEventListener", {
    get() {
      reads += 1
      throw new Error("SecurityError")
    }
  })
  iframe.contentWindow = win
  trigger.setAttribute("aria-expanded", "true")

  assert.doesNotThrow(() => controller.onExpanded())
  assert.equal(reads, 0)
  assert.equal(controller.boundWindow, null)
})

test("disconnect still removes parent listeners when frame cleanup throws", () => {
  const calls = []
  const documentStub = {
    body: { append() {} },
    addEventListener(type) { calls.push(["add", type]) },
    removeEventListener(type) { calls.push(["remove", type]) }
  }
  const media = {
    matches: true,
    addEventListener(type) { calls.push(["add", type]) },
    removeEventListener(type) { calls.push(["remove", type]) }
  }
  const Controller = loadController({
    document: documentStub,
    window: { matchMedia() { return media } }
  })
  const iframe = new Node("iframe")
  iframe.addEventListener = () => {}
  Object.defineProperty(iframe, "removeEventListener", {
    get() { throw new Error("SecurityError") }
  })
  const template = new Node("template", { "data-flat-pack--floating-frame-target": "source" })
  template.content = new Node("#fragment")
  template.content.children.push(iframe)
  const mountPoint = new Node("div", { "data-flat-pack--floating-frame-target": "mount" })
  const panel = new Node("div", { "data-flat-pack--floating-frame-target": "panel" })
  const close = new Node("button", { "data-flat-pack--floating-frame-target": "close" })
  const trigger = new Node("button", {
    "data-flat-pack--floating-frame-target": "trigger",
    "aria-expanded": "false"
  })
  const root = new Node("div")
  root.children.push(trigger, panel, template, mountPoint, close)
  const controller = new Controller()
  controller.element = root
  controller.connect()
  trigger.setAttribute("aria-expanded", "true")
  controller.onExpanded()

  assert.doesNotThrow(() => controller.disconnect())
  assert.ok(calls.some(([op, type]) => op === "remove" && type === "keydown"))
  assert.ok(calls.some(([op, type]) => op === "remove" && type === "change"))
})

test("modal focusin pulls a tab that left the frame back into the panel", () => {
  const { controller, close, iframe } = mount()
  const panel = new Node("div", { "data-flat-pack--floating-frame-target": "panel" })
  controller.element.children.push(panel)
  controller.open = true
  controller.smallScreen = () => true
  controller.tabStops = () => [close, iframe]
  controller.focusInside = (_panel, node) => node === close || node === iframe
  const outside = new Node("a")

  controller.onFocusIn({ target: outside, relatedTarget: iframe })

  assert.equal(close.focusCount, 1)
  assert.equal(outside.focusCount, 0)

  controller.pointerFocus = true
  controller.onFocusIn({ target: outside, relatedTarget: iframe })

  assert.equal(close.focusCount, 1)
  assert.equal(controller.pointerFocus, false)
})

test("an unchanged aria-expanded does not move focus", () => {
  const { controller, trigger, close } = mount()

  controller.onExpanded()

  assert.equal(close.focusCount, 0)
  assert.equal(trigger.focusCount, 0)
})
