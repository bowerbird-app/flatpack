// FlatPack Color Swatch Stimulus Controller
import { Controller } from "@hotwired/stimulus"

const HEX = /^#[0-9a-f]{6}$/i

export default class extends Controller {
  static targets = ["input", "swatch"]
  static values = {color: String}
  #ignoringInputEvents = false

  connect() {
    this.update()
  }

  update(event) {
    if (this.#ignoringInputEvents && event) return
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
    if (!this.hasInputTarget) return

    const next = this.#resetColor(event)
    this.inputTarget.value = next
    // input and change actions also call update. Skip that re-entry.
    this.#ignoringInputEvents = true
    try {
      this.update()
      this.inputTarget.dispatchEvent(new Event("input", {bubbles: true}))
      this.inputTarget.dispatchEvent(new Event("change", {bubbles: true}))
    } finally {
      this.#ignoringInputEvents = false
    }
  }

  #resetColor(event) {
    const override = event?.detail?.value
    if (override == null || (typeof override === "string" && override.trim() === "")) {
      return this.#requireHex(this.colorValue, "reset colour")
    }

    return this.#requireHex(override, "reset colour")
  }

  #requireHex(value, label) {
    if (typeof value !== "string" || !HEX.test(value.trim())) {
      throw new Error(`Color swatch ${label} must be #rrggbb, got ${JSON.stringify(value)}.`)
    }

    return value.trim().toLowerCase()
  }

  #dispatchChange(value) {
    this.element.dispatchEvent(
      new CustomEvent("color-swatch:change", {
        detail: {value},
        bubbles: true
      })
    )
  }
}
