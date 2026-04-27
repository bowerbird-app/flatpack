// FlatPack Toast Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    timeout: { type: Number, default: 5000 },
    dismissible: { type: Boolean, default: true }
  }

  connect() {
    // Enable pointer events for this toast
    this.element.style.pointerEvents = "auto"
    
    // Slide in animation
    this.show()
    
    // Auto-dismiss after timeout
    if (this.timeoutValue > 0) {
      this.autoDismissTimer = setTimeout(() => {
        this.dismiss()
      }, this.timeoutValue)
    }
  }

  disconnect() {
    if (this.autoDismissTimer) {
      clearTimeout(this.autoDismissTimer)
    }
  }

  show() {
    // Initial state
    this.element.style.transform = "translateX(100%)"
    this.element.style.opacity = "0"
    
    // Trigger reflow
    this.element.offsetHeight
    
    // Animate in
    requestAnimationFrame(() => {
      this.element.style.transition = "transform 0.3s ease-out, opacity 0.3s ease-out"
      
      // Check for prefers-reduced-motion
      if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
        this.element.style.transition = "none"
      }
      
      this.element.style.transform = "translateX(0)"
      this.element.style.opacity = "1"
    })
  }

  dismiss() {
    // Cancel auto-dismiss if manually dismissed
    if (this.autoDismissTimer) {
      clearTimeout(this.autoDismissTimer)
    }
    
    // Animate out
    this.element.style.transform = "translateX(100%)"
    this.element.style.opacity = "0"
    
    // Remove from DOM after animation
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }

  // Pause auto-dismiss on hover
  pauseDismiss() {
    if (this.autoDismissTimer) {
      clearTimeout(this.autoDismissTimer)
      this.autoDismissTimer = null
    }
  }

  // Resume auto-dismiss on mouse leave
  resumeDismiss() {
    if (this.timeoutValue > 0 && !this.autoDismissTimer) {
      this.autoDismissTimer = setTimeout(() => {
        this.dismiss()
      }, 1000) // Give 1 more second
    }
  }
}
