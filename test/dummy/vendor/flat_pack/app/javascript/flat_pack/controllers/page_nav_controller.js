import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { fallbackUrl: String }

  back(event) {
    if (this.hasInAppHistory()) {
      event.preventDefault()
      window.history.back()
      return
    }
    if (this.fallbackUrlValue) {
      event.preventDefault()
      window.location.assign(this.fallbackUrlValue)
      return
    }
    event.preventDefault()
    window.history.back()
  }

  hasInAppHistory() {
    if (window.history.length <= 1) return false

    const referrer = document.referrer
    if (!referrer) return true

    try {
      return new URL(referrer).origin === window.location.origin
    } catch {
      return false
    }
  }
}
