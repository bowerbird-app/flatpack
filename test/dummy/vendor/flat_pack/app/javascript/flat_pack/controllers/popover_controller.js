import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    triggerId: String,
    placement: { type: String, default: "bottom" }
  }

  connect() {
    this.spacing = 12
    this.viewportPadding = 8
    this.isOpen = false

    this.handleTriggerClick = this.handleTriggerClick.bind(this)
    this.handleDocumentClick = this.handleDocumentClick.bind(this)
    this.handleEscape = this.handleEscape.bind(this)
    this.handleReposition = this.handleReposition.bind(this)

    this.setupTrigger()
  }

  disconnect() {
    this.removeTriggerListener()
    this.removeListeners()
  }

  setupTrigger() {
    if (!this.triggerIdValue) return

    this.trigger = document.getElementById(this.triggerIdValue)
    if (!this.trigger) return

    this.trigger.addEventListener("click", this.handleTriggerClick)
    this.trigger.setAttribute("aria-haspopup", "dialog")
    this.trigger.setAttribute("aria-expanded", "false")
    this.preparePopoverA11y()
  }

  removeTriggerListener() {
    if (!this.trigger) return
    this.trigger.removeEventListener("click", this.handleTriggerClick)
  }

  handleTriggerClick(event) {
    event.preventDefault()
    event.stopPropagation()

    if (this.isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    if (!this.trigger) return

    this.isOpen = true
    this.element.classList.remove("hidden")
    this.element.setAttribute("aria-hidden", "false")
    this.position()
    this.trigger.setAttribute("aria-expanded", "true")
    this.addListeners()
  }

  close() {
    this.isOpen = false
    this.removeListeners()
    this.element.classList.add("hidden")
    this.element.setAttribute("aria-hidden", "true")
    this.trigger?.setAttribute("aria-expanded", "false")
  }

  handleDocumentClick(event) {
    if (!this.isOpen) return

    const clickedTrigger = this.trigger && this.trigger.contains(event.target)
    const clickedPopover = this.element.contains(event.target)

    if (!clickedTrigger && !clickedPopover) {
      this.close()
    }
  }

  handleEscape(event) {
    if (event.key !== "Escape" || !this.isOpen) return

    event.preventDefault()
    this.close()
    this.trigger?.focus()
  }

  handleReposition() {
    if (!this.isOpen) return
    this.position()
  }

  addListeners() {
    document.addEventListener("click", this.handleDocumentClick, true)
    document.addEventListener("keydown", this.handleEscape, true)
    window.addEventListener("resize", this.handleReposition)
    window.addEventListener("scroll", this.handleReposition, true)
  }

  removeListeners() {
    document.removeEventListener("click", this.handleDocumentClick, true)
    document.removeEventListener("keydown", this.handleEscape, true)
    window.removeEventListener("resize", this.handleReposition)
    window.removeEventListener("scroll", this.handleReposition, true)
  }

  position() {
    if (!this.trigger) return

    const triggerRect = this.trigger.getBoundingClientRect()
    const popoverRect = this.element.getBoundingClientRect()

    const placement = this.resolvePlacement(this.placementValue, triggerRect, popoverRect)
    const { top, left } = this.computePosition(placement, triggerRect, popoverRect)

    const clampedTop = Math.min(
      Math.max(top, this.viewportPadding),
      window.innerHeight - popoverRect.height - this.viewportPadding
    )

    const clampedLeft = Math.min(
      Math.max(left, this.viewportPadding),
      window.innerWidth - popoverRect.width - this.viewportPadding
    )

    this.element.style.position = "fixed"
    this.element.style.top = `${clampedTop}px`
    this.element.style.left = `${clampedLeft}px`
  }

  resolvePlacement(placement, triggerRect, popoverRect) {
    const fitsTop = triggerRect.top - popoverRect.height - this.spacing >= this.viewportPadding
    const fitsBottom = triggerRect.bottom + this.spacing + popoverRect.height <= window.innerHeight - this.viewportPadding
    const fitsLeft = triggerRect.left - popoverRect.width - this.spacing >= this.viewportPadding
    const fitsRight = triggerRect.right + this.spacing + popoverRect.width <= window.innerWidth - this.viewportPadding

    switch (placement) {
      case "top":
        return fitsTop ? "top" : "bottom"
      case "bottom":
        return fitsBottom ? "bottom" : "top"
      case "left":
        return fitsLeft ? "left" : "right"
      case "right":
        return fitsRight ? "right" : "left"
      default:
        return fitsBottom ? "bottom" : "top"
    }
  }

  computePosition(placement, triggerRect, popoverRect) {
    switch (placement) {
      case "top":
        return {
          top: triggerRect.top - popoverRect.height - this.spacing,
          left: triggerRect.left + (triggerRect.width / 2) - (popoverRect.width / 2)
        }
      case "bottom":
        return {
          top: triggerRect.bottom + this.spacing,
          left: triggerRect.left + (triggerRect.width / 2) - (popoverRect.width / 2)
        }
      case "left":
        return {
          top: triggerRect.top + (triggerRect.height / 2) - (popoverRect.height / 2),
          left: triggerRect.left - popoverRect.width - this.spacing
        }
      case "right":
      default:
        return {
          top: triggerRect.top + (triggerRect.height / 2) - (popoverRect.height / 2),
          left: triggerRect.right + this.spacing
        }
    }
  }

  preparePopoverA11y() {
    if (!this.element.id) {
      this.element.id = `flat-pack-popover-${Math.random().toString(36).slice(2, 10)}`
    }

    this.trigger?.setAttribute("aria-controls", this.element.id)
  }
}
