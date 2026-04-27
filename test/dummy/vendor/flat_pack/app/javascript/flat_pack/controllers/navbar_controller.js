import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "sidebar",
    "toggleButton",
    "toggleIcon",
    "toggleText",
    "itemText",
    "itemIcon",
    "itemBadge",
    "sectionTitle"
  ]

  static values = {
    expandedWidth: String,
    collapsedWidth: String,
    collapsed: Boolean
  }

  connect() {
    this.mobileOpen = false
    this.isMobile = window.innerWidth < 768
    
    // Load saved state from localStorage (desktop only)
    if (!this.isMobile) {
      this.loadState()
      this.applyDesktopState()
    }
    
    // Listen for window resize
    window.addEventListener("resize", this.handleResize.bind(this))
  }

  disconnect() {
    window.removeEventListener("resize", this.handleResize.bind(this))
    this.removeOverlay()
  }

  handleResize() {
    const wasMobile = this.isMobile
    this.isMobile = window.innerWidth < 768
    
    if (wasMobile !== this.isMobile) {
      if (this.isMobile) {
        // Switched to mobile - close sidebar and reset state
        this.closeMobile()
      } else {
        // Switched to desktop - apply saved state
        this.loadState()
        this.applyDesktopState()
      }
    }
  }

  toggle() {
    if (this.isMobile) {
      this.toggleMobile()
    } else {
      this.toggleDesktop()
    }
  }

  toggleDesktop() {
    this.collapsedValue = !this.collapsedValue
    this.applyDesktopState()
    this.saveState()
  }

  toggleMobile() {
    this.mobileOpen = !this.mobileOpen
    
    if (this.mobileOpen) {
      this.openMobile()
    } else {
      this.closeMobile()
    }
  }

  openMobile() {
    // Remove hidden class first
    this.sidebarTarget.classList.remove("hidden")
    
    // Force reflow for animation
    this.sidebarTarget.offsetHeight
    
    // Slide in from left
    this.sidebarTarget.classList.remove("-translate-x-full")
    
    // Create overlay
    this.createOverlay()
    
    // Prevent body scroll
    document.body.style.overflow = "hidden"
  }

  closeMobile() {
    // Slide out to left
    this.sidebarTarget.classList.add("-translate-x-full")
    
    // Wait for animation then hide
    setTimeout(() => {
      if (!this.mobileOpen && this.isMobile) {
        this.sidebarTarget.classList.add("hidden")
      }
    }, 300)
    
    // Remove overlay
    this.removeOverlay()
    
    // Restore body scroll
    document.body.style.overflow = ""
  }

  applyDesktopState() {
    const collapsed = this.collapsedValue
    
    // Set sidebar width
    if (collapsed) {
      this.sidebarTarget.style.width = this.collapsedWidthValue
    } else {
      this.sidebarTarget.style.width = this.expandedWidthValue
    }
    
    // Rotate toggle icon (chevron)
    if (this.hasToggleIconTarget) {
      if (collapsed) {
        this.toggleIconTarget.style.transform = "rotate(180deg)"
      } else {
        this.toggleIconTarget.style.transform = "rotate(0deg)"
      }
    }
    
    // Hide/show toggle text ("Minimize")
    if (this.hasToggleTextTarget) {
      if (collapsed) {
        this.toggleTextTarget.classList.add("hidden")
      } else {
        this.toggleTextTarget.classList.remove("hidden")
      }
    }
    
    // Adjust toggle button justification
    if (this.hasToggleButtonTarget) {
      if (collapsed) {
        this.toggleButtonTarget.classList.remove("gap-2")
        this.toggleButtonTarget.classList.add("justify-center")
      } else {
        this.toggleButtonTarget.classList.add("gap-2")
        this.toggleButtonTarget.classList.remove("justify-center")
      }
    }
    
    // Hide/show all item texts
    this.itemTextTargets.forEach(text => {
      if (collapsed) {
        text.classList.add("hidden")
      } else {
        text.classList.remove("hidden")
      }
    })
    
    // Hide/show all badges
    this.itemBadgeTargets.forEach(badge => {
      if (collapsed) {
        badge.classList.add("hidden")
      } else {
        badge.classList.remove("hidden")
      }
    })
    
    // Hide/show all section titles
    this.sectionTitleTargets.forEach(title => {
      if (collapsed) {
        title.classList.add("hidden")
      } else {
        title.classList.remove("hidden")
      }
    })
    
    // Center icons when collapsed
    this.itemIconTargets.forEach(icon => {
      const parent = icon.closest("a, button")
      if (parent) {
        if (collapsed) {
          parent.classList.add("justify-center")
          parent.classList.remove("gap-3")
        } else {
          parent.classList.remove("justify-center")
          parent.classList.add("gap-3")
        }
      }
    })
  }

  createOverlay() {
    if (this.overlay) return
    
    this.overlay = document.createElement("div")
    this.overlay.className = "fixed inset-0 bg-black/50 z-30 md:hidden"
    this.overlay.style.opacity = "0"
    this.overlay.addEventListener("click", () => {
      this.mobileOpen = false
      this.closeMobile()
    })
    
    document.body.appendChild(this.overlay)
    
    // Fade in
    requestAnimationFrame(() => {
      this.overlay.style.transition = "opacity 300ms"
      this.overlay.style.opacity = "1"
    })
  }

  removeOverlay() {
    if (!this.overlay) return
    
    // Fade out
    this.overlay.style.opacity = "0"
    
    setTimeout(() => {
      if (this.overlay && this.overlay.parentNode) {
        this.overlay.parentNode.removeChild(this.overlay)
      }
      this.overlay = null
    }, 300)
  }

  saveState() {
    localStorage.setItem("flatpack-navbar-collapsed", this.collapsedValue)
  }

  loadState() {
    const saved = localStorage.getItem("flatpack-navbar-collapsed")
    if (saved !== null) {
      this.collapsedValue = saved === "true"
    }
  }
}
