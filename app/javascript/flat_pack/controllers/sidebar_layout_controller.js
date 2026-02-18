import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "backdrop", "desktopToggle", "mobileToggle"]
  static values = {
    side: String,
    defaultOpen: Boolean,
    storageKey: String
  }

  connect() {
    this.collapsed = false
    this.mobileOpen = false
    this.isMobile = window.innerWidth < 768

    // Load saved desktop state from localStorage
    if (!this.isMobile && this.hasStorageKeyValue) {
      this.loadDesktopState()
    } else if (!this.isMobile) {
      this.collapsed = !this.defaultOpenValue
    }

    // Apply initial desktop state
    if (!this.isMobile) {
      this.applyDesktopState()
    }

    // Listen for window resize
    this.handleResize = this.handleResize.bind(this)
    window.addEventListener("resize", this.handleResize)
  }

  disconnect() {
    window.removeEventListener("resize", this.handleResize)
  }

  handleResize() {
    const wasMobile = this.isMobile
    this.isMobile = window.innerWidth < 768

    if (wasMobile !== this.isMobile) {
      if (this.isMobile) {
        // Switched to mobile - close sidebar
        this.closeMobile()
      } else {
        // Switched to desktop - apply saved state
        this.applyDesktopState()
      }
    }
  }

  toggleDesktop() {
    if (this.isMobile) return

    this.collapsed = !this.collapsed
    this.applyDesktopState()
    this.saveDesktopState()
  }

  toggleMobile() {
    if (!this.isMobile) return

    this.mobileOpen = !this.mobileOpen

    if (this.mobileOpen) {
      this.openMobile()
    } else {
      this.closeMobile()
    }
  }

  openMobile() {
    // Store the element that triggered the open for focus return
    this.previouslyFocusedElement = document.activeElement

    // Show sidebar
    this.sidebarTarget.classList.remove("hidden")

    // Force reflow for animation
    this.sidebarTarget.offsetHeight

    // Slide in from correct side
    if (this.sideValue === "right") {
      this.sidebarTarget.classList.remove("translate-x-full")
    } else {
      this.sidebarTarget.classList.remove("-translate-x-full")
    }

    // Show backdrop
    if (this.hasBackdropTarget) {
      this.backdropTarget.classList.remove("pointer-events-none")
      this.backdropTarget.classList.remove("opacity-0")
      this.backdropTarget.classList.add("opacity-100")
      this.backdropTarget.setAttribute("aria-hidden", "false")
    }

    // Prevent body scroll
    document.body.style.overflow = "hidden"

    // Focus first focusable element in sidebar
    setTimeout(() => {
      this.focusFirstElement()
    }, 100)

    // Listen for Escape key
    this.handleEscape = this.handleEscape.bind(this)
    document.addEventListener("keydown", this.handleEscape)
  }

  closeMobile() {
    // Slide out to correct side
    if (this.sideValue === "right") {
      this.sidebarTarget.classList.add("translate-x-full")
    } else {
      this.sidebarTarget.classList.add("-translate-x-full")
    }

    // Hide backdrop
    if (this.hasBackdropTarget) {
      this.backdropTarget.classList.add("pointer-events-none")
      this.backdropTarget.classList.remove("opacity-100")
      this.backdropTarget.classList.add("opacity-0")
      this.backdropTarget.setAttribute("aria-hidden", "true")
    }

    // Wait for animation then hide
    setTimeout(() => {
      if (!this.mobileOpen && this.isMobile) {
        this.sidebarTarget.classList.add("hidden")
      }
    }, 300)

    // Restore body scroll
    document.body.style.overflow = ""

    // Remove Escape key listener
    document.removeEventListener("keydown", this.handleEscape)

    // Return focus to toggle button
    if (this.previouslyFocusedElement) {
      this.previouslyFocusedElement.focus()
      this.previouslyFocusedElement = null
    }

    this.mobileOpen = false
  }

  handleEscape(event) {
    if (event.key === "Escape" && this.mobileOpen) {
      this.closeMobile()
    }
  }

  focusFirstElement() {
    const focusableSelectors = 'a[href], button:not([disabled]), input:not([disabled]), [tabindex]:not([tabindex="-1"])'
    const focusableElements = this.sidebarTarget.querySelectorAll(focusableSelectors)
    
    if (focusableElements.length > 0) {
      focusableElements[0].focus()
    }
  }

  applyDesktopState() {
    if (this.isMobile) return

    // Update sidebar width
    if (this.collapsed) {
      this.sidebarTarget.style.width = "4rem" // w-16
    } else {
      this.sidebarTarget.style.width = "16rem" // w-64
    }

    // Update desktop toggle if exists
    if (this.hasDesktopToggleTarget) {
      this.desktopToggleTarget.setAttribute("aria-expanded", !this.collapsed)
      
      // Update chevron rotation
      const chevron = this.desktopToggleTarget.querySelector('[data-flat-pack--sidebar-layout-target="chevron"]')
      if (chevron) {
        if (this.collapsed) {
          chevron.style.transform = "rotate(180deg)"
        } else {
          chevron.style.transform = "rotate(0deg)"
        }
      }
    }

    // Update labels visibility
    const labels = this.sidebarTarget.querySelectorAll(".sr-only")
    labels.forEach(label => {
      if (this.collapsed) {
        label.classList.add("sr-only")
      } else {
        label.classList.remove("sr-only")
      }
    })
  }

  saveDesktopState() {
    if (this.hasStorageKeyValue) {
      localStorage.setItem(this.storageKeyValue, this.collapsed.toString())
    }
  }

  loadDesktopState() {
    if (this.hasStorageKeyValue) {
      const saved = localStorage.getItem(this.storageKeyValue)
      if (saved !== null) {
        this.collapsed = saved === "true"
      }
    }
  }
}
