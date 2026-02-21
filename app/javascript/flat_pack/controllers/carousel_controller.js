import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "viewport", "track", "slide", "prevButton", "nextButton",
    "indicator", "counter", "liveRegion", "progressBar",
    "thumbnail", "thumbnailStrip"
  ]

  static values = {
    autoplay: { type: Boolean, default: false },
    interval: { type: Number, default: 5000 },
    loop: { type: Boolean, default: true },
    transition: { type: String, default: "slide" },
    swipe: { type: Boolean, default: true },
    startSlide: { type: Number, default: 0 },
    pauseOnHover: { type: Boolean, default: true },
    keyboard: { type: Boolean, default: true }
  }

  connect() {
    this.currentIndex = Math.min(Math.max(this.startSlideValue, 0), this.slideTargets.length - 1)
    this.autoplayTimer = null
    this.touchStartX = null
    this.pointerStartX = null

    this.boundHandleKeydown = this.handleKeydown.bind(this)
    this.boundHandleMouseEnter = this.handleMouseEnter.bind(this)
    this.boundHandleMouseLeave = this.handleMouseLeave.bind(this)
    this.boundMotionChange = () => this.goToIndex(this.currentIndex, false)

    this.reducedMotionMedia = window.matchMedia("(prefers-reduced-motion: reduce)")
    this.reducedMotionMedia.addEventListener("change", this.boundMotionChange)

    if (this.keyboardValue) {
      this.element.addEventListener("keydown", this.boundHandleKeydown)
    }

    if (this.pauseOnHoverValue) {
      this.element.addEventListener("mouseenter", this.boundHandleMouseEnter)
      this.element.addEventListener("mouseleave", this.boundHandleMouseLeave)
    }

    if (this.swipeValue) {
      this.setupTouchEvents()
    }

    this.goToIndex(this.currentIndex, false)

    if (this.autoplayValue) {
      this.startAutoplay()
    }
  }

  disconnect() {
    this.stopAutoplay()

    this.element.removeEventListener("keydown", this.boundHandleKeydown)
    this.element.removeEventListener("mouseenter", this.boundHandleMouseEnter)
    this.element.removeEventListener("mouseleave", this.boundHandleMouseLeave)
    this.reducedMotionMedia?.removeEventListener("change", this.boundMotionChange)

    this.viewportTarget?.removeEventListener("touchstart", this.onTouchStart)
    this.viewportTarget?.removeEventListener("touchmove", this.onTouchMove)
    this.viewportTarget?.removeEventListener("touchend", this.onTouchEnd)
    this.viewportTarget?.removeEventListener("pointerdown", this.onPointerDown)
    this.viewportTarget?.removeEventListener("pointerup", this.onPointerUp)
  }

  next() {
    if (this.currentIndex >= this.slideTargets.length - 1) {
      if (!this.loopValue) return
      this.goToIndex(0)
      return
    }

    this.goToIndex(this.currentIndex + 1)
  }

  previous() {
    if (this.currentIndex <= 0) {
      if (!this.loopValue) return
      this.goToIndex(this.slideTargets.length - 1)
      return
    }

    this.goToIndex(this.currentIndex - 1)
  }

  goToSlide(event) {
    const index = Number.parseInt(event.currentTarget.dataset.slideIndex, 10)
    if (Number.isNaN(index)) return

    this.goToIndex(index)
  }

  goToIndex(index, shouldResetAutoplay = true) {
    if (index < 0 || index >= this.slideTargets.length) return

    this.currentIndex = index
    const reducedMotion = this.reducedMotionMedia?.matches

    if (this.transitionValue === "slide") {
      this.trackTarget.style.transition = reducedMotion ? "none" : ""
      this.trackTarget.style.transform = `translateX(-${index * 100}%)`
      this.slideTargets.forEach((slide) => {
        slide.style.display = ""
        slide.style.opacity = ""
      })
    } else if (this.transitionValue === "fade") {
      this.trackTarget.style.transform = ""
      this.slideTargets.forEach((slide, i) => {
        slide.style.display = ""
        slide.style.transition = reducedMotion ? "none" : "opacity 300ms ease"
        slide.style.opacity = i === index ? "1" : "0"
      })
    } else {
      this.trackTarget.style.transform = ""
      this.slideTargets.forEach((slide, i) => {
        slide.style.transition = "none"
        slide.style.opacity = ""
        slide.style.display = i === index ? "block" : "none"
      })
    }

    this.slideTargets.forEach((slide, i) => {
      slide.setAttribute("aria-hidden", (i !== index).toString())
    })

    this.updateIndicators(index)
    this.updateCounter(index)
    this.updateLiveRegion(index)
    this.updateThumbnails(index)
    this.updateButtonStates(index)

    if (shouldResetAutoplay) {
      this.resetAutoplay()
    }
  }

  startAutoplay() {
    if (!this.autoplayValue || this.slideTargets.length <= 1) return

    this.stopAutoplay()
    this.animateProgressBar()

    this.autoplayTimer = setInterval(() => {
      this.next()
    }, this.intervalValue)
  }

  stopAutoplay() {
    if (this.autoplayTimer) {
      clearInterval(this.autoplayTimer)
      this.autoplayTimer = null
    }

    if (this.hasProgressBarTarget) {
      this.progressBarTarget.style.transition = "none"
      this.progressBarTarget.style.width = "0%"
    }
  }

  resetAutoplay() {
    if (!this.autoplayValue) return

    this.stopAutoplay()
    this.startAutoplay()
  }

  handleKeydown(event) {
    if (!this.element.contains(document.activeElement)) return

    switch (event.key) {
      case "ArrowLeft":
        event.preventDefault()
        this.previous()
        break
      case "ArrowRight":
        event.preventDefault()
        this.next()
        break
      case "Home":
        event.preventDefault()
        this.goToIndex(0)
        break
      case "End":
        event.preventDefault()
        this.goToIndex(this.slideTargets.length - 1)
        break
      case " ":
      case "Enter":
        if (event.target.dataset.slideIndex !== undefined) {
          event.preventDefault()
          this.goToSlide({ currentTarget: event.target })
        }
        break
    }
  }

  setupTouchEvents() {
    this.onTouchStart = (event) => {
      this.touchStartX = event.touches[0].clientX
    }

    this.onTouchMove = (event) => {
      this.touchEndX = event.touches[0].clientX
    }

    this.onTouchEnd = () => {
      if (this.touchStartX === null || this.touchEndX === null) return

      const delta = this.touchStartX - this.touchEndX
      if (Math.abs(delta) > 50) {
        if (delta > 0) {
          this.next()
        } else {
          this.previous()
        }
      }

      this.touchStartX = null
      this.touchEndX = null
    }

    this.onPointerDown = (event) => {
      this.pointerStartX = event.clientX
    }

    this.onPointerUp = (event) => {
      if (this.pointerStartX === null) return

      const delta = this.pointerStartX - event.clientX
      if (Math.abs(delta) > 50) {
        if (delta > 0) {
          this.next()
        } else {
          this.previous()
        }
      }

      this.pointerStartX = null
    }

    this.viewportTarget.addEventListener("touchstart", this.onTouchStart, { passive: true })
    this.viewportTarget.addEventListener("touchmove", this.onTouchMove, { passive: true })
    this.viewportTarget.addEventListener("touchend", this.onTouchEnd)
    this.viewportTarget.addEventListener("pointerdown", this.onPointerDown)
    this.viewportTarget.addEventListener("pointerup", this.onPointerUp)
  }

  handleMouseEnter() {
    if (this.pauseOnHoverValue) {
      this.stopAutoplay()
    }
  }

  handleMouseLeave() {
    if (this.pauseOnHoverValue && this.autoplayValue) {
      this.startAutoplay()
    }
  }

  updateIndicators(index) {
    if (!this.hasIndicatorTarget) return

    this.indicatorTargets.forEach((indicator, i) => {
      const active = i === index
      indicator.setAttribute("aria-selected", active.toString())
      indicator.classList.toggle("bg-[var(--color-primary)]", active)
      indicator.classList.toggle("scale-125", active)
      indicator.classList.toggle("bg-white/50", !active)
    })
  }

  updateCounter(index) {
    if (!this.hasCounterTarget) return

    this.counterTarget.textContent = `${index + 1} / ${this.slideTargets.length}`
  }

  updateLiveRegion(index) {
    if (!this.hasLiveRegionTarget) return

    this.liveRegionTarget.textContent = `Slide ${index + 1} of ${this.slideTargets.length}`
  }

  updateThumbnails(index) {
    if (!this.hasThumbnailTarget) return

    this.thumbnailTargets.forEach((thumbnail, i) => {
      const active = i === index
      thumbnail.classList.toggle("border-[var(--color-primary)]", active)
      thumbnail.classList.toggle("border-[var(--color-border)]", !active)
    })
  }

  updateButtonStates(index) {
    if (this.loopValue) {
      if (this.hasPrevButtonTarget) this.prevButtonTarget.disabled = false
      if (this.hasNextButtonTarget) this.nextButtonTarget.disabled = false
      return
    }

    if (this.hasPrevButtonTarget) this.prevButtonTarget.disabled = index === 0
    if (this.hasNextButtonTarget) this.nextButtonTarget.disabled = index === this.slideTargets.length - 1
  }

  animateProgressBar() {
    if (!this.hasProgressBarTarget) return

    this.progressBarTarget.style.transition = "none"
    this.progressBarTarget.style.width = "0%"

    requestAnimationFrame(() => {
      this.progressBarTarget.style.transition = `width ${this.intervalValue}ms linear`
      this.progressBarTarget.style.width = "100%"
    })
  }
}
