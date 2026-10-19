import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["link"]

  show() {
    if (!this.hasLinkTarget) return
    this.linkTarget.style.opacity = "1"
  }

  hide() {
    if (!this.hasLinkTarget) return
    this.linkTarget.style.opacity = "0"
  }
}
