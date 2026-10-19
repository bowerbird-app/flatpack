const test = require("node:test")
const assert = require("node:assert/strict")
const fs = require("node:fs")
const path = require("node:path")
const vm = require("node:vm")

const COPY = {
  "clipboard.nothing": "Nothing to copy",
  "clipboard.copied": "Copied to clipboard",
  "clipboard.unable": "Unable to copy",
  "clipboard.copy": "Copy",
  "clipboard.copied_label": "Copied",
  "clipboard.error_label": "Couldn’t copy"
}

function loadContext(options = {}) {
  const root = path.join(__dirname, "..", "..", "app", "javascript", "flat_pack")
  const clipboardSource = fs.readFileSync(path.join(root, "clipboard.js"), "utf8")
    .replace("export const ", "const ")
    .replace("export const ", "const ")
    .replace("export async function ", "async function ")
    .replace("export function ", "function ")
    .replace("export function ", "function ")
    .replace("export function ", "function ")
    .replace("export function ", "function ") +
    "\nglobalThis.writeClipboardText = writeClipboardText\nglobalThis.readClipboardSource = readClipboardSource\n"

  const controllerSource = fs.readFileSync(path.join(root, "controllers", "clipboard_controller.js"), "utf8")
    .replace('import { Controller } from "@hotwired/stimulus"\n', "class Controller {}\n")
    .replace(
      'import { flatPackCopy } from "flat_pack/copy"\n',
      "function flatPackCopy(key) { return globalThis.__copy[key] }\n"
    )
    .replace(
      'import { prefersReducedMotion } from "controllers/flat_pack/reduced_motion"\n',
      "function prefersReducedMotion() { return Boolean(globalThis.__reducedMotion) }\n"
    )
    .replace(/import \{[\s\S]*?\} from "flat_pack\/clipboard"\n/, "")
    .replace("export default class extends Controller", "class ClipboardController extends Controller") +
    "\nmodule.exports = ClipboardController\n"

  const created = []
  const nodes = []
  const documentEvents = []
  const timers = []
  const historyCalls = []

  function element(tag) {
    const node = {
      tagName: String(tag || "div").toUpperCase(),
      id: "",
      className: "",
      value: "",
      disabled: false,
      textContent: "",
      parent: null,
      children: [],
      attributes: {},
      style: {},
      tabIndex: 0,
      setAttribute(name, value) {
        this.attributes[name] = String(value)
        if (name === "id") this.id = String(value)
      },
      getAttribute(name) {
        return Object.prototype.hasOwnProperty.call(this.attributes, name) ? this.attributes[name] : null
      },
      removeAttribute(name) {
        delete this.attributes[name]
      },
      appendChild(child) {
        child.parent = this
        this.children.push(child)
        return child
      },
      remove() {
        if (!this.parent) return
        this.parent.children = this.parent.children.filter((child) => child !== this)
        this.parent = null
      },
      focus() {},
      select() {},
      setSelectionRange() {},
      matches(selector) {
        return matches(this, selector)
      },
      closest(selector) {
        let current = this
        while (current) {
          if (current.matches?.(selector)) return current
          current = current.parent
        }
        return null
      },
      querySelector(selector) {
        return find(this, selector)
      }
    }
    created.push(node)
    return node
  }

  function matches(node, selector) {
    if (selector === "button, a") return node.tagName === "BUTTON" || node.tagName === "A"
    if (selector === "a") return node.tagName === "A"
    if (selector === "a[href^='#']") {
      return node.tagName === "A" && String(node.getAttribute("href") || "").startsWith("#")
    }
    if (selector.startsWith("#")) return node.id === selector.slice(1)
    if (selector.startsWith(".")) return node.className.split(/\s+/).includes(selector.slice(1))
    if (selector.startsWith("[") && selector.endsWith("]")) {
      return node.getAttribute(selector.slice(1, -1)) != null
    }
    if (selector.includes("icon-name")) return node.getAttribute("data-flat-pack--icon-name-value") != null
    return false
  }

  function find(root, selector) {
    for (const child of root.children || []) {
      if (child.matches(selector)) return child
      const nested = find(child, selector)
      if (nested) return nested
    }
    return null
  }

  const body = element("body")
  const document = {
    body,
    events: documentEvents,
    createElement: element,
    getElementById(id) {
      return nodes.find((node) => node.id === id) || null
    },
    querySelector(selector) {
      return nodes.find((node) => node.matches(selector)) || find(body, selector)
    },
    execCommand() {
      return options.execCommand === undefined ? true : options.execCommand
    },
    dispatchEvent(event) {
      documentEvents.push(event)
    }
  }

  if (options.execCommandThrows) {
    document.execCommand = () => {
      throw new Error("copy failed")
    }
  }

  const writeCalls = []
  const context = {
    module: { exports: {} },
    exports: {},
    document,
    navigator: {
      clipboard: options.clipboard === null ? undefined : {
        writeText: async (text) => {
          writeCalls.push(text)
          if (options.writeError) throw new Error("denied")
        }
      }
    },
    isSecureContext: options.isSecureContext !== false,
    __copy: COPY,
    __reducedMotion: Boolean(options.reducedMotion),
    CustomEvent: class CustomEvent {
      constructor(type, init = {}) {
        this.type = type
        this.bubbles = Boolean(init.bubbles)
        this.detail = init.detail
      }
    },
    setTimeout(fn, delay) {
      const id = timers.length + 1
      timers.push({ id, fn, delay })
      return id
    },
    clearTimeout(id) {
      const timer = timers.find((item) => item.id === id)
      if (timer) timer.cleared = true
    },
    history: {
      calls: historyCalls,
      replaceState(...args) {
        historyCalls.push(args)
      }
    },
    location: { href: "https://example.com/docs" },
    URL,
    CSS: {
      escape(value) {
        return String(value).replace(/[^a-zA-Z0-9_-]/g, (character) => `\\${character}`)
      }
    },
    created,
    nodes,
    timers,
    writeCalls
  }
  context.globalThis = context
  context.window = context

  vm.runInNewContext(`${clipboardSource}\n${controllerSource}`, context, { filename: "clipboard_controller_test.js" })
  context.register = (node) => {
    nodes.push(node)
    return node
  }
  return context
}

