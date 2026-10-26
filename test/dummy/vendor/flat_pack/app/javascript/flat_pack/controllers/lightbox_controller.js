import { Controller } from "@hotwired/stimulus"
import { prefersReducedMotion, motionDuration, motionTransition } from "controllers/flat_pack/reduced_motion"

// Native <dialog> supplies the backdrop, Escape, and the focus trap.
// This controller opens it on a group, plays the overlay motion, and
// returns focus to the trigger. Sliding stays on the carousel inside.
export default class extends Controller {
  static targets = ["dialog", "stage"]
  static values = {
    group: String
  }

  connect() {
    this.trigger = null
    this.closing = false
    this.closeTimer = null
    this.onDocumentClick = (event) => this.#onDocumentClick(event)
    this.onOpenRequest = (event) => this.#onOpenRequest(event)
    this.onCloseRequest = (event) => this.#onCloseRequest(event)
    document.addEventListener("click", this.onDocumentClick)
    document.addEventListener("flat-pack:lightbox:open", this.onOpenRequest)
    document.addEventListener("flat-pack:lightbox:close-request", this.onCloseRequest)
  }

  disconnect() {
    document.removeEventListener("click", this.onDocumentClick)
    document.removeEventListener("flat-pack:lightbox:open", this.onOpenRequest)
    document.removeEventListener("flat-pack:lightbox:close-request", this.onCloseRequest)
    this.#clearCloseTimer()

    if (this.element.open) {
      this.element.close()
    }
  }

  openAt(index, trigger) {
    const normalized = Number.isInteger(index) ? index : 0

    if (this.element.open) {
      this.#carouselApi()?.to(normalized)
      return
    }

    this.trigger = trigger instanceof HTMLElement ? trigger : null
    this.closing = false
    this.element.hidden = false
    this.#carouselApi()?.to(normalized)
    this.#prepareEnter()

    if (typeof this.element.showModal === "function") {
      this.element.showModal()
    }

    document.body.classList.add("overflow-hidden")
    this.#finishEnter()
    this.#focusStage()
  }

  close(event) {
    event?.preventDefault()
    event?.stopPropagation()
    this.requestClose()
  }

  clickBackdrop(event) {
    if (event.target.closest("[data-flat-pack--lightbox-target='stage']")) return
    if (event.target.closest("button, a, video, input, textarea, select")) return

    this.requestClose()
  }

  cancel(event) {
    event.preventDefault()
    this.requestClose()
  }

  keydown(event) {
    if (event.key !== "ArrowLeft" && event.key !== "ArrowRight") return
    if (event.target.closest("video, input, textarea, select")) return
    if (event.target.closest("[data-flat-pack--carousel-target='viewport']")) return

    const api = this.#carouselApi()
    if (!api) return

    event.preventDefault()
    const forward = event.key === "ArrowRight"
    const rtl = window.getComputedStyle(this.element).direction === "rtl"
    if (forward === rtl) {
      api.prev()
    } else {
      api.next()
    }
  }

  closed() {
    this.closing = false
    this.#clearCloseTimer()
    this.element.hidden = true
    this.element.style.opacity = ""
    this.element.style.scale = ""
    this.element.style.transition = ""
    document.body.classList.remove("overflow-hidden")

    const trigger = this.trigger
    this.trigger = null
    if (trigger instanceof HTMLElement && typeof trigger.focus === "function") {
      window.requestAnimationFrame(() => trigger.focus())
    }

    document.dispatchEvent(new CustomEvent("flat-pack:lightbox:close", {
      bubbles: true,
      detail: { group: this.groupValue }
    }))
  }

  requestClose() {
    if (this.closing || !this.element.open) return

    this.closing = true
    if (prefersReducedMotion() || motionDuration("base") === 0) {
      this.element.close()
      return
    }

    this.element.style.transition = motionTransition(["opacity", "scale"], { duration: "base", easing: "exit" })
    this.element.style.opacity = "0"
    this.element.style.scale = "0.96"

    const done = (event) => {
      if (event && event.target !== this.element) return
      if (!this.closing) return

      this.element.removeEventListener("transitionend", done)
      this.#clearCloseTimer()
      this.element.close()
    }

    this.element.addEventListener("transitionend", done)
    this.closeTimer = window.setTimeout(() => done(), motionDuration("base") + 40)
  }

  #onDocumentClick(event) {
    const trigger = event.target?.closest?.("[data-flat-pack-lightbox-group]")
    if (!trigger || trigger.dataset.flatPackLightboxGroup !== this.groupValue) return
    if (this.element.contains(trigger)) return
    // The carousel root keeps the group for its controller. It is not a click target.
    if (this.#isCarouselRoot(trigger)) return
    if (event.metaKey || event.ctrlKey || event.shiftKey || event.altKey || event.button) return

    event.preventDefault()
    const index = Number.parseInt(trigger.dataset.flatPackLightboxIndex || "0", 10)
    this.openAt(Number.isNaN(index) ? 0 : index, trigger)
  }

  #onOpenRequest(event) {
    if (event.detail?.group !== this.groupValue) return

    const index = Number.parseInt(event.detail?.index, 10)
    this.openAt(Number.isNaN(index) ? 0 : index, event.detail?.trigger)
  }

  #onCloseRequest(event) {
    if (event.detail?.group !== this.groupValue) return

    this.requestClose()
  }

  #isCarouselRoot(trigger) {
    const controllers = trigger.getAttribute?.("data-controller") || trigger.dataset?.controller || ""
    return controllers.split(/\s+/).includes("flat-pack--carousel")
  }

  #carouselApi() {
    const root = this.element.querySelector("[data-flat-pack-lightbox-stage='true']")
    return root?.flatPackCarousel || null
  }

  #focusStage() {
    const viewport = this.element.querySelector("[data-flat-pack--carousel-target='viewport']")
    if (viewport instanceof HTMLElement) {
      viewport.focus()
      return
    }

    const closeButton = this.element.querySelector("button")
    closeButton?.focus()
  }

  #prepareEnter() {
    const reduce = prefersReducedMotion()
    this.element.style.transition = "none"
    this.element.style.opacity = reduce ? "1" : "0"
    this.element.style.scale = reduce ? "1" : "0.96"
  }

  #finishEnter() {
    if (prefersReducedMotion()) return

    window.requestAnimationFrame(() => {
      this.element.style.transition = motionTransition(["opacity", "scale"], { duration: "slow", easing: "enter" })
      this.element.style.opacity = "1"
      this.element.style.scale = "1"
    })
  }

  #clearCloseTimer() {
    if (this.closeTimer == null) return

    window.clearTimeout(this.closeTimer)
    this.closeTimer = null
  }
}
