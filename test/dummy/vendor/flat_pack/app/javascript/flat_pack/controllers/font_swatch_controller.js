// FlatPack Font Swatch Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "swatch"]

  connect() {
    this.update()
  }

  update() {
    if (!this.hasSelectTarget) return

    const value = this.selectTarget.value
    const label = this.selectedLabel(value)

    if (this.hasSwatchTarget) {
      this.swatchTarget.style.fontFamily = value
    }

    this.selectTarget.setAttribute("aria-label", label)

    const tooltip = this.element.querySelector('[role="tooltip"]')
    if (tooltip) {
      tooltip.textContent = label
    }

    this.element.dispatchEvent(
      new CustomEvent("font-swatch:change", {
        detail: { value, label },
        bubbles: true
      })
    )
  }

  selectedLabel(value) {
    const option = this.selectTarget.selectedOptions?.[0]
    const label = option?.textContent?.trim()
    return label || value || "Font"
  }
}
