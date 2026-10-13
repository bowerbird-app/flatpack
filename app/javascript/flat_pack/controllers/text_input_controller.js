import { Controller } from "@hotwired/stimulus"
import { flatPackCopy } from "flat_pack/copy"

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
      ? flatPackCopy("text.characters_with_limit", {count, limit: this.maxCharactersValue})
      : flatPackCopy("text.characters", {count})

    this.countTarget.classList.toggle("text-[var(--color-warning-border)]", belowMin || aboveMax)
    this.countTarget.classList.toggle("text-[var(--surface-muted-content-color)]", !(belowMin || aboveMax))
  }
}
