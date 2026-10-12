import { Controller } from "@hotwired/stimulus"
import { flatPackCopy } from "flat_pack/copy"

export default class extends Controller {
  static targets = ["input", "toggle", "eyeIcon", "eyeOffIcon"]

  toggle(event) {
    event.preventDefault()

    const showing = this.inputTarget.type === "password"
    this.inputTarget.type = showing ? "text" : "password"
    this.toggleTarget.setAttribute("aria-pressed", showing ? "true" : "false")
    this.toggleTarget.setAttribute("aria-label", showing ? flatPackCopy("password.hide") : flatPackCopy("password.show"))
  }
}
