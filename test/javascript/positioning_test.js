const test = require("node:test")
const assert = require("node:assert/strict")
const fs = require("node:fs")
const path = require("node:path")
const vm = require("node:vm")

function loadPositioning() {
  const filePath = path.join(__dirname, "..", "..", "app", "javascript", "flat_pack", "positioning.js")
  const source = fs.readFileSync(filePath, "utf8").replaceAll("export function ", "function ")
  const context = { module: { exports: {} }, exports: {} }
  vm.runInNewContext(
    `${source}\nmodule.exports = { place, readEdgeOffset, applyFixedPosition, watchViewport }\n`,
    context,
    { filename: filePath }
  )
  return context
}

function samePlace(actual, expected) {
  assert.equal(actual.placement, expected.placement)
  assert.equal(actual.top, expected.top)
  assert.equal(actual.left, expected.left)
}

function anchor(box) {
  return {
    top: 100,
    left: 180,
    width: 40,
    height: 40,
    right: 220,
    bottom: 140,
    ...box
  }
}

const panel = { width: 100, height: 80, top: 0, right: 100, bottom: 80, left: 0 }
const viewport = { width: 400, height: 400 }

test("bottom centers under the anchor when that side fits", () => {
  const { place } = loadPositioning().module.exports
  const placed = place(anchor(), panel, viewport, { placement: "bottom", gap: 12, edge: 8 })

  samePlace(placed, { placement: "bottom", top: 152, left: 150 })
})

test("bottom flips to top when the panel crosses the bottom edge", () => {
  const { place } = loadPositioning().module.exports
  const placed = place(anchor({ top: 300, bottom: 340 }), panel, viewport, {
    placement: "bottom",
    gap: 12,
    edge: 8
  })

  samePlace(placed, { placement: "top", top: 208, left: 150 })
})

test("top flips to bottom when the panel crosses the top edge", () => {
  const { place } = loadPositioning().module.exports
  const placed = place(anchor({ top: 40, bottom: 80 }), panel, viewport, {
    placement: "top",
    gap: 12,
    edge: 8
  })

  samePlace(placed, { placement: "bottom", top: 92, left: 150 })
})

test("left flips to right and right stays when it fits", () => {
  const { place } = loadPositioning().module.exports
  const tight = anchor({ left: 10, right: 50 })
  const open = anchor()

  samePlace(
    place(tight, panel, viewport, { placement: "left", gap: 12, edge: 8 }),
    { placement: "right", top: 80, left: 62 }
  )
  samePlace(
    place(open, panel, viewport, { placement: "right", gap: 12, edge: 8 }),
    { placement: "right", top: 80, left: 232 }
  )
})

test("an unknown placement follows bottom", () => {
  const { place } = loadPositioning().module.exports
  const placed = place(anchor(), panel, viewport, { placement: "middle", gap: 12, edge: 8 })

  assert.equal(placed.placement, "bottom")
  assert.equal(placed.top, 152)
})

test("a larger edge offset flips a side that still fits at 8px, and the gap stays put", () => {
  const { place } = loadPositioning().module.exports
  const fitted = anchor({ top: 80, bottom: 100 })
  const shortViewport = { width: 400, height: 200 }

  const atEight = place(fitted, panel, shortViewport, { placement: "bottom", gap: 12, edge: 8 })
  const atSixteen = place(fitted, panel, shortViewport, { placement: "bottom", gap: 12, edge: 16 })

  assert.equal(atEight.placement, "bottom")
  assert.equal(atEight.top, 112)
  assert.equal(atSixteen.placement, "top")
  assert.equal(atSixteen.top, 16)
})

test("clamp pulls a panel back to the edge offset", () => {
  const { place } = loadPositioning().module.exports
  const placed = place(
    anchor({ left: 0, right: 10, width: 10, top: 100, bottom: 120, height: 20 }),
    { width: 80, height: 20, top: 0, right: 80, bottom: 20, left: 0 },
    viewport,
    { placement: "bottom", gap: 12, edge: 8 }
  )

  assert.equal(placed.left, 8)
  assert.equal(placed.top, 132)
})

