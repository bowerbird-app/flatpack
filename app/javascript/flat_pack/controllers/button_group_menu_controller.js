// Disclosure for a collapsing button group. CSS owns the row and the menu.
import { Controller } from "@hotwired/stimulus"
import { onClickOutside } from "flat_pack/click_outside"

export default class extends Controller {
  static targets = ["trigger", "panel"]

  connect() {
    this.open = this.element.dataset.open === "true"
    this.onKeyDown = this.onKeyDown.bind(this)
    this.outsideClick = onClickOutside(document, () => this.close(), {
      event: "pointerdown",
      roots: () => this.element
    })
    this.triggerTarget.setAttribute("aria-expanded", this.open ? "true" : "false")
    if (this.open) this.bind()
  }

  disconnect() {
    this.unbind()
  }

  toggle(event) {
    event.preventDefault()
    if (this.open) {
      this.close()
    } else {
      this.show()
    }
  }

  show() {
    this.open = true
    this.element.dataset.open = "true"
    this.triggerTarget.setAttribute("aria-expanded", "true")
    this.bind()
  }

  close() {
    if (!this.open) return

    this.open = false
    this.element.dataset.open = "false"
    this.triggerTarget.setAttribute("aria-expanded", "false")
    this.unbind()
  }

  onKeyDown(event) {
    if (event.key !== "Escape" || !this.open) return

    event.preventDefault()
    event.stopPropagation()
    this.close()
    this.triggerTarget.focus()
  }

  bind() {
    this.outsideClick.add()
    document.addEventListener("keydown", this.onKeyDown)
  }

  unbind() {
    this.outsideClick?.remove()
    document.removeEventListener("keydown", this.onKeyDown)
  }
}