function mount(context, options = {}) {
  const ControllerClass = context.module.exports
  const controller = new ControllerClass()
  const host = context.document.createElement(options.hostTag || "span")
  const button = context.document.createElement("button")
  const label = context.document.createElement("span")
  const live = context.document.createElement("span")
  const icon = context.document.createElement("svg")
  label.textContent = options.labelText || "Copy"
  icon.setAttribute("data-flat-pack--icon-name-value", options.icon || "clipboard-document")
  button.appendChild(icon)
  host.appendChild(button)
  host.events = []
  host.dispatchEvent = (event) => {
    host.events.push(event)
  }
  if (options.href) host.setAttribute("href", options.href)
  if (options.disabled) button.disabled = true

  controller.element = host
  controller.buttonTarget = button
  controller.hasButtonTarget = options.hasButton !== false
  controller.labelTarget = label
  controller.hasLabelTarget = options.hasLabel !== false
  controller.liveTarget = live
  controller.hasLiveTarget = options.hasLive !== false
  controller.textValue = options.text ?? ""
  controller.hasTextValue = options.hasText !== false
  controller.targetValue = options.target || ""
  controller.hasTargetValue = Boolean(options.target)
  controller.sourceValue = options.source || "text"
  controller.hasSourceValue = options.hasSource !== false
  controller.feedbackValue = options.feedback || "button"
  controller.timeoutValue = options.timeout === undefined ? 2000 : options.timeout
  controller.iconValue = options.icon || "clipboard-document"
  controller.copiedLabelValue = "Copied"
  controller.errorLabelValue = "Couldn’t copy"
  controller.emptyLabelValue = "Nothing to copy"
  controller.copiedAnnouncementValue = options.copiedAnnouncement ?? "Copied to clipboard"
  controller.errorAnnouncementValue = "Unable to copy"
  controller.emptyAnnouncementValue = "Nothing to copy"
  controller.connect()

  return { controller, host, button, label, live, icon }
}

function clickEvent(target) {
  return {
    target,
    defaultPrevented: false,
    preventDefault() {
      this.defaultPrevented = true
    }
  }
}

test("writeClipboardText uses the async clipboard in a secure context", async () => {
  const context = loadContext()
  const copied = await context.writeClipboardText("Harbour")

  assert.equal(copied, true)
  assert.equal(JSON.stringify(context.writeCalls), JSON.stringify(["Harbour"]))
  assert.equal(context.document.body.children.length, 0)
})

test("writeClipboardText falls back when writeText rejects and removes the textarea", async () => {
  const context = loadContext({ writeError: true })
  const copied = await context.writeClipboardText("Harbour")
  const textarea = context.created.find((node) => node.tagName === "TEXTAREA")

  assert.equal(copied, true)
  assert.equal(textarea.getAttribute("readonly"), "")
  assert.equal(textarea.getAttribute("aria-hidden"), "true")
  assert.equal(textarea.value, "Harbour")
  assert.equal(textarea.parent, null)
  assert.equal(context.document.body.children.length, 0)
})

