// FlatPack Text Area Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["textarea", "count", "copyButton"]
  static values = {
    autogrow: { type: Boolean, default: true },
    submitOnEnter: { type: Boolean, default: false },
    characterCountEnabled: Boolean,
    quickCopyEnabled: Boolean,
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

    if (this.autogrowValue) {
      this.autoExpand()
    } else {
      this.textareaTarget.style.height = ""
    }

    this.updateCharacterCount()
  }

  autoExpand() {
    if (!this.autogrowValue) {
      this.textareaTarget.style.height = ""
      return
    }

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

  handleKeydown(event) {
    if (!this.submitOnEnterValue) {
      return
    }

    if (event.key === "Enter" && !event.shiftKey) {
      event.preventDefault()
      this.submitForm()
    }
  }

  submitForm() {
    const form = this.textareaTarget.closest("form")
    if (form) {
      form.requestSubmit()
    }
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

  async copyFromTextarea() {
    if (!this.quickCopyEnabledValue || !this.hasTextareaTarget || this.textareaTarget.disabled) return

    await this.copyTextareaValue()
  }

  async copyFromButton(event) {
    event.preventDefault()
    if (!this.quickCopyEnabledValue || !this.hasTextareaTarget || this.textareaTarget.disabled) return

    await this.copyTextareaValue()
  }

  async copyTextareaValue() {
    const value = this.textareaTarget.value || ""

    if (!value.length) {
      this.dispatchToast("warning", "Nothing to copy")
      return
    }

    const copied = await this.writeText(value)
    if (copied) {
      this.dispatchToast("success", "Copied to clipboard")
      return
    }

    this.dispatchToast("danger", "Unable to copy")
  }

  async writeText(text) {
    if (navigator.clipboard?.writeText) {
      try {
        await navigator.clipboard.writeText(text)
        return true
      } catch {
      }
    }

    const input = document.createElement("input")
    input.value = text
    input.style.position = "fixed"
    input.style.opacity = "0"

    document.body.appendChild(input)
    input.select()
    const copied = document.execCommand("copy")
    input.remove()

    return copied
  }

  dispatchToast(style, text) {
    document.dispatchEvent(new CustomEvent("toast:add", {
      detail: {
        style,
        text,
        timeout: 3000
      }
    }))
  }

  #isVisible(element) {
    return !!(element.offsetParent || element.getClientRects().length)
  }
}
