const test = require("node:test")
const assert = require("node:assert/strict")
const fs = require("node:fs")
const path = require("node:path")
const vm = require("node:vm")

function loadController() {
  const filePath = path.join(__dirname, "..", "..", "app", "javascript", "flat_pack", "controllers", "video_preview_controller.js")
  const source = fs.readFileSync(filePath, "utf8")
  const transformedSource = source
    .replace('import { Controller } from "@hotwired/stimulus"', "class Controller {}")
    .replace(
      'import { prefersReducedMotion, motionDuration, motionTransition } from "controllers/flat_pack/reduced_motion"',
      `function prefersReducedMotion() { return Boolean(globalThis.__reducedMotion) }
function motionDuration(token) { return prefersReducedMotion() ? 0 : (token === "fast" ? 150 : 200) }
function motionTransition(property) { return property + " var(--duration-base) var(--easing-exit)" }`
    )
    .replace("export default class extends Controller", "class VideoPreviewController extends Controller") + "\nmodule.exports = VideoPreviewController\n"

  const context = {
    module: { exports: {} },
    exports: {},
    CustomEvent: class {
      constructor(type, options = {}) {
        this.type = type
        this.bubbles = options.bubbles || false
        this.detail = options.detail
      }
    },
    setTimeout,
    clearTimeout,
    requestAnimationFrame: (fn) => setTimeout(fn, 0),
    cancelAnimationFrame: (id) => clearTimeout(id),
    __reducedMotion: false
  }
  context.globalThis = context

  vm.runInNewContext(transformedSource, context, { filename: filePath })

  return { ControllerClass: context.module.exports, context }
}

class Node {
  constructor(tagName, ownerDocument) {
    this.tagName = tagName
    this.ownerDocument = ownerDocument
    this.kind = 1
    this.childNodes = []
    this.parent = null
    this.attributes = {}
    this.style = {}
    this.className = ""
    this.tabIndex = 0
    this.focused = false
    this.removed = false
  }

  get nodeType() { return this.kind }

  get children() {
    return this.childNodes.filter((node) => node.nodeType === 1)
  }

  append(...nodes) {
    nodes.forEach((node) => {
      if (node.nodeType === 11) {
        node.childNodes.splice(0).forEach((child) => this.append(child))
        return
      }
      if (node.parent) node.parent.removeChild(node)
      node.parent = this
      this.childNodes.push(node)
    })
  }

  removeChild(node) {
    this.childNodes = this.childNodes.filter((child) => child !== node)
    node.parent = null
  }

  before(node) {
    const siblings = this.parent.childNodes
    const index = siblings.indexOf(this)
    if (node.parent) node.parent.removeChild(node)
    node.parent = this.parent
    siblings.splice(index, 0, node)
  }

  remove() {
    this.removed = true
    if (this.parent) this.parent.removeChild(this)
  }

  contains(node) {
    if (node === this) return true
    return this.childNodes.some((child) => child.nodeType === 1 && child.contains(node))
  }

  closest(selector) {
    let current = this
    while (current) {
      if (current.matches?.(selector)) return current
      current = current.parent
    }
    return null
  }

  matches(selector) {
    return selector.split(",").some((part) => this.matchesOne(part.trim()))
  }

  matchesOne(selector) {
    if (selector === "iframe") return this.tagName === "iframe"
    if (selector === "video") return this.tagName === "video"
    if (selector === "video[controls]") return this.tagName === "video" && this.attributes.controls != null
    if (selector === "audio[controls]") return this.tagName === "audio" && this.attributes.controls != null
    if (selector === "a[href]") return this.tagName === "a" && this.attributes.href
    if (selector === "button:not([disabled])") return this.tagName === "button" && this.attributes.disabled == null
    if (selector === "button") return this.tagName === "button"
    if (selector.startsWith("input")) return this.tagName === "input" && this.attributes.disabled == null && this.attributes.type !== "hidden"
    if (selector.startsWith("select")) return this.tagName === "select" && this.attributes.disabled == null
    if (selector.startsWith("textarea")) return this.tagName === "textarea" && this.attributes.disabled == null
    if (selector === "[role='button']") return this.attributes.role === "button"
    if (selector === "[tabindex]:not([tabindex='-1'])") {
      return this.attributes.tabindex != null && this.attributes.tabindex !== "-1"
    }
    if (selector.startsWith("[contenteditable]")) return this.attributes.contenteditable != null && this.attributes.contenteditable !== "false"
    return false
  }

  querySelector(selector) {
    for (const child of this.children) {
      if (child.tagName === "template") continue
      if (child.matches(selector)) return child
      const found = child.querySelector(selector)
      if (found) return found
    }
    return null
  }

  cloneNode(deep) {
    const copy = new Node(this.tagName, this.ownerDocument)
    copy.kind = this.kind
    copy.attributes = { ...this.attributes }
    copy.className = this.className
    if (deep) {
      this.childNodes.forEach((child) => copy.append(child.cloneNode(true)))
    }
    return copy
  }

  focus() {
    this.focused = true
    this.ownerDocument.activeElement = this
  }

  get content() {
    const fragment = new Node("#document-fragment", this.ownerDocument)
    fragment.kind = 11
    this.childNodes.forEach((child) => fragment.append(child.cloneNode(true)))
    return fragment
  }
}

