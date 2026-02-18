import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "button", "chevron"]
  static values = {
    defaultOpen: Boolean
  }

  connect() {
    this.isOpen = this.defaultOpenValue

    // Apply initial state
    if (this.isOpen) {
      this.open()
    } else {
      this.close()
    }
  }

  toggle() {
    if (this.isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.isOpen = true

    // Update aria-expanded
    if (this.hasButtonTarget) {
      this.buttonTarget.setAttribute("aria-expanded", "true")
    }

    // Rotate chevron
    if (this.hasChevronTarget) {
      this.chevronTarget.style.transform = "rotate(0deg)"
    }

    // Expand panel with height animation
    if (this.hasPanelTarget) {
      const panel = this.panelTarget
      
      // Get the full height
      panel.style.maxHeight = "none"
      const height = panel.scrollHeight
      panel.style.maxHeight = "0"
      
      // Force reflow
      panel.offsetHeight
      
      // Animate to full height
      panel.style.maxHeight = `${height}px`
      
      // After transition, remove max-height constraint
      setTimeout(() => {
        if (this.isOpen) {
          panel.style.maxHeight = "none"
        }
      }, 200)
    }
  }

  close() {
    this.isOpen = false

    // Update aria-expanded
    if (this.hasButtonTarget) {
      this.buttonTarget.setAttribute("aria-expanded", "false")
    }

    // Rotate chevron
    if (this.hasChevronTarget) {
      this.chevronTarget.style.transform = "rotate(-90deg)"
    }

    // Collapse panel with height animation
    if (this.hasPanelTarget) {
      const panel = this.panelTarget
      
      // Set current height
      const height = panel.scrollHeight
      panel.style.maxHeight = `${height}px`
      
      // Force reflow
      panel.offsetHeight
      
      // Animate to zero
      panel.style.maxHeight = "0"
    }
  }
}
