import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["slide", "indicator", "thumb", "counter", "caption", "lightboxImage", "lightboxCaption"]
  static values = { index: Number }

  connect() {
    this.indexValue = Number.isInteger(this.indexValue) ? this.indexValue : 0
    this.render()
  }

  prev() {
    this.goToIndex(this.indexValue - 1)
  }

  next() {
    this.goToIndex(this.indexValue + 1)
  }

  goTo(event) {
    const rawIndex = event.currentTarget.dataset.index
    this.goToIndex(Number.parseInt(rawIndex, 10))
  }

  openLightbox(event) {
    if (!this.hasLightboxImageTarget) {
      return
    }

    const trigger = event.currentTarget
    const imageSrc = trigger.dataset.lightboxSrc
    const imageAlt = trigger.dataset.lightboxAlt || "Carousel image"
    const caption = trigger.dataset.lightboxCaption || ""

    this.lightboxImageTarget.src = imageSrc
    this.lightboxImageTarget.alt = imageAlt

    if (this.hasLightboxCaptionTarget) {
      this.lightboxCaptionTarget.textContent = caption
    }
  }

  goToIndex(requestedIndex) {
    if (this.slideTargets.length === 0) {
      return
    }

    const slideCount = this.slideTargets.length
    const normalized = ((requestedIndex % slideCount) + slideCount) % slideCount

    this.indexValue = normalized
    this.render()
  }

  render() {
    this.slideTargets.forEach((slide, index) => {
      const isActive = index === this.indexValue
      slide.classList.toggle("hidden", !isActive)
      slide.setAttribute("aria-hidden", (!isActive).toString())

      // Keep paused video playback on inactive slides.
      if (!isActive) {
        slide.querySelectorAll("video").forEach((video) => {
          if (!video.paused) {
            video.pause()
          }
        })
      }
    })

    this.indicatorTargets.forEach((indicator, index) => {
      const isActive = index === this.indexValue
      indicator.classList.toggle("bg-[var(--color-primary)]", isActive)
      indicator.classList.toggle("bg-[var(--surface-border-color)]", !isActive)
      indicator.setAttribute("aria-current", isActive ? "true" : "false")
    })

    this.thumbTargets.forEach((thumb, index) => {
      const isActive = index === this.indexValue
      thumb.classList.toggle("ring-2", isActive)
      thumb.classList.toggle("ring-[var(--color-primary)]", isActive)
      thumb.classList.toggle("opacity-60", !isActive)
      thumb.setAttribute("aria-current", isActive ? "true" : "false")
    })

    if (this.hasCounterTarget) {
      this.counterTarget.textContent = `${this.indexValue + 1} / ${this.slideTargets.length}`
    }

    if (this.hasCaptionTarget) {
      const activeSlide = this.slideTargets[this.indexValue]
      this.captionTarget.textContent = activeSlide?.dataset.caption || ""
    }
  }
}
