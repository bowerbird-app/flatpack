// FlatPack Collapse Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["trigger", "content", "icon"]
  static values = {
    open: { type: Boolean, default: false }
  }

  connect() {
    this.updateState(this.openValue)
  }

  toggle(event) {
    event.preventDefault()
    this.openValue = !this.openValue
    this.updateState(this.openValue)
  }

  updateState(isOpen) {
    const content = this.contentTarget
    const trigger = this.triggerTarget
    const icon = this.hasIconTarget ? this.iconTarget : null

    // Update aria-expanded
    trigger.setAttribute("aria-expanded", isOpen)

    // Toggle content visibility
    if (isOpen) {
      content.hidden = false
      // Animate expansion
      requestAnimationFrame(() => {
        content.style.maxHeight = content.scrollHeight + "px"
      })
    } else {
      content.style.maxHeight = "0px"
      setTimeout(() => {
        content.hidden = true
      }, 300)
    }

    // Rotate icon
    if (icon) {
      if (isOpen) {
        icon.style.transform = "rotate(180deg)"
      } else {
        icon.style.transform = "rotate(0deg)"
      }
    }
  }
}
