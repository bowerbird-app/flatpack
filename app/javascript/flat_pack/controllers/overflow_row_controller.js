// FlatPack Overflow Row Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["scroller", "track"]

  connect() {
    this.update = this.update.bind(this)
    this.update()

    if (typeof ResizeObserver !== "undefined") {
      this.resizeObserver = new ResizeObserver(this.update)
      if (this.hasScrollerTarget) this.resizeObserver.observe(this.scrollerTarget)
      if (this.hasTrackTarget) this.resizeObserver.observe(this.trackTarget)
    }

    window.addEventListener("resize", this.update)
  }

  disconnect() {
    if (this.resizeObserver) {
      this.resizeObserver.disconnect()
      this.resizeObserver = null
    }

    window.removeEventListener("resize", this.update)
  }

  update() {
    if (!this.hasScrollerTarget) return

    const scroller = this.scrollerTarget
    const maxScrollLeft = scroller.scrollWidth - scroller.clientWidth
    const canScrollEnd = maxScrollLeft > 1 && scroller.scrollLeft < maxScrollLeft - 1

    this.element.dataset.canScrollEnd = canScrollEnd ? "true" : "false"
  }
}
