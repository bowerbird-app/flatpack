const test = require("node:test")
const assert = require("node:assert/strict")
const fs = require("node:fs")
const path = require("node:path")
const vm = require("node:vm")

function loadController({ reduced = false, fetchImpl, turbo, copy } = {}) {
  const controllerPath = path.join(__dirname, "..", "..", "app", "javascript", "flat_pack", "controllers", "inline_edit_controller.js")
  const bubblePath = path.join(__dirname, "..", "..", "app", "javascript", "flat_pack", "controllers", "exec_command_bubble.js")
  const bubbleSource = fs.readFileSync(bubblePath, "utf8")
    .replace('import { flatPackCopy } from "flat_pack/copy"', "const flatPackCopy = globalThis.flatPackCopy")
    .replace(/export function /g, "function ")
    + "\nmodule.exports = { applyFormat, hideToolbar, keepSelection, placeCaretFromPoint, updateToolbarFromSelection }\n"

  const bubbleContext = {
    module: {exports: {}},
    exports: {},
    document: globalThis.document || { queryCommandValue() { return "" }, queryCommandState() { return false }, execCommand() { return true }, getSelection() { return null }, createElement() { return { setAttribute() {}, appendChild() {} } } },
    prompt: () => null
  }
  vm.runInNewContext(bubbleSource, bubbleContext, {filename: bubblePath})
  const bubble = bubbleContext.module.exports

  const source = fs.readFileSync(controllerPath, "utf8")
    .replace('import { Controller } from "@hotwired/stimulus"', "class Controller { dispatch(name, { prefix, cancelable, detail } = {}) { const event = { type: `${prefix}:${name}`, defaultPrevented: false, detail, preventDefault() { this.defaultPrevented = true } }; (this.element.events || (this.element.events = [])).push(event); return event } }")
    .replace(
      'import { flatPackCopy } from "flat_pack/copy"',
      `const COPY = ${JSON.stringify(copy || {
        "inline_edit.saving": "Saving",
        "inline_edit.saved": "Saved",
        "inline_edit.required": "This can’t be empty",
        "inline_edit.too_long": "Too long",
        "inline_edit.save_failed": "Couldn’t save. Try again."
      })}\nconst flatPackCopy = (key) => COPY[key] || key`
    )
    .replace(
      'import { prefersReducedMotion, motionDuration } from "controllers/flat_pack/reduced_motion"',
      `function prefersReducedMotion() { return ${reduced} }\nfunction motionDuration() { return ${reduced ? 0 : 300} }`
    )
    .replace(
      'import {\n  applyFormat,\n  hideToolbar,\n  keepSelection as preventToolbarFocusLoss,\n  placeCaretFromPoint,\n  updateToolbarFromSelection\n} from "controllers/flat_pack/exec_command_bubble"',
      ""
    )
    .replace("export default class extends Controller", "class InlineEditController extends Controller")
    + "\nmodule.exports = InlineEditController\n"

  const context = {
    module: {exports: {}},
    exports: {},
    applyFormat: bubble.applyFormat,
    hideToolbar: bubble.hideToolbar,
    preventToolbarFocusLoss: bubble.keepSelection,
    placeCaretFromPoint: bubble.placeCaretFromPoint,
    updateToolbarFromSelection: bubble.updateToolbarFromSelection,
    URLSearchParams,
    CustomEvent,
    fetch: fetchImpl || (async () => ({ ok: true, headers: { get() { return "" } } })),
    document: {
      querySelector(selector) {
        if (String(selector).includes("csrf-token")) return {content: "csrf-token"}
        return null
      },
      createElement(tag) {
        return {
          tag,
          contentEditable: "true",
          textContent: "",
          innerHTML: "",
          setAttribute(name, value) {
            if (name === "contenteditable") this.contentEditable = value
          }
        }
      },
      execCommand() { return true },
      addEventListener() {},
      removeEventListener() {}
    },
    globalThis: {
      setTimeout(fn) { fn(); return 1 },
      clearTimeout() {},
      Turbo: turbo || null,
      matchMedia() { return {matches: reduced} }
    }
  }
  context.globalThis.fetch = context.fetch
  context.globalThis.Turbo = context.globalThis.Turbo

  vm.runInNewContext(source, context, {filename: controllerPath})
  return context.module.exports
}

