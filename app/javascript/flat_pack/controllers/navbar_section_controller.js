import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["content", "chevron"]
  static values = {
    collapsed: Boolean
  }

  connect() {
    this.updateVisibility()
  }

  toggle() {
    this.collapsedValue = !this.collapsedValue
    this.updateVisibility()
  }

  collapsedValueChanged() {
    this.updateVisibility()
  }

  updateVisibility() {
    if (!this.hasContentTarget) return

    if (this.collapsedValue) {
      this.contentTarget.style.display = "none"
      if (this.hasChevronTarget) {
        this.chevronTarget.style.transform = "rotate(-90deg)"
      }
    } else {
      this.contentTarget.style.display = "block"
      if (this.hasChevronTarget) {
        this.chevronTarget.style.transform = "rotate(0deg)"
      }
    }
  }
}
