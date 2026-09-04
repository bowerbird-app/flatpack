// FlatPack Modal Stimulus Controller
import { Controller } from "@hotwired/stimulus"
import { prefersReducedMotion, motionDuration, motionTransition } from "controllers/flat_pack/reduced_motion"

export default class extends Controller {
  static targets = ["dialog"]
  static values = {
    closeOnBackdrop: { type: Boolean, default: true },
    closeOnEscape: { type: Boolean, default: true }
  }

  connect() {
    this.previousActiveElement = null
    this.hideTimeout = null
    this.closing = false
    this.handleDocumentTriggerClick = this.handleDocumentTriggerClick.bind(this)
    document.addEventListener("click", this.handleDocumentTriggerClick)

    if (this.element.classList.contains("hidden")) {
      this.restoreBodyScroll()
    }
  }

  disconnect() {
    document.removeEventListener("click", this.handleDocumentTriggerClick)
    this.clearHideTimeout()

    // Restore scroll if modal was open when disconnected
    if (this.element.classList.contains("flex")) {
      this.restoreBodyScroll()
      this.restoreFocus()
    }
  }

  // Open modal. Interruptible: a close in flight reverses from the current frame.
  open() {
    const wasClosing = this.closing
    this.clearHideTimeout()
    this.closing = false

    if (!this.element.classList.contains("hidden") && !wasClosing) return

    if (!this.previousActiveElement) {
      this.previousActiveElement = document.activeElement
    }

    this.preventBodyScroll()
    this.element.classList.remove("hidden")
    this.element.classList.add("flex")
    this.element.setAttribute("aria-hidden", "false")
    this.element.offsetHeight

    this.applyEnterMotion()
    this.element.style.opacity = "1"

    requestAnimationFrame(() => {
      if (!this.hasDialogTarget) return

      this.dialogTarget.style.opacity = "1"
      this.dialogTarget.style.transform = prefersReducedMotion() ? "none" : "scale(1)"
    })

    setTimeout(() => this.trapFocus(), 100)
  }

  // Close modal. Exit is shorter than enter and uses the accelerate easing.
  close() {
    if (this.element.classList.contains("hidden") || this.closing) return

    this.closing = true
    this.clearHideTimeout()
    this.applyExitMotion()
    this.element.style.opacity = "0"
    this.restoreBodyScroll()

    if (this.hasDialogTarget) {
      this.dialogTarget.style.opacity = "0"
      if (!prefersReducedMotion()) {
        this.dialogTarget.style.transform = "scale(0.95)"
      }
    }

    this.hideTimeout = setTimeout(() => {
      this.hideTimeout = null
      this.closing = false
      this.element.classList.remove("flex")
      this.element.classList.add("hidden")
      this.element.setAttribute("aria-hidden", "true")
      this.restoreFocus()
    }, motionDuration("base"))
  }

  toggle() {
    if (this.element.classList.contains("hidden") || this.closing) {
      this.open()
    } else {
      this.close()
    }
  }

  handleDocumentTriggerClick(event) {
    const trigger = event.target.closest("[data-modal-id]")
    if (!trigger) return

    const modalId = trigger.dataset.modalId
    if (!modalId || modalId !== this.element.id) return

    this.previousActiveElement = trigger
    this.open()
  }

  clickBackdrop(event) {
    if (!this.closeOnBackdropValue) return

    if (event.target === event.currentTarget) {
      this.close()
    }
  }

  preventBodyScroll() {
    this.originalOverflow = document.body.style.overflow
    this.originalPaddingRight = document.body.style.paddingRight
    const lockCount = Number(document.body.dataset.flatPackModalLockCount || "0")

    if (lockCount === 0) {
      const scrollbarWidth = window.innerWidth - document.documentElement.clientWidth

      if (scrollbarWidth > 0) {
        document.body.style.paddingRight = `${scrollbarWidth}px`
      }

      document.body.style.overflow = "hidden"
    }

    document.body.dataset.flatPackModalLockCount = String(lockCount + 1)
  }

  restoreBodyScroll() {
    const lockCount = Number(document.body.dataset.flatPackModalLockCount || "0")

    if (lockCount > 1) {
      document.body.dataset.flatPackModalLockCount = String(lockCount - 1)
      return
    }

    delete document.body.dataset.flatPackModalLockCount

    if (this.originalOverflow !== undefined) {
      document.body.style.overflow = this.originalOverflow
    } else {
      document.body.style.removeProperty("overflow")
    }

    if (this.originalPaddingRight !== undefined) {
      document.body.style.paddingRight = this.originalPaddingRight
    } else {
      document.body.style.removeProperty("padding-right")
    }
  }

  restoreFocus() {
    if (this.previousActiveElement && typeof this.previousActiveElement.focus === "function") {
      this.previousActiveElement.focus()
      this.previousActiveElement = null
    }
  }

  trapFocus() {
    if (!this.hasDialogTarget) return

    const focusableElements = this.dialogTarget.querySelectorAll(
      'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
    )

    if (focusableElements.length > 0) {
      focusableElements[0].focus()
    } else {
      this.dialogTarget.focus()
    }
  }

  handleKeydown(event) {
    if (!this.hasDialogTarget) return

    if (event.key === "Tab") {
      const focusableElements = Array.from(
        this.dialogTarget.querySelectorAll(
          'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
        )
      )

      if (focusableElements.length === 0) return

      const firstElement = focusableElements[0]
      const lastElement = focusableElements[focusableElements.length - 1]

      if (event.shiftKey && document.activeElement === firstElement) {
        event.preventDefault()
        lastElement.focus()
      } else if (!event.shiftKey && document.activeElement === lastElement) {
        event.preventDefault()
        firstElement.focus()
      }
    }
  }

  applyEnterMotion() {
    this.element.style.transition = motionTransition("opacity", { duration: "slow", easing: "enter" })
    if (!this.hasDialogTarget) return

    this.dialogTarget.style.transition = motionTransition(
      ["opacity", "transform"],
      { duration: "slow", easing: "enter" }
    )
  }

  applyExitMotion() {
    this.element.style.transition = motionTransition("opacity", { duration: "base", easing: "exit" })
    if (!this.hasDialogTarget) return

    this.dialogTarget.style.transition = motionTransition(
      ["opacity", "transform"],
      { duration: "base", easing: "exit" }
    )
  }

  clearHideTimeout() {
    if (!this.hideTimeout) return

    clearTimeout(this.hideTimeout)
    this.hideTimeout = null
  }
}
