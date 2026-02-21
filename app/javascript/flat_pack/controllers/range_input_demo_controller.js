import { Controller } from "@hotwired/stimulus"

// Drives the color preview in the range input interactive demo page.
export default class extends Controller {
  static targets = ["preview", "value"]

  updatePreview() {
    const hue = this.readNumericValue("demo_hue", 200)
    const saturation = this.readNumericValue("demo_saturation", 70)
    const lightness = this.readNumericValue("demo_lightness", 50)
    const color = `hsl(${hue}, ${saturation}%, ${lightness}%)`

    if (this.hasPreviewTarget) {
      this.previewTarget.style.backgroundColor = color
    }

    if (this.hasValueTarget) {
      this.valueTarget.textContent = color
    }
  }

  readNumericValue(id, fallback) {
    const input = document.getElementById(id)
    if (!input) return fallback

    const value = Number.parseFloat(input.value)
    return Number.isNaN(value) ? fallback : value
  }
}