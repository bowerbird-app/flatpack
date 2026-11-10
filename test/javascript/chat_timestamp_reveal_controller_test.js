const test = require("node:test")
const assert = require("node:assert/strict")
const fs = require("node:fs")
const path = require("node:path")
const vm = require("node:vm")

function loadController() {
  const filePath = path.join(__dirname, "..", "..", "app", "javascript", "flat_pack", "controllers", "chat_timestamp_reveal_controller.js")
  const source = fs.readFileSync(filePath, "utf8")
  const transformed = source
    .replace('import { Controller } from "@hotwired/stimulus"', "class Controller {}")
    .replace("export default class extends Controller", "class ChatTimestampRevealController extends Controller") +
    "\nmodule.exports = ChatTimestampRevealController\n"

  const context = {
    module: { exports: {} },
    exports: {}
  }
  vm.runInNewContext(transformed, context, { filename: filePath })
  return context.module.exports
}

function classList() {
  const names = new Set()
  return {
    contains(name) { return names.has(name) },
    add(name) { names.add(name) },
    remove(name) { names.delete(name) },
    toggle(name) {
      if (names.has(name)) names.delete(name)
      else names.add(name)
    }
  }
}

function buildController({ fine = false } = {}) {
  const ControllerClass = loadController()
  const controller = new ControllerClass()
  controller.element = { classList: classList() }
  controller.finePointer = () => fine
  return controller
}

test("coarse pointer click toggles is-open", () => {
  const controller = buildController({ fine: false })
  controller.toggle({ target: { closest() { return null } } })
  assert.equal(controller.element.classList.contains("is-open"), true)
  controller.toggle({ target: { closest() { return null } } })
  assert.equal(controller.element.classList.contains("is-open"), false)
})

test("fine pointer click leaves is-open off", () => {
  const controller = buildController({ fine: true })
  controller.toggle({ target: { closest() { return null } } })
  assert.equal(controller.element.classList.contains("is-open"), false)
})

test("clicks on links do not toggle", () => {
  const controller = buildController({ fine: false })
  controller.toggle({ target: { closest() { return {} } } })
  assert.equal(controller.element.classList.contains("is-open"), false)
})
