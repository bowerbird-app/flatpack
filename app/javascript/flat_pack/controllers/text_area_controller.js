// FlatPack Text Area Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textarea"]

  connect() {
    // Auto-expand on initial load only when visible.
    // Hidden containers (e.g. closed modal) report incorrect scrollHeight,
    // which can set a clipped inline height.
    if (!this.#isVisible(this.textareaTarget)) {
      this.textareaTarget.style.height = ""
      return
    }

    this.autoExpand()
  }

  autoExpand() {
    const textarea = this.textareaTarget

    if (!this.#isVisible(textarea)) {
      textarea.style.height = ""
      return
    }
    
    // Reset height to auto to get the correct scrollHeight
    textarea.style.height = "auto"
    
    // Set the height to match the content
    textarea.style.height = `${textarea.scrollHeight}px`
  }

  #isVisible(element) {
    return !!(element.offsetParent || element.getClientRects().length)
  }
}
