const test = require("node:test")
const assert = require("node:assert/strict")
const fs = require("node:fs")
const path = require("node:path")
const vm = require("node:vm")

function loadController() {
  const filePath = path.join(__dirname, "..", "..", "app", "javascript", "flat_pack", "controllers", "image_input_controller.js")
  const source = fs.readFileSync(filePath, "utf8")
  const transformedSource = source
    .replace('import { Controller } from "@hotwired/stimulus"', "class Controller {}")
    .replace("export default class extends Controller", "class ImageInputController extends Controller") + "\nmodule.exports = ImageInputController\n"

  let urlCount = 0
  const revoked = []
  const context = {
    module: {exports: {}},
    exports: {},
    revoked,
    URL: {
      createObjectURL() {
        urlCount += 1
        return `blob:${urlCount}`
      },
      revokeObjectURL(url) {
        revoked.push(url)
      }
    },
    CustomEvent: class {
      constructor(type, options = {}) {
        this.type = type
        this.bubbles = options.bubbles || false
        this.detail = options.detail
      }
    },
    DataTransfer: class {
      constructor() {
        const files = []
        this.files = files
        this.items = {
          add(file) {
            files.push(file)
          }
        }
      }
    }
  }
  context.globalThis = context

  vm.runInNewContext(transformedSource, context, {filename: filePath})
  return {ControllerClass: context.module.exports, revoked}
}

function fakeEl() {
  return {
    hidden: false,
    value: "",
    src: "",
    alt: "",
    accept: "",
    files: [],
    classList: {
      classes: new Set(),
      add(name) { this.classes.add(name) },
      remove(name) { this.classes.delete(name) },
      contains(name) { return this.classes.has(name) }
    },
    removeAttribute(name) {
      if (name === "src") this.src = ""
    }
  }
}

function fakeEvent() {
  return {
    prevented: false,
    stopped: false,
    preventDefault() { this.prevented = true },
    stopPropagation() { this.stopped = true }
  }
}

function build({initialSrc = ""} = {}) {
  const {ControllerClass, revoked} = loadController()
  const controller = new ControllerClass()
  const events = []
  const element = fakeEl()
  element.dispatchEvent = (event) => {
    events.push(event)
    return true
  }

  controller.element = element
  controller.initialSrcValue = initialSrc
  controller.clearableValue = true
  controller.inputTarget = fakeEl()
  controller.inputTarget.accept = "image/*"
  controller.emptyTarget = fakeEl()
  controller.previewTarget = fakeEl()
  controller.overlayTarget = fakeEl()
  controller.clearTarget = fakeEl()
  controller.removeTarget = fakeEl()
  controller.removeTarget.value = "0"
  controller.hasClearTarget = true
  controller.hasRemoveTarget = true
  controller.connect()

  return {controller, events, revoked}
}

function imageFile() {
  return {type: "image/png", name: "portrait.png"}
}

test("choose an image file shows the preview object URL", () => {
  const {controller} = build()
  controller.inputTarget.files = [imageFile()]
  controller.choose({target: controller.inputTarget})

  assert.equal(controller.previewTarget.src, "blob:1")
  assert.equal(controller.previewTarget.hidden, false)
  assert.equal(controller.emptyTarget.hidden, true)
  assert.equal(controller.removeTarget.value, "0")
})

test("clear after choose with no initial src empties the preview", () => {
  const {controller, events} = build()
  controller.inputTarget.files = [imageFile()]
  controller.choose({target: controller.inputTarget})
  controller.clear(fakeEvent())

  assert.equal(controller.previewTarget.hidden, true)
  assert.equal(controller.previewTarget.src, "")
  assert.equal(controller.removeTarget.value, "1")
  assert.equal(events.length, 1)
  assert.equal(events[0].type, "flat-pack:image-input:clear")
  assert.equal(events[0].bubbles, true)
  assert.equal(events[0].detail.removed, true)
  assert.equal(events[0].detail.reverted, false)
})

test("clear after choosing over an initial src restores that src", () => {
  const {controller, events} = build({initialSrc: "https://example.com/a.jpg"})
  controller.inputTarget.files = [imageFile()]
  controller.choose({target: controller.inputTarget})
  controller.clear(fakeEvent())

  assert.equal(controller.previewTarget.src, "https://example.com/a.jpg")
  assert.equal(controller.previewTarget.hidden, false)
  assert.equal(controller.removeTarget.value, "0")
  assert.equal(events[0].detail.removed, false)
  assert.equal(events[0].detail.reverted, true)
})

test("a second clear after a revert removes the persisted picture", () => {
  const {controller, events} = build({initialSrc: "https://example.com/a.jpg"})
  controller.inputTarget.files = [imageFile()]
  controller.choose({target: controller.inputTarget})
  controller.clear(fakeEvent())
  controller.clear(fakeEvent())

  assert.equal(controller.previewTarget.hidden, true)
  assert.equal(controller.previewTarget.src, "")
  assert.equal(controller.removeTarget.value, "1")
  assert.equal(events[1].detail.removed, true)
  assert.equal(events[1].detail.reverted, false)
})

test("clearing a persisted picture then a new file does not restore the old picture", () => {
  const {controller, events} = build({initialSrc: "https://example.com/a.jpg"})
  controller.clear(fakeEvent())
  controller.inputTarget.files = [imageFile()]
  controller.choose({target: controller.inputTarget})
  controller.clear(fakeEvent())

  assert.equal(controller.initialSrcValue, "")
  assert.equal(controller.previewTarget.hidden, true)
  assert.equal(controller.previewTarget.src, "")
  assert.equal(controller.removeTarget.value, "1")
  assert.equal(events.at(-1).detail.removed, true)
  assert.equal(events.at(-1).detail.reverted, false)
})

test("choosing a text file clears the file input", () => {
  const {controller} = build()
  controller.previewTarget.hidden = true
  controller.inputTarget.files = [{type: "text/plain", name: "note.txt"}]
  controller.choose({target: controller.inputTarget})

  assert.equal(controller.inputTarget.value, "")
  assert.equal(controller.state, "empty")
  assert.equal(controller.previewTarget.src, "")
  assert.equal(controller.previewTarget.hidden, true)
})

test("drop of a text file does not change the preview", () => {
  const {controller} = build({initialSrc: "https://example.com/a.jpg"})
  controller.previewTarget.src = "https://example.com/a.jpg"
  controller.drop({
    preventDefault() {},
    dataTransfer: {files: [{type: "text/plain", name: "note.txt"}]}
  })

  assert.equal(controller.previewTarget.src, "https://example.com/a.jpg")
  assert.equal(controller.state, "persisted")
})

test("clear calls stopPropagation", () => {
  const {controller} = build()
  const event = fakeEvent()
  controller.clear(event)

  assert.equal(event.stopped, true)
  assert.equal(event.prevented, true)
})
