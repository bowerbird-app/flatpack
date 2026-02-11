import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["topNav", "leftNav", "collapseIcon", "itemText", "sectionTitle", "badge", "navItem"]
  static values = {
    leftNavWidth: String,
    leftNavCollapsedWidth: String,
    topNavHeight: String,
    collapsed: Boolean
  }

  connect() {
    this.transitionEndHandler = this.handleTransitionEnd.bind(this)
    this.updateLeftNavWidth()
    this.updateTextVisibility()
  }

  disconnect() {
    if (this.hasLeftNavTarget) {
      this.leftNavTarget.removeEventListener("transitionend", this.transitionEndHandler)
    }
  }

  toggleLeftNav() {
    this.collapsedValue = !this.collapsedValue
  }

  collapsedValueChanged() {
    this.updateLeftNavWidth()
    this.rotateCollapseIcon()
    this.updateTextVisibility()
  }

  handleTransitionEnd(event) {
    // Only apply aspect-ratio after the width transition completes
    if (event.propertyName === "width" && this.collapsedValue) {
      this.applyAspectRatio()
    }
  }

  updateLeftNavWidth() {
    if (!this.hasLeftNavTarget) return

    const width = this.collapsedValue ? this.leftNavCollapsedWidthValue : this.leftNavWidthValue
    this.leftNavTarget.style.width = width
    
    // Update CSS variable for main content margin
    this.element.style.setProperty("--navbar-left-nav-width", width)
    
    // Listen for transition end to apply aspect-ratio after collapse animation
    if (this.collapsedValue) {
      this.leftNavTarget.removeEventListener("transitionend", this.transitionEndHandler)
      this.leftNavTarget.addEventListener("transitionend", this.transitionEndHandler, { once: true })
    }
  }

  rotateCollapseIcon() {
    if (!this.hasCollapseIconTarget) return

    if (this.collapsedValue) {
      this.collapseIconTarget.style.transform = "rotate(180deg)"
    } else {
      this.collapseIconTarget.style.transform = "rotate(0deg)"
    }
  }

  updateTextVisibility() {
    // Center nav items when collapsed - aspect-ratio will be set after transition
    this.navItemTargets.forEach(item => {
      if (this.collapsedValue) {
        item.classList.add("justify-center")
        item.style.gap = "0"
        item.style.width = "auto"
        // Don't set aspect-ratio here - will be set after transition completes
      } else {
        item.classList.remove("justify-center")
        item.style.gap = ""
        item.style.aspectRatio = ""
        item.style.width = ""
      }
    })

    // Hide/show item text
    this.itemTextTargets.forEach(text => {
      if (this.collapsedValue) {
        text.style.opacity = "0"
        text.style.width = "0"
        text.style.overflow = "hidden"
      } else {
        text.style.opacity = "1"
        text.style.width = "auto"
        text.style.overflow = "visible"
      }
    })

    // Hide/show section titles
    this.sectionTitleTargets.forEach(title => {
      if (this.collapsedValue) {
        title.style.opacity = "0"
        title.style.height = "0"
        title.style.overflow = "hidden"
      } else {
        title.style.opacity = "1"
        title.style.height = "auto"
        title.style.overflow = "visible"
      }
    })

    // Hide/show badges
    this.badgeTargets.forEach(badge => {
      if (this.collapsedValue) {
        badge.style.opacity = "0"
        badge.style.width = "0"
        badge.style.overflow = "hidden"
      } else {
        badge.style.opacity = "1"
        badge.style.width = "auto"
        badge.style.overflow = "visible"
      }
    })
  }

  applyAspectRatio() {
    // Apply aspect-ratio only after the collapse transition completes
    this.navItemTargets.forEach(item => {
      item.style.aspectRatio = "1"
    })
  }
}
