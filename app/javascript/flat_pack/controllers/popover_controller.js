// FlatPack Popover Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    triggerId: String,
    placement: { type: String, default: "bottom" }
  }

  connect() {
    this.boundClose = this.close.bind(this)
    this.boundHandleEscape = this.handleEscape.bind(this)
    this.isOpen = false

    // Find and setup trigger
    this.setupTrigger()
  }

  disconnect() {
    this.removeTriggerListener()
    this.removeDocumentListeners()
  }

  setupTrigger() {
    if (!this.triggerIdValue) return

    this.trigger = document.getElementById(this.triggerIdValue)
    
    if (this.trigger) {
      this.triggerListener = this.toggle.bind(this)
      this.trigger.addEventListener("click", this.triggerListener)
      
      // Add ARIA attributes
      this.trigger.setAttribute("aria-haspopup", "true")
      this.trigger.setAttribute("aria-expanded", "false")
    }
  }

  removeTriggerListener() {
    if (this.trigger && this.triggerListener) {
      this.trigger.removeEventListener("click", this.triggerListener)
    }
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()

    if (this.isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.isOpen = true

    // Show popover
    this.element.classList.remove("hidden")
    this.element.setAttribute("aria-hidden", "false")

    // Position relative to trigger
    this.position()

    // Trigger animation
    requestAnimationFrame(() => {
      this.element.style.opacity = "1"
      this.element.style.transform = "scale(1)"
    })

    // Update trigger ARIA
    if (this.trigger) {
      this.trigger.setAttribute("aria-expanded", "true")
    }

    // Add document listeners for closing
    setTimeout(() => {
      document.addEventListener("click", this.boundClose)
      document.addEventListener("keydown", this.boundHandleEscape)
    }, 0)
  }

  close() {
    this.isOpen = false

    // Animate out
    this.element.style.opacity = "0"
    this.element.style.transform = "scale(0.95)"

    // Hide after animation
    setTimeout(() => {
      this.element.classList.add("hidden")
      this.element.setAttribute("aria-hidden", "true")
    }, 200)

    // Update trigger ARIA
    if (this.trigger) {
      this.trigger.setAttribute("aria-expanded", "false")
    }

    // Remove document listeners
    this.removeDocumentListeners()
  }

  handleEscape(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }

  removeDocumentListeners() {
    document.removeEventListener("click", this.boundClose)
    document.removeEventListener("keydown", this.boundHandleEscape)
  }

  // Don't close when clicking inside popover
  preventClose(event) {
    event.stopPropagation()
  }

  position() {
    if (!this.trigger) return

    const triggerRect = this.trigger.getBoundingClientRect()
    const popoverRect = this.element.getBoundingClientRect()
    const spacing = 8

    // Reset positioning
    this.element.style.top = ""
    this.element.style.left = ""
    this.element.style.right = ""
    this.element.style.bottom = ""

    let top, left

    switch (this.placementValue) {
      case "top":
        top = triggerRect.top - popoverRect.height - spacing
        left = triggerRect.left + (triggerRect.width / 2) - (popoverRect.width / 2)
        break

      case "bottom":
        top = triggerRect.bottom + spacing
        left = triggerRect.left + (triggerRect.width / 2) - (popoverRect.width / 2)
        break

      case "left":
        top = triggerRect.top + (triggerRect.height / 2) - (popoverRect.height / 2)
        left = triggerRect.left - popoverRect.width - spacing
        break

      case "right":
        top = triggerRect.top + (triggerRect.height / 2) - (popoverRect.height / 2)
        left = triggerRect.right + spacing
        break

      default:
        top = triggerRect.bottom + spacing
        left = triggerRect.left
    }

    // Apply position
    this.element.style.position = "fixed"
    this.element.style.top = `${top}px`
    this.element.style.left = `${left}px`

    // Clamp to viewport
    this.clampToViewport()
  }

  clampToViewport() {
    const rect = this.element.getBoundingClientRect()
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

    // Apply adjustments
    if (adjustLeft !== 0) {
      const currentLeft = parseFloat(this.element.style.left)
      this.element.style.left = `${currentLeft + adjustLeft}px`
    }

    if (adjustTop !== 0) {
      const currentTop = parseFloat(this.element.style.top)
      this.element.style.top = `${currentTop + adjustTop}px`
    }
  }
}
