import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["surface", "tray"]

  connect() {
    if (!this.hasSurfaceTarget) {
      return
    }

    this.open = false
    this.setSurfaceOffset(false)
    this.setTrayVisibility(false)
  }

  toggle(event) {
    if (event.target.closest("button, a, input, textarea, select")) {
      return
    }

    this.open ? this.close() : this.openReveal()
  }

  toggleByKey(event) {
    if (event.key === "Enter" || event.key === " ") {
      event.preventDefault()
      this.open ? this.close() : this.openReveal()
      return
    }

    if (event.key === "Escape") {
      this.close()
    }
  }

  handleWindowClick(event) {
    if (!this.open) {
      return
    }

    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  handleWindowKeydown(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }

  handlePeerOpened(event) {
    if (event.target === this.element) {
      return
    }

    this.close()
  }

  handleEdit(event) {
    event.stopPropagation()

    this.dispatch("edit", {
      detail: {
        element: this.element
      }
    })

    this.close()
  }

  handleDelete(event) {
    event.stopPropagation()

    this.dispatch("delete", {
      detail: {
        element: this.element
      }
    })

    this.close()
  }

  openReveal() {
    if (!this.hasSurfaceTarget) {
      return
    }

    this.dispatch("opened", {bubbles: true})
    this.setSurfaceOffset(true)
    this.setTrayVisibility(true)
    this.surfaceTarget.setAttribute("aria-expanded", "true")
    this.open = true
  }

  close() {
    if (!this.hasSurfaceTarget) {
      return
    }

    this.setSurfaceOffset(false)
    this.setTrayVisibility(false)
    this.surfaceTarget.setAttribute("aria-expanded", "false")
    this.open = false
  }

  setSurfaceOffset(revealed) {
    if (!this.hasSurfaceTarget) {
      return
    }

    if (!revealed) {
      this.surfaceTarget.style.transform = "translateX(0)"
      return
    }

    const trayWidth = this.hasTrayTarget ? Math.ceil(this.trayTarget.getBoundingClientRect().width) : 0
    const offset = trayWidth > 0 ? trayWidth : 128
    const direction = this.direction()
    const signedOffset = direction === "incoming"
      ? offset
      : (direction === "outgoing" ? -offset : (this.side() === "left" ? offset : -offset))
    this.surfaceTarget.style.transform = `translateX(${signedOffset}px)`
  }

  setTrayVisibility(revealed) {
    if (!this.hasTrayTarget) {
      return
    }

    this.trayTarget.classList.toggle("opacity-0", !revealed)
    this.trayTarget.classList.toggle("pointer-events-none", !revealed)
    this.trayTarget.classList.toggle("opacity-100", revealed)
  }

  side() {
    const side = this.element.getAttribute("data-chat-message-actions-side-value")
    return side === "left" ? "left" : "right"
  }

  direction() {
    const direction = this.element.getAttribute("data-chat-message-actions-direction-value")
    return direction === "incoming" || direction === "outgoing" ? direction : null
  }
}
