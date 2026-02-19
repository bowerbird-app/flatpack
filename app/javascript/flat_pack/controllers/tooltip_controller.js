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
    tooltip.style.position = "fixed"
    tooltip.style.top = ""
    tooltip.style.left = ""
    tooltip.style.right = ""
    tooltip.style.bottom = ""
    tooltip.style.marginTop = ""
    tooltip.style.marginRight = ""
    tooltip.style.marginBottom = ""
    tooltip.style.marginLeft = ""
    tooltip.style.transform = ""

    // Get dimensions
    const triggerRect = trigger.getBoundingClientRect()
    const tooltipRect = tooltip.getBoundingClientRect()
    const spacing = 8 // Gap between trigger and tooltip
    const viewportPadding = 8
    let top
    let left

    switch (placement) {
      case "top":
        if (triggerRect.top - tooltipRect.height - spacing >= viewportPadding) {
          top = triggerRect.top - tooltipRect.height - spacing
        } else {
          top = triggerRect.bottom + spacing
        }
        left = triggerRect.left + (triggerRect.width / 2) - (tooltipRect.width / 2)
        break

      case "bottom":
        if (triggerRect.bottom + spacing + tooltipRect.height <= window.innerHeight - viewportPadding) {
          top = triggerRect.bottom + spacing
        } else {
          top = triggerRect.top - tooltipRect.height - spacing
        }
        left = triggerRect.left + (triggerRect.width / 2) - (tooltipRect.width / 2)
        break

      case "left":
        top = triggerRect.top + (triggerRect.height / 2) - (tooltipRect.height / 2)
        left = triggerRect.left - tooltipRect.width - spacing
        break

      case "right":
        top = triggerRect.top + (triggerRect.height / 2) - (tooltipRect.height / 2)
        left = triggerRect.right + spacing
        break

      default:
        top = triggerRect.top - tooltipRect.height - spacing
        left = triggerRect.left + (triggerRect.width / 2) - (tooltipRect.width / 2)
        break
    }

    tooltip.style.top = `${top}px`
    tooltip.style.left = `${left}px`

    // Clamp to viewport
    this.clampToViewport(placement, triggerRect, spacing)
  }

  // Ensure tooltip stays within viewport
  clampToViewport(placement, triggerRect, spacing) {
    if (!this.hasTooltipTarget) return

    const tooltip = this.tooltipTarget
    const rect = tooltip.getBoundingClientRect()
    const viewportWidth = window.innerWidth
    const viewportHeight = window.innerHeight
    const padding = 8

    let adjustLeft = 0
    let adjustTop = 0

    // Check horizontal bounds
    if (rect.left < padding) {
      adjustLeft = padding - rect.left
    } else if (rect.right > viewportWidth - padding) {
      adjustLeft = (viewportWidth - padding) - rect.right
    }

    // Check vertical bounds
    if (rect.top < padding) {
      adjustTop = padding - rect.top
    } else if (rect.bottom > viewportHeight - padding) {
      adjustTop = (viewportHeight - padding) - rect.bottom
    }

    if (adjustLeft !== 0) {
      const currentLeft = parseFloat(tooltip.style.left)
      tooltip.style.left = `${currentLeft + adjustLeft}px`
    }

    if (adjustTop !== 0) {
      const currentTop = parseFloat(tooltip.style.top)
      tooltip.style.top = `${currentTop + adjustTop}px`
    }

    const rectAfterClamp = tooltip.getBoundingClientRect()
    const currentLeft = parseFloat(tooltip.style.left)

    if (placement === "right") {
      const minLeft = triggerRect.right + spacing
      if (currentLeft < minLeft) {
        tooltip.style.left = `${minLeft}px`
      }
    }

    if (placement === "left") {
      const maxLeft = triggerRect.left - rectAfterClamp.width - spacing
      if (currentLeft > maxLeft) {
        tooltip.style.left = `${maxLeft}px`
      }
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
