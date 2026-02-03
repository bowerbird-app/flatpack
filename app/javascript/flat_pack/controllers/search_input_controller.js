// FlatPack Search Input Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "clearButton"]

  connect() {
    this.toggleClearButton()
  }

  clear(event) {
    event.preventDefault()
    this.inputTarget.value = ""
    this.inputTarget.focus()
    this.toggleClearButton()
    
    // Dispatch input event to notify any listeners
    this.inputTarget.dispatchEvent(new Event("input", { bubbles: true }))
  }

  toggleClearButton() {
    // Use optional target accessor to avoid errors if clearButton doesn't exist
    if (!this.hasClearButtonTarget) return
    
    const hasValue = this.inputTarget.value.length > 0
    
    if (hasValue) {
      this.clearButtonTarget.classList.remove("hidden")
    } else {
      this.clearButtonTarget.classList.add("hidden")
    }
  }
}
