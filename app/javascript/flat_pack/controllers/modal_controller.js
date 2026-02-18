// FlatPack Modal Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog"]
  static values = {
    closeOnBackdrop: { type: Boolean, default: true },
    closeOnEscape: { type: Boolean, default: true }
  }

  connect() {
    this.previousActiveElement = null
  }

  disconnect() {
    // Restore scroll if modal was open when disconnected
    if (this.element.classList.contains("flex")) {
      this.restoreBodyScroll()
      this.restoreFocus()
    }
  }

  // Open modal
  open() {
    // Store the currently focused element
    this.previousActiveElement = document.activeElement

    // Prevent body scroll
    this.preventBodyScroll()

    // Show modal with fade-in animation
    this.element.classList.remove("hidden")
    this.element.classList.add("flex")
    this.element.setAttribute("aria-hidden", "false")

    // Trigger reflow for transition
    this.element.offsetHeight

    // Fade in backdrop
    this.element.style.opacity = "1"

    // Scale in dialog
    requestAnimationFrame(() => {
      if (this.hasDialogTarget) {
        this.dialogTarget.style.opacity = "1"
        this.dialogTarget.style.transform = "scale(1)"
      }
    })

    // Focus first focusable element or dialog itself
    setTimeout(() => this.trapFocus(), 100)
  }

  // Close modal
  close() {
    // Fade out animations
    this.element.style.opacity = "0"
    
    if (this.hasDialogTarget) {
      this.dialogTarget.style.opacity = "0"
      this.dialogTarget.style.transform = "scale(0.95)"
    }

    // Wait for animation to complete before hiding
    setTimeout(() => {
      this.element.classList.remove("flex")
      this.element.classList.add("hidden")
      this.element.setAttribute("aria-hidden", "true")
      
      // Restore body scroll
      this.restoreBodyScroll()
      
      // Restore focus to previous element
      this.restoreFocus()
    }, 300) // Match CSS transition duration
  }

  // Toggle modal state
  toggle() {
    if (this.element.classList.contains("hidden")) {
      this.open()
    } else {
      this.close()
    }
  }

  // Handle backdrop click
  clickBackdrop(event) {
    if (!this.closeOnBackdropValue) return
    
    // Only close if clicking directly on backdrop, not bubbled from dialog
    if (event.target === event.currentTarget) {
      this.close()
    }
  }

  // Prevent body scroll when modal is open
  preventBodyScroll() {
    this.originalOverflow = document.body.style.overflow
    this.originalPaddingRight = document.body.style.paddingRight
    
    // Get scrollbar width
    const scrollbarWidth = window.innerWidth - document.documentElement.clientWidth
    
    // Add padding to prevent layout shift
    if (scrollbarWidth > 0) {
      document.body.style.paddingRight = `${scrollbarWidth}px`
    }
    
    document.body.style.overflow = "hidden"
  }

  // Restore body scroll
  restoreBodyScroll() {
    if (this.originalOverflow !== undefined) {
      document.body.style.overflow = this.originalOverflow
    }
    if (this.originalPaddingRight !== undefined) {
      document.body.style.paddingRight = this.originalPaddingRight
    }
  }

  // Restore focus to previous element
  restoreFocus() {
    if (this.previousActiveElement && typeof this.previousActiveElement.focus === "function") {
      this.previousActiveElement.focus()
      this.previousActiveElement = null
    }
  }

  // Focus trap - focus first focusable element
  trapFocus() {
    if (!this.hasDialogTarget) return

    const focusableElements = this.dialogTarget.querySelectorAll(
      'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
    )

    if (focusableElements.length > 0) {
      focusableElements[0].focus()
    } else {
      this.dialogTarget.focus()
    }
  }

  // Handle keyboard navigation within modal (basic focus trap)
  handleKeydown(event) {
    if (!this.hasDialogTarget) return
    
    // Tab key for focus management
    if (event.key === "Tab") {
      const focusableElements = Array.from(
        this.dialogTarget.querySelectorAll(
          'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
        )
      )

      if (focusableElements.length === 0) return

      const firstElement = focusableElements[0]
      const lastElement = focusableElements[focusableElements.length - 1]

      // Shift + Tab on first element - wrap to last
      if (event.shiftKey && document.activeElement === firstElement) {
        event.preventDefault()
        lastElement.focus()
      }
      // Tab on last element - wrap to first
      else if (!event.shiftKey && document.activeElement === lastElement) {
        event.preventDefault()
        firstElement.focus()
      }
    }
  }
}
