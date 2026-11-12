// Mounts the framed page on the first open and moves focus with the panel.
// Popover still positions the panel, toggles aria-expanded, and handles Escape.
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.placeOnBody()
    if (this.observer) return

    this.trigger = this.element.querySelector("[data-flat-pack--floating-frame-target='trigger']")
    this.open = this.trigger?.getAttribute("aria-expanded") === "true"
    this.onExpanded = this.onExpanded.bind(this)
    this.observer = new MutationObserver(this.onExpanded)

    if (!this.trigger) return

    this.observer.observe(this.trigger, {
      attributes: true,
      attributeFilter: ["aria-expanded"]
    })
  }

  disconnect() {
    // Moving the node onto the body makes Stimulus disconnect and connect
    // again. Putting it back here would repeat that forever.
    if (this.moving) return

    this.observer?.disconnect()
    this.observer = null
  }

  // Page shells often clip with overflow. Fixed positioning inside that box
  // cannot paint over a sidebar, so the whole frame moves to the body.
  placeOnBody() {
    if (typeof document === "undefined" || !document.body || typeof this.element?.before !== "function") return
    if (this.element.parentElement === document.body) return

    this.moving = true
    this.slot = document.createComment("flat-pack-floating-frame")
    this.element.before(this.slot)
    document.body.append(this.element)
    this.moving = false
  }

  onExpanded() {
    const open = this.trigger.getAttribute("aria-expanded") === "true"
    if (open === this.open) return

    this.open = open
    if (open) {
      this.mountFrame()
      this.focusPanel()
    } else {
      this.focusTrigger()
    }
  }

  mountFrame() {
    const template = this.element.querySelector("[data-flat-pack--floating-frame-target='source']")
    const mount = this.element.querySelector("[data-flat-pack--floating-frame-target='mount']")
    if (!template || !mount || mount.childElementCount > 0) return

    mount.append(template.content)
  }

  focusPanel() {
    const close = this.element.querySelector("[data-flat-pack--floating-frame-target='close']")
    this.afterFrame(() => close?.focus())
  }

  focusTrigger() {
    this.trigger?.focus()
  }

  afterFrame(callback) {
    if (typeof requestAnimationFrame === "function") {
      requestAnimationFrame(callback)
    } else {
      callback()
    }
  }
}