test("writeClipboardText falls back when clipboard is missing or the context is insecure", async () => {
  const missing = loadContext({ clipboard: null })
  assert.equal(await missing.writeClipboardText("a"), true)
  assert.equal(missing.writeCalls.length, 0)

  const insecure = loadContext({ isSecureContext: false })
  assert.equal(await insecure.writeClipboardText("b"), true)
  assert.equal(insecure.writeCalls.length, 0)
})

test("writeClipboardText reports a failed fallback and still removes the textarea", async () => {
  const refused = loadContext({ clipboard: null, execCommand: false })
  assert.equal(await refused.writeClipboardText("a"), false)
  assert.equal(refused.document.body.children.length, 0)

  const thrown = loadContext({ clipboard: null, execCommandThrows: true })
  assert.equal(await thrown.writeClipboardText("b"), false)
  assert.equal(thrown.document.body.children.length, 0)
})

test("readClipboardSource reads text, targets, and hash anchors", () => {
  const context = loadContext()
  const input = context.register(context.document.createElement("input"))
  input.id = "api_key"
  input.value = "  sk_live  "
  const note = context.register(context.document.createElement("p"))
  note.className = "note"
  note.textContent = "Harbour take"

  assert.equal(
    JSON.stringify(context.readClipboardSource({ source: "text", text: "Hello" })),
    JSON.stringify({ status: "ok", text: "Hello", element: null })
  )
  assert.equal(context.readClipboardSource({ source: "text", text: null }).status, "missing")
  assert.equal(
    context.readClipboardSource({ source: "target", target: "api_key" }).text,
    "  sk_live  "
  )
  assert.equal(
    context.readClipboardSource({ source: "target", target: ".note" }).text,
    "Harbour take"
  )
  assert.equal(context.readClipboardSource({ source: "target", target: "missing" }).status, "missing")
  assert.equal(
    context.readClipboardSource({
      source: "anchor",
      href: "#overview",
      location: context.location
    }).text,
    "https://example.com/docs#overview"
  )
  assert.equal(
    context.readClipboardSource({ source: "anchor", href: "https://example.com/other" }).status,
    "ignore"
  )
})

test("button feedback copies, announces, and resets", async () => {
  const context = loadContext()
  const { controller, host, button, label, live } = mount(context, { text: "Harbour" })
  const event = clickEvent(button)

  await controller.copy(event)

  assert.equal(event.defaultPrevented, true)
  assert.equal(button.getAttribute("data-fp-clipboard-state"), "copied")
  assert.equal(label.textContent, "Copied")
  assert.equal(live.textContent, "Copied to clipboard")
  assert.equal(host.events[0].type, "flat-pack:clipboard:copied")
  assert.equal(JSON.stringify(host.events[0].detail), JSON.stringify({ text: "Harbour" }))
  assert.equal(context.timers[0].delay, 2000)
  assert.equal(context.document.events.length, 0)

  context.timers[0].fn()
  assert.equal(button.getAttribute("data-fp-clipboard-state"), "idle")
  assert.equal(label.textContent, "Copy")
  assert.equal(live.textContent, "")
})

test("reduced motion caps the hold and timeout 0 keeps the state", async () => {
  const reduced = loadContext({ reducedMotion: true })
  const reducedMount = mount(reduced, { text: "Harbour" })
  await reducedMount.controller.copy(clickEvent(reducedMount.button))
  assert.equal(reduced.timers[0].delay, 600)

  const held = loadContext()
  const heldMount = mount(held, { text: "Harbour", timeout: 0 })
  await heldMount.controller.copy(clickEvent(heldMount.button))
  assert.equal(held.timers.length, 0)
  assert.equal(heldMount.button.getAttribute("data-fp-clipboard-state"), "copied")
})

