// FlatPack Color Swatch Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "swatch"]

  connect() {
    this.update()
  }

  update() {
    if (!this.hasInputTarget || !this.hasSwatchTarget) return

    const value = this.inputTarget.value
    this.inputTarget.setAttribute("value", value)
    this.swatchTarget.style.backgroundColor = value

    this.element.dispatchEvent(
      new CustomEvent("color-swatch:change", {
        detail: { value },
        bubbles: true
      })
    )
  }
}
