import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["leftNav", "toggle", "collapseText", "chevron"]
  static values = {
    collapsed: Boolean,
    width: String,
    collapsedWidth: String
  }

  connect() {
    this.overlay = null
    this.isDesktop = window.matchMedia("(min-width: 768px)").matches
    
    // Initialize desktop state
    if (this.isDesktop) {
      this.applyDesktopState()
    }

    // Listen for window resize
    this.handleResize = this.handleResize.bind(this)
    window.addEventListener("resize", this.handleResize)

    // Listen for escape key
    this.handleEscape = this.handleEscape.bind(this)
    document.addEventListener("keydown", this.handleEscape)

    // Load collapsed state from localStorage
    const savedState = localStorage.getItem("flatpack-navbar-collapsed")
    if (savedState !== null) {
      this.collapsedValue = savedState === "true"
    }
  }

  disconnect() {
    window.removeEventListener("resize", this.handleResize)
    document.removeEventListener("keydown", this.handleEscape)
    this.removeOverlay()
  }

  toggleDesktop() {
    this.collapsedValue = !this.collapsedValue
    this.applyDesktopState()
    
    // Save state to localStorage
    localStorage.setItem("flatpack-navbar-collapsed", this.collapsedValue)
  }

  toggleMobile() {
    if (!this.hasLeftNavTarget) return

    const isHidden = this.leftNavTarget.classList.contains("hidden")
    if (isHidden) {
      this.openMobile()
    } else {
      this.closeMobile()
    }
  }

  openMobile() {
    if (!this.hasLeftNavTarget) return

    // Remove hidden class to add element to DOM
    this.leftNavTarget.classList.remove("hidden")
    
    // Force reflow
    this.leftNavTarget.offsetHeight

    // Animate slide in from right
    this.leftNavTarget.classList.remove("translate-x-full")
    this.leftNavTarget.classList.add("translate-x-0")

    // Create overlay
    this.createOverlay()

    // Prevent body scroll
    document.body.style.overflow = "hidden"
  }

  closeMobile() {
    if (!this.hasLeftNavTarget) return

    // Animate slide out to right
    this.leftNavTarget.classList.add("translate-x-full")
    this.leftNavTarget.classList.remove("translate-x-0")

    // Wait for animation, then hide
    setTimeout(() => {
      this.leftNavTarget.classList.add("hidden")
    }, 300)

    // Remove overlay
    this.removeOverlay()

    // Restore body scroll
    document.body.style.overflow = ""
  }

  createOverlay() {
    if (this.overlay) return

    this.overlay = document.createElement("div")
    this.overlay.className = "fixed inset-0 bg-black/50 z-30 md:hidden transition-opacity duration-300"
    this.overlay.style.opacity = "0"
    
    // Click to close
    this.overlay.addEventListener("click", () => this.closeMobile())

    document.body.appendChild(this.overlay)

    // Force reflow then fade in
    requestAnimationFrame(() => {
      this.overlay.style.opacity = "1"
    })
  }

  removeOverlay() {
    if (!this.overlay) return

    this.overlay.style.opacity = "0"
    setTimeout(() => {
      if (this.overlay && this.overlay.parentNode) {
        this.overlay.parentNode.removeChild(this.overlay)
      }
      this.overlay = null
    }, 300)
  }

  applyDesktopState() {
    if (!this.hasLeftNavTarget) return

    const width = this.collapsedValue ? this.collapsedWidthValue : this.widthValue
    this.leftNavTarget.style.width = width

    // Toggle text visibility
    this.collapseTextTargets.forEach(element => {
      if (this.collapsedValue) {
        element.classList.add("hidden")
      } else {
        element.classList.remove("hidden")
      }
    })

    // Rotate chevron
    if (this.hasChevronTarget) {
      if (this.collapsedValue) {
        this.chevronTarget.style.transform = "rotate(180deg)"
      } else {
        this.chevronTarget.style.transform = ""
      }
    }
  }

  handleResize() {
    const wasDesktop = this.isDesktop
    this.isDesktop = window.matchMedia("(min-width: 768px)").matches

    // Switching from mobile to desktop
    if (!wasDesktop && this.isDesktop) {
      this.closeMobile()
      this.applyDesktopState()
    }
    
    // Switching from desktop to mobile
    if (wasDesktop && !this.isDesktop) {
      // Ensure sidebar is hidden on mobile
      if (this.hasLeftNavTarget) {
        this.leftNavTarget.classList.add("hidden")
        this.leftNavTarget.classList.add("translate-x-full")
        this.leftNavTarget.classList.remove("translate-x-0")
      }
    }
  }

  handleEscape(event) {
    if (event.key === "Escape" && !this.isDesktop) {
      this.closeMobile()
    }
  }
}
