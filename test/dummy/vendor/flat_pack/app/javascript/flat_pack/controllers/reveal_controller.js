import { Controller } from "@hotwired/stimulus"
import { prefersReducedMotion } from "controllers/flat_pack/reduced_motion"

// Flips is-revealed once when the element enters the viewport.
// The resting CSS is the final state, so no JS and reduced motion stay visible.
export default class extends Controller {
  static values = {
    stagger: { type: Boolean, default: false }
  }

  connect() {
    if (prefersReducedMotion()) return
    if (this.element.classList.contains("is-revealed")) return

    this.assignStaggerIndexes()
    this.element.classList.add("is-pending")
    this.observer = new IntersectionObserver((entries) => this.onIntersect(entries))
    this.observer.observe(this.element)

    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        this.armed = true
        if (this.waiting) this.finish()
      })
    })
  }

  disconnect() {
    this.stopped = true
    this.observer?.disconnect()
    this.observer = null
  }

  onIntersect(entries) {
    if (!entries.some((entry) => entry.isIntersecting)) return

    if (this.armed) {
      this.finish()
    } else {
      this.waiting = true
    }
  }

  finish() {
    if (this.done || this.stopped) return

    this.done = true
    this.observer?.disconnect()
    this.observer = null
    this.element.classList.add("is-revealed")
    this.element.classList.remove("is-pending")
  }

  assignStaggerIndexes() {
    if (!this.staggerValue) return

    let index = 0
    Array.from(this.element.children).forEach((child) => {
      if (child.classList.contains("fp-reveal__plain")) return
      if (child.style.getPropertyValue("--reveal-index") !== "") return

      child.style.setProperty("--reveal-index", String(index))
      index += 1
    })
  }
}
