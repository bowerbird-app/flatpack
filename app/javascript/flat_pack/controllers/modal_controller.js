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
    this.handleDocumentTriggerClick = this.handleDocumentTriggerClick.bind(this)
    document.addEventListener("click", this.handleDocumentTriggerClick)

    if (this.element.classList.contains("hidden")) {
      this.restoreBodyScroll()
    }
  }

  disconnect() {
    document.removeEventListener("click", this.handleDocumentTriggerClick)

    // Restore scroll if modal was open when disconnected
    if (this.element.classList.contains("flex")) {
      this.restoreBodyScroll()
      this.restoreFocus()
    }
  }

  // Open modal
  open() {
    if (!this.element.classList.contains("hidden")) return

    // Store the currently focused element
    if (!this.previousActiveElement) {
      this.previousActiveElement = document.activeElement
    }

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
    if (this.element.classList.contains("hidden")) return

    // Fade out animations
    this.element.style.opacity = "0"

    // Restore body scroll immediately so page scrolling is never left locked
    this.restoreBodyScroll()
    
    if (this.hasDialogTarget) {
      this.dialogTarget.style.opacity = "0"
      this.dialogTarget.style.transform = "scale(0.95)"
    }

    // Wait for animation to complete before hiding
    setTimeout(() => {
      this.element.classList.remove("flex")
      this.element.classList.add("hidden")
      this.element.setAttribute("aria-hidden", "true")

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

  handleDocumentTriggerClick(event) {
    const trigger = event.target.closest("[data-modal-id]")
    if (!trigger) return

    const modalId = trigger.dataset.modalId
    if (!modalId || modalId !== this.element.id) return

    this.previousActiveElement = trigger
    this.open()
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
    const lockCount = Number(document.body.dataset.flatPackModalLockCount || "0")
    
    if (lockCount === 0) {
      // Get scrollbar width
      const scrollbarWidth = window.innerWidth - document.documentElement.clientWidth

      // Add padding to prevent layout shift
      if (scrollbarWidth > 0) {
        document.body.style.paddingRight = `${scrollbarWidth}px`
      }

      document.body.style.overflow = "hidden"
    }

    document.body.dataset.flatPackModalLockCount = String(lockCount + 1)
  }

  // Restore body scroll
  restoreBodyScroll() {
    const lockCount = Number(document.body.dataset.flatPackModalLockCount || "0")

    if (lockCount > 1) {
      document.body.dataset.flatPackModalLockCount = String(lockCount - 1)
      return
    }

    delete document.body.dataset.flatPackModalLockCount

    if (this.originalOverflow !== undefined) {
      document.body.style.overflow = this.originalOverflow
    } else {
      document.body.style.removeProperty("overflow")
    }

    if (this.originalPaddingRight !== undefined) {
      document.body.style.paddingRight = this.originalPaddingRight
    } else {
      document.body.style.removeProperty("padding-right")
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
