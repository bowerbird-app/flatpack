// FlatPack Button Dropdown Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["trigger", "menu", "chevron"]
  static values = {
    maxHeight: String
  }

  connect() {
    this.isOpen = false
    // Bind methods to maintain context
    this.handleClickOutside = this.handleClickOutside.bind(this)
    this.handleEscape = this.handleEscape.bind(this)
  }

  disconnect() {
    this.removeListeners()
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()
    
    if (this.isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.isOpen = true
    
    // Update ARIA state
    this.triggerTarget.setAttribute("aria-expanded", "true")
    
    // Show menu with animation
    this.menuTarget.classList.remove("hidden")
    
    // Trigger reflow to ensure animation works
    this.menuTarget.offsetHeight
    
    this.menuTarget.classList.remove("opacity-0", "scale-95")
    this.menuTarget.classList.add("opacity-100", "scale-100")
    
    // Rotate chevron
    if (this.hasChevronTarget) {
      this.chevronTarget.style.transform = "rotate(180deg)"
    }
    
    // Focus first menu item
    setTimeout(() => {
      this.focusFirstItem()
    }, 0)
    
    // Add event listeners
    this.addListeners()
  }

  close() {
    this.isOpen = false
    
    // Update ARIA state
    this.triggerTarget.setAttribute("aria-expanded", "false")
    
    // Hide menu with animation
    this.menuTarget.classList.remove("opacity-100", "scale-100")
    this.menuTarget.classList.add("opacity-0", "scale-95")
    
    // Rotate chevron back
    if (this.hasChevronTarget) {
      this.chevronTarget.style.transform = "rotate(0deg)"
    }
    
    // Hide after animation completes
    setTimeout(() => {
      this.menuTarget.classList.add("hidden")
    }, 200)
    
    // Return focus to trigger
    this.triggerTarget.focus()
    
    // Remove event listeners
    this.removeListeners()
  }

  handleClickOutside(event) {
    // Close if click is outside the dropdown
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  handleEscape(event) {
    if (event.key === "Escape") {
      event.preventDefault()
      this.close()
    } else if (event.key === "ArrowDown") {
      event.preventDefault()
      this.focusNextItem()
    } else if (event.key === "ArrowUp") {
      event.preventDefault()
      this.focusPreviousItem()
    } else if (event.key === "Home") {
      event.preventDefault()
      this.focusFirstItem()
    } else if (event.key === "End") {
      event.preventDefault()
      this.focusLastItem()
    } else if (event.key === "Tab") {
      // Allow tab but close menu
      this.close()
    }
  }

  addListeners() {
    // Use capture phase for click outside
    document.addEventListener("click", this.handleClickOutside, true)
    document.addEventListener("keydown", this.handleEscape, true)
  }

  removeListeners() {
    document.removeEventListener("click", this.handleClickOutside, true)
    document.removeEventListener("keydown", this.handleEscape, true)
  }

  // Focus management methods
  getFocusableItems() {
    return Array.from(
      this.menuTarget.querySelectorAll('[role="menuitem"]:not([tabindex="-1"])')
    )
  }

  focusFirstItem() {
    const items = this.getFocusableItems()
    if (items.length > 0) {
      items[0].focus()
    }
  }

  focusLastItem() {
    const items = this.getFocusableItems()
    if (items.length > 0) {
      items[items.length - 1].focus()
    }
  }

  focusNextItem() {
    const items = this.getFocusableItems()
    const currentIndex = items.indexOf(document.activeElement)
    
    if (currentIndex === -1) {
      this.focusFirstItem()
    } else {
      const nextIndex = (currentIndex + 1) % items.length
      items[nextIndex].focus()
    }
  }

  focusPreviousItem() {
    const items = this.getFocusableItems()
    const currentIndex = items.indexOf(document.activeElement)
    
    if (currentIndex === -1) {
      this.focusLastItem()
    } else {
      const previousIndex = currentIndex === 0 ? items.length - 1 : currentIndex - 1
      items[previousIndex].focus()
    }
  }
}
