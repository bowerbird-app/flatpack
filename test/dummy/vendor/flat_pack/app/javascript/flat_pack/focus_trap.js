// One Tab cycle for overlay dialogs.
// Drawer and Command palette call trapTab(event, container).
// Modal passes { modal: true }. Its focusable set is narrower, an empty
// dialog focuses the container, and Tab wraps when focus is outside it.
// Those three differences are the modal option. The selector string is shared.

export const FOCUSABLE_SELECTOR = 'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'

export function focusableElements(container, { modal = false } = {}) {
  if (!container || typeof container.querySelectorAll !== "function") return []

  const found = Array.from(container.querySelectorAll(FOCUSABLE_SELECTOR))
  if (!modal) return found

  return found.filter(isModalFocusable)
}

export function trapTab(event, container, options = {}) {
  if (!event || event.key !== "Tab" || !container) return

  const focusable = focusableElements(container, options)
  if (focusable.length === 0) {
    if (!options.modal) return

    event.preventDefault()
    if (typeof container.focus === "function") container.focus()
    return
  }

  const first = focusable[0]
  const last = focusable[focusable.length - 1]
  const active = document.activeElement
  const outside = Boolean(options.modal) && !container.contains(active)

  if (event.shiftKey) {
    if (outside || active === first) {
      event.preventDefault()
      last.focus()
    }
  } else if (outside || active === last) {
    event.preventDefault()
    first.focus()
  }
}

// Modal's query is a subset of FOCUSABLE_SELECTOR, plus aria-hidden and tabIndex.
// Matching that subset here keeps one selector string in querySelectorAll.
function isModalFocusable(element) {
  if (element.disabled) return false
  if (element.getAttribute("aria-hidden") === "true") return false
  if (element.tabIndex < 0) return false
  if (typeof element.matches !== "function") return false

  if (element.matches('[tabindex]:not([tabindex="-1"])')) return true
  if (element.matches("a[href]")) return true
  if (element.matches("button, select, textarea")) return true
  if (element.matches("input") && !element.matches('[type="hidden"]')) return true

  return false
}
