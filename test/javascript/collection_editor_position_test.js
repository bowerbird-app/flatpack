const test = require("node:test")
const assert = require("node:assert/strict")
const fs = require("node:fs")
const path = require("node:path")
const vm = require("node:vm")

function loadController(globals) {
  const root = path.join(__dirname, "..", "..", "app", "javascript", "flat_pack")
  const helper = (name) => fs.readFileSync(path.join(root, name), "utf8").replaceAll("export function ", "function ")
  const source = fs.readFileSync(path.join(root, "controllers", "collection_editor_controller.js"), "utf8")
    .replace('import { Controller } from "@hotwired/stimulus"', "class Controller {}")
    .replace('import { flatPackCopy } from "flat_pack/copy"', "function flatPackCopy(key) { return key }")
    .replace(/import \{[^}]+\} from "flat_pack\/click_outside"\n/, "")
    .replace(/import \{[^}]+\} from "flat_pack\/positioning"\n/, "")
    .replace("export default class extends Controller", "class CollectionEditorController extends Controller")

  const context = {
    module: { exports: {} },
    exports: {},
    window: globals.window,
    document: globals.document,
    getComputedStyle: globals.getComputedStyle
  }
  vm.runInNewContext(
    `${helper("click_outside.js")}\n${helper("positioning.js")}\n${source}\nmodule.exports = CollectionEditorController\n`,
    context,
    { filename: "collection_editor_controller.js" }
  )
  return context.module.exports
}

function events() {
  const entries = []
  return {
    entries,
    addEventListener(type, listener, capture) {
      entries.push({ type, listener, capture: capture === true })
    },
    removeEventListener(type, listener, capture) {
      const flag = capture === true
      const index = entries.findIndex((entry) => {
        return entry.type === type && entry.listener === listener && entry.capture === flag
      })
      if (index >= 0) entries.splice(index, 1)
    },
    dispatch(type) {
      entries.filter((entry) => entry.type === type).forEach((entry) => entry.listener())
    }
  }
}

function mount({
  anchor,
  menu = { height: 80 },
  viewport = { width: 800, height: 700 },
  edge = "8px",
  count = 1,
  panelHidden = false
} = {}) {
  const windowEvents = events()
  const documentEvents = events()
  const body = { appendChild(node) { node.parentElement = body } }
  const host = { appendChild(node) { node.parentElement = host } }
  const input = {
    rect: anchor,
    getBoundingClientRect() { return this.rect },
    setAttribute() {},
    focus() {}
  }
  const panel = { hidden: panelHidden }
  const list = {
    style: {},
    classList: {
      classes: new Set(),
      add(name) { this.classes.add(name) },
      remove(name) { this.classes.delete(name) },
      contains(name) { return this.classes.has(name) }
    },
    childElementCount: count,
    parentElement: host,
    getBoundingClientRect() {
      return { top: 0, left: 0, right: 192, bottom: menu.height, width: 192, height: menu.height }
    }
  }
  const row = {
    _resultsList: list,
    querySelector(selector) {
      if (selector === "[data-collection-editor-search]") return input
      if (selector === "[data-collection-editor-panel]") return panel
      return null
    }
  }
  const element = {
    rows: [row],
    addEventListener() {},
    removeEventListener() {},
    querySelectorAll(selector) {
      if (selector === "[data-collection-editor-row]") return this.rows
      return []
    }
  }
  const windowStub = {
    innerWidth: viewport.width,
    innerHeight: viewport.height,
    addEventListener: windowEvents.addEventListener.bind(windowEvents),
    removeEventListener: windowEvents.removeEventListener.bind(windowEvents),
    dispatch: windowEvents.dispatch.bind(windowEvents)
  }
  const Controller = loadController({
    window: windowStub,
    document: {
      body,
      addEventListener: documentEvents.addEventListener.bind(documentEvents),
      removeEventListener: documentEvents.removeEventListener.bind(documentEvents)
    },
    getComputedStyle() {
      return { getPropertyValue() { return edge } }
    }
  })
  const controller = new Controller()
  controller.element = element
  controller.hasEmptyTarget = false
  controller.connect()
  controller.placeResults(row)
  return { controller, row, list, input, body, windowEvents, documentEvents }
}

const field = { top: 40, right: 220, bottom: 80, left: 180, width: 40, height: 40 }

