// Disclosure for a collapsing button group. CSS owns the row and the menu.
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["trigger", "panel"]

  connect() {
    this.open = this.element.dataset.open === "true"
    this.onPointerDown = this.onPointerDown.bind(this)
    this.onKeyDown = this.onKeyDown.bind(this)
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

  onPointerDown(event) {
    if (this.element.contains(event.target)) return
    if (this.pointerInChildMenu(event.target)) return

    this.close()
  }

  // A child dropdown moves its menu to document.body and stamps the dropdown id.
  pointerInChildMenu(target) {
    const menu = target.closest?.("[data-flat-pack--button-dropdown-target='menu']")
    if (!menu) return false

    const ownerId = menu.getAttribute("data-flat-pack-dropdown-owner")
    if (!ownerId) return false

    const owner = document.getElementById(ownerId)
    return Boolean(owner && this.element.contains(owner))
  }

  onKeyDown(event) {
    if (event.key !== "Escape" || !this.open) return

    event.preventDefault()
    event.stopPropagation()
    this.close()
    this.triggerTarget.focus()
  }

  bind() {
    document.addEventListener("pointerdown", this.onPointerDown)
    document.addEventListener("keydown", this.onKeyDown)
  }

  unbind() {
    document.removeEventListener("pointerdown", this.onPointerDown)
    document.removeEventListener("keydown", this.onKeyDown)
  }
}
