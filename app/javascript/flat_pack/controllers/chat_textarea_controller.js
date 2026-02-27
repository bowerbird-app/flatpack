// FlatPack Chat Textarea Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textarea"]
  static values = {
    autogrow: { type: Boolean, default: true },
    submitOnEnter: { type: Boolean, default: true }
  }

  connect() {
    if (this.autogrowValue) {
      this.autoExpand()
    }
  }

  autoExpand() {
    if (!this.hasTextareaTarget || !this.autogrowValue) {
      return
    }

    const textarea = this.textareaTarget

    // Reset height to auto to get the correct scrollHeight
    textarea.style.height = "auto"

    const computedStyle = window.getComputedStyle(textarea)
    const minHeight = parseFloat(computedStyle.minHeight) || 0
    const borderHeight = textarea.offsetHeight - textarea.clientHeight
    const targetHeight = textarea.scrollHeight + borderHeight

    // Ensure baseline control height is preserved before/without focus
    textarea.style.height = `${Math.max(targetHeight, minHeight)}px`
  }

  handleKeydown(event) {
    if (!this.submitOnEnterValue) {
      return
    }

    // Submit on Enter, but allow Shift+Enter for newlines
    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault()
      this.submitForm()
    }
  }

  submitForm() {
    // Find the closest form and submit it
    const form = this.textareaTarget.closest("form")
    if (form) {
      form.requestSubmit()
    }
  }

  clear() {
    if (this.hasTextareaTarget) {
      this.textareaTarget.value = ""
      this.autoExpand()
    }
  }
}
