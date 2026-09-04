// FlatPack Toast Stimulus Controller
import { Controller } from "@hotwired/stimulus"
import { prefersReducedMotion, motionDuration } from "controllers/flat_pack/reduced_motion"

export default class extends Controller {
  static values = {
    timeout: { type: Number, default: 5000 },
    dismissible: { type: Boolean, default: true }
  }

  connect() {
    this.element.style.pointerEvents = "auto"
    this.show()

    if (this.timeoutValue > 0) {
      this.autoDismissTimer = setTimeout(() => {
        this.dismiss()
      }, this.timeoutValue)
    }
  }

  disconnect() {
    if (this.autoDismissTimer) {
      clearTimeout(this.autoDismissTimer)
    }
  }

  show() {
    if (prefersReducedMotion()) {
      this.element.style.opacity = "1"
      this.element.style.transform = "none"
      return
    }

    this.element.style.transform = "translateX(100%)"
    this.element.style.opacity = "0"
    this.element.offsetHeight

    requestAnimationFrame(() => {
      this.element.style.transition = "transform var(--duration-slow), opacity var(--duration-slow)"
      this.element.style.transform = "translateX(0)"
      this.element.style.opacity = "1"
    })
  }

  dismiss() {
    if (this.autoDismissTimer) {
      clearTimeout(this.autoDismissTimer)
    }

    const remove = () => this.element.remove()

    if (prefersReducedMotion()) {
      remove()
      return
    }

    this.element.style.transition = "transform var(--duration-base), opacity var(--duration-base)"
    this.element.style.transform = "translateX(100%)"
    this.element.style.opacity = "0"

    setTimeout(remove, motionDuration("base"))
  }

  pauseDismiss() {
    if (this.autoDismissTimer) {
      clearTimeout(this.autoDismissTimer)
      this.autoDismissTimer = null
    }
  }

  resumeDismiss() {
    if (this.timeoutValue > 0 && !this.autoDismissTimer) {
      this.autoDismissTimer = setTimeout(() => {
        this.dismiss()
      }, 1000)
    }
  }
}
