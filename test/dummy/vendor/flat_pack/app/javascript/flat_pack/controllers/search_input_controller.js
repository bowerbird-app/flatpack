// FlatPack Search Input Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "clearButton"]
  static values = {
    submitOnClear: { type: Boolean, default: false }
  }

  connect() {
    this.toggleClearButton()
  }

  clear(event) {
    event.preventDefault()
    this.inputTarget.value = ""
    this.inputTarget.focus()
    this.toggleClearButton()
    this.inputTarget.dispatchEvent(new Event("input", { bubbles: true }))

    if (this.submitOnClearValue) {
      this.inputTarget.form?.requestSubmit()
    }
  }

  toggleClearButton() {
    if (!this.hasClearButtonTarget) return

    const hasValue = this.inputTarget.value.length > 0

    if (hasValue) {
      this.clearButtonTarget.classList.remove("hidden")
    } else {
      this.clearButtonTarget.classList.add("hidden")
    }
  }
}
