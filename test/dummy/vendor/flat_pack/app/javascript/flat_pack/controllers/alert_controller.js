// FlatPack Alert Stimulus Controller
import { Controller } from "@hotwired/stimulus"
import { playCollapseExit } from "controllers/flat_pack/reduced_motion"

export default class extends Controller {
  static targets = ["alert"]

  dismiss() {
    playCollapseExit(this.alertTarget, {
      axis: "block",
      onHidden: () => {
        const event = new CustomEvent("alert:dismissed", {
          bubbles: true,
          detail: { element: this.alertTarget }
        })
        this.element.dispatchEvent(event)
        this.element.remove()
      }
    })
  }
}
