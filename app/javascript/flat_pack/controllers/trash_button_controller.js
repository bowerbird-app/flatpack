import { Controller } from "@hotwired/stimulus"
import { prefersReducedMotion, motionTransition } from "controllers/flat_pack/reduced_motion"

const CONFIRM_GUARD_MS = 300

export default class extends Controller {
  static targets = ["arm", "confirm", "cancel", "rest", "armed", "cancelSlot", "live", "primary", "form"]
  static values = {
    armed: { type: Boolean, default: false },
    timeout: { type: Number, default: 4000 },
    expand: { type: String, default: "right" },
    armedAnnouncement: { type: String, default: "" },
    restoredAnnouncement: { type: String, default: "" }
  }

  initialize() {
    this.boundPointerDown = this.onDocumentPointerDown.bind(this)
    this.boundKeyDown = this.onDocumentKeyDown.bind(this)
    this.confirmBlocked = false
  }

  disconnect() {
    this.clearRevertTimer()
    this.clearConfirmGuard()
    this.removeDocumentListeners()
    this.clearWidthAnimation()
  }

  arm(event) {
    event?.preventDefault()
    event?.stopPropagation()
    if (this.armedValue) return

    this.focusAfterSync = true
    this.armedValue = true
  }

  cancel(event) {
    event?.preventDefault()
    this.disarm({ focus: true })
  }

  confirm(event) {
    if (!this.armedValue || this.confirmBlocked) {
      event?.preventDefault()
      return
    }

    const confirmEvent = new CustomEvent("flat-pack:trash-button:confirm", {
      bubbles: true,
      cancelable: true,
      detail: {
        url: this.formUrl(),
        method: this.formMethod()
      }
    })
    this.element.dispatchEvent(confirmEvent)

    if (confirmEvent.defaultPrevented) {
      event?.preventDefault()
    }
  }

  armedValueChanged(armed, previous) {
    if (!this.hasArmTarget) return

    const isInitial = previous === undefined
    const focus = isInitial ? false : this.focusAfterSync !== false
    this.focusAfterSync = undefined
    this.syncArmed({ focus, announce: !isInitial })
  }

  disarm({ focus = true } = {}) {
    if (!this.armedValue) return

    this.focusAfterSync = focus
    this.armedValue = false
  }

  syncArmed({ focus = false, announce = true } = {}) {
    const armed = this.armedValue
    const primary = this.hasPrimaryTarget ? this.primaryTarget : null
    const startWidth = primary ? primary.offsetWidth : null

    this.element.setAttribute("data-fp-armed", armed ? "true" : "false")
    this.toggleInert(this.restTarget, armed)
    this.toggleInert(this.armedTarget, !armed)
    this.toggleInert(this.cancelSlotTarget, !armed)
    this.armTarget.setAttribute("aria-expanded", armed ? "true" : "false")

    if (primary && startWidth != null) {
      this.animateWidth(primary, startWidth)
    }

    if (focus) {
      const target = armed ? this.confirmTarget : this.armTarget
      target?.focus?.()
    }

    if (announce) {
      this.announce(armed ? this.armedAnnouncementValue : this.restoredAnnouncementValue)
    }

    this.clearRevertTimer()
    this.removeDocumentListeners()

    if (armed) {
      this.blockConfirmTemporarily()
      this.startRevertTimer()
      this.queueDocumentListeners()
    } else {
      this.confirmBlocked = false
      this.confirmTarget?.removeAttribute("aria-disabled")
    }
  }

  animateWidth(element, startWidth) {
    const endWidth = element.offsetWidth
    this.clearWidthAnimation()

    if (prefersReducedMotion() || startWidth === endWidth) {
      element.style.width = ""
      element.style.transition = ""
      return
    }

    element.style.width = `${startWidth}px`
    element.style.transition = "none"
    element.getBoundingClientRect()
    element.style.transition = motionTransition("width", { duration: "base", easing: "standard" })
    element.style.width = `${endWidth}px`

    this.widthElement = element
    this.widthHandler = (event) => {
      if (event.propertyName && event.propertyName !== "width") return

      this.clearWidthAnimation()
    }
    element.addEventListener("transitionend", this.widthHandler)
  }

  clearWidthAnimation() {
    if (this.widthElement && this.widthHandler) {
      this.widthElement.removeEventListener("transitionend", this.widthHandler)
    }
    if (this.widthElement) {
      this.widthElement.style.width = ""
      this.widthElement.style.transition = ""
    }
    this.widthElement = null
    this.widthHandler = null
  }

  blockConfirmTemporarily() {
    this.confirmBlocked = true
    this.confirmTarget?.setAttribute("aria-disabled", "true")
    this.clearConfirmGuard()
    this.confirmGuardTimer = globalThis.setTimeout(() => {
      this.confirmBlocked = false
      this.confirmTarget?.removeAttribute("aria-disabled")
      this.confirmGuardTimer = null
    }, CONFIRM_GUARD_MS)
  }

  startRevertTimer() {
    if (!this.timeoutValue) return

    this.revertTimer = globalThis.setTimeout(() => {
      this.disarm({ focus: true })
    }, this.timeoutValue)
  }

  queueDocumentListeners() {
    this.listenerFrame = globalThis.requestAnimationFrame(() => {
      this.listenerFrame = null
      this.addDocumentListeners()
    })
  }

  addDocumentListeners() {
    document.addEventListener("pointerdown", this.boundPointerDown)
    document.addEventListener("keydown", this.boundKeyDown)
  }

  removeDocumentListeners() {
    if (this.listenerFrame) {
      globalThis.cancelAnimationFrame(this.listenerFrame)
      this.listenerFrame = null
    }
    document.removeEventListener("pointerdown", this.boundPointerDown)
    document.removeEventListener("keydown", this.boundKeyDown)
  }

  onDocumentPointerDown(event) {
    if (!this.armedValue) return
    if (this.element.contains(event.target)) return

    this.disarm({ focus: true })
  }

  onDocumentKeyDown(event) {
    if (!this.armedValue) return
    if (event.key !== "Escape") return

    event.preventDefault()
    this.disarm({ focus: true })
  }

  announce(message) {
    if (!this.hasLiveTarget || !message) return

    this.liveTarget.textContent = ""
    globalThis.requestAnimationFrame(() => {
      this.liveTarget.textContent = message
    })
  }

  toggleInert(element, inert) {
    if (!element) return

    if (inert) {
      element.setAttribute("inert", "")
    } else {
      element.removeAttribute("inert")
    }
  }

  formUrl() {
    if (!this.hasFormTarget) return null

    return this.formTarget.getAttribute("action")
  }

  formMethod() {
    if (!this.hasFormTarget) return null

    const override = this.formTarget.querySelector("input[name='_method']")
    if (override?.value) return override.value

    return this.formTarget.getAttribute("method") || "post"
  }

  clearRevertTimer() {
    if (!this.revertTimer) return

    globalThis.clearTimeout(this.revertTimer)
    this.revertTimer = null
  }

  clearConfirmGuard() {
    if (!this.confirmGuardTimer) return

    globalThis.clearTimeout(this.confirmGuardTimer)
    this.confirmGuardTimer = null
  }
}
