import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["empty", "content"]

  showContent() {
    if (!this.hasEmptyTarget || !this.hasContentTarget) return

    this.emptyTarget.hidden = true
    this.contentTarget.hidden = false
    this.replayEnter(this.contentTarget, "fp-content-enter")
  }

  showEmpty() {
    if (!this.hasEmptyTarget || !this.hasContentTarget) return

    this.contentTarget.hidden = true
    this.emptyTarget.hidden = false
    const emptyPanel = this.emptyTarget.querySelector(".fp-empty-state") || this.emptyTarget
    this.replayEnter(emptyPanel, "fp-empty-state")
  }

  replayEnter(element, enterClass) {
    element.classList.remove(enterClass)
    void element.offsetWidth
    element.classList.add(enterClass)
  }
}
