import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  toggle(event) {
    if (this.finePointer()) return
    if (event.target.closest("button, a, input, textarea, select")) return

    this.element.classList.toggle("is-open")
  }

  finePointer() {
    return window.matchMedia("(hover: hover) and (pointer: fine)").matches
  }
}
