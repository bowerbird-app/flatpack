const test = require("node:test")
const assert = require("node:assert/strict")
const fs = require("node:fs")
const path = require("node:path")
const vm = require("node:vm")

function loadController() {
  const filePath = path.join(__dirname, "..", "..", "app", "javascript", "flat_pack", "controllers", "font_swatch_controller.js")
  const source = fs.readFileSync(filePath, "utf8")
  const transformed = source
    .replace('import { Controller } from "@hotwired/stimulus"', "class Controller {}")
    .replace("export default class extends Controller", "class FontSwatchController extends Controller")
    + "\nmodule.exports = FontSwatchController\n"

  const context = {
    module: {exports: {}},
    exports: {},
    MutationObserver: class {
      observe() {}
      disconnect() {}
    },
    CustomEvent: class {
      constructor(type, options = {}) {
        this.type = type
        this.bubbles = options.bubbles || false
        this.detail = options.detail
      }
    }
  }
  context.globalThis = context
  vm.runInNewContext(transformed, context, {filename: filePath})
  return context.module.exports
}

function option(value, label, selected) {
  return {
    dataset: {value, label},
    attributes: {"aria-selected": selected ? "true" : "false"},
    setAttribute(name, next) { this.attributes[name] = next }
  }
}

function build({inputValue = "ui-sans-serif", fontValue = "ui-sans-serif"} = {}) {
  const ControllerClass = loadController()
  const controller = new ControllerClass()
  const events = []
  const input = {value: inputValue}
  const swatch = {style: {fontFamily: inputValue}}
  const trigger = {
    attributes: {"aria-label": "Sans", "aria-expanded": "false"},
    setAttribute(name, next) { this.attributes[name] = next },
    getAttribute(name) { return this.attributes[name] }
  }
  const options = [
    option("ui-sans-serif", "Sans", true),
    option("ui-serif", "Serif", false)
  ]
  const tooltip = {textContent: "Sans"}

  controller.element = {
    dispatchEvent(event) {
      events.push(event)
      return true
    },
    querySelector(selector) {
      return selector === '[role="tooltip"]' ? tooltip : null
    }
  }
  controller.fontValue = fontValue
  controller.inputTarget = input
  controller.swatchTarget = swatch
  controller.triggerTarget = trigger
  controller.optionTargets = options
  controller.hasInputTarget = true
  controller.hasSwatchTarget = true
  controller.hasTriggerTarget = true
  controller.hasOptionTarget = true
  controller.connect()

  return {controller, input, swatch, trigger, options, tooltip, events}
}

test("reset restores the server font and option selection", () => {
  const {controller, input, swatch, trigger, options, tooltip, events} = build()

  input.value = "ui-serif"
  swatch.style.fontFamily = "ui-serif"
  options[0].attributes["aria-selected"] = "false"
  options[1].attributes["aria-selected"] = "true"
  events.length = 0

  controller.reset()

  assert.equal(input.value, "ui-sans-serif")
  assert.equal(swatch.style.fontFamily, "ui-sans-serif")
  assert.equal(options[0].attributes["aria-selected"], "true")
  assert.equal(options[1].attributes["aria-selected"], "false")
  assert.equal(trigger.attributes["aria-label"], "Sans")
  assert.equal(tooltip.textContent, "Sans")
  assert.equal(events.at(-1).type, "font-swatch:change")
  assert.equal(events.at(-1).detail.value, "ui-sans-serif")
  assert.equal(events.at(-1).detail.label, "Sans")
  assert.equal(events.at(-1).bubbles, true)
})

test("reset uses detail.value when the host passes a font-family", () => {
  const {controller, input, swatch, options} = build()

  controller.reset({
    preventDefault() {},
    detail: {value: "  ui-serif  "}
  })

  assert.equal(input.value, "ui-serif")
  assert.equal(swatch.style.fontFamily, "ui-serif")
  assert.equal(options[1].attributes["aria-selected"], "true")
})

test("reset ignores a blank detail.value", () => {
  const {controller, input} = build()

  input.value = "ui-serif"
  controller.reset({detail: {value: "   "}})

  assert.equal(input.value, "ui-sans-serif")
})

test("reset rejects an empty font", () => {
  const {controller} = build({fontValue: ""})

  assert.throws(() => controller.reset(), /font-family/)
})

test("reset is a no-op without an input target", () => {
  const ControllerClass = loadController()
  const controller = new ControllerClass()
  const events = []
  controller.element = {dispatchEvent(event) { events.push(event) }}
  controller.fontValue = "ui-sans-serif"
  controller.hasInputTarget = false
  controller.hasSwatchTarget = false
  controller.reset()

  assert.equal(events.length, 0)
})
