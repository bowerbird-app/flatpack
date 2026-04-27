// FlatPack Alert Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["alert"]

  dismiss() {
    // Fade out animation
    this.alertTarget.style.transition = "opacity 300ms ease-out, transform 300ms ease-out"
    this.alertTarget.style.opacity = "0"
    this.alertTarget.style.transform = "translateY(-10px)"

    // Remove from DOM after animation
    setTimeout(() => {
      // Emit custom event
      const event = new CustomEvent("alert:dismissed", {
        bubbles: true,
        detail: { element: this.alertTarget }
      })
      this.element.dispatchEvent(event)

      // Remove element
      this.element.remove()
    }, 300)
  }
}
