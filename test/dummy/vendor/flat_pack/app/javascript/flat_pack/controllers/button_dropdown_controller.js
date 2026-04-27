// FlatPack Button Dropdown Stimulus Controller
import { Controller } from "@hotwired/stimulus"

const CLOSE_ANIMATION_DURATION = 200
const MENU_OFFSET = 8
const VIEWPORT_PADDING = 8

export default class extends Controller {
  static targets = ["trigger", "menu", "chevron"]
  static values = {
    maxHeight: String,
    position: { type: String, default: "bottom_right" }
  }

  connect() {
    this.isOpen = false
    this.closeTimeout = null
    this.menuOffset = MENU_OFFSET
    this.viewportPadding = VIEWPORT_PADDING
    this.menuElement = this.menuTarget
    this.originalMenuParent = this.menuElement.parentNode
    this.originalMenuNextSibling = this.menuElement.nextSibling
    this.contextControllerElements = this.collectContextControllerElements()

    // Bind methods to maintain context
    this.handleClickOutside = this.handleClickOutside.bind(this)
    this.handleEscape = this.handleEscape.bind(this)
    this.handleReposition = this.handleReposition.bind(this)
    this.handleMenuItemClick = this.handleMenuItemClick.bind(this)
  }

  disconnect() {
    this.clearCloseTimeout()
    this.removeListeners()
    this.restoreMenu()
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
    this.clearCloseTimeout()
    this.isOpen = true

    this.ensureMenuInBody()
    
    // Update ARIA state
    this.triggerTarget.setAttribute("aria-expanded", "true")
    
    // Show menu with animation
    this.menuElement.classList.remove("hidden")
    this.menuElement.setAttribute("aria-hidden", "false")
    this.positionMenu()
    
    // Trigger reflow to ensure animation works
    this.menuElement.offsetHeight
    
    this.menuElement.classList.remove("opacity-0", "scale-95")
    this.menuElement.classList.add("opacity-100", "scale-100")
    
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

  close({ returnFocus = true } = {}) {
    this.clearCloseTimeout()
    this.isOpen = false
    
    // Update ARIA state
    this.triggerTarget.setAttribute("aria-expanded", "false")
    
    // Hide menu with animation
    this.menuElement.classList.remove("opacity-100", "scale-100")
    this.menuElement.classList.add("opacity-0", "scale-95")
    
    // Rotate chevron back
    if (this.hasChevronTarget) {
      this.chevronTarget.style.transform = "rotate(0deg)"
    }
    
    // Hide after animation completes
    this.closeTimeout = window.setTimeout(() => {
      this.menuElement.classList.add("hidden")
      this.menuElement.setAttribute("aria-hidden", "true")
      this.restoreMenu()
    }, CLOSE_ANIMATION_DURATION)
    
    // Return focus to trigger
    if (returnFocus) {
      this.triggerTarget.focus()
    }
    
    // Remove event listeners
    this.removeListeners()
  }

  handleClickOutside(event) {
    // Close if click is outside the dropdown
    const clickedTrigger = this.element.contains(event.target)
    const clickedMenu = this.menuElement.contains(event.target)

    if (!clickedTrigger && !clickedMenu) {
      this.close()
    }
  }

  handleEscape(event) {
    if (!this.isOpen) return

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
      this.close({ returnFocus: false })
    }
  }

  handleReposition() {
    if (!this.isOpen) return

    this.positionMenu()
  }

  handleMenuItemClick(event) {
    const menuItem = event.target.closest('[role="menuitem"]')
    if (!menuItem || !this.menuElement.contains(menuItem) || menuItem.matches("[disabled], [aria-disabled='true']")) {
      return
    }

    this.dispatchDetachedActions(menuItem, event)

    if (!this.isOpen) return

    requestAnimationFrame(() => {
      if (this.isOpen) {
        this.close({ returnFocus: false })
      }
    })
  }

  addListeners() {
    // Use capture phase for click outside
    document.addEventListener("click", this.handleClickOutside, true)
    document.addEventListener("keydown", this.handleEscape, true)
    window.addEventListener("resize", this.handleReposition)
    window.addEventListener("scroll", this.handleReposition, true)
    this.menuElement.addEventListener("click", this.handleMenuItemClick)
  }

  removeListeners() {
    document.removeEventListener("click", this.handleClickOutside, true)
    document.removeEventListener("keydown", this.handleEscape, true)
    window.removeEventListener("resize", this.handleReposition)
    window.removeEventListener("scroll", this.handleReposition, true)
    this.menuElement.removeEventListener("click", this.handleMenuItemClick)
  }

