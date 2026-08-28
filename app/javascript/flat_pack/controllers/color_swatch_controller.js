// FlatPack Color Swatch Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "swatch", "preview", "hex"]

  connect() {
    this.update()
  }

  update() {
    if (!this.hasInputTarget) return

    const value = this.inputTarget.value
    this.inputTarget.setAttribute("value", value)

    if (this.hasSwatchTarget) {
      this.swatchTarget.style.backgroundColor = value
    }

    if (this.hasPreviewTarget) {
      this.previewTarget.style.backgroundColor = value
    }

    if (this.hasHexTarget) {
      this.hexTarget.textContent = value.toUpperCase()
    }

    this.element.dispatchEvent(
      new CustomEvent("color-swatch:change", {
        detail: { value },
        bubbles: true
      })
    )
  }
}
