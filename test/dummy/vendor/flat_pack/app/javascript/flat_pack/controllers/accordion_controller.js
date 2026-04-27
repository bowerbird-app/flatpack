// FlatPack Accordion Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["trigger", "content", "icon"]
  static values = {
    allowMultiple: { type: Boolean, default: false }
  }

  connect() {
    // Initialize state for each item
    this.contentTargets.forEach((content, index) => {
      const isOpen = content.dataset.flatPackAccordionOpen === "true"
      this.updateItemState(index, isOpen, false)
    })
  }

  toggle(event) {
    event.preventDefault()
    const trigger = event.currentTarget
    const index = this.triggerTargets.indexOf(trigger)
    const content = this.contentTargets[index]
    const isCurrentlyOpen = content.getAttribute("aria-expanded") !== "false"

    // If not allowing multiple, close all other items
    if (!this.allowMultipleValue && !isCurrentlyOpen) {
      this.contentTargets.forEach((otherContent, otherIndex) => {
        if (otherIndex !== index) {
          this.updateItemState(otherIndex, false, true)
        }
      })
    }

    // Toggle current item
    this.updateItemState(index, !isCurrentlyOpen, true)
  }

  updateItemState(index, isOpen, animate = true) {
    const trigger = this.triggerTargets[index]
    const content = this.contentTargets[index]
    const icons = this.iconTargets

    // Update aria-expanded
    trigger.setAttribute("aria-expanded", isOpen)
    content.setAttribute("aria-expanded", isOpen)

    // Toggle content visibility
    if (isOpen) {
      content.hidden = false
      if (animate) {
        requestAnimationFrame(() => {
          content.style.maxHeight = content.scrollHeight + "px"
        })
      } else {
        content.style.maxHeight = content.scrollHeight + "px"
      }
    } else {
      if (animate) {
        content.style.maxHeight = "0px"
        setTimeout(() => {
          content.hidden = true
        }, 300)
      } else {
        content.style.maxHeight = "0px"
        content.hidden = true
      }
    }

    // Rotate icon for this specific trigger
    if (icons[index]) {
      const icon = icons[index]
      if (isOpen) {
        icon.style.transform = "rotate(180deg)"
      } else {
        icon.style.transform = "rotate(0deg)"
      }
    }
  }
}
