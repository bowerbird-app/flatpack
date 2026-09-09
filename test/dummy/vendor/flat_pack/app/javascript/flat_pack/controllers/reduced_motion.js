const QUERY = "(prefers-reduced-motion: reduce)"
const DURATION_MS = {
  fast: 150,
  base: 200,
  slow: 300
}
const OVERLAY_OFFSET_PX = 4
const overlayHideTimeouts = new WeakMap()

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

export function cancelOverlayHide(element) {
  if (!element) return false

  const timeoutId = overlayHideTimeouts.get(element)
  if (timeoutId == null) return false

  globalThis.clearTimeout(timeoutId)
  overlayHideTimeouts.delete(element)
  return true
}

export function playOverlayEnter(element, { placement = "bottom", interrupt = false, beforeAnimate } = {}) {
  const resume = interrupt || cancelOverlayHide(element)
  element.classList.remove("hidden")

  if (!resume) {
    element.style.transition = "none"
    element.style.opacity = "0"
    element.style.transform = "none"
    beforeAnimate?.()
    element.style.transformOrigin = overlayOrigin(placement)
    void element.offsetHeight

    if (!prefersReducedMotion()) {
      element.style.transform = overlayEnterOffset(placement)
      void element.offsetHeight
    }
  } else {
    beforeAnimate?.()
  }

  element.style.transition = motionTransition(
    ["opacity", "transform"],
    { duration: "base", easing: "enter" }
  )

  requestAnimationFrame(() => {
    element.style.opacity = "1"
    element.style.transform = "none"
  })
}

export function playOverlayExit(element, { placement = "bottom", onHidden } = {}) {
  cancelOverlayHide(element)
  element.style.transition = motionTransition(
    ["opacity", "transform"],
    { duration: "base", easing: "exit" }
  )
  element.style.opacity = "0"
  element.style.transform = prefersReducedMotion() ? "none" : overlayEnterOffset(placement)

  const timeoutId = globalThis.setTimeout(() => {
    overlayHideTimeouts.delete(element)
    element.classList.add("hidden")
    onHidden?.()
  }, motionDuration("base"))
  overlayHideTimeouts.set(element, timeoutId)
  return timeoutId
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
