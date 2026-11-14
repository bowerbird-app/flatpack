const test = require("node:test")
const assert = require("node:assert/strict")
const fs = require("node:fs")
const path = require("node:path")
const vm = require("node:vm")

function loadController() {
  const filePath = path.join(__dirname, "..", "..", "app", "javascript", "flat_pack", "controllers", "file_input_controller.js")
  const source = fs.readFileSync(filePath, "utf8")
    .replace('import { Controller } from "@hotwired/stimulus"\n', "class Controller {}\n")
    .replace(
      'import { flatPackCopy } from "flat_pack/copy"\n',
      "function flatPackCopy(key, vars = {}) { return key + \":\" + JSON.stringify(vars || {}) }\n"
    )
    .replace("export default class extends Controller", "class FileInputController extends Controller") +
    "\nmodule.exports = FileInputController\n"

  function makeNode() {
    const names = new Set()
    return {
      className: "",
      textContent: "",
      innerHTML: "",
      type: "",
      disabled: false,
      files: [],
      children: [],
      focused: false,
      classList: {
        add(name) { names.add(name) },
        remove(name) { names.delete(name) },
        contains(name) { return names.has(name) }
      },
      appendChild(child) { this.children.push(child); return child },
      setAttribute() {},
      addEventListener(type, handler) { this.handler = handler; this.eventType = type },
      focus() { this.focused = true },
      click() { this.clicked = true }
    }
  }

  const context = {
    module: {exports: {}},
    exports: {},
    console,
    setTimeout() {},
    document: {
      createElement() { return makeNode() },
      createElementNS() { return makeNode() }
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

  vm.runInNewContext(source, context, {filename: filePath})
  return context.module.exports
}

function build(overrides = {}) {
  const ControllerClass = loadController()
  const controller = new ControllerClass()
  const events = []
  const element = {
    classList: classList(),
    dispatchEvent(event) {
      events.push(event)
      return true
    }
  }
  const input = {
    files: [],
    disabled: false,
    clicked: false,
    click() { this.clicked = true }
  }
  const fileList = {innerHTML: "", classList: classList(), appendChild() {}}
  const limitMessage = {textContent: "", classList: classList(["hidden"])}
  const button = {focused: false, focus() { this.focused = true }}

  controller.element = element
  controller.inputTarget = input
  controller.fileListTarget = fileList
  controller.limitMessageTarget = limitMessage
  controller.validationErrorTarget = {textContent: "", classList: classList(["hidden"])}
  controller.buttonTarget = button
  controller.hasFileListTarget = true
  controller.hasPreviewTarget = false
  controller.hasLimitMessageTarget = true
  controller.hasValidationErrorTarget = true
  controller.hasButtonTarget = false
  controller.hasMaxSizeValue = false
  controller.hasMaxFilesValue = false
  controller.hasLimitMessageValue = false
  controller.previewValue = false
  controller.showListValue = true
  controller.multipleValue = true
  Object.assign(controller, overrides)
  controller.connect()

  return {controller, events, input, fileList, limitMessage, button}
}

function classList(initial = []) {
  const names = new Set(initial)
  return {
    add(name) { names.add(name) },
    remove(name) { names.delete(name) },
    contains(name) { return names.has(name) }
  }
}

function file(name) {
  return {name, size: 12, type: "text/plain"}
}

test("change dispatches flat-pack:file-input:change with the selected files", () => {
  const {controller, events, input} = build()
  const files = [file("a.txt"), file("b.txt")]
  input.files = files

  controller.handleFiles({target: input})

  assert.equal(events.length, 1)
  assert.equal(events[0].type, "flat-pack:file-input:change")
  assert.equal(events[0].bubbles, true)
  assert.equal(events[0].detail.files.length, 2)
  assert.equal(events[0].detail.files[0].name, "a.txt")
  assert.equal(events[0].detail.files[1].name, "b.txt")
  assert.equal(events[0].detail.files[0], files[0])
  assert.equal(input.files, files)
})

test("drop dispatches the same event and does not assign input.files", () => {
  const {controller, events, input} = build()
  const original = []
  input.files = original
  const dropped = [file("stem.wav")]

  controller.drop({
    preventDefault() {},
    dataTransfer: {files: dropped}
  })

  assert.equal(input.files, original)
  assert.equal(events.length, 1)
  assert.equal(events[0].type, "flat-pack:file-input:change")
  assert.equal(events[0].detail.files[0], dropped[0])
})

test("button variant dispatches the event and skips the file list", () => {
  const {controller, events, input, fileList, button} = build({
    showListValue: false,
    hasButtonTarget: true
  })
  const files = [file("mix.wav")]
  input.files = files

  controller.handleFiles({target: input})

  assert.equal(events[0].detail.files[0], files[0])
  assert.equal(fileList.innerHTML, "")
  assert.equal(button.focused, true)
  assert.equal(input.files, files)
})

test("max_files keeps the first files, announces the rest, and does not mutate input.files", () => {
  const {controller, events, input, limitMessage} = build({
    hasMaxFilesValue: true,
    maxFilesValue: 2,
    hasLimitMessageValue: true,
    limitMessageValue: "Only the first 2 files were kept."
  })
  const files = [file("one.txt"), file("two.txt"), file("three.txt"), file("four.txt")]
  input.files = files

  controller.handleFiles({target: input})

  assert.equal(input.files, files)
  assert.equal(input.files.length, 4)
  assert.equal(events[0].detail.files.length, 2)
  assert.equal(events[0].detail.files[0].name, "one.txt")
  assert.equal(events[0].detail.files[1].name, "two.txt")
  assert.equal(limitMessage.textContent, "Only the first 2 files were kept.")
  assert.equal(limitMessage.classList.contains("hidden"), false)
})

test("a selection inside the cap clears the limit message", () => {
  const {controller, events, input, limitMessage} = build({
    hasMaxFilesValue: true,
    maxFilesValue: 2,
    hasLimitMessageValue: true,
    limitMessageValue: "Only the first 2 files were kept."
  })
  limitMessage.classList.remove("hidden")
  limitMessage.textContent = "Only the first 2 files were kept."
  const files = [file("one.txt")]
  input.files = files

  controller.handleFiles({target: input})

  assert.equal(events[0].detail.files.length, 1)
  assert.equal(limitMessage.textContent, "")
  assert.equal(limitMessage.classList.contains("hidden"), true)
  assert.equal(input.files, files)
})

test("remove updates the event and leaves input.files alone", () => {
  const {controller, events, input} = build()
  const files = [file("one.txt"), file("two.txt")]
  input.files = files
  controller.handleFiles({target: input})

  controller.removeFile(0)

  assert.equal(input.files, files)
  assert.equal(events.length, 2)
  assert.equal(events[1].detail.files.length, 1)
  assert.equal(events[1].detail.files[0].name, "two.txt")
})

test("show_file_list false dispatches { files } on every selection and skips the list", () => {
  let listed = false
  const {controller, events, input} = build({
    showListValue: false,
    hasFileListTarget: false,
    hasPreviewTarget: false,
    fileListTarget: {
      set innerHTML(_value) { listed = true },
      classList: classList(),
      appendChild() { listed = true }
    }
  })

  input.files = [file("one.txt"), file("two.txt")]
  controller.handleFiles({target: input})

  input.files = [file("three.txt")]
  controller.handleFiles({target: input})

  assert.equal(listed, false)
  assert.equal(events.length, 2)
  assert.equal(events[0].type, "flat-pack:file-input:change")
  assert.equal(events[0].bubbles, true)
  assert.deepEqual(Object.keys(events[0].detail), ["files"])
  assert.equal(events[0].detail.files.length, 2)
  assert.equal(events[0].detail.files[0].name, "one.txt")
  assert.equal(events[1].detail.files.length, 1)
  assert.equal(events[1].detail.files[0].name, "three.txt")
})

test("an empty selection dispatches an empty file list", () => {
  const {controller, events, input} = build()
  input.files = []

  controller.handleFiles({target: input})

  assert.equal(events.length, 1)
  assert.equal(events[0].detail.files.length, 0)
})
