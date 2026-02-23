// FlatPack Text Area Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textarea", "count"]
  static values = {
    characterCountEnabled: Boolean,
    minCharacters: Number,
    maxCharacters: Number
  }

  connect() {
    // Auto-expand on initial load only when visible.
    // Hidden containers (e.g. closed modal) report incorrect scrollHeight,
    // which can set a clipped inline height.
    if (!this.#isVisible(this.textareaTarget)) {
      this.textareaTarget.style.height = ""
      this.updateCharacterCount()
      return
    }

    this.autoExpand()
    this.updateCharacterCount()
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

  updateCharacterCount() {
    if (!this.characterCountEnabledValue || !this.hasCountTarget) return

    const count = this.textareaTarget.value.length
    const hasMax = this.hasMaxCharactersValue
    const belowMin = this.hasMinCharactersValue && count < this.minCharactersValue
    const aboveMax = hasMax && count > this.maxCharactersValue

    this.countTarget.textContent = hasMax
      ? `${count}/${this.maxCharactersValue} characters`
      : `${count} characters`

    this.countTarget.classList.toggle("text-[var(--color-warning-border)]", belowMin || aboveMax)
    this.countTarget.classList.toggle("text-[var(--surface-muted-content-color)]", !(belowMin || aboveMax))
  }

  #isVisible(element) {
    return !!(element.offsetParent || element.getClientRects().length)
  }
}
