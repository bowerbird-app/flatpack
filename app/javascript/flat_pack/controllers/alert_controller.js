// FlatPack Alert Stimulus Controller
import { Controller } from "@hotwired/stimulus"
import { prefersReducedMotion, motionDuration } from "controllers/flat_pack/reduced_motion"

export default class extends Controller {
  static targets = ["alert"]

  dismiss() {
    const finish = () => {
      const event = new CustomEvent("alert:dismissed", {
        bubbles: true,
        detail: { element: this.alertTarget }
      })
      this.element.dispatchEvent(event)
      this.element.remove()
    }

    if (prefersReducedMotion()) {
      finish()
      return
    }

    this.alertTarget.style.transition = "opacity var(--duration-slow), transform var(--duration-slow)"
    this.alertTarget.style.opacity = "0"
    this.alertTarget.style.transform = "translateY(-10px)"

    setTimeout(finish, motionDuration("slow"))
  }
}