test("an oversized panel can sit past the edge", () => {
  const { place } = loadPositioning().module.exports
  const placed = place(
    anchor({ top: 10, bottom: 30, height: 20 }),
    { width: 40, height: 500, top: 0, right: 40, bottom: 500, left: 0 },
    { width: 400, height: 200 },
    { placement: "bottom", gap: 12, edge: 8 }
  )

  assert.equal(placed.top, 200 - 500 - 8)
})

test("corner placements align to the anchor start or end and can flip on that axis", () => {
  const { place } = loadPositioning().module.exports
  const options = { gap: 8, edge: 8 }

  samePlace(
    place(anchor(), panel, viewport, { ...options, placement: "bottom_left", flip: false }),
    { placement: "bottom_left", top: 148, left: 180 }
  )
  samePlace(
    place(anchor(), panel, viewport, { ...options, placement: "bottom_right", flip: false }),
    { placement: "bottom_right", top: 148, left: 120 }
  )
  samePlace(
    place(anchor({ top: 300, bottom: 340 }), panel, viewport, { ...options, placement: "bottom_right" }),
    { placement: "top_right", top: 212, left: 120 }
  )
  samePlace(
    place(anchor(), panel, viewport, { ...options, placement: "top_left", flip: false }),
    { placement: "top_left", top: 12, left: 180 }
  )
})

test("flip false keeps the requested side, then clamp still runs", () => {
  const { place } = loadPositioning().module.exports
  const placed = place(anchor({ top: 300, bottom: 340 }), panel, viewport, {
    placement: "bottom",
    gap: 12,
    edge: 8,
    flip: false
  })

  assert.equal(placed.placement, "bottom")
  assert.equal(placed.top, 400 - 80 - 8)
})

test("readEdgeOffset accepts px and falls back otherwise", () => {
  const context = loadPositioning()
  const { readEdgeOffset } = context.module.exports
  const node = {}

  context.getComputedStyle = () => ({ getPropertyValue: () => "16px" })
  assert.equal(readEdgeOffset(node), 16)

  context.getComputedStyle = () => ({ getPropertyValue: () => " 0px " })
  assert.equal(readEdgeOffset(node), 0)

  context.getComputedStyle = () => ({ getPropertyValue: () => "0.5rem" })
  assert.equal(readEdgeOffset(node), 8)

  context.getComputedStyle = () => ({ getPropertyValue: () => "" })
  assert.equal(readEdgeOffset(node), 8)
  assert.equal(readEdgeOffset(null), 8)
})

test("applyFixedPosition writes fixed top and left", () => {
  const { applyFixedPosition } = loadPositioning().module.exports
  const element = { style: {} }

  applyFixedPosition(element, { top: 12, left: 24 })

  assert.equal(element.style.position, "fixed")
  assert.equal(element.style.top, "12px")
  assert.equal(element.style.left, "24px")
})

test("watchViewport follows scroll and resize, ignores a second add, and remove drops both", () => {
  const context = loadPositioning()
  const { watchViewport } = context.module.exports
  const entries = []
  context.window = {
    addEventListener(type, listener, capture) {
      entries.push({ type, listener, capture: capture === true })
    },
    removeEventListener(type, listener, capture) {
      const flag = capture === true
      const index = entries.findIndex((entry) => {
        return entry.type === type && entry.listener === listener && entry.capture === flag
      })
      if (index >= 0) entries.splice(index, 1)
    }
  }

  let moves = 0
  const watch = watchViewport(() => { moves += 1 })
  watch.add()
  watch.add()

  assert.equal(entries.length, 2)
  assert.equal(entries.find((entry) => entry.type === "resize").capture, false)
  assert.equal(entries.find((entry) => entry.type === "scroll").capture, true)

  entries.forEach((entry) => entry.listener())
  assert.equal(moves, 2)

  watch.remove()
  watch.remove()
  assert.equal(entries.length, 0)
})
