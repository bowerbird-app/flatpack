// FlatPack Range Input Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "valueDisplay"]

  connect() {
    this.update()
  }

  update() {
    const value = this.inputTarget.value
    
    if (this.hasValueDisplayTarget) {
      this.valueDisplayTarget.textContent = value
    }

    // Update aria-valuenow
    this.inputTarget.setAttribute("aria-valuenow", value)

    // Dispatch custom event for external listeners
    this.element.dispatchEvent(
      new CustomEvent("range-input:change", {
        detail: { value: parseFloat(value) },
        bubbles: true
      })
    )
  }
}