function classListStub(initial = []) {
  const names = new Set(initial)
  return {
    contains(name) { return names.has(name) },
    add(name) { names.add(name) },
    remove(name) { names.delete(name) },
    toggle(name, force) {
      const should = force === undefined ? !names.has(name) : Boolean(force)
      if (should) names.add(name)
      else names.delete(name)
      return should
    },
    toArray() { return [...names] }
  }
}

function buildController(options = {}) {
  const surface = {
    innerText: options.value || "Trail kit",
    textContent: options.value || "Trail kit",
    innerHTML: options.html || options.value || "Trail kit",
    attrs: {},
    events: [],
    classList: classListStub(["fp-inline-edit__surface"]),
    focused: false,
    contains(node) { return node === surface || node == null },
    closest() { return null },
    setAttribute(name, value) { this.attrs[name] = String(value) },
    getAttribute(name) { return this.attrs[name] },
    removeAttribute(name) { delete this.attrs[name] },
    addEventListener(type, handler) { this.events.push([type, handler]) },
    removeEventListener(type, handler) {
      this.events = this.events.filter((entry) => entry[0] !== type || entry[1] !== handler)
    },
    focus() { this.focused = true },
    getClientRects() { return [{right: 120, top: 10, height: 24, left: 0, width: 120}] },
    getBoundingClientRect() { return {right: 120, top: 10, height: 24, left: 0, width: 120} }
  }
  const field = {value: options.value || "Trail kit"}
  const live = {id: "live", textContent: ""}
  const spinner = {hidden: true}
  const tick = {hidden: true}
  const status = {style: {}}
  const heading = {textContent: "Coast path", innerText: "Coast path", innerHTML: "Coast path", classList: classListStub(), attrs: {}, setAttribute(name, value) { this.attrs[name] = String(value) }, getAttribute() { return null }, contains() { return false }, addEventListener() {}, removeEventListener() {}, focus() {}, getClientRects() { return [] }, getBoundingClientRect() { return {right: 0, top: 0, height: 0, left: 0, width: 0} }}

  const element = {
    events: [],
    classList: classListStub(["fp-inline-edit"]),
    contains(node) { return node === surface || node === element },
    querySelector(selector) {
      if (selector.includes("data-inline-edit-target")) return options.marked || null
      if (selector.includes("h1")) return options.wrapped ? heading : null
      return null
    },
    getBoundingClientRect() { return {left: 0, top: 0} }
  }

  const InlineEditController = loadController(options)
  const controller = new InlineEditController()
  controller.element = element
  controller.hasSurfaceTarget = !options.wrapped
  controller.surfaceTarget = surface
  controller.hasFieldTarget = true
  controller.fieldTarget = field
  controller.hasLiveTarget = true
  controller.liveTarget = live
  controller.hasSpinnerTarget = true
  controller.spinnerTarget = spinner
  controller.hasTickTarget = true
  controller.tickTarget = tick
  controller.hasStatusTarget = true
  controller.statusTarget = status
  controller.hasBubbleTarget = false
  controller.nameValue = "kit[title]"
  controller.modeValue = options.mode || "text"
  controller.updateUrlValue = options.updateUrl || ""
  controller.methodValue = "patch"
  controller.requiredValue = Boolean(options.required)
  controller.saveOnBlurValue = options.saveOnBlur !== false
  controller.maxlengthValue = options.maxlength || 0
  controller.labelValue = "Kit title"
  controller.placeholderValue = "Untitled kit"
  controller.connect()
  return {controller, surface, field, live, element, heading, spinner, tick}
}

test("enter activates a resting title then saves on the next enter", async () => {
  const {controller, surface, field} = buildController({updateUrl: "/kits/1"})
  controller.onKeydown({key: "Enter", preventDefault() {}, target: surface, currentTarget: surface})
  assert.equal(surface.attrs.contenteditable, "plaintext-only")
  surface.innerText = "New kit"
  surface.textContent = "New kit"
  await controller.commit()
  assert.equal(field.value, "New kit")
  assert.equal(surface.attrs.contenteditable, undefined)
})

