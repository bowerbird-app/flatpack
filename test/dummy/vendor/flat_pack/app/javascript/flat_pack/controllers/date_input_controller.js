// FlatPack Date Input Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.openPicker = this.openPicker.bind(this)
    this.element.addEventListener("click", this.openPicker)
    this.element.addEventListener("focus", this.openPicker)
  }

  disconnect() {
    this.element.removeEventListener("click", this.openPicker)
    this.element.removeEventListener("focus", this.openPicker)
  }

  openPicker() {
    if (this.element.disabled || this.element.readOnly) return
    if (typeof this.element.showPicker !== "function") return

    try {
      this.element.showPicker()
    } catch (_error) {
      // Some browsers require strict user gestures; ignore if blocked.
    }
  }
}