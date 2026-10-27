import { Controller } from "@hotwired/stimulus"
import {
  prefersReducedMotion,
  motionDuration,
  motionTransition,
  overlayOrigin,
  overlayEnterOffset
} from "controllers/flat_pack/reduced_motion"
import { onClickOutside } from "flat_pack/click_outside"
import { applyFixedPosition, place, readEdgeOffset, watchViewport } from "flat_pack/positioning"

const PANEL_GAP = 12

export default class extends Controller {
  static values = {
    triggerId: String,
    placement: { type: String, default: "bottom" }
  }

  connect() {
    this.isOpen = false
    this.hideTimeout = null
    this.resolvedPlacement = this.placementValue

    this.handleTriggerClick = this.handleTriggerClick.bind(this)
    this.handleEscape = this.handleEscape.bind(this)
    this.outsideClick = onClickOutside(document, () => this.close(), {
      capture: true,
      roots: () => [this.trigger, this.element],
      onlyWhen: () => this.isOpen
    })
    this.viewportWatch = watchViewport(() => {
      if (!this.isOpen) return
      this.position()
    })

    this.setupTrigger()
  }

  disconnect() {
    this.clearHideTimeout()
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

    const wasClosing = Boolean(this.hideTimeout)
    this.clearHideTimeout()
    this.isOpen = true
    this.trigger.setAttribute("aria-expanded", "true")
    this.element.classList.remove("hidden")
    this.element.setAttribute("aria-hidden", "false")

    if (!wasClosing) {
      this.element.style.transition = "none"
      this.element.style.opacity = "0"
      this.element.style.transform = "none"
      this.position()
      this.element.style.transformOrigin = overlayOrigin(this.resolvedPlacement)
      this.element.offsetHeight

      if (!prefersReducedMotion()) {
        this.element.style.transform = overlayEnterOffset(this.resolvedPlacement)
        this.element.offsetHeight
      }
    }

    this.element.style.transition = motionTransition(
      ["opacity", "transform"],
      { duration: "base", easing: "enter" }
    )

    requestAnimationFrame(() => {
      this.element.style.opacity = "1"
      this.element.style.transform = "none"
    })

    this.addListeners()
  }

  close() {
    this.isOpen = false
    this.removeListeners()
    this.trigger?.setAttribute("aria-expanded", "false")
    this.clearHideTimeout()

    this.element.style.transition = motionTransition(
      ["opacity", "transform"],
      { duration: "base", easing: "exit" }
    )
    this.element.style.opacity = "0"
    this.element.style.transform = prefersReducedMotion() ? "none" : overlayEnterOffset(this.resolvedPlacement)

    this.hideTimeout = setTimeout(() => {
      this.hideTimeout = null
      this.element.classList.add("hidden")
      this.element.setAttribute("aria-hidden", "true")
    }, motionDuration("base"))
  }

  handleEscape(event) {
    if (event.key !== "Escape" || !this.isOpen) return

    event.preventDefault()
    this.close()
    this.trigger?.focus()
  }

  addListeners() {
    this.outsideClick.add()
    document.addEventListener("keydown", this.handleEscape, true)
    this.viewportWatch.add()
  }

  removeListeners() {
    this.outsideClick?.remove()
    document.removeEventListener("keydown", this.handleEscape, true)
    this.viewportWatch?.remove()
  }

  position() {
    if (!this.trigger) return

    const placed = place(
      this.trigger.getBoundingClientRect(),
      this.element.getBoundingClientRect(),
      { width: window.innerWidth, height: window.innerHeight },
      {
        placement: this.placementValue,
        gap: PANEL_GAP,
        edge: readEdgeOffset(this.element)
      }
    )

    this.resolvedPlacement = placed.placement
    applyFixedPosition(this.element, placed)
    this.element.style.transformOrigin = overlayOrigin(this.resolvedPlacement)
  }

  preparePopoverA11y() {
    if (!this.element.id) {
      this.element.id = `flat-pack-popover-${Math.random().toString(36).slice(2, 10)}`
    }

    this.trigger?.setAttribute("aria-controls", this.element.id)
  }

  clearHideTimeout() {
    if (!this.hideTimeout) return

    clearTimeout(this.hideTimeout)
    this.hideTimeout = null
  }
}
