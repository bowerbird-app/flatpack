import { Controller } from "@hotwired/stimulus"
import { motionDuration, motionTransition } from "controllers/flat_pack/reduced_motion"

export default class extends Controller {
  static targets = ["panel", "button", "chevron"]
  static values = { open: Boolean }

  connect() {
    this.isOpen = this.openValue
    this.disableTransitions()
    this.applyState({ animate: false })
  }

  disconnect() {
    this.clearTimer()
  }

  toggle(event) {
    event.preventDefault()
    this.isOpen = !this.isOpen
    this.applyState({ animate: true })
  }

  applyState({ animate }) {
    this.element.dataset.open = this.isOpen ? "true" : "false"
    if (animate) this.enableTransitions()

    if (this.hasButtonTarget) {
      this.buttonTarget.setAttribute("aria-expanded", this.isOpen ? "true" : "false")
    }

    if (this.hasChevronTarget) {
      this.chevronTarget.style.transform = this.isOpen ? "rotate(0deg)" : "rotate(-90deg)"
    }

    if (!this.hasPanelTarget) return

    if (this.isOpen) {
      this.expand(animate)
    } else {
      this.collapse(animate)
    }
  }

  expand(animate) {
    const panel = this.panelTarget
    this.clearTimer()
    panel.hidden = false

    if (!animate) {
      panel.style.maxHeight = "none"
      return
    }

    panel.style.maxHeight = "none"
    const height = panel.scrollHeight
    panel.style.maxHeight = "0px"
    panel.offsetHeight
    panel.style.maxHeight = `${height}px`
    this.heightTimer = window.setTimeout(() => {
      if (this.isOpen) panel.style.maxHeight = "none"
    }, motionDuration("base"))
  }

  collapse(animate) {
    const panel = this.panelTarget
    this.clearTimer()

    if (!animate) {
      panel.style.maxHeight = "0px"
      panel.hidden = true
      return
    }

    panel.hidden = false
    panel.style.maxHeight = `${panel.scrollHeight}px`
    panel.offsetHeight
    panel.style.maxHeight = "0px"
    this.heightTimer = window.setTimeout(() => {
      if (!this.isOpen) panel.hidden = true
    }, motionDuration("base"))
  }

  disableTransitions() {
    if (this.hasPanelTarget) this.panelTarget.style.transition = "none"
    if (this.hasChevronTarget) this.chevronTarget.style.transition = "none"
  }

  enableTransitions() {
    if (this.hasPanelTarget) {
      this.panelTarget.style.transition = motionTransition("max-height", { duration: "base", easing: "standard" })
    }

    if (this.hasChevronTarget) {
      this.chevronTarget.style.transition = motionTransition("transform", { duration: "base", easing: "standard" })
    }
  }

  clearTimer() {
    if (!this.heightTimer) return

    window.clearTimeout(this.heightTimer)
    this.heightTimer = null
  }
}
