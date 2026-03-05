import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["viewport", "frame", "slide", "indicator", "thumb", "caption", "counter"]

  static values = {
    initialIndex: { type: Number, default: 0 },
    loop: { type: Boolean, default: false },
    autoplay: { type: Boolean, default: false },
    autoplayInterval: { type: Number, default: 5000 },
    pauseOnHover: { type: Boolean, default: true },
    pauseOnFocus: { type: Boolean, default: true },
    touchSwipe: { type: Boolean, default: true },
    transition: { type: String, default: "slide" }
  }

  connect() {
    this.currentIndex = this.#clampIndex(this.initialIndexValue)
    this.autoplayTimer = null
    this.pauseReasons = new Set()
    this.activePointerId = null
    this.pointerStartX = null
    this.pointerStartY = null
    this.pointerLastX = null

    this.#bindInteropEvents()
    this.#bindViewportInteractions()
    this.#exposeApi()

    this.render({ emit: false })

    if (this.autoplayValue && !this.#prefersReducedMotion()) {
      this.play({ emit: false })
    }
  }

  disconnect() {
    this.#clearAutoplayTimer()
    this.#resetPointerDragState()
    this.#unbindInteropEvents()
    this.#unbindViewportInteractions()

    if (this.element.flatPackCarousel) {
      delete this.element.flatPackCarousel
    }
  }

  prev() {
    this.goToIndex(this.currentIndex - 1, { trigger: "prev" })
  }

  next() {
    this.goToIndex(this.currentIndex + 1, { trigger: "next" })
  }

  goTo(event) {
    const index = Number.parseInt(event?.currentTarget?.dataset?.index || "", 10)
    this.goToIndex(index, { trigger: "goTo" })
  }

  to(index) {
    this.goToIndex(index, { trigger: "to" })
  }

  goToIndex(index, options = {}) {
    if (!Number.isInteger(index) || this.slideTargets.length === 0) {
      return
    }

    const normalized = this.#normalizeIndex(index)
    if (normalized === null) {
      return
    }

    this.currentIndex = normalized
    this.render({ emit: options.emit !== false, trigger: options.trigger || "goToIndex" })
  }

  play(options = {}) {
    this.pauseReasons.delete("manual")
    this.#toggleAutoplay(options.emit !== false)
  }

  pause(options = {}) {
    this.pauseReasons.add("manual")
    this.#clearAutoplayTimer()

    if (options.emit !== false) {
      this.#dispatch("carousel:pause", { reason: "manual" })
    }
  }

  stop(options = {}) {
    this.pause(options)
  }

  refresh() {
    this.currentIndex = this.#clampIndex(this.currentIndex)
    this.render({ emit: false })
  }

  handleKeydown(event) {
    const isRtl = this.#isRtl()

    switch (event.key) {
      case "ArrowLeft":
        event.preventDefault()
        isRtl ? this.next() : this.prev()
        break
      case "ArrowRight":
        event.preventDefault()
        isRtl ? this.prev() : this.next()
        break
      case "Home":
        event.preventDefault()
        this.goToIndex(0, { trigger: "home" })
        break
      case "End":
        event.preventDefault()
        this.goToIndex(this.slideTargets.length - 1, { trigger: "end" })
        break
      case " ":
      case "Spacebar":
        event.preventDefault()
        if (this.autoplayTimer) {
          this.pause()
        } else {
          this.play()
        }
        break
      default:
        break
    }
  }

  render(options = {}) {
    const useFade = this.transitionValue === "fade"

    this.slideTargets.forEach((slide, index) => {
      const isActive = index === this.currentIndex

      if (useFade) {
        slide.hidden = false
        slide.classList.toggle("opacity-0", !isActive)
        slide.classList.toggle("opacity-100", isActive)
        slide.classList.toggle("pointer-events-none", !isActive)
      } else {
        slide.hidden = false
      }

      slide.setAttribute("aria-hidden", (!isActive).toString())
    })

    if (!useFade && this.hasFrameTarget) {
      this.frameTarget.style.transform = `translate3d(-${this.currentIndex * 100}%, 0, 0)`
    }

    this.indicatorTargets.forEach((indicator, index) => {
      const isActive = index === this.currentIndex
      indicator.classList.toggle("bg-[var(--carousel-indicator-active-background-color)]", isActive)
      indicator.classList.toggle("bg-[var(--carousel-indicator-background-color)]", !isActive)
      indicator.setAttribute("aria-current", isActive ? "true" : "false")
    })

    this.thumbTargets.forEach((thumb, index) => {
      const isActive = index === this.currentIndex
      thumb.classList.toggle("ring-2", isActive)
      thumb.classList.toggle("ring-primary", isActive)
      thumb.classList.toggle("opacity-60", !isActive)
      thumb.classList.toggle("opacity-100", isActive)
      thumb.setAttribute("aria-current", isActive ? "true" : "false")
    })

    if (this.hasCounterTarget) {
      this.counterTarget.textContent = `${this.currentIndex + 1} / ${this.slideTargets.length}`
    }

    if (this.hasCaptionTarget) {
      const activeSlide = this.slideTargets[this.currentIndex]
      this.captionTarget.textContent = activeSlide?.dataset?.caption || ""
    }

    if (options.emit !== false) {
      this.#dispatch("carousel:change", {
        index: this.currentIndex,
        slideCount: this.slideTargets.length,
        trigger: options.trigger || "render"
      })
    }
  }

  #bindInteropEvents() {
    this.interopHandlers = {
      "next.owl.carousel": () => this.next(),
      "prev.owl.carousel": () => this.prev(),
      "to.owl.carousel": (event) => {
        const detailIndex = event?.detail?.index
        const eventIndex = Number.isInteger(detailIndex) ? detailIndex : Number.parseInt(event?.target?.dataset?.index || "", 10)
        this.to(eventIndex)
      },
      "play.owl.autoplay": () => this.play(),
      "stop.owl.autoplay": () => this.stop()
    }

    Object.entries(this.interopHandlers).forEach(([eventName, handler]) => {
      this.element.addEventListener(eventName, handler)
    })
  }

  #unbindInteropEvents() {
    if (!this.interopHandlers) {
      return
    }

    Object.entries(this.interopHandlers).forEach(([eventName, handler]) => {
      this.element.removeEventListener(eventName, handler)
    })
  }

  #bindViewportInteractions() {
    if (!this.hasViewportTarget) {
      return
    }

    this.pointerDownHandler = (event) => {
      if (!this.touchSwipeValue || !this.#isPrimarySwipePointer(event)) {
        return
      }

      this.activePointerId = event.pointerId
      this.pointerStartX = event.clientX
      this.pointerStartY = event.clientY
      this.pointerLastX = event.clientX

      if (typeof this.viewportTarget.setPointerCapture === "function") {
        this.viewportTarget.setPointerCapture(event.pointerId)
      }

      if (event.pointerType === "mouse") {
        this.viewportTarget.classList.add("cursor-grabbing")
      }
    }

    this.pointerMoveHandler = (event) => {
      if (!this.touchSwipeValue || !this.#isActivePointer(event) || this.pointerStartX === null || this.pointerStartY === null) {
        return
      }

      this.pointerLastX = event.clientX
      const deltaX = event.clientX - this.pointerStartX
      const deltaY = event.clientY - this.pointerStartY

      if (Math.abs(deltaX) > Math.abs(deltaY)) {
        event.preventDefault()
      }
    }

    this.pointerUpHandler = (event) => {
      if (!this.touchSwipeValue || !this.#isActivePointer(event) || this.pointerStartX === null) {
        return
      }

      const endX = Number.isFinite(event.clientX) ? event.clientX : this.pointerLastX
      const deltaX = endX - this.pointerStartX

      this.#resetPointerDragState()

      if (Math.abs(deltaX) < this.#swipeThresholdPx()) {
        return
      }

      const isRtl = this.#isRtl()
      if (deltaX < 0) {
        isRtl ? this.prev() : this.next()
      } else {
        isRtl ? this.next() : this.prev()
      }
    }

    this.pointerCancelHandler = () => {
      this.#resetPointerDragState()
    }

    this.mouseDownHandler = (event) => {
      if (!this.touchSwipeValue || this.activePointerId !== null || event.button !== 0) {
        return
      }

      this.pointerStartX = event.clientX
      this.pointerStartY = event.clientY
      this.pointerLastX = event.clientX
      this.viewportTarget.classList.add("cursor-grabbing")
    }

    this.mouseMoveHandler = (event) => {
      if (!this.touchSwipeValue || this.pointerStartX === null || this.activePointerId !== null) {
        return
      }

      this.pointerLastX = event.clientX
      const deltaX = event.clientX - this.pointerStartX
      const deltaY = event.clientY - this.pointerStartY

      if (Math.abs(deltaX) > Math.abs(deltaY)) {
        event.preventDefault()
      }
    }

    this.mouseUpHandler = (event) => {
      if (!this.touchSwipeValue || this.pointerStartX === null || this.activePointerId !== null) {
        return
      }

      const deltaX = event.clientX - this.pointerStartX
      this.#resetPointerDragState()

      if (Math.abs(deltaX) < this.#swipeThresholdPx()) {
        return
      }

      const isRtl = this.#isRtl()
      if (deltaX < 0) {
        isRtl ? this.prev() : this.next()
      } else {
        isRtl ? this.next() : this.prev()
      }
    }

    this.dragStartHandler = (event) => {
      if (!this.touchSwipeValue) {
        return
      }

      event.preventDefault()
    }

    this.viewportTarget.addEventListener("pointerdown", this.pointerDownHandler)
    this.viewportTarget.addEventListener("pointermove", this.pointerMoveHandler)
    this.viewportTarget.addEventListener("pointerup", this.pointerUpHandler)
    this.viewportTarget.addEventListener("pointercancel", this.pointerCancelHandler)
    this.viewportTarget.addEventListener("lostpointercapture", this.pointerCancelHandler)
    this.viewportTarget.addEventListener("mousedown", this.mouseDownHandler)
    this.viewportTarget.addEventListener("mousemove", this.mouseMoveHandler)
    this.viewportTarget.addEventListener("mouseup", this.mouseUpHandler)
    this.viewportTarget.addEventListener("dragstart", this.dragStartHandler)

    if (this.pauseOnHoverValue) {
      this.hoverInHandler = () => {
        this.pauseReasons.add("hover")
        this.#toggleAutoplay(false)
      }

      this.hoverOutHandler = () => {
        this.pauseReasons.delete("hover")
        this.#toggleAutoplay(false)
      }

      this.viewportTarget.addEventListener("mouseenter", this.hoverInHandler)
      this.viewportTarget.addEventListener("mouseleave", this.hoverOutHandler)
    }

    if (this.pauseOnFocusValue) {
      this.focusInHandler = () => {
        this.pauseReasons.add("focus")
        this.#toggleAutoplay(false)
      }

      this.focusOutHandler = (event) => {
        if (this.element.contains(event.relatedTarget)) {
          return
        }

        this.pauseReasons.delete("focus")
        this.#toggleAutoplay(false)
      }

      this.viewportTarget.addEventListener("focusin", this.focusInHandler)
      this.viewportTarget.addEventListener("focusout", this.focusOutHandler)
    }
  }

  #unbindViewportInteractions() {
    if (!this.hasViewportTarget) {
      return
    }

    if (this.pointerDownHandler) {
      this.viewportTarget.removeEventListener("pointerdown", this.pointerDownHandler)
    }

    if (this.pointerUpHandler) {
      this.viewportTarget.removeEventListener("pointerup", this.pointerUpHandler)
    }

    if (this.pointerMoveHandler) {
      this.viewportTarget.removeEventListener("pointermove", this.pointerMoveHandler)
    }

    if (this.pointerCancelHandler) {
      this.viewportTarget.removeEventListener("pointercancel", this.pointerCancelHandler)
      this.viewportTarget.removeEventListener("lostpointercapture", this.pointerCancelHandler)
    }

    if (this.mouseDownHandler) {
      this.viewportTarget.removeEventListener("mousedown", this.mouseDownHandler)
    }

    if (this.mouseMoveHandler) {
      this.viewportTarget.removeEventListener("mousemove", this.mouseMoveHandler)
    }

    if (this.mouseUpHandler) {
      this.viewportTarget.removeEventListener("mouseup", this.mouseUpHandler)
    }

    if (this.dragStartHandler) {
      this.viewportTarget.removeEventListener("dragstart", this.dragStartHandler)
    }

    if (this.hoverInHandler) {
      this.viewportTarget.removeEventListener("mouseenter", this.hoverInHandler)
    }

    if (this.hoverOutHandler) {
      this.viewportTarget.removeEventListener("mouseleave", this.hoverOutHandler)
    }

    if (this.focusInHandler) {
      this.viewportTarget.removeEventListener("focusin", this.focusInHandler)
    }

    if (this.focusOutHandler) {
      this.viewportTarget.removeEventListener("focusout", this.focusOutHandler)
    }
  }

  #toggleAutoplay(emitEvent) {
    this.#clearAutoplayTimer()

    if (!this.autoplayValue || this.pauseReasons.size > 0 || this.slideTargets.length <= 1) {
      if (emitEvent) {
        this.#dispatch("carousel:pause", { reason: "state" })
      }
      return
    }

    this.autoplayTimer = window.setInterval(() => {
      this.next()
    }, this.autoplayIntervalValue)

    if (emitEvent) {
      this.#dispatch("carousel:play", { interval: this.autoplayIntervalValue })
    }
  }

  #clearAutoplayTimer() {
    if (this.autoplayTimer) {
      window.clearInterval(this.autoplayTimer)
      this.autoplayTimer = null
    }
  }

  #normalizeIndex(index) {
    if (this.slideTargets.length === 0) {
      return null
    }

    if (this.loopValue) {
      const length = this.slideTargets.length
      return ((index % length) + length) % length
    }

    if (index < 0 || index >= this.slideTargets.length) {
      return null
    }

    return index
  }

  #clampIndex(index) {
    if (this.slideTargets.length === 0) {
      return 0
    }

    if (!Number.isInteger(index)) {
      return 0
    }

    return Math.max(0, Math.min(index, this.slideTargets.length - 1))
  }

  #prefersReducedMotion() {
    return Boolean(window.matchMedia && window.matchMedia("(prefers-reduced-motion: reduce)").matches)
  }

  #isRtl() {
    const direction = window.getComputedStyle(this.element).direction
    return direction === "rtl"
  }

  #dispatch(name, detail = {}) {
    this.element.dispatchEvent(new CustomEvent(name, {
      bubbles: true,
      detail
    }))
  }

  #isPrimarySwipePointer(event) {
    if (event.isPrimary === false) {
      return false
    }

    if (event.pointerType === "mouse" && event.button !== 0) {
      return false
    }

    return true
  }

  #isActivePointer(event) {
    return this.activePointerId !== null && event.pointerId === this.activePointerId
  }

  #swipeThresholdPx() {
    if (!this.hasViewportTarget) {
      return 35
    }

    return Math.max(35, Math.round(this.viewportTarget.clientWidth * 0.1))
  }

  #resetPointerDragState() {
    if (this.hasViewportTarget && this.activePointerId !== null && this.viewportTarget.hasPointerCapture?.(this.activePointerId)) {
      this.viewportTarget.releasePointerCapture(this.activePointerId)
    }

    this.activePointerId = null
    this.pointerStartX = null
    this.pointerStartY = null
    this.pointerLastX = null

    if (this.hasViewportTarget) {
      this.viewportTarget.classList.remove("cursor-grabbing")
    }
  }

  #exposeApi() {
    this.element.flatPackCarousel = {
      next: () => this.next(),
      prev: () => this.prev(),
      goTo: (index) => this.to(index),
      to: (index) => this.to(index),
      play: () => this.play(),
      pause: () => this.pause(),
      stop: () => this.stop(),
      refresh: () => this.refresh()
    }
  }
}
