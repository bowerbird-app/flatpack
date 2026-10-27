// Shared floating-panel geometry.
//
// place(anchor, panel, viewport, { placement, gap, edge, flip })
//   anchor, panel: { top, right, bottom, left, width, height }
//   viewport: { width, height }
//   placement: top | bottom | left | right | top_left | top_right | bottom_left | bottom_right
//              unknown names follow bottom
//   gap: space between the anchor and the panel (not the viewport inset)
//   edge: viewport inset, from --overlay-edge-offset
//   flip: when the preferred side does not fit, use the opposite side (default true)
//   stickToEdge: when the panel is larger than the viewport, pin it to `edge`
//                (default false). Popover leaves an oversized panel past the edge.
//                Button dropdown sticks.
//   returns { top, left, placement }
//   Cross axis is centered for top/bottom/left/right, the anchor's start for *_left,
//   and the anchor's end for *_right. Clamp uses
//   min(max(value, edge), viewport - size - edge). With stickToEdge, the upper
//   bound is at least `edge`.
//
// readEdgeOffset(node) reads --overlay-edge-offset as px. Anything else is 8.
// applyFixedPosition(element, { top, left }) sets position, top, and left.
// watchViewport(onChange) listens for window resize and window scroll (capture).
//   add() twice is a no-op. remove() drops both listeners.

const OPPOSITE_SIDE = {
  top: "bottom",
  bottom: "top",
  left: "right",
  right: "left"
}

const PLACEMENTS = {
  top: { side: "top", align: "center" },
  bottom: { side: "bottom", align: "center" },
  left: { side: "left", align: "center" },
  right: { side: "right", align: "center" },
  top_left: { side: "top", align: "start" },
  top_right: { side: "top", align: "end" },
  bottom_left: { side: "bottom", align: "start" },
  bottom_right: { side: "bottom", align: "end" }
}

const EDGE_OFFSET_FALLBACK = 8

function fitsOnSide(side, anchor, panel, viewport, gap, edge) {
  if (side === "top") return anchor.top - panel.height - gap >= edge
  if (side === "bottom") return anchor.bottom + gap + panel.height <= viewport.height - edge
  if (side === "left") return anchor.left - panel.width - gap >= edge
  return anchor.right + gap + panel.width <= viewport.width - edge
}

function coordinatesFor(side, align, anchor, panel, gap) {
  const centeredLeft = anchor.left + (anchor.width / 2) - (panel.width / 2)
  const centeredTop = anchor.top + (anchor.height / 2) - (panel.height / 2)
  let top
  let left

  if (side === "top") top = anchor.top - panel.height - gap
  else if (side === "bottom") top = anchor.bottom + gap
  else if (align === "start") top = anchor.top
  else if (align === "end") top = anchor.bottom - panel.height
  else top = centeredTop

  if (side === "left") left = anchor.left - panel.width - gap
  else if (side === "right") left = anchor.right + gap
  else if (align === "start") left = anchor.left
  else if (align === "end") left = anchor.right - panel.width
  else left = centeredLeft

  return { top, left }
}

function placementName(side, align) {
  if (align === "start" && (side === "top" || side === "bottom")) return `${side}_left`
  if (align === "end" && (side === "top" || side === "bottom")) return `${side}_right`
  return side
}

function clampToEdge(value, size, viewportSize, edge, stickToEdge) {
  const limit = viewportSize - size - edge
  const max = stickToEdge ? Math.max(edge, limit) : limit
  return Math.min(Math.max(value, edge), max)
}

export function place(anchor, panel, viewport, {
  placement = "bottom",
  gap = 0,
  edge = 0,
  flip = true,
  stickToEdge = false
} = {}) {
  const requested = PLACEMENTS[placement] || PLACEMENTS.bottom
  let side = requested.side

  if (flip && !fitsOnSide(side, anchor, panel, viewport, gap, edge)) {
    side = OPPOSITE_SIDE[side]
  }

  const point = coordinatesFor(side, requested.align, anchor, panel, gap)

  return {
    placement: placementName(side, requested.align),
    top: clampToEdge(point.top, panel.height, viewport.height, edge, stickToEdge),
    left: clampToEdge(point.left, panel.width, viewport.width, edge, stickToEdge)
  }
}

export function readEdgeOffset(node) {
  if (!node || typeof getComputedStyle !== "function") return EDGE_OFFSET_FALLBACK

  const raw = getComputedStyle(node).getPropertyValue("--overlay-edge-offset")
  const match = String(raw || "").trim().match(/^(-?(?:\d+\.\d+|\d+))px$/)
  return match ? Number(match[1]) : EDGE_OFFSET_FALLBACK
}

export function applyFixedPosition(element, { top, left }) {
  element.style.position = "fixed"
  element.style.top = `${top}px`
  element.style.left = `${left}px`
}

export function watchViewport(onChange) {
  let listening = false
  const listener = () => onChange()

  return {
    add() {
      if (listening) return
      listening = true
      window.addEventListener("resize", listener)
      window.addEventListener("scroll", listener, true)
    },
    remove() {
      if (!listening) return
      listening = false
      window.removeEventListener("resize", listener)
      window.removeEventListener("scroll", listener, true)
    }
  }
}
