// FlatPack Modal Stimulus Controller
import { Controller } from "@hotwired/stimulus"
import { prefersReducedMotion, motionDuration, motionTransition } from "controllers/flat_pack/reduced_motion"
import {
  applyTriggerOriginStart,
  canUseTriggerOrigin,
  clearTriggerOriginStyles,
  isTriggerOrigin,
  playTriggerOriginEnter,
  playTriggerOriginExit,
  resolveTrigger
} from "controllers/flat_pack/trigger_origin"
import { focusableElements as sharedFocusableElements, trapTab as trapTabWithin } from "flat_pack/focus_trap"

export default class extends Controller {
  static targets = ["dialog"]
  static values = {
    closeOnBackdrop: { type: Boolean, default: true },
    closeOnEscape: { type: Boolean, default: true },
    origin: { type: String, default: "center" }
  }

  connect() {
    this.previousActiveElement = null
    this.triggerElement = null
    this.hideTimeout = null
    this.closing = false
    this.usedTriggerOrigin = false
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

    this.rememberTrigger()
    this.preventBodyScroll()
    this.element.classList.remove("hidden")
    this.element.classList.add("flex")
    this.element.setAttribute("aria-hidden", "false")
    this.element.scrollTop = 0
    this.element.offsetHeight

    const resumeTriggerOrigin = this.usedTriggerOrigin && wasClosing
    this.usedTriggerOrigin = resumeTriggerOrigin || this.shouldUseTriggerOrigin()

    if (this.usedTriggerOrigin && this.hasDialogTarget) {
      this.applyEnterMotion()
      this.element.style.opacity = "1"
      if (!resumeTriggerOrigin) {
        applyTriggerOriginStart(this.dialogTarget, this.triggerElement)
      }
      requestAnimationFrame(() => {
        if (!this.hasDialogTarget) return

        playTriggerOriginEnter(this.dialogTarget)
      })
    } else {
      this.applyEnterMotion()
      this.element.style.opacity = "1"

      requestAnimationFrame(() => {
        if (!this.hasDialogTarget) return

        this.dialogTarget.style.opacity = "1"
        this.dialogTarget.style.scale = prefersReducedMotion() ? "none" : "1"
      })
    }

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

    const closedFromTrigger = this.usedTriggerOrigin &&
      this.hasDialogTarget &&
      playTriggerOriginExit(this.dialogTarget, this.triggerElement)

    if (this.hasDialogTarget && !closedFromTrigger) {
      if (this.usedTriggerOrigin) clearTriggerOriginStyles(this.dialogTarget)
      this.dialogTarget.style.opacity = "0"
      if (!prefersReducedMotion()) {
        this.dialogTarget.style.scale = "0.95"
      }
    }

    this.hideTimeout = setTimeout(() => {
      this.hideTimeout = null
      this.closing = false
      this.usedTriggerOrigin = false
      if (this.hasDialogTarget) clearTriggerOriginStyles(this.dialogTarget)
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
    this.triggerElement = trigger
    this.open()
  }

  rememberTrigger() {
    this.triggerElement = resolveTrigger(this.triggerElement, this.previousActiveElement)
  }

  shouldUseTriggerOrigin() {
    if (!isTriggerOrigin(this.originValue)) return false
    if (!this.hasDialogTarget) return false

    return canUseTriggerOrigin(this.triggerElement, this.dialogTarget)
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
    this.originalOverscrollBehavior = document.body.style.overscrollBehavior
    const lockCount = Number(document.body.dataset.flatPackModalLockCount || "0")

    if (lockCount === 0) {
      const scrollbarWidth = window.innerWidth - document.documentElement.clientWidth

      if (scrollbarWidth > 0) {
        document.body.style.paddingRight = `${scrollbarWidth}px`
      }

      document.body.style.overflow = "hidden"
      document.body.style.overscrollBehavior = "none"
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

    if (this.originalOverscrollBehavior !== undefined) {
      document.body.style.overscrollBehavior = this.originalOverscrollBehavior
    } else {
      document.body.style.removeProperty("overscroll-behavior")
    }
  }

  restoreFocus() {
    if (this.previousActiveElement && typeof this.previousActiveElement.focus === "function") {
      this.previousActiveElement.focus()
      this.previousActiveElement = null
    }
  }

  trapFocus() {
    const focusable = this.focusableElements()

    if (focusable.length > 0) {
      focusable[0].focus()
    } else if (this.hasDialogTarget) {
      this.dialogTarget.focus()
    }
  }

  handleKeydown(event) {
    if (event.key !== "Tab") return
    if (!this.hasDialogTarget) return
    if (this.element.classList.contains("hidden")) return

    trapTabWithin(event, this.dialogTarget, { modal: true })
  }

  focusableElements() {
    if (!this.hasDialogTarget) return []

    return sharedFocusableElements(this.dialogTarget, { modal: true })
  }

  applyEnterMotion() {
    this.element.style.transition = motionTransition("opacity", { duration: "slow", easing: "enter" })
    if (!this.hasDialogTarget) return

    this.dialogTarget.style.transition = motionTransition(
      ["opacity", "scale"],
      { duration: "slow", easing: "enter" }
    )
  }

  applyExitMotion() {
    this.element.style.transition = motionTransition("opacity", { duration: "base", easing: "exit" })
    if (!this.hasDialogTarget) return

    this.dialogTarget.style.transition = motionTransition(
      ["opacity", "scale"],
      { duration: "base", easing: "exit" }
    )
  }

  clearHideTimeout() {
    if (!this.hideTimeout) return

    clearTimeout(this.hideTimeout)
    this.hideTimeout = null
  }
}
