const test = require("node:test")
const assert = require("node:assert/strict")
const fs = require("node:fs")
const path = require("node:path")
const vm = require("node:vm")

function loadController({ reduced = false, delay = "40ms" } = {}) {
  const filePath = path.join(__dirname, "..", "..", "app", "javascript", "flat_pack", "controllers", "text_stream_controller.js")
  const source = fs.readFileSync(filePath, "utf8")
  const transformed = source
    .replace('import { Controller } from "@hotwired/stimulus"', "class Controller {}")
    .replace(
      'import { prefersReducedMotion } from "controllers/flat_pack/reduced_motion"',
      `function prefersReducedMotion() { return ${reduced} }`
    )
    .replace("export default class extends Controller", "class TextStreamController extends Controller") +
    "\nmodule.exports = TextStreamController\n"

  const timers = []
  const context = {
    module: { exports: {} },
    exports: {},
    getComputedStyle() {
      return { getPropertyValue() { return delay } }
    },
    setTimeout(fn) {
      timers.push(fn)
      return timers.length
    },
    clearTimeout(id) {
      if (id != null) timers[id - 1] = null
    }
  }
  context.globalThis = context
  vm.runInNewContext(transformed, context, { filename: filePath })
  return { ControllerClass: context.module.exports, timers, context }
}

function classList() {
  const names = new Set()
  return {
    contains(name) { return names.has(name) },
    add(name) { names.add(name) },
    names() { return Array.from(names) }
  }
}

function build({ reduced = false, text = "Hi!", delay = "40ms" } = {}) {
  const loaded = loadController({ reduced, delay })
  let observer = null
  loaded.context.IntersectionObserver = class {
    constructor(callback) {
      this.callback = callback
      observer = this
    }
    observe() {}
    disconnect() { this.disconnected = true }
  }

  const source = { textContent: text }
  const typed = { textContent: "" }
  const caret = { hidden: true }
  const live = { hidden: true }
  const element = { classList: classList() }
  const controller = Object.assign(new loaded.ControllerClass(), {
    element,
    sourceTarget: source,
    typedTarget: typed,
    caretTarget: caret,
    liveTarget: live,
    hasSourceTarget: true,
    hasTypedTarget: true,
    hasCaretTarget: true,
    hasLiveTarget: true
  })

  return {
    controller,
    element,
    source,
    typed,
    caret,
    live,
    timers: loaded.timers,
    get observer() { return observer },
    restore() {},
    flush() {
      let guard = 0
      while (loaded.timers.some(Boolean) && guard < 500) {
        const batch = loaded.timers.splice(0)
        batch.forEach((fn) => fn && fn())
        guard += 1
      }
    }
  }
}

test("reduced motion does not hide the source or start typing", () => {
  const harness = build({ reduced: true })
  harness.controller.connect()

  assert.deepEqual(harness.element.classList.names(), [])
  assert.equal(harness.live.hidden, true)
  assert.equal(harness.typed.textContent, "")
  assert.equal(harness.source.textContent, "Hi!")
  assert.equal(harness.observer, null)
  harness.restore()
})

test("connect arms the caret and intersection types the source once", () => {
  const harness = build({ text: "Ab" })
  harness.controller.connect()

  assert.ok(harness.element.classList.contains("is-streaming"))
  assert.equal(harness.live.hidden, false)
  assert.equal(harness.caret.hidden, false)
  assert.equal(harness.typed.textContent, "")
  assert.equal(harness.source.textContent, "Ab")

  harness.observer.callback([{ isIntersecting: false }])
  assert.equal(harness.typed.textContent, "")

  harness.observer.callback([{ isIntersecting: true }])
  assert.equal(harness.typed.textContent, "A")
  assert.equal(harness.observer.disconnected, true)

  harness.flush()
  assert.equal(harness.typed.textContent, "Ab")
  assert.equal(harness.caret.hidden, true)
  assert.equal(harness.source.textContent, "Ab")
  harness.restore()
})

test("glyph delay clamps the stagger token", () => {
  const slow = build({ text: "A", delay: "400ms" })
  slow.controller.connect()
  assert.equal(slow.controller.readDelay(), 80)
  slow.restore()

  const fast = build({ text: "A", delay: "1ms" })
  fast.controller.connect()
  assert.equal(fast.controller.readDelay(), 12)
  fast.restore()

  const fallback = build({ text: "A", delay: "0ms" })
  fallback.controller.connect()
  assert.equal(fallback.controller.readDelay(), 32)
  fallback.restore()
})

test("disconnect clears a pending keystroke", () => {
  const harness = build({ text: "Ab" })
  harness.controller.connect()
  harness.observer.callback([{ isIntersecting: true }])
  assert.equal(harness.timers.length, 1)

  harness.controller.disconnect()
  harness.flush()
  assert.equal(harness.typed.textContent, "A")
  harness.restore()
})
