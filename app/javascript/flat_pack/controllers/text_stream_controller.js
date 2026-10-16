import { Controller } from "@hotwired/stimulus"
import { prefersReducedMotion } from "controllers/flat_pack/reduced_motion"

// Types the visible copy once the line is in view.
// The source text stays in the DOM for screen readers. The caret is decorative.
export default class extends Controller {
  static targets = ["source", "live", "typed", "caret"]

  connect() {
    if (prefersReducedMotion()) return
    if (!this.hasSourceTarget || !this.hasTypedTarget) return

    this.glyphs = Array.from(this.sourceTarget.textContent)
    this.index = 0
    this.arm()
    this.observer = new IntersectionObserver((entries) => this.onIntersect(entries))
    this.observer.observe(this.element)
  }

  disconnect() {
    this.observer?.disconnect()
    this.observer = null
    if (this.timer != null) {
      clearTimeout(this.timer)
      this.timer = null
    }
  }

  onIntersect(entries) {
    if (!entries.some((entry) => entry.isIntersecting)) return

    this.observer?.disconnect()
    this.observer = null
    this.start()
  }

  arm() {
    this.element.classList.add("is-streaming")
    if (this.hasLiveTarget) this.liveTarget.hidden = false
    if (this.hasCaretTarget) this.caretTarget.hidden = false
  }

  start() {
    if (this.started) return

    this.started = true
    this.arm()
    this.delay = this.readDelay()
    this.tick()
  }

  tick() {
    if (this.index >= this.glyphs.length) {
      if (this.hasCaretTarget) this.caretTarget.hidden = true
      return
    }

    this.index += 1
    this.typedTarget.textContent = this.glyphs.slice(0, this.index).join("")
    this.timer = setTimeout(() => this.tick(), this.delay)
  }

  readDelay() {
    const raw = getComputedStyle(this.element).getPropertyValue("--reveal-stagger")
    const ms = Number.parseFloat(raw)
    if (!Number.isFinite(ms) || ms <= 0) return 32

    return Math.min(80, Math.max(12, Math.round(ms)))
  }
}
