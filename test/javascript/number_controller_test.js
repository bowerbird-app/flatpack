const test = require("node:test")
const assert = require("node:assert/strict")
const fs = require("node:fs")
const path = require("node:path")
const vm = require("node:vm")

function loadController({ reduced = false } = {}) {
  const filePath = path.join(__dirname, "..", "..", "app", "javascript", "flat_pack", "controllers", "number_controller.js")
  const source = fs.readFileSync(filePath, "utf8")
  const transformed = source
    .replace('import { Controller } from "@hotwired/stimulus"', "class Controller {}")
    .replace(
      'import { observeOnce, prefersReducedMotion, motionTokenMs } from "controllers/flat_pack/reduced_motion"',
      `function prefersReducedMotion() { return ${reduced} }
function motionTokenMs() { return ${reduced} ? 0 : 300 }
function observeOnce(element, onEnter) {
  let armed = false
  let waiting = false
  let stopped = false
  const observer = new IntersectionObserver((entries) => {
    if (stopped) return
    if (!entries.some((entry) => entry.isIntersecting)) return
    if (armed) finish()
    else waiting = true
  })
  observer.observe(element)
  requestAnimationFrame(() => {
    requestAnimationFrame(() => {
      if (stopped) return
      armed = true
      if (waiting) finish()
    })
  })
  function finish() {
    if (stopped) return
    stopped = true
    observer.disconnect()
    onEnter()
  }
  return () => {
    stopped = true
    observer.disconnect()
  }
}`
    )
    .replace("export default class extends Controller", "class NumberController extends Controller") +
    "\nmodule.exports = NumberController\n"

  const frames = []
  const context = {
    module: { exports: {} },
    exports: {},
    Intl,
    console,
    requestAnimationFrame(fn) {
      frames.push(fn)
      return frames.length
    },
    cancelAnimationFrame() {},
    document: {
      createElement() {
        const node = { className: "", textContent: "", children: [], writes: [] }
        let transform = ""
        node.style = {}
        Object.defineProperty(node.style, "transform", {
          get() { return transform },
          set(value) {
            transform = value
            node.writes.push(value)
          }
        })
        node.append = (child) => { node.children.push(child) }
        node.replaceChildren = () => { node.children = [] }
        return node
      }
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

function textNode(text) {
  return {
    textContent: text,
    children: [],
    append(child) { this.children.push(child) },
    replaceChildren() { this.children = [] }
  }
}

function build({ reduced = false, animate = "count", value = 2480, from = 0, final = "2,480", fromText = "0", format = "number", currency = "", prefix = "", suffix = "", decimals = undefined } = {}) {
  const loaded = loadController({ reduced })
  let observer = null
  loaded.context.IntersectionObserver = class {
    constructor(callback) {
      this.callback = callback
      observer = this
    }
    observe() {}
    disconnect() { this.disconnected = true }
  }
  const clocks = []
  const element = {
    classList: classList(animate === "none" ? ["is-static"] : []),
    pendingAtFlush: false,
    getBoundingClientRect() { this.pendingAtFlush = this.classList.contains("is-pending") },
    animate() {
      const clock = { currentTime: 0, playState: "running", cancel() { this.playState = "idle" } }
      clocks.push(clock)
      return clock
    }
  }
  const finalTarget = textNode(final)
  const sizerTarget = textNode(final)
  const stageTarget = textNode("")
  const controller = Object.assign(new loaded.ControllerClass(), {
    element,
    animateValue: animate,
    valueValue: value,
    fromValue: from,
    formatValue: format,
    currencyValue: currency,
    prefixValue: prefix,
    suffixValue: suffix,
    durationValue: "slow",
    localeValue: "en",
    fromTextValue: fromText,
    hasDecimalsValue: decimals != null,
    decimalsValue: decimals,
    hasFinalTarget: true,
    hasSizerTarget: true,
    hasStageTarget: true,
    finalTarget,
    sizerTarget,
    stageTarget
  })
  let current = value
  Object.defineProperty(controller, "valueValue", {
    get() { return current },
    set(next) {
      const previous = current
      current = next
      controller.valueValueChanged(next, previous)
    }
  })

  return {
    controller,
    element,
    finalTarget,
    stageTarget,
    clocks,
    get observer() { return observer },
    paint() {
      const batch = loaded.frames.splice(0)
      batch.forEach((fn) => fn())
    }
  }
}

function enter(harness) {
  harness.controller.connect()
  harness.observer.callback([{ isIntersecting: true }])
  harness.paint()
  harness.paint()
}

test("reduced motion shows the finished value and does not observe", () => {
  const harness = build({ reduced: true })
  harness.controller.valueValueChanged(2480, 0)
  harness.controller.connect()

  assert.ok(harness.element.classList.contains("is-static"))
  assert.equal(harness.observer, null)
  assert.equal(harness.stageTarget.textContent, "")
  assert.equal(harness.finalTarget.textContent, "2,480")
})

test("a static number stays on the finished value", () => {
  const harness = build({ animate: "none" })
  harness.controller.connect()

  assert.ok(harness.element.classList.contains("is-static"))
  assert.equal(harness.observer, null)
  harness.controller.setValue(30)
  assert.equal(harness.finalTarget.textContent, "30")
  assert.equal(harness.clocks.length, 0)
})

test("count stays blank until the reveal frame, then eases to the finished string", () => {
  const harness = build()
  harness.controller.valueValueChanged(2480, 0)
  harness.controller.connect()

  assert.equal(harness.stageTarget.textContent, "")
  harness.observer.callback([{ isIntersecting: true }])
  assert.equal(harness.stageTarget.textContent, "")

  harness.paint()
  harness.paint()
  harness.paint()

  assert.equal(harness.stageTarget.textContent, "0")
  assert.equal(harness.clocks.length, 1)

  harness.clocks[0].currentTime = 300
  harness.paint()

  assert.equal(harness.stageTarget.textContent, "2,480")
  assert.equal(harness.finalTarget.textContent, "2,480")
  assert.ok(harness.element.classList.contains("is-settled"))
})

test("a later setValue counts from the number on screen", () => {
  const harness = build()
  enter(harness)
  harness.paint()
  harness.clocks[0].currentTime = 300
  harness.paint()

  harness.controller.setValue(3000)
  harness.paint()

  assert.equal(harness.finalTarget.textContent, "3,000")
  assert.equal(harness.stageTarget.textContent, "2,480")
  assert.equal(harness.clocks.length, 2)

  harness.clocks[1].currentTime = 300
  harness.paint()
  assert.equal(harness.stageTarget.textContent, "3,000")
})

test("a value change before the first frame counts to the new number", () => {
  const harness = build()
  harness.controller.connect()
  harness.controller.setValue(90)
  assert.equal(harness.finalTarget.textContent, "90")
  assert.equal(harness.stageTarget.textContent, "")

  harness.observer.callback([{ isIntersecting: true }])
  harness.paint()
  harness.paint()
  harness.paint()
  harness.clocks[0].currentTime = 300
  harness.paint()

  assert.equal(harness.stageTarget.textContent, "90")
})

test("disconnect before the frame paints does not count", () => {
  const harness = build()
  harness.controller.connect()
  harness.observer.callback([{ isIntersecting: true }])
  harness.controller.disconnect()
  harness.paint()
  harness.paint()

  assert.equal(harness.stageTarget.textContent, "")
  assert.equal(harness.clocks.length, 0)
  assert.equal(harness.observer.disconnected, true)
})

test("fade writes the finished string and settles after the pending frame", () => {
  const harness = build({ animate: "fade" })
  enter(harness)

  assert.equal(harness.stageTarget.textContent, "2,480")
  assert.equal(harness.element.pendingAtFlush, true)
  assert.equal(harness.element.classList.contains("is-pending"), false)
  assert.ok(harness.element.classList.contains("is-settled"))
  assert.equal(harness.clocks.length, 0)
})

test("roll starts each digit at the from column and moves to the finished digit", () => {
  const harness = build({ animate: "roll", fromText: "0" })
  enter(harness)

  const columns = harness.stageTarget.children[0].children.find((node) => node.className === "fp-number__columns")
  const strips = columns.children.filter((node) => node.className === "fp-number__digit").map((digit) => digit.children[0])

  assert.equal(strips.length, 4)
  assert.deepEqual(strips[0].writes, ["translateY(calc(0 * -1em))", "translateY(calc(2 * -1em))"])
  assert.deepEqual(strips[3].writes, ["translateY(calc(0 * -1em))", "translateY(calc(0 * -1em))"])
  assert.equal(harness.element.pendingAtFlush, true)
  assert.equal(harness.element.classList.contains("is-pending"), false)
  assert.equal(columns.children.some((node) => node.className === "fp-number__mark" && node.textContent === ","), true)
})
