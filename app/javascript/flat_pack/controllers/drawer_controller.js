import { Controller } from "@hotwired/stimulus"
import { prefersReducedMotion, motionDuration, motionTransition } from "controllers/flat_pack/reduced_motion"

const LOCK_KEY = "flatPackModalLockCount"

export default class extends Controller {
  static targets = ["panel"]
  static values = {
    side: { type: String, default: "right" },
    closeOnBackdrop: { type: Boolean, default: true },
    closeOnEscape: { type: Boolean, default: true }
  }

  connect() {
    if (this.element.parentElement !== document.body) {
      this.previousActiveElement = null
      this.hideTimeout = null
      this.closing = false
    }
    if (!this.handleDocumentTriggerClickBound) {
      this.handleDocumentTriggerClick = this.handleDocumentTriggerClick.bind(this)
      this.handleDocumentTriggerClickBound = true
    }
    document.addEventListener("click", this.handleDocumentTriggerClick)
  }

  disconnect() {
    document.removeEventListener("click", this.handleDocumentTriggerClick)
    this.clearHideTimeout()
    if (this.moving) return
    if (!this.element.classList.contains("hidden")) {
      this.restoreBodyScroll()
      this.restoreFocus()
    }
    this.restorePosition()
  }

  open() {
    const wasClosing = this.closing
    this.clearHideTimeout()
    this.closing = false
    if (!this.element.classList.contains("hidden") && !wasClosing) return

    if (!this.previousActiveElement) {
      this.previousActiveElement = document.activeElement
    }

    this.ensureInBody()
    this.preventBodyScroll()
    this.element.classList.remove("hidden")
    this.element.setAttribute("aria-hidden", "false")
    this.element.offsetHeight
    this.applyEnterMotion()
    this.element.style.opacity = "1"

    requestAnimationFrame(() => {
      if (!this.hasPanelTarget) return
      this.panelTarget.style.opacity = "1"
      this.panelTarget.style.translate = "0"
    })

    setTimeout(() => this.trapFocus(), 100)
  }

  close() {
    if (this.element.classList.contains("hidden") || this.closing) return

    this.closing = true
    this.clearHideTimeout()
    this.applyExitMotion()
    this.element.style.opacity = "0"
    this.restoreBodyScroll()

    if (this.hasPanelTarget && !prefersReducedMotion()) {
      this.panelTarget.style.opacity = "0"
      this.panelTarget.style.translate = this.closedTranslate()
    } else if (this.hasPanelTarget) {
      this.panelTarget.style.opacity = "0"
    }

    this.hideTimeout = setTimeout(() => {
      this.hideTimeout = null
      this.closing = false
      this.element.classList.add("hidden")
      this.element.setAttribute("aria-hidden", "true")
      this.restorePosition()
      this.restoreFocus()
    }, motionDuration("base"))
  }

  ensureInBody() {
    if (this.element.parentElement === document.body) return

    const slot = document.createElement("span")
    slot.hidden = true
    slot.setAttribute("data-fp-drawer-slot", this.element.id)
    this.element.parentNode.insertBefore(slot, this.element)
    this.moving = true
    document.body.appendChild(this.element)
    this.moving = false
  }

  restorePosition() {
    if (this.element.parentElement !== document.body) return

    const slotId = (typeof CSS !== "undefined" && CSS.escape) ? CSS.escape(this.element.id) : this.element.id
    const slot = document.querySelector(`[data-fp-drawer-slot="${slotId}"]`)
    if (!slot?.parentNode) return

    this.moving = true
    slot.parentNode.insertBefore(this.element, slot)
    slot.remove()
    this.moving = false
  }

  handleDocumentTriggerClick(event) {
    const trigger = event.target.closest("[data-drawer-id]")
    if (!trigger) return
    if (trigger.dataset.drawerId !== this.element.id) return

    this.previousActiveElement = trigger
    this.open()
  }

  clickBackdrop(event) {
    if (!this.closeOnBackdropValue) return
    if (event.target === event.currentTarget) this.close()
  }

  trapTab(event) {
    if (event.key !== "Tab" || !this.hasPanelTarget) return

    const focusable = Array.from(
      this.panelTarget.querySelectorAll('button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])')
    )
    if (focusable.length === 0) return

    const first = focusable[0]
    const last = focusable[focusable.length - 1]
    if (event.shiftKey && document.activeElement === first) {
      event.preventDefault()
      last.focus()
    } else if (!event.shiftKey && document.activeElement === last) {
      event.preventDefault()
      first.focus()
    }
  }

  closedTranslate() {
    switch (this.sideValue) {
      case "left":
        return "-100% 0"
      case "bottom":
        return "0 100%"
      default:
        return "100% 0"
    }
  }

  trapFocus() {
    if (!this.hasPanelTarget) return
    const focusable = this.panelTarget.querySelectorAll(
      'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
    )
    if (focusable.length > 0) {
      focusable[0].focus()
    } else {
      this.panelTarget.setAttribute("tabindex", "-1")
      this.panelTarget.focus()
    }
  }

  preventBodyScroll() {
    this.originalOverflow = document.body.style.overflow
    this.originalPaddingRight = document.body.style.paddingRight
    this.originalOverscrollBehavior = document.body.style.overscrollBehavior
    const lockCount = Number(document.body.dataset[LOCK_KEY] || "0")

    if (lockCount === 0) {
      const scrollbarWidth = window.innerWidth - document.documentElement.clientWidth
      if (scrollbarWidth > 0) document.body.style.paddingRight = `${scrollbarWidth}px`
      document.body.style.overflow = "hidden"
      document.body.style.overscrollBehavior = "none"
    }

    document.body.dataset[LOCK_KEY] = String(lockCount + 1)
  }

  restoreBodyScroll() {
    const lockCount = Number(document.body.dataset[LOCK_KEY] || "0")
    if (lockCount > 1) {
      document.body.dataset[LOCK_KEY] = String(lockCount - 1)
      return
    }

    delete document.body.dataset[LOCK_KEY]
    document.body.style.overflow = this.originalOverflow || ""
    document.body.style.paddingRight = this.originalPaddingRight || ""
    document.body.style.overscrollBehavior = this.originalOverscrollBehavior || ""
  }

  restoreFocus() {
    if (this.previousActiveElement?.focus) {
      this.previousActiveElement.focus()
      this.previousActiveElement = null
    }
  }

  applyEnterMotion() {
    this.element.style.transition = motionTransition("opacity", { duration: "slow", easing: "enter" })
    if (!this.hasPanelTarget) return
    this.panelTarget.style.transition = motionTransition(["opacity", "translate"], { duration: "slow", easing: "enter" })
  }

  applyExitMotion() {
    this.element.style.transition = motionTransition("opacity", { duration: "base", easing: "exit" })
    if (!this.hasPanelTarget) return
    this.panelTarget.style.transition = motionTransition(["opacity", "translate"], { duration: "base", easing: "exit" })
  }

  clearHideTimeout() {
    if (!this.hideTimeout) return
    clearTimeout(this.hideTimeout)
    this.hideTimeout = null
  }
}
