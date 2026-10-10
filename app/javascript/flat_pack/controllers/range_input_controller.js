// FlatPack Range Input Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "valueDisplay", "preview"]
  static values = {
    previewSelector: String
  }

  connect() {
    this.update()
  }

  update() {
    const value = this.inputTarget.value

    // Keep the HTML attribute in sync with the live property value.
    // This ensures devtools/form markup reflects the current slider position.
    this.inputTarget.setAttribute("value", value)

    if (this.hasValueDisplayTarget) {
      this.valueDisplayTarget.textContent = value
    }

    // Update aria-valuenow
    this.inputTarget.setAttribute("aria-valuenow", value)

    this.updateFill()
    this.updatePreview(value)

    // Dispatch custom event for external listeners
    this.element.dispatchEvent(
      new CustomEvent("range-input:change", {
        detail: { value: parseFloat(value) },
        bubbles: true
      })
    )
  }

  updateFill() {
    const input = this.inputTarget
    const min = Number(input.min)
    const max = Number(input.max)
    const value = Number(input.value)
    const span = max - min
    const percent = span <= 0 ? 0 : ((value - min) / span) * 100
    const clamped = Math.min(100, Math.max(0, percent))

    input.style.setProperty("--range-progress", `${clamped}%`)
  }

  updatePreview(value) {
    if (!this.hasPreviewTarget && !this.previewSelectorPresent()) {
      return
    }

    const numeric = Number.parseFloat(value)
    const min = Number(this.inputTarget.min)
    const max = Number(this.inputTarget.max)
    const span = max - min
    const scale = span <= 0 ? 0 : Math.min(1, Math.max(0, (numeric - min) / span))

    this.previewElements().forEach((element) => {
      element.style.setProperty("--fp-range-value", String(numeric))
      element.style.setProperty("--fp-range-scale", String(scale))
    })
  }

  previewSelectorPresent() {
    return this.hasPreviewSelectorValue && Boolean(this.previewSelectorValue)
  }

  previewElements() {
    const elements = []

    if (this.hasPreviewTarget) {
      this.previewTargets.forEach((element) => elements.push(element))
    }

    if (!this.previewSelectorPresent() || typeof document === "undefined") {
      return elements
    }

    try {
      document.querySelectorAll(this.previewSelectorValue).forEach((element) => {
        elements.push(element)
      })
    } catch (_error) {
      // Ignore invalid selectors from hosts.
    }

    return elements
  }
}
