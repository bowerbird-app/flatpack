import { Controller } from "@hotwired/stimulus"
import { prefersReducedMotion, motionDuration, motionTransition } from "controllers/flat_pack/reduced_motion"

const FOCUSABLE = [
  "a[href]",
  "button:not([disabled])",
  "input:not([disabled]):not([type='hidden'])",
  "select:not([disabled])",
  "textarea:not([disabled])",
  "iframe",
  "video[controls]",
  "audio[controls]",
  "[contenteditable]:not([contenteditable='false'])",
  "[tabindex]:not([tabindex='-1'])"
].join(", ")

const ACTIVATION_KEYS = new Set(["Enter", " "])

export default class extends Controller {
  static targets = ["poster", "player", "play"]

  connect() {
    this.played = false
  }

  disconnect() {
    this.clearFade()
  }

  play(event) {
    if (this.played || !this.activates(event)) return

    this.played = true
    event.preventDefault()
    this.reveal()
  }

  activates(event) {
    const target = event.target?.nodeType === 1 ? event.target : event.target?.parentElement
    if (!target) return false

    if (event.type === "keydown") {
      if (!ACTIVATION_KEYS.has(event.key)) return false
      return this.hasPlayTarget && this.playTarget.contains(target)
    }

    if (event.type !== "click") return false
    if (!this.hasPosterTarget || !this.posterTarget.contains(target)) return false

    const interactive = target.closest("a[href], button, input, select, textarea, [role='button']")
    if (!interactive) return true

    return this.hasPlayTarget && this.playTarget.contains(interactive)
  }

  reveal() {
    const poster = this.posterTarget
    const stage = this.element.ownerDocument.createElement("div")
    stage.className = "fp-video-preview__player"
    stage.append(this.playerTarget.content.cloneNode(true))
    poster.before(stage)
    this.focusPlayer(stage)
    this.element.dispatchEvent(new CustomEvent("flat-pack:video-preview:play", { bubbles: true }))

    if (prefersReducedMotion()) {
      poster.remove()
      return
    }

    poster.style.pointerEvents = "none"
    const duration = motionDuration("base")
    this.fadeFrame = requestAnimationFrame(() => {
      this.fadeFrame = null
      poster.style.transition = motionTransition("opacity", { duration: "base", easing: "exit" })
      poster.style.opacity = "0"
      this.fadeTimer = setTimeout(() => {
        this.fadeTimer = null
        poster.remove()
      }, duration)
    })
  }

  focusPlayer(stage) {
    const focusable = stage.querySelector(FOCUSABLE)
    if (focusable) {
      focusable.focus({ preventScroll: true })
      return
    }

    stage.tabIndex = -1
    stage.focus({ preventScroll: true })
  }

  clearFade() {
    if (this.fadeFrame != null) {
      cancelAnimationFrame(this.fadeFrame)
      this.fadeFrame = null
    }

    if (this.fadeTimer != null) {
      clearTimeout(this.fadeTimer)
      this.fadeTimer = null
    }
  }
}
