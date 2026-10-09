// Grow/shrink an overlay panel from a trigger rect. Modal uses this first;
// Drawer can import the same helpers later. Animate only transform and opacity.
import { prefersReducedMotion, motionTransition } from "controllers/flat_pack/reduced_motion"

export const TRIGGER_ORIGIN = "trigger"
export const CENTER_ORIGIN = "center"
export const MIN_VIEWPORT_WIDTH = 640
const MIN_SCALE = 0.08
const MAX_SCALE = 0.4
const FALLBACK_SCALE = 0.12

export function isTriggerOrigin(origin) {
  return String(origin || "") === TRIGGER_ORIGIN
}

export function resolveTrigger(stored, activeElement, root = document) {
  const candidates = [stored, activeElement]
  for (const node of candidates) {
    if (!isUsableTrigger(node, root)) continue

    return node.closest?.("[data-modal-id]") || node
  }

  return null
}

export function isUsableTrigger(node, root = document) {
  if (!node || node.nodeType !== 1) return false
  if (node === root.body || node === root.documentElement) return false
  if (typeof node.getBoundingClientRect !== "function") return false
  if (node.isConnected === false) return false
  if (node.closest?.('[role="dialog"]')) return false

  return true
}

export function triggerIsOnScreen(rect, viewport = globalThis) {
  if (!rect) return false
  if (rect.width <= 0 || rect.height <= 0) return false

  const viewportWidth = viewport.innerWidth || 0
  const viewportHeight = viewport.innerHeight || 0

  return rect.right > 0 && rect.bottom > 0 && rect.left < viewportWidth && rect.top < viewportHeight
}

export function viewportAllowsTriggerOrigin(viewport = globalThis) {
  return (viewport.innerWidth || 0) >= MIN_VIEWPORT_WIDTH
}

export function canUseTriggerOrigin(trigger, panel, {
  viewport = globalThis,
  reducedMotion = prefersReducedMotion()
} = {}) {
  if (reducedMotion) return false
  if (!viewportAllowsTriggerOrigin(viewport)) return false
  if (!isUsableTrigger(trigger)) return false
  if (!panel || typeof panel.getBoundingClientRect !== "function") return false

  return triggerIsOnScreen(trigger.getBoundingClientRect(), viewport)
}

export function computeTriggerOriginMotion(panelRect, triggerRect) {
  const triggerCenterX = triggerRect.left + triggerRect.width / 2
  const triggerCenterY = triggerRect.top + triggerRect.height / 2
  const originX = triggerCenterX - panelRect.left
  const originY = triggerCenterY - panelRect.top
  const scale = clampScale(Math.min(
    triggerRect.width / Math.max(panelRect.width, 1),
    triggerRect.height / Math.max(panelRect.height, 1)
  ))
  // Scale around the trigger, then nudge so the small card sits on it.
  const dx = -((panelRect.width / 2 - originX) * scale)
  const dy = -((panelRect.height / 2 - originY) * scale)

  return {
    transformOrigin: `${round(originX)}px ${round(originY)}px`,
    transform: `translate(${round(dx)}px, ${round(dy)}px) scale(${round(scale, 4)})`
  }
}

export function applyTriggerOriginStart(panel, trigger) {
  prepareTriggerOriginPanel(panel)
  const motion = computeTriggerOriginMotion(panel.getBoundingClientRect(), trigger.getBoundingClientRect())
  panel.style.transformOrigin = motion.transformOrigin
  panel.style.transform = motion.transform
  panel.style.opacity = "0"
  void panel.offsetHeight

  return motion
}

export function playTriggerOriginEnter(panel) {
  panel.style.transition = motionTransition(
    ["opacity", "transform"],
    { duration: "slow", easing: "enter" }
  )
  panel.style.opacity = "1"
  panel.style.transform = "none"
}

export function playTriggerOriginExit(panel, trigger, {
  viewport = globalThis
} = {}) {
  if (!isUsableTrigger(trigger)) return false
  if (!triggerIsOnScreen(trigger.getBoundingClientRect(), viewport)) return false

  const motion = computeTriggerOriginMotion(panel.getBoundingClientRect(), trigger.getBoundingClientRect())
  panel.style.transition = motionTransition(
    ["opacity", "transform"],
    { duration: "base", easing: "exit" }
  )
  panel.style.transformOrigin = motion.transformOrigin
  panel.style.opacity = "0"
  panel.style.transform = motion.transform

  return true
}

export function clearTriggerOriginStyles(panel) {
  if (!panel?.style) return

  panel.style.removeProperty("transform")
  panel.style.removeProperty("transform-origin")
  panel.style.removeProperty("transition")
  panel.style.removeProperty("opacity")
  panel.style.removeProperty("scale")
}

function prepareTriggerOriginPanel(panel) {
  panel.style.transition = "none"
  panel.style.scale = "none"
  panel.style.opacity = "0"
  panel.style.transform = "none"
  void panel.offsetHeight
}

function clampScale(scale) {
  if (!Number.isFinite(scale) || scale <= 0) return FALLBACK_SCALE

  return Math.min(Math.max(scale, MIN_SCALE), MAX_SCALE)
}

function round(value, digits = 2) {
  const factor = 10 ** digits

  return Math.round(value * factor) / factor
}
