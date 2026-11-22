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
import { isBackdropClick } from "flat_pack/click_outside"

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
    this.settleTimer = null
    this.settleListener = null
    this.closing = false
    this.usedTriggerOrigin = false
    this.handleDocumentTriggerClick = this.handleDocumentTriggerClick.bind(this)
    this.handleTurboBeforeCache = this.handleTurboBeforeCache.bind(this)
    document.addEventListener("click", this.handleDocumentTriggerClick)
    document.addEventListener("turbo:before-cache", this.handleTurboBeforeCache)

    if (this.element.classList.contains("hidden")) {
      this.restoreBodyScroll()
    }
  }

  disconnect() {
    document.removeEventListener("click", this.handleDocumentTriggerClick)
    document.removeEventListener("turbo:before-cache", this.handleTurboBeforeCache)
    this.clearHideTimeout()
    this.clearSettle()

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
    this.clearSettle()
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
        this.scheduleSettleEnterMotion()
      })
    } else {
      if (this.hasDialogTarget) {
        this.dialogTarget.classList?.add("scale-95", "motion-reduce:scale-100")
      }
      this.applyEnterMotion()
      this.element.style.opacity = "1"

      requestAnimationFrame(() => {
        if (!this.hasDialogTarget) return

        this.dialogTarget.style.opacity = "1"
        this.dialogTarget.style.scale = prefersReducedMotion() ? "none" : "1"
        this.scheduleSettleEnterMotion()
      })
    }

    setTimeout(() => this.trapFocus(), 100)
  }

  // Close modal. Exit is shorter than enter and uses the accelerate easing.
  close() {
    if (this.element.classList.contains("hidden") || this.closing) return

    this.closing = true
    this.clearHideTimeout()
    this.clearSettle()
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

  // Snapshot a closed dialog. An animated close would still be `flex` when Turbo
  // copies the page, and a leftover lock count would freeze scroll on restore.
  handleTurboBeforeCache() {
    if (this.element.classList.contains("hidden") && !this.closing) return

    this.clearHideTimeout()
    this.clearSettle()

    const holdsLock = !this.closing && this.element.classList.contains("flex")
    this.closing = false
    this.usedTriggerOrigin = false

    if (holdsLock) this.restoreBodyScroll()
    if (this.hasDialogTarget) {
      clearTriggerOriginStyles(this.dialogTarget)
      this.dialogTarget.style.opacity = ""
      this.dialogTarget.style.scale = ""
      this.dialogTarget.style.transition = ""
    }

    this.element.style.opacity = ""
    this.element.style.transition = ""
    this.element.classList.remove("flex")
    this.element.classList.add("hidden")
    this.element.setAttribute("aria-hidden", "true")
    this.restoreFocus()
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
    if (!isBackdropClick(event)) return

    this.close()
  }

  preventBodyScroll() {
    const lockCount = Number(document.body.dataset.flatPackModalLockCount || "0")

    if (lockCount === 0) {
      this.originalOverflow = document.body.style.overflow
      this.originalPaddingRight = document.body.style.paddingRight
      this.originalOverscrollBehavior = document.body.style.overscrollBehavior
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

  scheduleSettleEnterMotion() {
    this.clearSettle()
    if (!this.hasDialogTarget) return
    if (prefersReducedMotion()) {
      this.settleEnterMotion()
      return
    }

    const dialog = this.dialogTarget
    const finish = (event) => {
      if (event && event.target && event.target !== dialog) return
      if (event && !isEnterMotionProperty(event.propertyName)) return

      this.clearSettle()
      this.settleEnterMotion()
    }

    this.settleListener = finish
    dialog.addEventListener("transitionend", finish)
    this.settleTimer = setTimeout(finish, motionDuration("slow") + 50)
  }

  // scale-95 and motion-reduce:scale-100 are only the enter start. Left on,
  // they keep this dialog as the containing block for position: fixed menus.
  settleEnterMotion() {
    if (this.closing || !this.hasDialogTarget) return
    if (this.element.classList.contains("hidden")) return

    const dialog = this.dialogTarget
    dialog.classList?.remove("scale-95", "motion-reduce:scale-100")
    dialog.style.transition = "none"
    clearInlineProperty(dialog.style, "scale")
    clearInlineProperty(dialog.style, "translate")
    clearInlineProperty(dialog.style, "rotate")
    clearInlineProperty(dialog.style, "transform")
    clearInlineProperty(dialog.style, "transform-origin")
    void dialog.offsetHeight
    clearInlineProperty(dialog.style, "transition")
    this.element.style.transition = ""

    if (typeof CustomEvent === "function" && typeof dialog.dispatchEvent === "function") {
      dialog.dispatchEvent(new CustomEvent("flat-pack:overlay-settled", { bubbles: true }))
    }
  }

  clearSettle() {
    if (this.settleTimer) {
      clearTimeout(this.settleTimer)
      this.settleTimer = null
    }

    if (this.settleListener && this.hasDialogTarget) {
      this.dialogTarget.removeEventListener("transitionend", this.settleListener)
    }

    this.settleListener = null
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

const ENTER_MOTION_PROPERTIES = new Set(["scale", "transform", "opacity", "translate", "rotate"])

function isEnterMotionProperty(name) {
  return name == null || name === "" || ENTER_MOTION_PROPERTIES.has(name)
}

function clearInlineProperty(style, property) {
  if (!style) return

  if (typeof style.removeProperty === "function") {
    style.removeProperty(property)
    return
  }

  const key = property.replace(/-([a-z])/g, (_, letter) => letter.toUpperCase())
  style[key] = ""
}
