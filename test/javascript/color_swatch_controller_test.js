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
    },
    Event: class {
      constructor(type, options = {}) {
        this.type = type
        this.bubbles = options.bubbles || false
      }
    }
  }
  context.globalThis = context
  vm.runInNewContext(transformed, context, {filename: filePath})
  return context.module.exports
}

function build({inputValue = "#321100", colorValue = "#321100", swatchColor = "#321100"} = {}) {
  const ControllerClass = loadController()
  const controller = new ControllerClass()
  const events = []
  const inputEvents = []
  const input = {
    value: inputValue,
    attributes: {value: inputValue},
    setAttribute(name, next) { this.attributes[name] = next },
    dispatchEvent(event) {
      inputEvents.push(event)
      return true
    }
  }
  const swatch = {style: {backgroundColor: swatchColor}}

  controller.element = {
    dispatchEvent(event) {
      events.push(event)
      return true
    }
  }
  controller.colorValue = colorValue
  controller.inputTarget = input
  controller.swatchTarget = swatch
  controller.hasInputTarget = true
  controller.hasSwatchTarget = true
  controller.connect()

  return {controller, input, swatch, events, inputEvents}
}

test("connect paints the face from the input and does not snapshot that value", () => {
  const {controller, input, swatch} = build({inputValue: "#abcdef", colorValue: "#321100", swatchColor: "var(--color-primary)"})

  assert.equal(controller.colorValue, "#321100")
  assert.equal(swatch.style.backgroundColor, "#abcdef")
  assert.equal(input.attributes.value, "#abcdef")
  assert.equal(controller.defaultInputValue, undefined)
})

test("reset uses the server colour when the input changed before connect", () => {
  const {controller, input, swatch, events} = build({
    inputValue: "#ffffff",
    colorValue: "#321100",
    swatchColor: "var(--color-primary)"
  })

  input.value = "#00ff00"
  controller.update()
  assert.equal(swatch.style.backgroundColor, "#00ff00")

  events.length = 0
  controller.reset()

  assert.equal(input.value, "#321100")
  assert.equal(input.attributes.value, "#321100")
  assert.equal(swatch.style.backgroundColor, "#321100")
  assert.equal(events.at(-1).type, "color-swatch:change")
  assert.equal(events.at(-1).detail.value, "#321100")
})

test("reset fires input and change on the colour input", () => {
  const {controller, inputEvents} = build()

  inputEvents.length = 0
  controller.reset()

  assert.deepEqual(inputEvents.map((event) => event.type), ["input", "change"])
  assert.equal(inputEvents.every((event) => event.bubbles), true)
})

test("reset uses detail.value when the host passes #rrggbb", () => {
  const {controller, input, swatch} = build()

  controller.reset({
    preventDefault() {},
    detail: {value: "  #FF00AA  "}
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

test("reset rejects a colour that is not #rrggbb", () => {
  const {controller} = build()

  assert.throws(() => controller.reset({detail: {value: "red"}}), /#rrggbb/)
  assert.throws(() => controller.reset({detail: {value: "#fff"}}), /#rrggbb/)
  assert.throws(() => controller.reset({detail: {value: "var(--color-primary)"}}), /#rrggbb/)
})

test("reset is a no-op without an input target", () => {
  const ControllerClass = loadController()
  const controller = new ControllerClass()
  const events = []
  controller.element = {dispatchEvent(event) { events.push(event) }}
  controller.colorValue = "#321100"
  controller.hasInputTarget = false
  controller.hasSwatchTarget = false
  controller.connect()
  controller.reset()

  assert.equal(events.length, 0)
})
