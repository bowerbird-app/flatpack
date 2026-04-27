// FlatPack Badge Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["badge"]

  remove() {
    // Fade out animation
    this.badgeTarget.style.transition = "opacity 200ms ease-out, transform 200ms ease-out"
    this.badgeTarget.style.opacity = "0"
    this.badgeTarget.style.transform = "scale(0.8)"

    // Remove from DOM after animation
    setTimeout(() => {
      // Emit custom event
      const event = new CustomEvent("badge:removed", {
        bubbles: true,
        detail: { element: this.badgeTarget }
      })
      this.element.dispatchEvent(event)

      // Remove element
      this.element.remove()
    }, 200)
  }
}
