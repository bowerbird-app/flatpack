import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "count"]
  static values = {
    characterCountEnabled: Boolean,
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
}
