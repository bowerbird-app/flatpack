const test = require("node:test")
const assert = require("node:assert/strict")
const fs = require("node:fs")
const path = require("node:path")
const vm = require("node:vm")

function loadController({ reduced = false, tokens = null } = {}) {
  const filePath = path.join(__dirname, "..", "..", "app", "javascript", "flat_pack", "controllers", "svg_motion_controller.js")
  const source = fs.readFileSync(filePath, "utf8")
  const transformed = source
    .replace('import { Controller } from "@hotwired/stimulus"', "class Controller {}")
    .replace(
      'import { prefersReducedMotion, motionTokenMs } from "controllers/flat_pack/reduced_motion"',
      `function prefersReducedMotion() { return ${reduced} }\nfunction motionTokenMs(token) { return token === "fast" ? 150 : token === "slow" ? 300 : 200 }`
    )
    .replace("export default class extends Controller", "class SvgMotionController extends Controller")
    + "\nmodule.exports = SvgMotionController\n"

  const context = { module: { exports: {} }, exports: {}, globalThis: {} }
  context.globalThis = context
  if (tokens) {
    context.document = { documentElement: {} }
    context.getComputedStyle = () => ({
      getPropertyValue(name) { return tokens[name] || "" }
    })
  }
  vm.runInNewContext(transformed, context, { filename: filePath })
  return context.module.exports
}

function animationRecord(frames, timing) {
  return {
    frames,
    timing,
    playState: "running",
    cancel() { this.playState = "idle" },
    pause() { this.playState = "paused" },
    play() { this.playState = "running" }
  }
}

function buildElement() {
  const records = []
  const animatable = () => ({
    style: {},
    animate(frames, timing) {
      const record = animationRecord(frames, timing)
      records.push(record)
      return record
    }
  })
  const body = animatable()
  const eyes = animatable()
  const stroke = Object.assign(animatable(), { getTotalLength() { return 24 } })
  const element = {
    style: {},
    listeners: {},
    records,
    body,
    eyes,
    stroke,
    addEventListener(type, fn) { this.listeners[type] = fn },
    removeEventListener(type) { delete this.listeners[type] },
    querySelectorAll(selector) {
      if (selector.includes("data-part") && selector.includes("path")) return [eyes, stroke]
      if (selector.includes("eyes")) return [eyes]
      if (selector.includes("body")) return [body]
      if (selector.includes("path")) return [stroke]
      return []
    },
    animate(frames, timing) {
      const record = animationRecord(frames, timing)
      records.push(record)
      return record
    }
  }
  return element
}

function mount(definition, { state = "idle", trigger = "mount", reduced = false, tokens = null } = {}) {
  const SvgMotionController = loadController({ reduced, tokens })
  const element = buildElement()
  const controller = new SvgMotionController()
  controller.element = element
  controller.definitionValue = definition
  controller.stateValue = state
  controller.triggerValue = trigger
  controller.connect()
  return { controller, element }
}

const bot = {
  states: {
    idle: {
      tracks: [
        { part: "body", property: "translateY", keyframes: [0, -1.5, 0], duration: 2200, delay: 0, easing: "standard", iterations: "infinite" }
      ]
    },
    blink: {
      tracks: [
        { part: "eyes", property: "scaleY", keyframes: [1, 0.08, 1], duration: 160, delay: 0, easing: "standard", iterations: 1 }
      ]
    }
  }
}

test("mount plays the idle track on the named part", () => {
  const { element } = mount(bot)
  const record = element.records[0]

  assert.equal(element.records.length, 1)
  assert.equal(record.frames[1].translate, "0px -1.5px")
  assert.equal(record.timing.iterations, Infinity)
  assert.equal(record.timing.easing, "cubic-bezier(0.2, 0, 0, 1)")
})

test("setState switches tracks and cancels the previous animation", () => {
  const { controller, element } = mount(bot)
  const idle = element.records[0]

  controller.setState("blink")

  assert.equal(idle.playState, "idle")
  assert.equal(element.records.at(-1).frames[1].scale, "1 0.08")
})

test("setState reads a stimulus action param", () => {
  const { controller, element } = mount(bot)

  controller.setState({ params: { state: "blink" } })

  assert.equal(element.records.at(-1).frames[1].scale, "1 0.08")
})

test("reduced motion stays on the first frame", () => {
  const { controller, element } = mount(bot, { reduced: true })

  controller.setState("blink")

  assert.equal(element.records.length, 0)
  assert.equal(controller.stateValue, "blink")
})

