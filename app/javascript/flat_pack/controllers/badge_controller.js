// FlatPack Badge Stimulus Controller
import { Controller } from "@hotwired/stimulus"
import { playCollapseExit } from "controllers/flat_pack/reduced_motion"

export default class extends Controller {
  static targets = ["badge"]

  remove() {
    playCollapseExit(this.badgeTarget, {
      axis: "both",
      onHidden: () => {
        const event = new CustomEvent("badge:removed", {
          bubbles: true,
          detail: { element: this.badgeTarget }
        })
        this.element.dispatchEvent(event)
        this.element.remove()
      }
    })
  }
}
