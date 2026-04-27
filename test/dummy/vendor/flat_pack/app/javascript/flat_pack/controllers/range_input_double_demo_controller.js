import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["minInput", "maxInput", "summary", "selection", "minValue", "maxValue"]

  connect() {
    this.sync()
  }

  sync(event) {
    if (!this.hasMinInputTarget || !this.hasMaxInputTarget) return

    let minValue = Number.parseFloat(this.minInputTarget.value)
    let maxValue = Number.parseFloat(this.maxInputTarget.value)
    if (Number.isNaN(minValue) || Number.isNaN(maxValue)) return

    const changedThumb = this.readChangedThumb(event)

    if (minValue > maxValue) {
      if (changedThumb === "max") {
        minValue = maxValue
        this.syncInput(this.minInputTarget, minValue)
      } else {
        maxValue = minValue
        this.syncInput(this.maxInputTarget, maxValue)
      }
    }

    this.syncInput(this.minInputTarget, minValue)
    this.syncInput(this.maxInputTarget, maxValue)

    this.updateSummary(minValue, maxValue)
    this.updateSelection(minValue, maxValue)
  }

  updateSummary(minValue, maxValue) {
    if (this.hasSummaryTarget) {
      this.summaryTarget.textContent = `$${Math.round(minValue)} - $${Math.round(maxValue)}`
    }

    if (this.hasMinValueTarget) {
      this.minValueTarget.textContent = `Min: $${Math.round(minValue)}`
    }

    if (this.hasMaxValueTarget) {
      this.maxValueTarget.textContent = `Max: $${Math.round(maxValue)}`
    }
  }

  readChangedThumb(event) {
    if (!event?.target) return null
    if (event.target === this.maxInputTarget) return "max"
    if (event.target === this.minInputTarget) return "min"
    return null
  }

  updateSelection(minValue, maxValue) {
    if (!this.hasSelectionTarget) return

    const minBound = Number.parseFloat(this.minInputTarget.min)
    const maxBound = Number.parseFloat(this.maxInputTarget.max)
    const range = maxBound - minBound || 1

    const leftPercent = ((minValue - minBound) / range) * 100
    const rightPercent = ((maxValue - minBound) / range) * 100

    this.selectionTarget.style.left = `${leftPercent}%`
    this.selectionTarget.style.width = `${Math.max(0, rightPercent - leftPercent)}%`
  }

  syncInput(input, value) {
    const nextValue = String(value)
    input.value = nextValue
    input.setAttribute("value", nextValue)
    input.setAttribute("aria-valuenow", nextValue)
  }
}