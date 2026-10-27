const test = require("node:test")
const assert = require("node:assert/strict")
const fs = require("node:fs")
const path = require("node:path")
const vm = require("node:vm")

function loadClickOutside() {
  const filePath = path.join(__dirname, "..", "..", "app", "javascript", "flat_pack", "click_outside.js")
  const source = fs.readFileSync(filePath, "utf8").replaceAll("export function ", "function ")
  const context = { module: { exports: {} }, exports: {} }
  vm.runInNewContext(
    `${source}\nmodule.exports = { isOutside, onClickOutside, isBackdropClick }\n`,
    context,
    { filename: filePath }
  )
  return context.module.exports
}

function node(id, children = []) {
  const element = {
    id,
    children,
    contains(target) {
      if (target === element) return true
      return children.some((child) => child === target || child.contains?.(target))
    }
  }
  return element
}

function documentStub() {
  const entries = []
  return {
    entries,
    addEventListener(type, listener, capture) {
      entries.push({ type, listener, capture })
    },
    removeEventListener(type, listener, capture) {
      const index = entries.findIndex((entry) => {
        return entry.type === type && entry.listener === listener && entry.capture === capture
      })
      if (index >= 0) entries.splice(index, 1)
    },
    dispatch(type, event) {
      entries.filter((entry) => entry.type === type).forEach((entry) => entry.listener(event))
    }
  }
}

test("an outside click is outside and a click inside the element is not", () => {
  const { isOutside } = loadClickOutside()
  const panel = node("panel", [node("child")])
  const child = panel.children[0]
  const outside = node("outside")

  assert.equal(isOutside({ target: outside }, panel), true)
  assert.equal(isOutside({ target: panel }, panel), false)
  assert.equal(isOutside({ target: child }, panel), false)
})

test("a click on the trigger is ignored when the trigger is a separate root", () => {
  const { isOutside } = loadClickOutside()
  const trigger = node("trigger")
  const panel = node("panel")

  assert.equal(isOutside({ target: trigger }, [trigger, panel]), false)
  assert.equal(isOutside({ target: panel }, [trigger, panel]), false)
  assert.equal(isOutside({ target: node("page") }, [trigger, panel]), true)
})

test("outside click closes, inside click does not, and remove drops the listener", () => {
  const { onClickOutside } = loadClickOutside()
  const doc = documentStub()
  const panel = node("panel")
  let closed = 0
  const outside = onClickOutside(doc, () => { closed += 1 }, {
    roots: () => panel
  })

  outside.add()
  doc.dispatch("click", { target: panel })
  assert.equal(closed, 0)

  doc.dispatch("click", { target: node("page") })
  assert.equal(closed, 1)

  outside.remove()
  doc.dispatch("click", { target: node("page") })
  assert.equal(closed, 1)
  assert.equal(doc.entries.length, 0)
})

test("the listener keeps the caller's event and capture phase", () => {
  const { onClickOutside } = loadClickOutside()
  const doc = documentStub()
  const outside = onClickOutside(doc, () => {}, {
    event: "mousedown",
    capture: true,
    roots: () => node("panel")
  })

  outside.add()

  assert.equal(doc.entries.length, 1)
  assert.equal(doc.entries[0].type, "mousedown")
  assert.equal(doc.entries[0].capture, true)

  outside.remove()
  assert.equal(doc.entries.length, 0)
})

test("a second add reuses the same listener and one remove drops one registration", () => {
  const { onClickOutside } = loadClickOutside()
  const doc = documentStub()
  const outside = onClickOutside(doc, () => {}, { roots: () => [] })

  outside.add()
  outside.add()

  assert.equal(doc.entries[0].listener, doc.entries[1].listener)
  outside.remove()
  assert.equal(doc.entries.length, 1)
  outside.remove()
  assert.equal(doc.entries.length, 0)
})

test("onlyWhen skips the close while the overlay is shut", () => {
  const { onClickOutside } = loadClickOutside()
  const doc = documentStub()
  let open = false
  let closed = 0
  const outside = onClickOutside(doc, () => { closed += 1 }, {
    capture: true,
    roots: () => node("panel"),
    onlyWhen: () => open
  })

  outside.add()
  doc.dispatch("click", { target: node("page") })
  assert.equal(closed, 0)

  open = true
  doc.dispatch("click", { target: node("page") })
  assert.equal(closed, 1)
  assert.equal(doc.entries[0].capture, true)
})

test("pointerdown uses the same outside check", () => {
  const { onClickOutside } = loadClickOutside()
  const doc = documentStub()
  const root = node("root")
  let closed = 0
  const outside = onClickOutside(doc, () => { closed += 1 }, {
    event: "pointerdown",
    capture: true,
    roots: () => root
  })

  outside.add()
  doc.dispatch("pointerdown", { target: root })
  assert.equal(closed, 0)
  doc.dispatch("pointerdown", { target: node("page") })
  assert.equal(closed, 1)
  assert.equal(doc.entries[0].type, "pointerdown")
  assert.equal(doc.entries[0].capture, true)
})

test("omitted roots still deliver the event so the caller can decide per panel", () => {
  const { isOutside, onClickOutside } = loadClickOutside()
  const doc = documentStub()
  const row = node("row")
  const list = node("list")
  const seen = []
  const outside = onClickOutside(doc, (event) => {
    seen.push(isOutside(event, [row, list]))
  })

  outside.add()
  doc.dispatch("click", { target: row })
  doc.dispatch("click", { target: list })
  doc.dispatch("click", { target: node("page") })

  assert.deepEqual(seen, [false, false, true])
})

test("a backdrop click is the backdrop element and a click inside dialog content is not", () => {
  const { isBackdropClick } = loadClickOutside()
  const backdrop = { id: "backdrop" }
  const content = { id: "dialog" }

  assert.equal(isBackdropClick({ target: backdrop, currentTarget: backdrop }), true)
  assert.equal(isBackdropClick({ target: content, currentTarget: backdrop }), false)
})

test("lightbox treats the stage and controls as content and the shell as backdrop", () => {
  const { isBackdropClick } = loadClickOutside()
  const options = {
    content: "[data-flat-pack--lightbox-target='stage']",
    controls: "button, a, video, input, textarea, select"
  }
  const stage = {
    closest(selector) {
      return selector.includes("stage") ? stage : null
    }
  }
  const button = {
    closest(selector) {
      return selector.includes("button") ? button : null
    }
  }
  const shell = { closest() { return null } }

  assert.equal(isBackdropClick({ target: stage }, options), false)
  assert.equal(isBackdropClick({ target: button }, options), false)
  assert.equal(isBackdropClick({ target: shell }, options), true)
})
