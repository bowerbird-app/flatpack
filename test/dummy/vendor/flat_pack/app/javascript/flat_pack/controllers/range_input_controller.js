// FlatPack Range Input Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "valueDisplay"]

  connect() {
    this.update()
  }

  update() {
    const value = this.inputTarget.value

    // Keep the HTML attribute in sync with the live property value.
    // This ensures devtools/form markup reflects the current slider position.
    this.inputTarget.setAttribute("value", value)

    if (this.hasValueDisplayTarget) {
      this.valueDisplayTarget.textContent = value
    }

    // Update aria-valuenow
    this.inputTarget.setAttribute("aria-valuenow", value)

    this.updateFill()

    // Dispatch custom event for external listeners
    this.element.dispatchEvent(
      new CustomEvent("range-input:change", {
        detail: { value: parseFloat(value) },
        bubbles: true
      })
    )
  }

  updateFill() {
    const input = this.inputTarget
    const min = Number(input.min)
    const max = Number(input.max)
    const value = Number(input.value)
    const span = max - min
    const percent = span <= 0 ? 0 : ((value - min) / span) * 100
    const clamped = Math.min(100, Math.max(0, percent))

    input.style.setProperty("--range-progress", `${clamped}%`)
  }
}
