// FlatPack Color Swatch Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "swatch"]

  connect() {
    this.defaultInputValue = this.hasInputTarget ? this.inputTarget.value : ""
    this.defaultSwatchColor = this.hasSwatchTarget
      ? this.swatchTarget.style.backgroundColor
      : this.defaultInputValue
    this.update()
  }

  update() {
    if (!this.hasInputTarget) return

    const value = this.inputTarget.value
    this.inputTarget.setAttribute("value", value)

    if (this.hasSwatchTarget) {
      this.swatchTarget.style.backgroundColor = value
    }

    this.#dispatchChange(value)
  }

  reset(event) {
    event?.preventDefault?.()

    const override = this.#overrideColor(event)
    if (this.hasInputTarget) {
      this.inputTarget.value = override || this.defaultInputValue
    }

    this.update()

    if (!override && this.hasSwatchTarget) {
      this.swatchTarget.style.backgroundColor = this.defaultSwatchColor
    }
  }

  clear(event) {
    this.reset(event)
  }

  #overrideColor(event) {
    const value = event?.detail?.value
    if (typeof value !== "string") return null

    const trimmed = value.trim()
    return trimmed === "" ? null : trimmed
  }

  #dispatchChange(value) {
    this.element.dispatchEvent(
      new CustomEvent("color-swatch:change", {
        detail: { value },
        bubbles: true
      })
    )
  }
}
