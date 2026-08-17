import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "count", "copyButton"]
  static values = {
    characterCountEnabled: Boolean,
    quickCopyEnabled: Boolean,
    minCharacters: Number,
    maxCharacters: Number
  }

  connect() {
    this.updateCharacterCount()
  }

  updateCharacterCount() {
    if (!this.characterCountEnabledValue || !this.hasCountTarget || !this.hasInputTarget) return

    const count = this.inputTarget.value.length
    const hasMax = this.hasMaxCharactersValue
    const belowMin = this.hasMinCharactersValue && count < this.minCharactersValue
    const aboveMax = hasMax && count > this.maxCharactersValue

    this.countTarget.textContent = hasMax
      ? `${count}/${this.maxCharactersValue} characters`
      : `${count} characters`

    this.countTarget.classList.toggle("text-[var(--color-warning-border)]", belowMin || aboveMax)
    this.countTarget.classList.toggle("text-[var(--surface-muted-content-color)]", !(belowMin || aboveMax))
  }

  async copyFromInput() {
    if (!this.quickCopyEnabledValue || !this.hasInputTarget || this.inputTarget.disabled) return

    await this.copyInputValue()
  }

  async copyFromButton(event) {
    event.preventDefault()
    if (!this.quickCopyEnabledValue || !this.hasInputTarget || this.inputTarget.disabled) return

    await this.copyInputValue()
  }

  async copyInputValue() {
    const value = this.inputTarget.value || ""

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
}
