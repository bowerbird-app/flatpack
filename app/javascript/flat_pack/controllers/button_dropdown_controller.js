// FlatPack Button Dropdown Stimulus Controller
import { Controller } from "@hotwired/stimulus"
import { prefersReducedMotion, motionDuration, motionTransition } from "controllers/flat_pack/reduced_motion"
import { onClickOutside } from "flat_pack/click_outside"
import { focusableElements } from "flat_pack/focus_trap"
import { place, readEdgeOffset, watchViewport } from "flat_pack/positioning"

const ITEM_HOOK = "[data-flat-pack-dropdown-item]"

const MENU_GAP = 8

export default class extends Controller {
  static targets = ["trigger", "menu", "chevron"]
  static values = {
    maxHeight: String,
    placement: { type: String, default: "bottom_right" }
  }

  connect() {
    this.isOpen = false
    this.closeTimeout = null
    this.menuElement = this.menuTarget
    this.originalMenuParent = this.menuElement.parentNode
    this.originalMenuNextSibling = this.menuElement.nextSibling
    this.contextControllerElements = this.collectContextControllerElements()

    this.handleEscape = this.handleEscape.bind(this)
    this.handleFocusOut = this.handleFocusOut.bind(this)
    this.handleMenuItemClick = this.handleMenuItemClick.bind(this)
    this.outsideClick = onClickOutside(document, () => this.close(), {
      capture: true,
      roots: () => [this.element, this.menuElement]
    })
    this.viewportWatch = watchViewport(() => {
      if (!this.isOpen) return
      this.positionMenu()
    })
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

    this.menuElement.offsetHeight
    this.menuElement.style.transition = motionTransition(
      ["opacity", "transform"],
      { duration: "base", easing: "enter" }
    )

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
    this.menuElement.style.transition = motionTransition(
      ["opacity", "transform"],
      { duration: "base", easing: "exit" }
    )
    this.menuElement.classList.remove("opacity-100", "scale-100")
    this.menuElement.classList.add("opacity-0")
    if (!prefersReducedMotion()) {
      this.menuElement.classList.add("scale-95")
    }
    
    // Rotate chevron back
    if (this.hasChevronTarget) {
      this.chevronTarget.style.transform = "rotate(0deg)"
    }
    
    // Hide after animation completes
    this.closeTimeout = window.setTimeout(() => {
      this.menuElement.classList.add("hidden")
      this.menuElement.setAttribute("aria-hidden", "true")
      this.restoreMenu()
    }, motionDuration("base"))
    
    // Return focus to trigger
    if (returnFocus) {
      this.triggerTarget.focus()
    }
    
    // Remove event listeners
    this.removeListeners()
  }

  handleEscape(event) {
    if (!this.isOpen) return

    if (event.key === "Escape") {
      event.preventDefault()
      this.close()
      return
    }

    if (event.key === "Tab") {
      if (this.tabKeepsMenuOpen(event)) return

      event.preventDefault()
      this.close()
      return
    }

    if (!this.isActionMenu()) return

    if (this.keepsMenuOpen(event.target) && this.isFormField(event.target)) {
      return
    }

    if (event.key === "ArrowDown") {
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
    }
  }

  // Focus leaving the panel closes it. Tab on a role=menu also closes, and
  // returns focus to the trigger. A dialog panel keeps Tab inside.
  handleFocusOut(event) {
    if (!this.isOpen) return

    const next = event.relatedTarget
    if (next) {
      if (this.focusStaysInMenu(next)) return

      this.close({ returnFocus: false })
      return
    }

    requestAnimationFrame(() => {
      if (!this.isOpen) return
      if (this.focusStaysInMenu(document.activeElement)) return

      this.close({ returnFocus: false })
    })
  }

  // Only a dialog panel keeps Tab inside. A role=menu closes on Tab even
  // when the current item, or the next stop, is keep_open.
  tabKeepsMenuOpen(event) {
    if (this.isActionMenu()) return false

    if (this.keepsMenuOpen(event.target)) return true

    const next = this.tabStop(event.target, event.shiftKey)
    if (next && this.keepsMenuOpen(next)) return true
    if (next && this.menuElement.contains(next)) return true

    return false
  }

