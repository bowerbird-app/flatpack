// FlatPack Tooltip Stimulus Controller
import { Controller } from "@hotwired/stimulus"
import {
  prefersReducedMotion,
  motionDuration,
  motionTransition,
  overlayOrigin,
  overlayEnterOffset
} from "controllers/flat_pack/reduced_motion"

const SHOW_DELAY_MS = 200

export default class extends Controller {
  static targets = ["tooltip"]
  static values = {
    placement: { type: String, default: "top" },
    collapsedOnly: { type: Boolean, default: false }
  }

  connect() {
    this.showTimeout = null
    this.hideTimeout = null
    this.resolvedPlacement = this.placementValue
  }

  disconnect() {
    this.clearTimeouts()
  }

  show() {
    if (!this.shouldShowTooltip()) return

    this.clearTimeouts()

    const alreadyVisible = this.hasTooltipTarget && !this.tooltipTarget.classList.contains("hidden")
    const delay = alreadyVisible ? 0 : SHOW_DELAY_MS

    this.showTimeout = setTimeout(() => {
      this.reveal()
    }, delay)
  }

  hide() {
    this.clearTimeouts()

    if (!this.hasTooltipTarget) return

    this.tooltipTarget.style.transition = motionTransition(
      ["opacity", "transform"],
      { duration: "base", easing: "exit" }
    )
    this.tooltipTarget.style.opacity = "0"
    this.tooltipTarget.style.transform = prefersReducedMotion() ? "none" : overlayEnterOffset(this.resolvedPlacement)

    this.hideTimeout = setTimeout(() => {
      this.tooltipTarget.classList.add("hidden")
      this.hideTimeout = null
    }, motionDuration("base"))
  }

  reveal() {
    if (!this.hasTooltipTarget) return

    const wasHidden = this.tooltipTarget.classList.contains("hidden")
    this.tooltipTarget.classList.remove("hidden")

    if (wasHidden) {
      this.tooltipTarget.style.transition = "none"
      this.tooltipTarget.style.opacity = "0"
      this.tooltipTarget.style.transform = "none"
      this.position()
      this.tooltipTarget.style.transformOrigin = overlayOrigin(this.resolvedPlacement)
      this.tooltipTarget.offsetHeight

      if (!prefersReducedMotion()) {
        this.tooltipTarget.style.transform = overlayEnterOffset(this.resolvedPlacement)
        this.tooltipTarget.offsetHeight
      }
    }

    this.tooltipTarget.style.transition = motionTransition(
      ["opacity", "transform"],
      { duration: "base", easing: "enter" }
    )

    requestAnimationFrame(() => {
      this.tooltipTarget.style.opacity = "1"
      this.tooltipTarget.style.transform = "none"
    })
  }

  position() {
    if (!this.hasTooltipTarget) return

    const tooltip = this.tooltipTarget
    const trigger = this.element
    const placement = this.placementValue

    tooltip.style.position = "fixed"
    tooltip.style.top = ""
    tooltip.style.left = ""
    tooltip.style.right = ""
    tooltip.style.bottom = ""
    tooltip.style.marginTop = ""
    tooltip.style.marginRight = ""
    tooltip.style.marginBottom = ""
    tooltip.style.marginLeft = ""

    const triggerRect = trigger.getBoundingClientRect()
    const tooltipRect = tooltip.getBoundingClientRect()
    const spacing = 8
    const viewportPadding = 8
    let top
    let left
    let resolved = placement

    switch (placement) {
      case "top":
        if (triggerRect.top - tooltipRect.height - spacing >= viewportPadding) {
          top = triggerRect.top - tooltipRect.height - spacing
          resolved = "top"
        } else {
          top = triggerRect.bottom + spacing
          resolved = "bottom"
        }
        left = triggerRect.left + (triggerRect.width / 2) - (tooltipRect.width / 2)
        break

      case "bottom":
        if (triggerRect.bottom + spacing + tooltipRect.height <= window.innerHeight - viewportPadding) {
          top = triggerRect.bottom + spacing
          resolved = "bottom"
        } else {
          top = triggerRect.top - tooltipRect.height - spacing
          resolved = "top"
        }
        left = triggerRect.left + (triggerRect.width / 2) - (tooltipRect.width / 2)
        break

      case "left":
        top = triggerRect.top + (triggerRect.height / 2) - (tooltipRect.height / 2)
        left = triggerRect.left - tooltipRect.width - spacing
        resolved = "left"
        break

      case "right":
        top = triggerRect.top + (triggerRect.height / 2) - (tooltipRect.height / 2)
        left = triggerRect.right + spacing
        resolved = "right"
        break

      default:
        top = triggerRect.top - tooltipRect.height - spacing
        left = triggerRect.left + (triggerRect.width / 2) - (tooltipRect.width / 2)
        resolved = "top"
        break
    }

    this.resolvedPlacement = resolved
    tooltip.style.top = `${top}px`
    tooltip.style.left = `${left}px`
    tooltip.style.transformOrigin = overlayOrigin(resolved)

    this.clampToViewport(resolved, triggerRect, spacing)
  }

  clampToViewport(placement, triggerRect, spacing) {
    if (!this.hasTooltipTarget) return

    const tooltip = this.tooltipTarget
    const rect = tooltip.getBoundingClientRect()
    const viewportWidth = window.innerWidth
    const viewportHeight = window.innerHeight
    const padding = 8

    let adjustLeft = 0
    let adjustTop = 0

    if (rect.left < padding) {
      adjustLeft = padding - rect.left
    } else if (rect.right > viewportWidth - padding) {
      adjustLeft = (viewportWidth - padding) - rect.right
    }

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

  shouldShowTooltip() {
    if (!this.collapsedOnlyValue) return true

    const label = this.element.querySelector("span.flex-1")
    if (label) return label.classList.contains("sr-only")

    const sidebar = this.element.closest("[data-flat-pack-sidebar-collapsed]")
    if (sidebar) return sidebar.dataset.flatPackSidebarCollapsed === "true"

    return true
  }
}
