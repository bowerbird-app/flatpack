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

function menuOwnedBy(ownerId) {
  const menu = element("div")
  menu.setAttribute("data-flat-pack--button-dropdown-target", "menu")
  menu.setAttribute("data-flat-pack-dropdown-owner", ownerId)
  const item = element("button")
  menu.appendChild(item)
  return { menu, item }
}

test("a press in a child dropdown menu stays inside the group", () => {
  const body = element("body")
  const { document, listeners, track } = documentWith(body)
  const Group = loadController("button_group_menu_controller.js", "ButtonGroupMenuController", { document })
  const controller = new Group()
  const group = element("div")
  const trigger = element("button")
  const panel = element("div")
  const dropdown = element("div")
  dropdown.setAttribute("id", "share-root")
  const outside = element("div")
  const foreign = element("div")
  foreign.setAttribute("id", "page-root")

  group.dataset = { open: "false" }
  group.appendChild(trigger)
  group.appendChild(panel)
  group.appendChild(dropdown)
  body.appendChild(group)
  body.appendChild(outside)
  body.appendChild(foreign)
  ;[group, trigger, panel, dropdown, outside, foreign].forEach(track)

  const child = menuOwnedBy("share-root")
  const other = menuOwnedBy("page-root")
  body.appendChild(child.menu)
  body.appendChild(other.menu)
  ;[child.menu, child.item, other.menu, other.item].forEach(track)

  controller.element = group
  controller.triggerTarget = trigger
  controller.panelTarget = panel
  controller.connect()
  controller.show()

  const press = (target) => listeners.pointerdown.forEach((handler) => handler({ target }))

  press(child.item)
  assert.equal(group.dataset.open, "true")
  assert.equal(trigger.getAttribute("aria-expanded"), "true")

  press(other.item)
  assert.equal(group.dataset.open, "false")
  assert.equal(trigger.getAttribute("aria-expanded"), "false")

  controller.show()
  press(outside)
  assert.equal(group.dataset.open, "false")
})

test("opening a dropdown stamps the portaled menu with the dropdown id", () => {
  const body = element("body")
  const { document } = documentWith(body)
  const Dropdown = loadController(
    "button_dropdown_controller.js",
    "ButtonDropdownController",
    { document },
    [[
      'import { prefersReducedMotion, motionDuration, motionTransition } from "controllers/flat_pack/reduced_motion"\n',
      "function prefersReducedMotion() { return false }\nfunction motionDuration() { return 0 }\nfunction motionTransition() { return \"\" }\n"
    ]]
  )
  const controller = new Dropdown()
  const root = element("div")
  const menu = element("div")
  root.id = "actions"
  controller.element = root
  controller.menuElement = menu

  controller.ensureMenuInBody()

  assert.equal(menu.parent, body)
  assert.equal(menu.getAttribute("data-flat-pack-dropdown-owner"), "actions")
  assert.equal(root.id, "actions")

  const bare = element("div")
  const bareMenu = element("div")
  controller.element = bare
  controller.menuElement = bareMenu
  controller.ensureMenuInBody()

  assert.match(bare.id, /^flat-pack-dropdown-[a-z0-9]+$/)
  assert.equal(bareMenu.getAttribute("data-flat-pack-dropdown-owner"), bare.id)
  assert.equal(bareMenu.parent, body)
})
