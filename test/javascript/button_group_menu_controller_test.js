const test = require("node:test")
const assert = require("node:assert/strict")
const fs = require("node:fs")
const path = require("node:path")
const vm = require("node:vm")

const CONTROLLERS = path.join(__dirname, "..", "..", "app", "javascript", "flat_pack", "controllers")

function loadController(filename, className, sandbox = {}, extraReplacements = []) {
  const filePath = path.join(CONTROLLERS, filename)
  let source = fs.readFileSync(filePath, "utf8")
    .replace('import { Controller } from "@hotwired/stimulus"\n', "class Controller {}\n")
    .replace(/import \{[^}]+\} from "flat_pack\/click_outside"\n/, "")
  const clickOutsidePath = path.join(__dirname, "..", "..", "app", "javascript", "flat_pack", "click_outside.js")
  const clickOutsideSource = fs.readFileSync(clickOutsidePath, "utf8").replaceAll("export function ", "function ")
  source = clickOutsideSource + "\n" + source

  extraReplacements.forEach(([from, to]) => {
    source = source.replace(from, to)
  })

  source = source
    .replace("export default class extends Controller", `class ${className} extends Controller`) +
    `\nmodule.exports = ${className}\n`

  const context = { module: { exports: {} }, exports: {}, Math, ...sandbox }
  context.globalThis = context
  vm.runInNewContext(source, context, { filename: filePath })
  return context.module.exports
}

function documentWith(body) {
  const ids = new Map()
  const listeners = { pointerdown: new Set(), keydown: new Set() }
  const document = {
    body,
    addEventListener(type, handler) { listeners[type].add(handler) },
    removeEventListener(type, handler) { listeners[type].delete(handler) },
    getElementById(id) { return ids.get(id) || null }
  }
  body.ownerDocument = document

  function track(node) {
    node.ownerDocument = document
    const setAttribute = node.setAttribute.bind(node)
    node.setAttribute = (name, value) => {
      setAttribute(name, value)
      if (name === "id") ids.set(String(value), node)
    }
    if (node.id) ids.set(node.id, node)
  }

  return { document, listeners, track }
}

function element(tag) {
  const node = {
    tagName: tag,
    id: "",
    parent: null,
    children: [],
    attributes: {},
    setAttribute(name, value) {
      this.attributes[name] = String(value)
      if (name === "id") this.id = String(value)
    },
    getAttribute(name) {
      return Object.prototype.hasOwnProperty.call(this.attributes, name) ? this.attributes[name] : null
    },
    get parentElement() {
      return this.parent
    },
    appendChild(child) {
      child.parent = this
      this.children.push(child)
      return child
    },
    contains(target) {
      if (target === this) return true
      return this.children.some((child) => child.contains?.(target))
    },
    matches(selector) {
      const attr = selector.match(/^\[([^=]+)='([^']+)'\]$/)
      return Boolean(attr) && this.getAttribute(attr[1]) === attr[2]
    },
    closest(selector) {
      let current = this
      while (current) {
        if (current.matches?.(selector)) return current
        current = current.parent
      }
      return null
    }
  }
  return node
}

test("a press inside the panel stays open and a press outside closes", () => {
  const body = element("body")
  const { document, listeners, track } = documentWith(body)
  const Group = loadController("button_group_menu_controller.js", "ButtonGroupMenuController", { document })
  const controller = new Group()
  const group = element("div")
  const trigger = element("button")
  const panel = element("div")
  const row = element("button")
  const outside = element("div")

  group.dataset = { open: "false" }
  group.appendChild(trigger)
  group.appendChild(panel)
  panel.appendChild(row)
  body.appendChild(group)
  body.appendChild(outside)
  ;[group, trigger, panel, row, outside].forEach(track)

  controller.element = group
  controller.triggerTarget = trigger
  controller.panelTarget = panel
  controller.connect()
  controller.show()

  const press = (target) => listeners.pointerdown.forEach((handler) => handler({ target }))

  press(row)
  assert.equal(group.dataset.open, "true")
  assert.equal(trigger.getAttribute("aria-expanded"), "true")

  press(outside)
  assert.equal(group.dataset.open, "false")
  assert.equal(trigger.getAttribute("aria-expanded"), "false")
})