  focusStaysInMenu(node) {
    if (!node) return false
    if (node === this.triggerTarget) return true
    if (typeof this.element?.contains === "function" && this.element.contains(node)) return true
    if (typeof this.menuElement?.contains === "function" && this.menuElement.contains(node)) return true

    return this.keepsMenuOpen(node)
  }

  isActionMenu() {
    return this.menuElement.getAttribute("role") === "menu"
  }

  tabStop(from, shiftKey) {
    const stops = this.getTabStops()
    const index = stops.indexOf(from)
    if (index === -1) return null

    return stops[shiftKey ? index - 1 : index + 1] || null
  }

  getTabStops() {
    return focusableElements(this.menuElement).filter((item) => {
      if (typeof item.closest === "function" && item.closest("[hidden]")) return false
      if (typeof item.getAttribute === "function" && item.getAttribute("tabindex") === "-1") return false
      if (typeof item.getAttribute === "function" && item.getAttribute("aria-disabled") === "true") return false

      return true
    })
  }

  handleMenuItemClick(event) {
    if (this.keepsMenuOpen(event.target)) return

    const menuItem = event.target.closest(ITEM_HOOK)
    if (menuItem && this.menuElement.contains(menuItem)) {
      if (menuItem.matches("[disabled], [aria-disabled='true']")) return

      this.dispatchDetachedActions(menuItem, event)
      this.closeAfterAction()
      return
    }

    // A disclosure inside the menu calls preventDefault on its header.
    // An action row does not, so choosing it closes this menu.
    if (event.defaultPrevented) return

    const action = event.target.closest("a, button")
    if (!action || !this.menuElement.contains(action)) return
    if (action.matches("[disabled], [aria-disabled='true']")) return

    this.closeAfterAction()
  }

  keepsMenuOpen(node) {
    if (!node || typeof node.closest !== "function") return false
    if (!this.menuElement.contains(node)) return false

    return Boolean(node.closest("[data-flat-pack-dropdown-keep-open]"))
  }

  isFormField(node) {
    if (!node || !node.tagName) return false

    return /^(INPUT|SELECT|TEXTAREA)$/.test(node.tagName) || node.isContentEditable === true
  }

  closeAfterAction() {
    if (!this.isOpen) return

    requestAnimationFrame(() => {
      if (this.isOpen) this.close({ returnFocus: false })
    })
  }

  addListeners() {
    this.outsideClick.add()
    document.addEventListener("keydown", this.handleEscape, true)
    this.menuElement.addEventListener("focusout", this.handleFocusOut)
    this.viewportWatch.add()
    this.menuElement.addEventListener("click", this.handleMenuItemClick)
  }

  removeListeners() {
    this.outsideClick?.remove()
    document.removeEventListener("keydown", this.handleEscape, true)
    this.menuElement.removeEventListener("focusout", this.handleFocusOut)
    this.viewportWatch?.remove()
    this.menuElement.removeEventListener("click", this.handleMenuItemClick)
  }

  // Focus management methods
  getFocusableItems() {
    return Array.from(this.menuElement.querySelectorAll("a[href], button:not([disabled])")).filter((item) => {
      if (item.closest("[hidden]")) return false
      if (item.getAttribute("tabindex") === "-1") return false
      if (item.getAttribute("aria-disabled") === "true") return false

      return true
    })
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
    const menu = this.menuElement
    const placed = place(
      this.triggerTarget.getBoundingClientRect(),
      { width: menu.offsetWidth, height: menu.offsetHeight },
      { width: window.innerWidth, height: window.innerHeight },
      {
        placement: this.menuPlacement(),
        gap: MENU_GAP,
        edge: readEdgeOffset(menu),
        flip: false,
        stickToEdge: true
      }
    )

    menu.style.top = `${placed.top}px`
    menu.style.left = `${placed.left}px`
    menu.style.transformOrigin = this.originFor(placed.placement)
  }

  menuPlacement() {
    switch (this.placementValue) {
      case "bottom_left":
      case "top_right":
      case "top_left":
      case "bottom_right":
        return this.placementValue
      default:
        return "bottom_right"
    }
  }

  originFor(placement) {
    switch (placement) {
      case "bottom_left":
        return "top left"
      case "top_right":
        return "bottom right"
      case "top_left":
        return "bottom left"
      default:
        return "top right"
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
