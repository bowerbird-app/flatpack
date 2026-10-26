const test = require("node:test")
const assert = require("node:assert/strict")
const fs = require("node:fs")
const path = require("node:path")
const vm = require("node:vm")

function loadFocusTrap(documentStub) {
  const filePath = path.join(__dirname, "..", "..", "app", "javascript", "flat_pack", "focus_trap.js")
  const source = fs.readFileSync(filePath, "utf8")
    .replaceAll("export function ", "function ")
    .replaceAll("export const ", "const ")

  const context = {
    module: { exports: {} },
    exports: {},
    document: documentStub
  }
  vm.runInNewContext(
    `${source}\nmodule.exports = { trapTab, focusableElements, FOCUSABLE_SELECTOR }\n`,
    context,
    { filename: filePath }
  )
  return context.module.exports
}

function tabEvent({ shiftKey = false } = {}) {
  return {
    key: "Tab",
    shiftKey,
    prevented: false,
    preventDefault() { this.prevented = true }
  }
}

function control(id, { match, disabled = false, tabIndex = 0, ariaHidden = null } = {}) {
  return {
    id,
    disabled,
    tabIndex,
    focused: false,
    getAttribute(name) { return name === "aria-hidden" ? ariaHidden : null },
    matches(selector) { return typeof match === "function" ? match(selector) : match !== false },
    focus() { this.focused = true }
  }
}

function containerWith(nodes, { containsActive = true } = {}) {
  return {
    focused: false,
    querySelectorAll() { return nodes },
    contains(node) {
      if (node === this) return true
      if (!containsActive) return false
      return nodes.includes(node)
    },
    focus() { this.focused = true }
  }
}

test("tab on the last focusable wraps to the first", () => {
  const nodes = [control("first"), control("middle"), control("last")]
  const container = containerWith(nodes)
  const { trapTab } = loadFocusTrap({ activeElement: nodes[2] })
  const event = tabEvent()

  trapTab(event, container)

  assert.equal(event.prevented, true)
  assert.equal(nodes[0].focused, true)
  assert.equal(nodes[2].focused, false)
})

test("shift-tab on the first focusable wraps to the last", () => {
  const nodes = [control("first"), control("middle"), control("last")]
  const { trapTab } = loadFocusTrap({ activeElement: nodes[0] })
  const event = tabEvent({ shiftKey: true })

  trapTab(event, containerWith(nodes))

  assert.equal(event.prevented, true)
  assert.equal(nodes[2].focused, true)
})

test("tab between first and last does not wrap", () => {
  const nodes = [control("first"), control("middle"), control("last")]
  const { trapTab } = loadFocusTrap({ activeElement: nodes[1] })
  const event = tabEvent()

  trapTab(event, containerWith(nodes))

  assert.equal(event.prevented, false)
  assert.equal(nodes[0].focused, false)
  assert.equal(nodes[2].focused, false)
})

test("no focusables leaves the event alone", () => {
  const container = containerWith([])
  const { trapTab } = loadFocusTrap({ activeElement: null })
  const event = tabEvent()

  trapTab(event, container)

  assert.equal(event.prevented, false)
  assert.equal(container.focused, false)
})

test("modal with no focusables focuses the container", () => {
  const container = containerWith([])
  const { trapTab } = loadFocusTrap({ activeElement: null })
  const event = tabEvent()

  trapTab(event, container, { modal: true })

  assert.equal(event.prevented, true)
  assert.equal(container.focused, true)
})

test("focus on the container itself does not wrap while descendants exist", () => {
  const nodes = [control("first"), control("last")]
  const container = containerWith(nodes)
  const { trapTab } = loadFocusTrap({ activeElement: container })
  const event = tabEvent()

  trapTab(event, container, { modal: true })

  assert.equal(event.prevented, false)
  assert.equal(nodes[0].focused, false)
})

test("shift-tab on the container itself does not wrap while descendants exist", () => {
  const nodes = [control("first"), control("last")]
  const container = containerWith(nodes)
  const { trapTab } = loadFocusTrap({ activeElement: container })
  const event = tabEvent({ shiftKey: true })

  trapTab(event, container, { modal: true })

  assert.equal(event.prevented, false)
})

test("modal wraps when focus is outside the container", () => {
  const nodes = [control("first"), control("last")]
  const container = containerWith(nodes, { containsActive: false })
  const { trapTab } = loadFocusTrap({ activeElement: control("outside") })
  const forward = tabEvent()

  trapTab(forward, container, { modal: true })

  assert.equal(forward.prevented, true)
  assert.equal(nodes[0].focused, true)

  nodes[0].focused = false
  const backward = tabEvent({ shiftKey: true })
  trapTab(backward, container, { modal: true })
  assert.equal(backward.prevented, true)
  assert.equal(nodes[1].focused, true)
})

test("drawer does not pull focus back from outside the container", () => {
  const nodes = [control("first"), control("last")]
  const container = containerWith(nodes, { containsActive: false })
  const { trapTab } = loadFocusTrap({ activeElement: control("outside") })
  const event = tabEvent()

  trapTab(event, container)

  assert.equal(event.prevented, false)
  assert.equal(nodes[0].focused, false)
})

test("modal drops disabled hidden and non-anchor href controls", () => {
  const kept = control("kept", { match: (selector) => selector.includes("button") })
  const disabled = control("disabled", { disabled: true, match: () => true })
  const hidden = control("hidden", { ariaHidden: "true", match: () => true })
  const untabbable = control("untabbable", { tabIndex: -1, match: () => true })
  const area = control("area", { match: () => false })
  const container = containerWith([disabled, hidden, untabbable, area, kept])
  const { focusableElements } = loadFocusTrap({ activeElement: null })

  const found = focusableElements(container, { modal: true })

  assert.equal(found.map((node) => node.id).join(","), "kept")
})

test("drawer keeps the controls modal would drop", () => {
  const disabled = control("disabled", { disabled: true, match: () => false })
  const area = control("area", { match: () => false })
  const container = containerWith([disabled, area])
  const { focusableElements } = loadFocusTrap({ activeElement: null })

  const found = focusableElements(container)

  assert.equal(found.map((node) => node.id).join(","), "disabled,area")
})

test("non-tab keys do nothing", () => {
  const nodes = [control("only")]
  const { trapTab } = loadFocusTrap({ activeElement: nodes[0] })
  const event = tabEvent()
  event.key = "Escape"

  trapTab(event, containerWith(nodes), { modal: true })

  assert.equal(event.prevented, false)
})