test("pause resume stop and reset", () => {
  const { controller, element } = mount(bot)
  const idle = element.records[0]

  controller.pause()
  assert.equal(idle.playState, "paused")
  controller.resume()
  assert.equal(idle.playState, "running")
  controller.stop()
  assert.equal(idle.playState, "idle")

  element.eyes.style.strokeDasharray = "12"
  controller.reset()
  assert.equal(element.eyes.style.strokeDasharray, "")
  assert.equal(element.style.translate, "")
})

test("draw animates stroke length to zero", () => {
  const draw = {
    states: {
      play: {
        tracks: [
          { part: "strokes", property: "strokeDashoffset", keyframes: ["length", 0], duration: "base", delay: 0, easing: "enter", iterations: 1 }
        ]
      }
    }
  }
  const { element } = mount(draw, { state: "play" })
  const record = element.records[0]

  assert.equal(element.stroke.style.strokeDasharray, "24")
  assert.equal(record.frames[0].strokeDashoffset, 24)
  assert.equal(record.frames[1].strokeDashoffset, 0)
  assert.equal(record.timing.duration, 200)
  assert.equal(record.timing.easing, "cubic-bezier(0.05, 0.7, 0.1, 1)")
})

test("named durations and enter easing read the motion tokens", () => {
  const draw = {
    states: {
      play: {
        tracks: [
          { part: "strokes", property: "strokeDashoffset", keyframes: ["length", 0], duration: "slow", delay: 0, easing: "enter", iterations: 1 }
        ]
      }
    }
  }
  const { element } = mount(draw, {
    state: "play",
    tokens: { "--motion-ease-out": "cubic-bezier(0.1, 0.2, 0.3, 1)" }
  })

  assert.equal(element.records[0].timing.duration, 300)
  assert.equal(element.records[0].timing.easing, "cubic-bezier(0.1, 0.2, 0.3, 1)")
})

test("standard, exit, and linear stay off the motion ease", () => {
  const spec = {
    states: {
      play: {
        tracks: [
          { part: "root", property: "opacity", keyframes: [0, 1], duration: 100, delay: 0, easing: "standard", iterations: 1 },
          { part: "root", property: "opacity", keyframes: [1, 0], duration: 100, delay: 0, easing: "exit", iterations: 1 },
          { part: "root", property: "opacity", keyframes: [0, 1], duration: 100, delay: 0, easing: "linear", iterations: 1 }
        ]
      }
    }
  }
  const { element } = mount(spec, {
    state: "play",
    tokens: {
      "--easing-standard": "cubic-bezier(0.11, 0, 0, 1)",
      "--easing-exit": "cubic-bezier(0.4, 0, 1, 1)",
      "--motion-ease-out": "cubic-bezier(0.9, 0, 0, 1)"
    }
  })

  assert.equal(element.records[0].timing.easing, "cubic-bezier(0.11, 0, 0, 1)")
  assert.equal(element.records[1].timing.easing, "cubic-bezier(0.4, 0, 1, 1)")
  assert.equal(element.records[2].timing.easing, "linear")
})

test("matching scale axes become one scale animation", () => {
  const pop = {
    states: {
      play: {
        tracks: [
          { part: "root", property: "scaleX", keyframes: [1, 1.18, 1], duration: 200, delay: 0, easing: "enter", iterations: 1 },
          { part: "root", property: "scaleY", keyframes: [1, 0.9, 1], duration: 200, delay: 0, easing: "enter", iterations: 1 }
        ]
      }
    }
  }
  const { element } = mount(pop, { state: "play" })

  assert.equal(element.records.length, 1)
  assert.equal(element.records[0].frames[1].scale, "1.18 0.9")
})

test("hover waits for pointerenter and click waits for click", () => {
  const wiggle = {
    states: {
      play: {
        tracks: [
          { part: "root", property: "rotate", keyframes: [0, -14, 0], duration: 480, delay: 0, easing: "standard", iterations: 1 }
        ]
      }
    }
  }
  const hover = mount(wiggle, { state: "play", trigger: "hover" })
  assert.equal(hover.element.records.length, 0)
  hover.element.listeners.pointerenter()
  assert.equal(hover.element.records[0].frames[1].rotate, "-14deg")

  const click = mount(wiggle, { state: "play", trigger: "click" })
  assert.equal(click.element.records.length, 0)
  click.element.listeners.click()
  assert.equal(click.element.records.length, 1)
})
