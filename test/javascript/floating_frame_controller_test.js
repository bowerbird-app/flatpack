const test = require("node:test")
const assert = require("node:assert/strict")
const fs = require("node:fs")
const path = require("node:path")
const vm = require("node:vm")

function loadController(documentStub) {
  const source = fs.readFileSync(
    path.join(__dirname, "..", "..", "app", "javascript", "flat_pack", "controllers", "floating_frame_controller.js"),
    "utf8"
  )
    .replace('import { Controller } from "@hotwired/stimulus"', "class Controller {}")
    .replace("export default class extends Controller", "class FloatingFrameController extends Controller")

  const context = {
    module: { exports: {} },
    document: documentStub,
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

test("closing restores focus and a later open does not mount a second iframe", () => {
  const { controller, trigger, mountPoint, close } = mount()

  trigger.setAttribute("aria-expanded", "true")
  controller.onExpanded()
  trigger.setAttribute("aria-expanded", "false")
  controller.onExpanded()

  assert.equal(trigger.focusCount, 1)
  assert.equal(mountPoint.childElementCount, 1)

  trigger.setAttribute("aria-expanded", "true")
  controller.onExpanded()

  assert.equal(mountPoint.childElementCount, 1)
  assert.equal(close.focusCount, 2)
})

test("an unchanged aria-expanded does not move focus", () => {
  const { controller, trigger, close } = mount()

  controller.onExpanded()

  assert.equal(close.focusCount, 0)
  assert.equal(trigger.focusCount, 0)
})
