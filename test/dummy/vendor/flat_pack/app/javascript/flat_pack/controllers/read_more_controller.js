import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["line", "body", "toggle"]
  static values = {
    open: { type: Boolean, default: false },
    overflowing: { type: Boolean, default: false },
    moreLabel: String,
    lessLabel: String
  }

  connect() {
    this.resetObserver()

    if (typeof ResizeObserver !== "undefined") {
      this.observer = new ResizeObserver(() => this.measure())
      this.observer.observe(this.bodyTarget)
    }

    this.measure()
    this.syncOpen()
  }

  disconnect() {
    this.resetObserver()
  }

  resetObserver() {
    if (!this.observer) return

    this.observer.disconnect()
    this.observer = null
  }

  toggle() {
    this.openValue = !this.openValue
  }

  openValueChanged() {
    this.syncOpen()
  }

  overflowingValueChanged() {
    this.publish()
  }

  contentOverflows(fullHeight, lineBox, lines) {
    if (!(lineBox > 0) || !(lines > 0)) return false

    return fullHeight - (lineBox * lines) > 1
  }

  measure() {
    if (!this.hasBodyTarget || !this.hasLineTarget) return

    const lines = Number.parseFloat(getComputedStyle(this.element).getPropertyValue("--read-more-lines"))
    const lineBox = Number.parseFloat(getComputedStyle(this.lineTarget).height)
    this.overflowingValue = this.contentOverflows(this.bodyTarget.scrollHeight, lineBox, lines)
    this.publish()
  }

  publish() {
    if (!this.hasToggleTarget) return

    this.toggleTarget.hidden = !this.overflowingValue
  }

  syncOpen() {
    if (!this.hasToggleTarget) return

    this.toggleTarget.setAttribute("aria-expanded", this.openValue ? "true" : "false")
    const label = this.toggleTarget.querySelector("span")
    if (!label) return

    label.textContent = this.openValue ? this.lessLabelValue : this.moreLabelValue
  }
}
