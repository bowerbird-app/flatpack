const test = require("node:test")
const assert = require("node:assert/strict")
const fs = require("node:fs")
const path = require("node:path")
const vm = require("node:vm")

function loadController() {
  const filePath = path.join(__dirname, "..", "..", "app", "javascript", "flat_pack", "controllers", "color_swatch_controller.js")
  const source = fs.readFileSync(filePath, "utf8")
  const transformed = source
    .replace('import { Controller } from "@hotwired/stimulus"', "class Controller {}")
    .replace("export default class extends Controller", "class ColorSwatchController extends Controller")
    + "\nmodule.exports = ColorSwatchController\n"

  const context = {
    module: {exports: {}},
    exports: {},
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

function build({inputValue = "#321100", swatchColor = "#321100"} = {}) {
  const ControllerClass = loadController()
  const controller = new ControllerClass()
  const events = []
  const input = {
    value: inputValue,
    attributes: {value: inputValue},
    setAttribute(name, next) { this.attributes[name] = next }
  }
  const swatch = {style: {backgroundColor: swatchColor}}

  controller.element = {
    dispatchEvent(event) {
      events.push(event)
      return true
    }
  }
  controller.inputTarget = input
  controller.swatchTarget = swatch
  controller.hasInputTarget = true
  controller.hasSwatchTarget = true
  controller.connect()

  return {controller, input, swatch, events}
}

test("connect stores the original colour and paints the face", () => {
  const {controller, input, swatch} = build({inputValue: "#abcdef", swatchColor: "var(--color-primary)"})

  assert.equal(controller.defaultInputValue, "#abcdef")
  assert.equal(controller.defaultSwatchColor, "var(--color-primary)")
  assert.equal(swatch.style.backgroundColor, "#abcdef")
  assert.equal(input.attributes.value, "#abcdef")
})

test("reset restores the connect-time picker value and swatch face", () => {
  const {controller, input, swatch, events} = build({
    inputValue: "#321100",
    swatchColor: "var(--color-primary)"
  })

  input.value = "#ffffff"
  controller.update()
  assert.equal(swatch.style.backgroundColor, "#ffffff")

  events.length = 0
  controller.reset()

  assert.equal(input.value, "#321100")
  assert.equal(input.attributes.value, "#321100")
  assert.equal(swatch.style.backgroundColor, "var(--color-primary)")
  assert.equal(events.at(-1).type, "color-swatch:change")
  assert.equal(events.at(-1).detail.value, "#321100")
})

test("clear is an alias of reset", () => {
  const {controller, input, swatch} = build()

  input.value = "#00ff00"
  controller.update()
  controller.clear()

  assert.equal(input.value, "#321100")
  assert.equal(swatch.style.backgroundColor, "#321100")
})

test("reset uses detail.value when the host passes a colour", () => {
  const {controller, input, swatch} = build()

  controller.reset({
    preventDefault() {},
    detail: {value: "  #ff00aa  "}
  })

  assert.equal(input.value, "#ff00aa")
  assert.equal(swatch.style.backgroundColor, "#ff00aa")
})

test("reset ignores a blank detail.value", () => {
  const {controller, input} = build()

  input.value = "#ffffff"
  controller.reset({detail: {value: "   "}})

  assert.equal(input.value, "#321100")
})

test("reset is a no-op without an input target", () => {
  const ControllerClass = loadController()
  const controller = new ControllerClass()
  const events = []
  controller.element = {dispatchEvent(event) { events.push(event) }}
  controller.hasInputTarget = false
  controller.hasSwatchTarget = false
  controller.connect()
  controller.reset()

  assert.equal(events.length, 0)
})
