import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "backdrop", "desktopToggle", "collapsedToggle", "mobileToggle", "headerLabel", "headerBrand", "footer"]
  static values = {
    side: String,
    defaultOpen: Boolean,
    storageKey: String
  }

  connect() {
    this.desktopRevealTimeout = null
    this.collapsed = false
    this.mobileOpen = false
    this.isMobile = window.innerWidth < 768
    this.transitionDuration = "300ms"
    this.transitionEasing = "cubic-bezier(0.4, 0, 0.2, 1)"

    // Load saved desktop state from localStorage
    if (!this.isMobile && this.hasStorageKeyValue) {
      this.loadDesktopState()
    } else if (!this.isMobile) {
      this.collapsed = !this.defaultOpenValue
    }

    // Apply initial desktop state
    if (!this.isMobile) {
      this.sidebarTarget.style.pointerEvents = ""
      this.applySidebarPresentationMode()
      this.applyDesktopState()
    } else {
      this.applySidebarPresentationMode()
      this.sidebarTarget.style.pointerEvents = "none"
    }

    // Listen for window resize
    this.handleResize = this.handleResize.bind(this)
    window.addEventListener("resize", this.handleResize)
  }

  disconnect() {
    this.clearDesktopRevealTimeout()
    window.removeEventListener("resize", this.handleResize)
  }

  handleResize() {
    const wasMobile = this.isMobile
    this.isMobile = window.innerWidth < 768

    if (wasMobile !== this.isMobile) {
      if (this.isMobile) {
        // Switched to mobile - close sidebar
        this.applySidebarPresentationMode()
        this.closeMobile()
      } else {
        // Switched to desktop - apply saved state
        this.applySidebarPresentationMode()
        this.sidebarTarget.style.pointerEvents = ""
        this.applyDesktopState()
      }
    }
  }

  toggleDesktop() {
    if (this.isMobile) return

    const opening = this.collapsed
    this.collapsed = !this.collapsed
    this.applyDesktopState({ delayContentReveal: opening })
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

    // Enable interaction while open
    this.sidebarTarget.style.pointerEvents = "auto"

    // Ensure starting off-screen state is rendered before animating in
    if (this.sideValue === "right") {
      this.sidebarTarget.classList.add("translate-x-full")
    } else {
      this.sidebarTarget.classList.add("-translate-x-full")
    }

    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        if (!this.mobileOpen || !this.isMobile) return

        // Slide in from correct side
        if (this.sideValue === "right") {
          this.sidebarTarget.classList.remove("translate-x-full")
        } else {
          this.sidebarTarget.classList.remove("-translate-x-full")
        }
      })
    })

    // Show backdrop
    if (this.hasBackdropTarget) {
      this.backdropTarget.classList.remove("pointer-events-none")
      this.backdropTarget.classList.remove("opacity-0")
      this.backdropTarget.classList.add("opacity-100")
      this.backdropTarget.setAttribute("aria-hidden", "false")
    }

    // Prevent body scroll
    document.body.style.overflow = "hidden"

    // Focus sidebar container without scrolling to avoid layout jump
    if (!this.sidebarTarget.hasAttribute("tabindex")) {
      this.sidebarTarget.setAttribute("tabindex", "-1")
    }
    this.sidebarTarget.focus({ preventScroll: true })

    // Listen for Escape key
    this.handleEscape = this.handleEscape.bind(this)
    document.addEventListener("keydown", this.handleEscape)
  }

  closeMobile() {
      // Disable interaction while closed
      this.sidebarTarget.style.pointerEvents = "none"

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

  applyDesktopState({ delayContentReveal = false } = {}) {
    if (this.isMobile) return

    // Update sidebar width
    const sidebarContent = this.sidebarTarget.querySelector("aside")
    if (this.collapsed) {
      this.sidebarTarget.style.width = "4rem" // w-16
      if (sidebarContent) sidebarContent.style.width = "4rem"
    } else {
      this.sidebarTarget.style.width = "16rem" // w-64
      if (sidebarContent) sidebarContent.style.width = "16rem"
    }

    // Update desktop toggle if exists
    if (this.hasDesktopToggleTarget) {
      this.desktopToggleTarget.setAttribute("aria-expanded", !this.collapsed)
      if (this.collapsed) {
        this.desktopToggleTarget.classList.add("hidden")
      } else {
        this.desktopToggleTarget.classList.remove("hidden")
      }
      
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

    // Update collapsed-state toggle visibility
    if (this.hasCollapsedToggleTarget) {
      this.collapsedToggleTarget.setAttribute("aria-expanded", this.collapsed ? "false" : "true")
      if (this.collapsed) {
        this.collapsedToggleTarget.classList.remove("hidden")
        this.collapsedToggleTarget.classList.add("flex")
      } else {
        this.collapsedToggleTarget.classList.add("hidden")
        this.collapsedToggleTarget.classList.remove("flex")
      }
    }

    this.clearDesktopRevealTimeout()

    if (this.collapsed) {
      this.setDesktopExpandedContentVisible(false)
      return
    }

    if (delayContentReveal) {
      this.setDesktopExpandedContentVisible(false)
      this.desktopRevealTimeout = setTimeout(() => {
        if (!this.isMobile && !this.collapsed) {
          this.setDesktopExpandedContentVisible(true)
        }
      }, 300)
      return
    }

    this.setDesktopExpandedContentVisible(true)
  }

  setDesktopExpandedContentVisible(visible) {
    const headerBrands = this.sidebarTarget.querySelectorAll('[data-flat-pack--sidebar-layout-target="headerBrand"]')
    headerBrands.forEach(brand => {
      if (visible) {
        brand.classList.remove("hidden")
      } else {
        brand.classList.add("hidden")
      }
    })

    // Only toggle text label spans (avoid containers like .flex-1 overflow-y-auto)
    const labels = this.sidebarTarget.querySelectorAll("a > span.flex-1, button > span.flex-1")
    labels.forEach(label => {
      if (visible) {
        label.classList.remove("sr-only")
      } else if (!label.classList.contains("sr-only")) {
        label.classList.add("sr-only")
      }
    })

    const headerLabels = this.sidebarTarget.querySelectorAll('[data-flat-pack--sidebar-layout-target="headerLabel"]')
    headerLabels.forEach(label => {
      if (visible) {
        label.classList.remove("sr-only")
      } else {
        label.classList.add("sr-only")
      }
    })

    const footers = this.sidebarTarget.querySelectorAll('[data-flat-pack--sidebar-layout-target="footer"]')
    footers.forEach(footer => {
      if (visible) {
        footer.classList.remove("hidden")
      } else {
        footer.classList.add("hidden")
      }
    })
  }

  clearDesktopRevealTimeout() {
    if (this.desktopRevealTimeout) {
      clearTimeout(this.desktopRevealTimeout)
      this.desktopRevealTimeout = null
    }
  }

  applySidebarPresentationMode() {
    const sidebarContent = this.sidebarTarget.querySelector("aside")

    this.sidebarTarget.style.transitionDuration = this.transitionDuration
    this.sidebarTarget.style.transitionTimingFunction = this.transitionEasing

    if (this.isMobile) {
      this.sidebarTarget.style.zIndex = "50"
      this.sidebarTarget.style.transitionProperty = "transform"

      if (sidebarContent) {
        sidebarContent.style.transitionProperty = ""
        sidebarContent.style.transitionDuration = ""
        sidebarContent.style.transitionTimingFunction = ""
      }
      return
    }

    this.sidebarTarget.style.zIndex = "auto"
    this.sidebarTarget.style.transitionProperty = "width, transform"

    if (sidebarContent) {
      sidebarContent.style.transitionProperty = "width"
      sidebarContent.style.transitionDuration = this.transitionDuration
      sidebarContent.style.transitionTimingFunction = this.transitionEasing
    }
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
