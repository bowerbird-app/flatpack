// FlatPack Password Input Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "toggle", "eyeIcon", "eyeOffIcon"]

  toggle(event) {
    event.preventDefault()
    
    const input = this.inputTarget
    const isPassword = input.type === "password"
    
    // Toggle input type
    input.type = isPassword ? "text" : "password"
    
    // Toggle icon visibility
    if (isPassword) {
      this.eyeIconTarget.classList.add("hidden")
      this.eyeOffIconTarget.classList.remove("hidden")
    } else {
      this.eyeIconTarget.classList.remove("hidden")
      this.eyeOffIconTarget.classList.add("hidden")
    }
  }
}
