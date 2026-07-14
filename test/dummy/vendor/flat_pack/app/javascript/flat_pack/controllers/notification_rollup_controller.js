import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["trigger", "content", "icon", "row"]

  connect() {
    this.closeAll()
  }

  toggle(event) {
    event.preventDefault()

    const trigger = event.currentTarget
    const index = this.triggerTargets.indexOf(trigger)
    if (index < 0) return

    const isOpen = trigger.getAttribute("aria-expanded") === "true"

    if (isOpen) {
      this.updateItemState(index, false)
      return
    }

    this.closeAll(index)
    this.updateItemState(index, true)
  }

  closeAll(exceptIndex = null) {
    this.triggerTargets.forEach((_, index) => {
      if (index === exceptIndex) return

      this.updateItemState(index, false)
    })
  }

  updateItemState(index, isOpen) {
    const trigger = this.triggerTargets[index]
    const content = this.contentTargets[index]
    const icon = this.iconTargets[index]
    const row = this.rowTargets[index]

    if (!trigger || !content) return

    trigger.setAttribute("aria-expanded", isOpen ? "true" : "false")
    if (row) {
      row.classList.toggle("hidden", !isOpen)
    }
    content.hidden = !isOpen

    if (icon) {
      icon.style.transform = isOpen ? "rotate(180deg)" : "rotate(0deg)"
    }
  }
}
