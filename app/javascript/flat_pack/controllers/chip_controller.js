// FlatPack Chip Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["chip"]
  static values = { value: String }

  remove() {
    // Fade out animation
    this.chipTarget.style.transition = "opacity 200ms ease-out, transform 200ms ease-out"
    this.chipTarget.style.opacity = "0"
    this.chipTarget.style.transform = "scale(0.8)"

    // Remove from DOM after animation
    setTimeout(() => {
      // Emit custom event
      const event = new CustomEvent("chip:removed", {
        bubbles: true,
        detail: { 
          value: this.valueValue,
          element: this.chipTarget 
        }
      })
      this.element.dispatchEvent(event)

      // Remove element
      this.element.remove()
    }, 200)
  }

  toggle(event) {
    // Toggle aria-pressed
    const currentPressed = this.element.getAttribute("aria-pressed") === "true"
    const newPressed = !currentPressed
    this.element.setAttribute("aria-pressed", String(newPressed))

    // Toggle selected class (ring-2 ring-[var(--color-ring)])
    this.element.classList.toggle("ring-2")
    this.element.classList.toggle("ring-[var(--color-ring)]")

    // Emit chip:toggled event
    const toggleEvent = new CustomEvent("chip:toggled", {
      bubbles: true,
      detail: {
        value: this.valueValue,
        selected: newPressed,
        element: this.element
      }
    })
    this.element.dispatchEvent(toggleEvent)
  }
}
