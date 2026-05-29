import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    delay: { type: Number, default: 300 }
  }

  connect() {
    this.timeoutId = null
  }

  disconnect() {
    this.clearTimer()
  }

  queueSubmit() {
    this.clearTimer()
    this.timeoutId = setTimeout(() => {
      this.submitNow()
    }, this.delayValue)
  }

  submitNow() {
    this.clearTimer()

    if (this.element.requestSubmit) {
      this.element.requestSubmit()
      return
    }

    this.element.submit()
  }

  clearTimer() {
    if (this.timeoutId) {
      clearTimeout(this.timeoutId)
      this.timeoutId = null
    }
  }
}
