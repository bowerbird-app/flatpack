import { Controller } from "@hotwired/stimulus"

const FAN_X_OFFSETS = [0, 10, 24]
const FAN_Y_OFFSETS = [0, 6, 14]
const FAN_ROTATIONS = [0, 4, 8]
const TOUCH_PREVIEW_MS = 900

export default class extends Controller {
  static targets = ["card"]

  connect() {
    this.touchPreviewTimeout = null
    this.reducedMotion = this.prefersReducedMotion()

    if (this.reducedMotion) {
      this.cardTargets.forEach((card) => {
        card.style.transitionDuration = "1ms"
      })
    }

    this.applyBaseTransforms()
  }

  disconnect() {
    this.clearTouchPreviewTimeout()
  }

  fanOut() {
    this.cardTargets
      .slice()
      .sort((left, right) => this.cardIndex(left) - this.cardIndex(right))
      .forEach((card) => {
        const index = this.cardIndex(card)
        const fanX = FAN_X_OFFSETS[index] ?? FAN_X_OFFSETS[FAN_X_OFFSETS.length - 1]
        const fanY = FAN_Y_OFFSETS[index] ?? FAN_Y_OFFSETS[FAN_Y_OFFSETS.length - 1]
        const fanRotation = FAN_ROTATIONS[index] ?? FAN_ROTATIONS[FAN_ROTATIONS.length - 1]

        const xOffset = this.baseHorizontalOffset(index) + this.directionSign() * fanX
        const yOffset = this.baseVerticalOffset(index) + fanY
        const rotation = this.direction() === "incoming" ? fanRotation : -fanRotation

        this.applyTransform(card, xOffset, yOffset, rotation)
      })
  }

  collapse() {
    this.applyBaseTransforms()
  }

  collapseOnFocusOut(event) {
    if (this.element.contains(event.relatedTarget)) {
      return
    }

    this.collapse()
  }

  handlePointerDown(event) {
    if (event.pointerType !== "touch") {
      return
    }

    this.fanOut()
    this.clearTouchPreviewTimeout()
    this.touchPreviewTimeout = window.setTimeout(() => this.collapse(), TOUCH_PREVIEW_MS)
  }

  applyBaseTransforms() {
    this.cardTargets.forEach((card) => {
      const index = this.cardIndex(card)
      this.applyTransform(card, this.baseHorizontalOffset(index), this.baseVerticalOffset(index), 0)
    })
  }

  applyTransform(card, xOffset, yOffset, rotation) {
    card.style.transformOrigin = this.transformOrigin()
    card.style.transform = `translate(${xOffset}px, ${yOffset}px) rotate(${rotation}deg)`
  }

  direction() {
    const value = this.element.getAttribute("data-flat-pack-chat-image-deck-direction")
    return value === "outgoing" ? "outgoing" : "incoming"
  }

  directionSign() {
    return this.direction() === "incoming" ? 1 : -1
  }

  transformOrigin() {
    return this.direction() === "incoming" ? "16% 86%" : "84% 86%"
  }

  baseHorizontalOffset(index) {
    return this.directionSign() * this.overlapX() * index
  }

  baseVerticalOffset(index) {
    return this.overlapY() * index
  }

  overlapX() {
    return this.parseIntegerAttribute("data-flat-pack-chat-image-deck-overlap-x", 14)
  }

  overlapY() {
    return this.parseIntegerAttribute("data-flat-pack-chat-image-deck-overlap-y", 14)
  }

  cardIndex(card) {
    return this.parseIntegerAttribute("data-flat-pack-chat-image-deck-index", 0, card)
  }

  parseIntegerAttribute(name, fallback, element = this.element) {
    const parsed = Number.parseInt(element.getAttribute(name), 10)
    return Number.isNaN(parsed) ? fallback : parsed
  }

  clearTouchPreviewTimeout() {
    if (this.touchPreviewTimeout) {
      window.clearTimeout(this.touchPreviewTimeout)
      this.touchPreviewTimeout = null
    }
  }

  prefersReducedMotion() {
    return window.matchMedia("(prefers-reduced-motion: reduce)").matches
  }
}
