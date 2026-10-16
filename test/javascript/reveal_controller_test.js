const test = require("node:test")
const assert = require("node:assert/strict")
const fs = require("node:fs")
const path = require("node:path")
const vm = require("node:vm")

function loadController({ reduced = false } = {}) {
  const filePath = path.join(__dirname, "..", "..", "app", "javascript", "flat_pack", "controllers", "reveal_controller.js")
  const source = fs.readFileSync(filePath, "utf8")
  const transformed = source
    .replace('import { Controller } from "@hotwired/stimulus"', "class Controller {}")
    .replace(
      'import { prefersReducedMotion } from "controllers/flat_pack/reduced_motion"',
      `function prefersReducedMotion() { return ${reduced} }`
    )
    .replace("export default class extends Controller", "class RevealController extends Controller") +
    "\nmodule.exports = RevealController\n"

  const frames = []
  const context = {
    module: { exports: {} },
    exports: {},
    requestAnimationFrame(fn) {
      frames.push(fn)
      return frames.length
    }
  }
  context.globalThis = context
  vm.runInNewContext(transformed, context, { filename: filePath })
  return { ControllerClass: context.module.exports, frames, context }
}

function classList(initial = []) {
  const names = new Set(initial)
  return {
    contains(name) { return names.has(name) },
    add(name) { names.add(name) },
    remove(name) { names.delete(name) },
    names() { return Array.from(names) }
  }
}

function styleStub(initial = {}) {
  const props = { ...initial }
  return {
    getPropertyValue(name) { return props[name] || "" },
    setProperty(name, value) { props[name] = value },
    props
  }
}

function child(className, style) {
  return { classList: classList(className ? [className] : []), style: styleStub(style) }
}

function build({ reduced = false, stagger = false, classes = [], children = [] } = {}) {
  const loaded = loadController({ reduced })
  let observer = null
  loaded.context.IntersectionObserver = class {
    constructor(callback) {
      this.callback = callback
      this.disconnected = false
      observer = this
    }
    observe() {}
    disconnect() { this.disconnected = true }
  }
  const element = { classList: classList(classes), children, style: styleStub() }
  const controller = Object.assign(new loaded.ControllerClass(), {
    element,
    staggerValue: stagger
  })

  return {
    controller,
    element,
    frames: loaded.frames,
    get observer() { return observer },
    restore() {},
    paint() {
      const batch = loaded.frames.splice(0)
      batch.forEach((fn) => fn())
    }
  }
}

test("reduced motion leaves the element in its final state", () => {
  const harness = build({ reduced: true })
  harness.controller.connect()

  assert.deepEqual(harness.element.classList.names(), [])
  assert.equal(harness.observer, null)
  harness.restore()
})

test("connect waits two frames, then reveals once on intersection", () => {
  const harness = build()
  harness.controller.connect()

  assert.ok(harness.element.classList.contains("is-pending"))
  harness.observer.callback([{ isIntersecting: false }])
  assert.ok(harness.element.classList.contains("is-pending"))

  harness.observer.callback([{ isIntersecting: true }])
  assert.equal(harness.element.classList.contains("is-revealed"), false)

  harness.paint()
  harness.paint()

  assert.ok(harness.element.classList.contains("is-revealed"))
  assert.equal(harness.element.classList.contains("is-pending"), false)
  assert.equal(harness.observer.disconnected, true)

  harness.controller.finish()
  assert.ok(harness.element.classList.contains("is-revealed"))
  harness.restore()
})

test("disconnect before the frame paints does not reveal", () => {
  const harness = build()
  harness.controller.connect()
  harness.observer.callback([{ isIntersecting: true }])
  harness.controller.disconnect()
  harness.paint()
  harness.paint()

  assert.equal(harness.element.classList.contains("is-revealed"), false)
  assert.equal(harness.observer.disconnected, true)
  harness.restore()
})

test("stagger indexes children and skips plain text and preset indexes", () => {
  const plain = child("fp-reveal__plain")
  const preset = child("", { "--reveal-index": "4" })
  const first = child()
  const second = child()
  const harness = build({ stagger: true, children: [plain, preset, first, second] })

  harness.controller.connect()

  assert.equal(plain.style.props["--reveal-index"], undefined)
  assert.equal(preset.style.props["--reveal-index"], "4")
  assert.equal(first.style.props["--reveal-index"], "0")
  assert.equal(second.style.props["--reveal-index"], "1")
  harness.restore()
})
