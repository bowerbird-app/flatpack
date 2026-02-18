// FlatPack Tooltip Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tooltip"]
  static values = {
    placement: { type: String, default: "top" }
  }

  connect() {
    this.showTimeout = null
    this.hideTimeout = null
  }

  disconnect() {
    this.clearTimeouts()
  }

  // Show tooltip on mouseenter or focus
  show(event) {
    this.clearTimeouts()
    
    // Small delay before showing
    this.showTimeout = setTimeout(() => {
      if (!this.hasTooltipTarget) return

      this.tooltipTarget.classList.remove("hidden")
      this.position()
      
      // Trigger opacity transition
      requestAnimationFrame(() => {
        this.tooltipTarget.style.opacity = "1"
      })
    }, 200)
  }

  // Hide tooltip on mouseleave or blur
  hide(event) {
    this.clearTimeouts()
    
    if (!this.hasTooltipTarget) return

    this.tooltipTarget.style.opacity = "0"
    
    // Hide after transition
    this.hideTimeout = setTimeout(() => {
      this.tooltipTarget.classList.add("hidden")
    }, 200)
  }

  // Position tooltip based on placement value
  position() {
    if (!this.hasTooltipTarget) return

    const tooltip = this.tooltipTarget
    const trigger = this.element
    const placement = this.placementValue

    // Reset positioning
    tooltip.style.top = ""
    tooltip.style.left = ""
    tooltip.style.right = ""
    tooltip.style.bottom = ""
    tooltip.style.transform = ""

    // Get dimensions
    const triggerRect = trigger.getBoundingClientRect()
    const tooltipRect = tooltip.getBoundingClientRect()
    const spacing = 8 // Gap between trigger and tooltip

    switch (placement) {
      case "top":
        tooltip.style.bottom = "100%"
        tooltip.style.left = "50%"
        tooltip.style.transform = "translateX(-50%)"
        tooltip.style.marginBottom = `${spacing}px`
        break

      case "bottom":
        tooltip.style.top = "100%"
        tooltip.style.left = "50%"
        tooltip.style.transform = "translateX(-50%)"
        tooltip.style.marginTop = `${spacing}px`
        break

      case "left":
        tooltip.style.right = "100%"
        tooltip.style.top = "50%"
        tooltip.style.transform = "translateY(-50%)"
        tooltip.style.marginRight = `${spacing}px`
        break

      case "right":
        tooltip.style.left = "100%"
        tooltip.style.top = "50%"
        tooltip.style.transform = "translateY(-50%)"
        tooltip.style.marginLeft = `${spacing}px`
        break
    }

    // Clamp to viewport
    this.clampToViewport()
  }

  // Ensure tooltip stays within viewport
  clampToViewport() {
    if (!this.hasTooltipTarget) return

    const tooltip = this.tooltipTarget
    const rect = tooltip.getBoundingClientRect()
    const viewportWidth = window.innerWidth
    const viewportHeight = window.innerHeight
    const padding = 8

    // Check horizontal bounds
    if (rect.left < padding) {
      const offset = padding - rect.left
      tooltip.style.left = `${parseFloat(tooltip.style.left || 0) + offset}px`
    } else if (rect.right > viewportWidth - padding) {
      const offset = rect.right - (viewportWidth - padding)
      tooltip.style.left = `${parseFloat(tooltip.style.left || 0) - offset}px`
    }

    // Check vertical bounds
    if (rect.top < padding) {
      const offset = padding - rect.top
      tooltip.style.top = `${parseFloat(tooltip.style.top || 0) + offset}px`
    } else if (rect.bottom > viewportHeight - padding) {
      const offset = rect.bottom - (viewportHeight - padding)
      tooltip.style.top = `${parseFloat(tooltip.style.top || 0) - offset}px`
    }
  }

  clearTimeouts() {
    if (this.showTimeout) {
      clearTimeout(this.showTimeout)
      this.showTimeout = null
    }
    if (this.hideTimeout) {
      clearTimeout(this.hideTimeout)
      this.hideTimeout = null
    }
  }
}
