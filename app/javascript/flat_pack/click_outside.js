// One document listener for overlays that close when the pointer lands outside.
// Callers keep their own event (click, mousedown, or pointerdown) and phase.
// Escape stays on the caller. add() and remove() use the same listener, so a
// second add is a no-op in the browser and one remove drops it.
//
// isBackdropClick is the dialog form. Modal, Drawer, and Command palette listen
// on an empty backdrop, so the click target is that element. Lightbox listens
// on the dialog; the stage and the controls are not the backdrop.

export function isOutside(event, roots) {
  const target = event?.target
  if (!target) return false

  const list = typeof roots === "function" ? roots() : roots
  const nodes = Array.isArray(list) ? list : [list]

  return !nodes.some((node) => typeof node?.contains === "function" && node.contains(target))
}

export function onClickOutside(target, onOutside, {
  event = "click",
  capture = false,
  roots = null,
  onlyWhen = null
} = {}) {
  const listener = (domEvent) => {
    if (typeof onlyWhen === "function" && !onlyWhen()) return
    if (roots != null && !isOutside(domEvent, roots)) return
    onOutside(domEvent)
  }

  return {
    add() {
      target.addEventListener(event, listener, capture)
    },
    remove() {
      target.removeEventListener(event, listener, capture)
    }
  }
}

export function isBackdropClick(event, { content = null, controls = null } = {}) {
  if (!event) return false

  if (!content && !controls) return event.target === event.currentTarget

  const target = event.target
  if (content && target.closest(content)) return false
  if (controls && target.closest(controls)) return false
  return true
}
