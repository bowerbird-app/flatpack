// FlatPack Navbar Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["leftNav", "overlay", "collapseIcon", "collapseText", "itemText", "sectionTitle"]

  connect() {
    console.log("FlatPack Navbar controller connected")
    this.loadCollapsedState()
  }

  // Toggle mobile menu (slides from right)
  toggleMobile() {
    const nav = this.leftNavTarget
    const overlay = this.overlayTarget

    if (nav.classList.contains("translate-x-full")) {
      // Open menu
      nav.classList.remove("translate-x-full")
      nav.classList.add("translate-x-0")
      overlay.classList.remove("opacity-0", "pointer-events-none")
      overlay.classList.add("opacity-100")
      document.body.style.overflow = "hidden"
    } else {
      // Close menu
      this.closeMobile()
    }
  }

  // Close mobile menu
  closeMobile() {
    const nav = this.leftNavTarget
    const overlay = this.overlayTarget

    nav.classList.add("translate-x-full")
    nav.classList.remove("translate-x-0")
    overlay.classList.add("opacity-0", "pointer-events-none")
    overlay.classList.remove("opacity-100")
    document.body.style.overflow = ""
  }

  // Toggle collapsed state (desktop only)
  toggleCollapse() {
    const nav = this.leftNavTarget
    const isCollapsed = nav.classList.contains("md:w-16")

    if (isCollapsed) {
      // Expand
      nav.classList.remove("md:w-16")
      nav.classList.add("md:w-64")
      this.showText()
      this.saveCollapsedState(false)
    } else {
      // Collapse
      nav.classList.remove("md:w-64")
      nav.classList.add("md:w-16")
      this.hideText()
      this.saveCollapsedState(true)
    }

    // Rotate icon
    if (this.hasCollapseIconTarget) {
      this.collapseIconTarget.classList.toggle("rotate-180")
    }
  }

  // Hide text elements when collapsed
  hideText() {
    if (this.hasCollapseTextTarget) {
      this.collapseTextTarget.classList.add("md:hidden")
    }
    this.itemTextTargets.forEach(text => {
      text.classList.add("md:hidden")
    })
    this.sectionTitleTargets.forEach(title => {
      title.classList.add("md:hidden")
    })
  }

  // Show text elements when expanded
  showText() {
    if (this.hasCollapseTextTarget) {
      this.collapseTextTarget.classList.remove("md:hidden")
    }
    this.itemTextTargets.forEach(text => {
      text.classList.remove("md:hidden")
    })
    this.sectionTitleTargets.forEach(title => {
      title.classList.remove("md:hidden")
    })
  }

  // Save collapsed state to localStorage
  saveCollapsedState(collapsed) {
    try {
      localStorage.setItem("flatpack-navbar-collapsed", collapsed ? "true" : "false")
    } catch (e) {
      console.error("Failed to save navbar state:", e)
    }
  }

  // Load collapsed state from localStorage
  loadCollapsedState() {
    try {
      const collapsed = localStorage.getItem("flatpack-navbar-collapsed") === "true"
      if (collapsed && this.hasLeftNavTarget) {
        const nav = this.leftNavTarget
        nav.classList.remove("md:w-64")
        nav.classList.add("md:w-16")
        this.hideText()
        if (this.hasCollapseIconTarget) {
          this.collapseIconTarget.classList.add("rotate-180")
        }
      }
    } catch (e) {
      console.error("Failed to load navbar state:", e)
    }
  }
}