  // Focus management methods
  getFocusableItems() {
    return Array.from(
      this.menuElement.querySelectorAll('[role="menuitem"]:not([tabindex="-1"])')
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

  clearCloseTimeout() {
    if (!this.closeTimeout) return

    window.clearTimeout(this.closeTimeout)
    this.closeTimeout = null
  }

  ensureMenuInBody() {
    if (this.menuElement.parentElement === document.body) return

    document.body.appendChild(this.menuElement)
  }

  restoreMenu() {
    if (!this.originalMenuParent || this.menuElement.parentElement === this.originalMenuParent) return

    if (this.originalMenuNextSibling?.parentNode === this.originalMenuParent) {
      this.originalMenuParent.insertBefore(this.menuElement, this.originalMenuNextSibling)
    } else {
      this.originalMenuParent.appendChild(this.menuElement)
    }
  }

  positionMenu() {
    const triggerRect = this.triggerTarget.getBoundingClientRect()
    const menuWidth = this.menuElement.offsetWidth
    const menuHeight = this.menuElement.offsetHeight
    const { top, left, transformOrigin } = this.computePosition(triggerRect, menuWidth, menuHeight)

    const maxTop = Math.max(this.viewportPadding, window.innerHeight - menuHeight - this.viewportPadding)
    const maxLeft = Math.max(this.viewportPadding, window.innerWidth - menuWidth - this.viewportPadding)

    this.menuElement.style.top = `${Math.min(Math.max(top, this.viewportPadding), maxTop)}px`
    this.menuElement.style.left = `${Math.min(Math.max(left, this.viewportPadding), maxLeft)}px`
    this.menuElement.style.transformOrigin = transformOrigin
  }

  computePosition(triggerRect, menuWidth, menuHeight) {
    switch (this.positionValue) {
      case "bottom_left":
        return {
          top: triggerRect.bottom + this.menuOffset,
          left: triggerRect.left,
          transformOrigin: "top left"
        }
      case "top_right":
        return {
          top: triggerRect.top - menuHeight - this.menuOffset,
          left: triggerRect.right - menuWidth,
          transformOrigin: "bottom right"
        }
      case "top_left":
        return {
          top: triggerRect.top - menuHeight - this.menuOffset,
          left: triggerRect.left,
          transformOrigin: "bottom left"
        }
      case "bottom_right":
      default:
        return {
          top: triggerRect.bottom + this.menuOffset,
          left: triggerRect.right - menuWidth,
          transformOrigin: "top right"
        }
    }
  }

  collectContextControllerElements() {
    const elements = []
    let current = this.element

    while (current) {
      const identifiers = (current.getAttribute("data-controller") || "")
        .split(/\s+/)
        .filter(Boolean)

      if (identifiers.length > 0) {
        elements.push({ element: current, identifiers })
      }

      current = current.parentElement
    }

    return elements
  }

  dispatchDetachedActions(menuItem, originalEvent) {
    const descriptors = (menuItem.dataset.action || "").split(/\s+/).filter(Boolean)

    descriptors.forEach((descriptor) => {
      const action = this.parseActionDescriptor(descriptor)
      if (!action || (action.eventName && action.eventName !== "click")) return

      if (action.identifier === "flat-pack--button-dropdown") {
        this.invokeControllerMethod(this, action.methodName, menuItem, originalEvent)
        return
      }

      const controllerElement = this.findContextControllerElement(action.identifier)
      if (!controllerElement) return

      const controller = this.application.getControllerForElementAndIdentifier(controllerElement, action.identifier)
      if (!controller) return

      this.invokeControllerMethod(controller, action.methodName, menuItem, originalEvent)
    })
  }

  parseActionDescriptor(descriptor) {
    const match = descriptor.match(/^(?:(.+?)->)?([^#]+)#(.+)$/)
    if (!match) return null

    const [, eventName, identifier, methodName] = match
    return { eventName, identifier, methodName }
  }

  findContextControllerElement(identifier) {
    const entry = this.contextControllerElements.find(({ identifiers }) => identifiers.includes(identifier))
    return entry?.element || null
  }

  invokeControllerMethod(controller, methodName, menuItem, originalEvent) {
    const method = controller?.[methodName]
    if (typeof method !== "function") return

    method.call(controller, {
      currentTarget: menuItem,
      target: originalEvent.target,
      detail: originalEvent.detail,
      preventDefault: () => originalEvent.preventDefault(),
      stopPropagation: () => originalEvent.stopPropagation()
    })
  }
}