test("opens under the field, on its left edge, with a 4px gap", () => {
  const { list } = mount({ anchor: field })

  assert.equal(list.style.position, "fixed")
  assert.equal(list.style.top, "84px")
  assert.equal(list.style.left, "180px")
  assert.equal(list.style.width, "192px")
})

test("keeps a wide field's left edge and uses that width", () => {
  const anchor = { top: 40, right: 360, bottom: 80, left: 40, width: 320, height: 40 }
  const { list } = mount({ anchor })

  assert.equal(list.style.left, "40px")
  assert.equal(list.style.width, "320px")
  assert.equal(list.style.top, "84px")
})

test("does not clamp a field that starts outside the viewport", () => {
  const anchor = { top: 40, right: 20, bottom: 80, left: -30, width: 50, height: 40 }
  const { list } = mount({ anchor, viewport: { width: 400, height: 700 } })

  assert.equal(list.style.left, "-30px")
  assert.equal(list.style.top, "84px")
})

test("flips above when the menu crosses the bottom edge", () => {
  const anchor = { top: 520, right: 220, bottom: 560, left: 180, width: 40, height: 40 }
  const { list } = mount({
    anchor,
    menu: { height: 120 },
    viewport: { width: 800, height: 600 }
  })

  assert.equal(list.style.top, "396px")
  assert.equal(list.style.left, "180px")
})

test("a larger edge offset flips a menu that still fits at 8px, and the gap stays 4px", () => {
  const anchor = { top: 260, right: 120, bottom: 300, left: 40, width: 80, height: 40 }
  const fitting = mount({ anchor, menu: { height: 88 }, viewport: { width: 400, height: 400 }, edge: "8px" })
  const flipped = mount({ anchor, menu: { height: 88 }, viewport: { width: 400, height: 400 }, edge: "16px" })

  assert.equal(fitting.list.style.top, "304px")
  assert.equal(fitting.list.style.left, "40px")
  assert.equal(flipped.list.style.top, "168px")
  assert.equal(flipped.list.style.left, "40px")
})

test("a menu that would start above the viewport sticks to the edge", () => {
  const anchor = { top: -50, right: 80, bottom: -20, left: -30, width: 110, height: 30 }
  const { list } = mount({ anchor, menu: { height: 30 } })

  assert.equal(list.style.top, "8px")
  assert.equal(list.style.left, "-30px")
})

test("an oversized menu sticks to the top edge", () => {
  const anchor = { top: 20, right: 80, bottom: 50, left: 10, width: 70, height: 30 }
  const { list } = mount({
    anchor,
    menu: { height: 400 },
    viewport: { width: 400, height: 200 }
  })

  assert.equal(list.style.top, "8px")
  assert.equal(list.style.left, "10px")
})

test("moves an open menu to the body", () => {
  const { list, body } = mount({ anchor: field })

  assert.equal(list.parentElement, body)
})

test("a hidden panel or an empty menu is not placed", () => {
  const hidden = mount({ anchor: field, panelHidden: true })
  assert.equal(hidden.list.style.top, undefined)
  assert.equal(hidden.list.classList.contains("is-open"), false)

  const empty = mount({ anchor: field, count: 0 })
  assert.equal(empty.list.style.top, undefined)
})

test("window scroll and resize move an open menu, and disconnect removes both listeners", () => {
  const { controller, input, list, windowEvents, documentEvents } = mount({ anchor: field })
  assert.equal(list.style.top, "84px")
  assert.equal(documentEvents.entries.filter((entry) => entry.type === "scroll").length, 0)
  assert.equal(windowEvents.entries.filter((entry) => entry.type === "resize").length, 1)
  assert.equal(windowEvents.entries.filter((entry) => entry.type === "scroll" && entry.capture).length, 1)

  input.rect = { top: 80, right: 220, bottom: 120, left: 200, width: 20, height: 40 }
  windowEvents.dispatch("scroll")
  windowEvents.dispatch("resize")
  assert.equal(list.style.top, "124px")
  assert.equal(list.style.left, "200px")

  controller.viewportWatch.add()
  assert.equal(windowEvents.entries.filter((entry) => entry.type === "resize").length, 1)

  controller.disconnect()
  assert.equal(windowEvents.entries.filter((entry) => entry.type === "resize").length, 0)
  assert.equal(windowEvents.entries.filter((entry) => entry.type === "scroll").length, 0)
})
