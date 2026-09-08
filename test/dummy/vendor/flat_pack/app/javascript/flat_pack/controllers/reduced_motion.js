const QUERY = "(prefers-reduced-motion: reduce)"
const DURATION_MS = {
  fast: 150,
  base: 200,
  slow: 300
}
const OVERLAY_OFFSET_PX = 4

export function prefersReducedMotion() {
  return Boolean(globalThis.matchMedia?.(QUERY).matches)
}

export function motionDuration(token = "slow") {
  if (prefersReducedMotion()) return 0

  return readDurationToken(token)
}

export function motionTransition(properties, { duration = "base", easing = "standard" } = {}) {
  const list = Array.isArray(properties)
    ? properties
    : String(properties).split(",").map((property) => property.trim()).filter(Boolean)

  return list
    .map((property) => `${property} var(--duration-${duration}) var(--easing-${easing})`)
    .join(", ")
}

export function overlayOrigin(placement) {
  switch (placement) {
    case "top":
      return "bottom center"
    case "bottom":
      return "top center"
    case "left":
      return "right center"
    case "right":
      return "left center"
    default:
      return "top center"
  }
}

export function overlayEnterOffset(placement) {
  switch (placement) {
    case "top":
      return `translateY(${OVERLAY_OFFSET_PX}px)`
    case "bottom":
      return `translateY(-${OVERLAY_OFFSET_PX}px)`
    case "left":
      return `translateX(${OVERLAY_OFFSET_PX}px)`
    case "right":
      return `translateX(-${OVERLAY_OFFSET_PX}px)`
    default:
      return `translateY(-${OVERLAY_OFFSET_PX}px)`
  }
}

function readDurationToken(token) {
  const fallback = DURATION_MS[token] ?? DURATION_MS.slow

  if (typeof document === "undefined" || !document.documentElement) {
    return fallback
  }

  const raw = getComputedStyle(document.documentElement).getPropertyValue(`--duration-${token}`).trim()
  if (!raw) return fallback

  const value = Number.parseFloat(raw)
  if (Number.isNaN(value)) return fallback
  if (raw.endsWith("ms")) return value
  if (raw.endsWith("s")) return value * 1000

  return value
}
