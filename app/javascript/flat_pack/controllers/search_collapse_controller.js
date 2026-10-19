import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggle", "field", "input"]
  static values = {
    collapsed: { type: Boolean, default: true }
  }

  initialize() {
    this.onPointerDown = this.onPointerDown.bind(this)
    this.onKeyDown = this.onKeyDown.bind(this)
    this.listening = false
    this.pendingFrame = null
    this.focusAfter = undefined
  }

  connect() {
    if (this.occupied() && this.collapsedValue) {
      this.focusAfter = false
      this.collapsedValue = false
    }
  }

  disconnect() {
    this.removeDocumentListeners()
  }

  expand(event) {
    event?.preventDefault()
    if (!this.collapsedValue) return

    this.focusAfter = "input"
    this.collapsedValue = false
  }

  dismiss(event) {
    if (this.collapsedValue || this.occupied()) return

    const next = event.relatedTarget
    if (next && this.element.contains(next)) return

    this.focusAfter = next ? false : "toggle"
    this.collapse()
  }

  collapse() {
    if (this.collapsedValue || this.occupied()) {
      this.focusAfter = undefined
      return
    }

    this.collapsedValue = true
  }

  collapsedValueChanged(collapsed, previous) {
    const initial = previous === undefined
    this.element.dataset.fpCollapsed = collapsed ? "true" : "false"

    if (this.hasToggleTarget) {
      this.toggleTarget.inert = !collapsed
      this.toggleTarget.setAttribute("aria-expanded", collapsed ? "false" : "true")
    }

    if (this.hasFieldTarget) this.fieldTarget.inert = collapsed

    if (collapsed) {
      this.closeResults()
      this.removeDocumentListeners()
    } else {
      this.armDocumentListeners()
    }

    if (initial) return

    if (this.focusAfter === "input" && this.hasInputTarget) this.inputTarget.focus()
    if (this.focusAfter === "toggle" && this.hasToggleTarget) this.toggleTarget.focus()
    this.focusAfter = undefined
  }

  occupied() {
    return this.hasInputTarget && this.inputTarget.value.trim() !== ""
  }

  closeResults() {
    const dropdown = this.element.querySelector("[data-flat-pack--search-target='dropdown']")
    dropdown?.classList.add("hidden")
    if (this.hasInputTarget) this.inputTarget.setAttribute("aria-expanded", "false")
  }

  armDocumentListeners() {
    if (this.listening) return

    this.pendingFrame = requestAnimationFrame(() => {
      this.pendingFrame = null
      if (this.collapsedValue || this.listening) return

      document.addEventListener("pointerdown", this.onPointerDown)
      document.addEventListener("keydown", this.onKeyDown)
      this.listening = true
    })
  }

  removeDocumentListeners() {
    if (this.pendingFrame != null) {
      cancelAnimationFrame(this.pendingFrame)
      this.pendingFrame = null
    }

    if (!this.listening) return

    document.removeEventListener("pointerdown", this.onPointerDown)
    document.removeEventListener("keydown", this.onKeyDown)
    this.listening = false
  }

  onPointerDown(event) {
    if (this.collapsedValue || this.element.contains(event.target) || this.occupied()) return

    const landedOnControl = event.target.closest?.("a, button, input, select, textarea, summary, [tabindex]:not([tabindex='-1'])")
    if (!landedOnControl) event.preventDefault()
    this.focusAfter = landedOnControl ? false : "toggle"
    this.collapse()
  }

  onKeyDown(event) {
    if (event.key !== "Escape" || this.collapsedValue || this.occupied()) return

    event.preventDefault()
    this.focusAfter = "toggle"
    this.collapse()
  }
}
