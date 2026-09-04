// FlatPack Badge Stimulus Controller
import { Controller } from "@hotwired/stimulus"
import { prefersReducedMotion, motionDuration, motionTransition } from "controllers/flat_pack/reduced_motion"

export default class extends Controller {
  static targets = ["badge"]

  remove() {
    const finish = () => {
      const event = new CustomEvent("badge:removed", {
        bubbles: true,
        detail: { element: this.badgeTarget }
      })
      this.element.dispatchEvent(event)
      this.element.remove()
    }

    if (prefersReducedMotion()) {
      finish()
      return
    }

    this.badgeTarget.style.transition = motionTransition(
      ["opacity", "transform"],
      { duration: "base", easing: "exit" }
    )
    this.badgeTarget.style.opacity = "0"
    this.badgeTarget.style.transform = "scale(0.8)"

    setTimeout(finish, motionDuration("base"))
  }
}
