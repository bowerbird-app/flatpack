import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["swatch"]

  reset() {
    this.swatchTarget.dispatchEvent(new CustomEvent("font-swatch:reset", {bubbles: true}))
  }
}
