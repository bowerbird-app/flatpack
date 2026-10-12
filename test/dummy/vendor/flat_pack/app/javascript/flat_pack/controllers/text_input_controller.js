import { Controller } from "@hotwired/stimulus"
import { flatPackCopy } from "flat_pack/copy"

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
      ? flatPackCopy("text.characters_with_limit", {count, limit: this.maxCharactersValue})
      : flatPackCopy("text.characters", {count})

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
      this.dispatchToast("warning", flatPackCopy("clipboard.nothing"))
      return
    }

    const copied = await this.writeText(value)
    if (copied) {
      this.dispatchToast("success", flatPackCopy("clipboard.copied"))
      return
    }

    this.dispatchToast("danger", flatPackCopy("clipboard.unable"))
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
