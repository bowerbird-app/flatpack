// FlatPack Text Area Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textarea"]

  connect() {
    // Auto-expand on initial load if there's content
    this.autoExpand()
  }

  autoExpand() {
    const textarea = this.textareaTarget
    
    // Reset height to auto to get the correct scrollHeight
    textarea.style.height = "auto"
    
    // Set the height to match the content
    textarea.style.height = `${textarea.scrollHeight}px`
  }
}
