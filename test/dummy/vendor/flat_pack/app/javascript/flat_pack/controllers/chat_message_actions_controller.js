import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["surface", "tray"]
  static values = {
    direction: String,
    side: String
  }

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
      prefix: "chat-message-actions",
      detail: {
        element: this.element
      }
    })

    this.close()
  }

  handleDelete(event) {
    event.stopPropagation()

    this.dispatch("delete", {
      prefix: "chat-message-actions",
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

    this.dispatch("opened", { bubbles: true, prefix: "chat-message-actions" })
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
    const surfaceWidth = Math.ceil(this.surfaceTarget.getBoundingClientRect().width)
    const preferredOffset = trayWidth > 0 ? trayWidth : 128
    const maxOffset = Math.max(surfaceWidth - 24, 0)
    const offset = maxOffset > 0 ? Math.min(preferredOffset, maxOffset) : preferredOffset
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
    return this.hasSideValue && this.sideValue === "left" ? "left" : "right"
  }

  direction() {
    return this.hasDirectionValue && ["incoming", "outgoing"].includes(this.directionValue)
      ? this.directionValue
      : null
  }
}