function build({ reducedMotion = false, player = "iframe" } = {}) {
  const { ControllerClass, context } = loadController()
  context.__reducedMotion = reducedMotion
  const document = { activeElement: null, createElement: (tag) => new Node(tag, document) }
  const element = new Node("div", document)
  element.ownerDocument = document
  const poster = new Node("div", document)
  const playButton = new Node("button", document)
  const badge = new Node("span", document)
  const link = new Node("a", document)
  link.attributes.href = "/share"
  poster.append(playButton, badge, link)

  const template = new Node("template", document)
  if (player === "iframe") {
    const iframe = new Node("iframe", document)
    template.append(iframe)
  } else if (player === "video") {
    const video = new Node("video", document)
    video.attributes.controls = ""
    template.append(video)
  } else {
    template.append(new Node("div", document))
  }

  element.append(poster, template)

  const events = []
  element.dispatchEvent = (event) => {
    events.push(event)
    return true
  }

  const controller = new ControllerClass()
  controller.element = element
  controller.posterTarget = poster
  controller.playerTarget = template
  controller.playTarget = playButton
  controller.hasPosterTarget = true
  controller.hasPlayerTarget = true
  controller.hasPlayTarget = true
  controller.connect()

  return { controller, element, poster, playButton, badge, link, template, events, document }
}

function press(target, key) {
  let prevented = false
  const event = {
    type: "keydown",
    key,
    target,
    preventDefault() { prevented = true }
  }
  return { event, get prevented() { return prevented } }
}

test("template content is not in the live tree before activation", () => {
  const { element, template } = build()

  assert.equal(element.querySelector("iframe"), null)
  assert.equal(template.querySelector("iframe").tagName, "iframe")
})

test("Enter swaps the template in, focuses the player, dispatches, and runs once", () => {
  const { controller, element, poster, playButton, events, document } = build({ reducedMotion: true })
  const pressEnter = press(playButton, "Enter")

  controller.play(pressEnter.event)

  assert.equal(pressEnter.prevented, true)
  assert.equal(poster.removed, true)
  assert.equal(element.querySelector("iframe").focused, true)
  assert.equal(document.activeElement.tagName, "iframe")
  assert.equal(events.length, 1)
  assert.equal(events[0].type, "flat-pack:video-preview:play")
  assert.equal(events[0].bubbles, true)

  const again = press(playButton, "Enter")
  controller.play(again.event)

  assert.equal(again.prevented, false)
  assert.equal(events.length, 1)
  assert.equal(element.children.filter((child) => child.className === "fp-video-preview__player").length, 1)
})

test("Space activates the play button", () => {
  const { controller, playButton, poster, events } = build({ reducedMotion: true })
  const pressSpace = press(playButton, "Space")

  controller.play(pressSpace.event)
  assert.equal(poster.removed, false)
  assert.equal(events.length, 0)

  const pressBlank = press(playButton, " ")
  controller.play(pressBlank.event)

  assert.equal(pressBlank.prevented, true)
  assert.equal(poster.removed, true)
  assert.equal(events[0].type, "flat-pack:video-preview:play")
})

test("click on the poster plays and a link in an overlay item does not", () => {
  const { controller, badge, link, poster, events } = build({ reducedMotion: true })
  let prevented = false

  controller.play({
    type: "click",
    target: link,
    preventDefault() { prevented = true }
  })

  assert.equal(prevented, false)
  assert.equal(poster.removed, false)

  controller.play({
    type: "click",
    target: badge,
    preventDefault() { prevented = true }
  })

  assert.equal(prevented, true)
  assert.equal(poster.removed, true)
  assert.equal(events.length, 1)
})

test("focus moves to a video with controls", () => {
  const { controller, playButton, element } = build({ reducedMotion: true, player: "video" })

  controller.play(press(playButton, "Enter").event)

  assert.equal(element.querySelector("video").focused, true)
})

test("focus moves to the player container when nothing inside can take focus", () => {
  const { controller, playButton, element, document } = build({ reducedMotion: true, player: "plain" })

  controller.play(press(playButton, "Enter").event)

  const stage = element.children.find((child) => child.className === "fp-video-preview__player")
  assert.equal(stage.tabIndex, -1)
  assert.equal(stage.focused, true)
  assert.equal(document.activeElement, stage)
})

test("reduced motion removes the poster immediately and motion fades it", async () => {
  const instant = build({ reducedMotion: true })
  instant.controller.play(press(instant.playButton, "Enter").event)
  assert.equal(instant.poster.removed, true)
  assert.equal(instant.poster.style.opacity, undefined)

  const faded = build({ reducedMotion: false })
  faded.controller.play(press(faded.playButton, "Enter").event)

  assert.equal(faded.poster.removed, false)
  assert.equal(faded.poster.style.pointerEvents, "none")
  assert.equal(faded.element.querySelector("iframe").focused, true)

  await new Promise((resolve) => setTimeout(resolve, 20))
  assert.equal(faded.poster.style.opacity, "0")
  assert.match(faded.poster.style.transition, /opacity/)

  await new Promise((resolve) => setTimeout(resolve, 220))
  assert.equal(faded.poster.removed, true)
})