test("empty, missing, and failed copies dispatch an error", async () => {
  const emptyContext = loadContext()
  const emptyMount = mount(emptyContext, { text: "" })
  await emptyMount.controller.copy(clickEvent(emptyMount.button))
  assert.equal(emptyMount.button.getAttribute("data-fp-clipboard-state"), "error")
  assert.equal(emptyMount.label.textContent, "Nothing to copy")
  assert.equal(emptyMount.live.textContent, "Nothing to copy")
  assert.equal(emptyMount.host.events[0].type, "flat-pack:clipboard:error")
  assert.equal(JSON.stringify(emptyMount.host.events[0].detail), JSON.stringify({ text: "", reason: "empty" }))

  const missingContext = loadContext()
  const missingMount = mount(missingContext, {
    hasText: false,
    source: "target",
    target: "missing"
  })
  await missingMount.controller.copy(clickEvent(missingMount.button))
  assert.equal(missingMount.host.events[0].detail.reason, "missing")
  assert.equal(missingMount.label.textContent, "Couldn’t copy")

  const failedContext = loadContext({ clipboard: null, execCommand: false })
  const failedMount = mount(failedContext, { text: "Harbour" })
  await failedMount.controller.copy(clickEvent(failedMount.button))
  assert.equal(
    JSON.stringify(failedMount.host.events[0].detail),
    JSON.stringify({ text: "Harbour", reason: "failed" })
  )
  assert.equal(failedMount.live.textContent, "Unable to copy")
})

test("a disabled button or source does nothing", async () => {
  const disabledContext = loadContext()
  const disabledMount = mount(disabledContext, { text: "Harbour", disabled: true })
  await disabledMount.controller.copy(clickEvent(disabledMount.button))
  assert.equal(disabledMount.host.events.length, 0)

  const sourceContext = loadContext()
  const input = sourceContext.register(sourceContext.document.createElement("input"))
  input.id = "api_key"
  input.value = "sk_live"
  input.disabled = true
  const sourceMount = mount(sourceContext, { hasText: false, source: "target", target: "api_key" })
  await sourceMount.controller.copy(clickEvent(sourceMount.button))
  assert.equal(sourceMount.host.events.length, 0)
  assert.equal(sourceContext.writeCalls.length, 0)
})

test("toast feedback uses toasts and leaves the live region alone", async () => {
  const context = loadContext()
  const input = context.register(context.document.createElement("input"))
  input.id = "api_key"
  input.value = "sk_live"
  const { controller, button, icon, live } = mount(context, {
    hasText: false,
    source: "target",
    target: "api_key",
    feedback: "toast",
    hasLive: true
  })

  await controller.copy(clickEvent(input))

  assert.equal(context.document.events[0].type, "toast:add")
  assert.equal(context.document.events[0].detail.style, "success")
  assert.equal(context.document.events[0].detail.text, "Copied to clipboard")
  assert.equal(live.textContent, "")
  assert.equal(button.style.color, "")
  assert.equal(icon.getAttribute("data-flat-pack--icon-name-value"), "check")
  assert.equal(context.writeCalls[0], "sk_live")

  input.value = ""
  await controller.copy(clickEvent(input))
  assert.equal(button.style.color, "var(--color-error)")
  assert.equal(icon.getAttribute("data-flat-pack--icon-name-value"), "exclamation-circle")
})

test("quiet anchor copy updates the hash and a non-hash link is ignored", async () => {
  const context = loadContext()
  const { controller, host, button, icon, live } = mount(context, {
    hostTag: "a",
    href: "#overview",
    source: "anchor",
    hasText: false,
    feedback: "quiet",
    icon: "link",
    hasLabel: false
  })
  const event = clickEvent(button)
  button.parent = host

  await controller.copy(event)

  assert.equal(event.defaultPrevented, true)
  assert.equal(context.writeCalls[0], "https://example.com/docs#overview")
  assert.equal(
    JSON.stringify(context.history.calls[0]),
    JSON.stringify([{}, "", "https://example.com/docs#overview"])
  )
  assert.equal(live.textContent, "Copied to clipboard")
  assert.equal(button.style.color, "")
  assert.equal(icon.getAttribute("data-flat-pack--icon-name-value"), "check")
  assert.equal(context.document.events.length, 0)

  const ignored = loadContext()
  const ignoredMount = mount(ignored, {
    hostTag: "a",
    href: "https://example.com/other",
    source: "anchor",
    hasText: false,
    feedback: "quiet"
  })
  const ignoredEvent = clickEvent(ignoredMount.button)
  await ignoredMount.controller.copy(ignoredEvent)
  assert.equal(ignoredEvent.defaultPrevented, false)
  assert.equal(ignored.history.calls.length, 0)
  assert.equal(ignoredMount.host.events.length, 0)
})

test("blank announcement values fall back to flatPackCopy", async () => {
  const context = loadContext()
  const { controller, button, live } = mount(context, {
    text: "Harbour",
    feedback: "quiet",
    copiedAnnouncement: ""
  })

  await controller.copy(clickEvent(button))

  assert.equal(live.textContent, "Copied to clipboard")
})