test("escape restores the original words", () => {
  const {controller, surface, field} = buildController()
  controller.activate()
  assert.equal(surface.attrs.contenteditable, "plaintext-only")
  surface.innerText = "Changed"
  surface.textContent = "Changed"
  controller.cancel()
  assert.equal(surface.textContent, "Trail kit")
  assert.equal(field.value, "Trail kit")
})

test("required empty value does not save", async () => {
  const {controller, surface, live, element} = buildController({required: true})
  controller.activate()
  surface.innerText = "   "
  surface.textContent = "   "
  await controller.commit()
  assert.equal(live.textContent, "This can’t be empty")
  assert.equal(element.classList.contains("is-error"), true)
})

test("cancelable save event stops the request", async () => {
  let fetched = false
  const {controller, surface} = buildController({
    updateUrl: "/kits/1",
    fetchImpl: async () => {
      fetched = true
      return {ok: true, headers: {get() { return "" }}}
    }
  })
  controller.activate()
  surface.innerText = "New kit"
  surface.textContent = "New kit"
  const originalDispatch = controller.dispatch.bind(controller)
  controller.dispatch = (name, options) => {
    const event = originalDispatch(name, options)
    if (name === "save") event.preventDefault()
    return event
  }
  await controller.commit()
  assert.equal(fetched, false)
})

test("failed save restores the original value", async () => {
  const {controller, surface, live} = buildController({
    updateUrl: "/kits/1",
    fetchImpl: async () => ({ok: false, headers: {get() { return "" }}})
  })
  controller.activate()
  surface.innerText = "Broken"
  surface.textContent = "Broken"
  await controller.commit()
  assert.equal(surface.textContent, "Trail kit")
  assert.equal(live.textContent, "Couldn’t save. Try again.")
})

test("successful save applies a turbo stream body", async () => {
  let rendered = null
  const {controller, surface} = buildController({
    updateUrl: "/kits/1",
    fetchImpl: async () => ({
      ok: true,
      headers: {get() { return "text/vnd.turbo-stream.html" }},
      async text() { return "<turbo-stream></turbo-stream>" }
    }),
    turbo: {renderStreamMessage(html) { rendered = html }}
  })
  controller.activate()
  surface.innerText = "Saved kit"
  surface.textContent = "Saved kit"
  await controller.commit()
  assert.equal(rendered, "<turbo-stream></turbo-stream>")
})

test("wrapped block finds the first heading", () => {
  const {controller, heading} = buildController({wrapped: true})
  assert.equal(controller.surface, heading)
  assert.equal(heading.attrs.role, "textbox")
})

test("wrapped block prefers a heading over a leading paragraph", () => {
  const paragraph = {textContent: "Tagline", innerText: "Tagline", classList: classListStub(), attrs: {}, setAttribute() {}, getAttribute() { return null }}
  const {controller, heading, element} = buildController({wrapped: true})
  element.querySelector = (selector) => {
    if (selector.includes("data-inline-edit-target")) return null
    if (selector.includes("h1")) return heading
    if (selector === "p") return paragraph
    return null
  }
  assert.equal(controller.findSurface(), heading)
})

test("plain mode saves with meta enter", () => {
  const {controller, surface} = buildController({mode: "plain", value: "Line one"})
  let saved = false
  controller.commit = async () => { saved = true }
  controller.activate()
  controller.onKeydown({key: "Enter", metaKey: true, preventDefault() {}, target: surface, currentTarget: surface})
  assert.equal(saved, true)
})

test("text paste strips newlines", () => {
  const {controller, surface} = buildController()
  controller.activate()
  let inserted = null
  const previous = globalThis.document
  // execCommand is on the vm document; call the handler directly
  const event = {
    clipboardData: {getData() { return "One\nTwo" }},
    preventDefault() {}
  }
  const original = require("node:vm")
  void original
  void previous
  controller.surface = surface
  const commands = []
  const doc = {execCommand(_name, _show, text) { commands.push(text); return true }}
  const bound = controller.onPaste.bind(controller)
  const patched = new Proxy(event, {})
  controller.onPaste = function(evt) {
    evt.preventDefault()
    let text = evt.clipboardData.getData("text/plain")
    if (this.modeValue === "text") text = text.replace(/[\r\n]+/g, " ")
    commands.push(text)
  }.bind(controller)
  controller.onPaste(patched)
  assert.equal(commands[0], "One Two")
})
