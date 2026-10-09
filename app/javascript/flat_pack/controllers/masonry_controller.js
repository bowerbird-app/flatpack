// FlatPack Masonry Stimulus Controller
// Rows-order layout: measure each item and set grid-row span so mixed
// heights pack without holes. Native CSS masonry skips the math.
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]
  static values = {
    rowHeight: { type: Number, default: 8 }
  }

  connect() {
    this.scheduleLayout = this.scheduleLayout.bind(this)
    this.onImageLoad = this.scheduleLayout

    if (this.supportsNativeMasonry()) {
      this.element.dataset.fpMasonryNative = "true"
      return
    }

    this.element.addEventListener("load", this.onImageLoad, true)
    window.addEventListener("resize", this.scheduleLayout)

    if (typeof ResizeObserver !== "undefined") {
      this.resizeObserver = new ResizeObserver(this.scheduleLayout)
      this.layoutItems().forEach((item) => this.resizeObserver.observe(item))
    }

    this.layout()
  }

  itemTargetConnected(item) {
    if (this.element.dataset.fpMasonryNative === "true") return

    this.resizeObserver?.observe(item)
    this.scheduleLayout()
  }

  itemTargetDisconnected() {
    if (this.element.dataset.fpMasonryNative === "true") return

    this.scheduleLayout()
  }

  disconnect() {
    this.element.removeEventListener("load", this.onImageLoad, true)
    window.removeEventListener("resize", this.scheduleLayout)

    if (this.frame) {
      cancelAnimationFrame(this.frame)
      this.frame = null
    }

    if (this.resizeObserver) {
      this.resizeObserver.disconnect()
      this.resizeObserver = null
    }
  }

  supportsNativeMasonry() {
    if (typeof CSS === "undefined" || typeof CSS.supports !== "function") return false

    return CSS.supports("grid-template-rows", "masonry") || CSS.supports("display", "masonry")
  }

  layoutItems() {
    if (this.itemTargets.length > 0) return this.itemTargets

    return Array.from(this.element.children)
  }

  scheduleLayout() {
    if (this.updating || this.element.dataset.fpMasonryNative === "true") return

    if (this.frame) cancelAnimationFrame(this.frame)
    this.frame = requestAnimationFrame(() => this.layout())
  }

  layout() {
    if (this.supportsNativeMasonry()) {
      this.element.dataset.fpMasonryNative = "true"
      delete this.element.dataset.fpMasonryReady
      return
    }

    this.element.dataset.fpMasonryReady = "true"

    const styles = window.getComputedStyle(this.element)
    const gap = Number.parseFloat(styles.rowGap || styles.gap) || 0
    const rowHeight = this.rowHeightValue
    const rowPitch = rowHeight + gap

    this.updating = true
    try {
      this.layoutItems().forEach((item) => {
        const height = this.itemContentHeight(item)
        const span = Math.max(1, Math.ceil((height + gap) / rowPitch))
        const next = `span ${span}`
        if (item.style.gridRowEnd !== next) {
          item.style.gridRowEnd = next
        }
      })
    } finally {
      this.updating = false
    }
  }

  itemContentHeight(item) {
    const first = item.firstElementChild
    const last = item.lastElementChild
    if (first && last) {
      return Math.max(0, last.getBoundingClientRect().bottom - first.getBoundingClientRect().top)
    }

    return Math.max(item.scrollHeight, item.getBoundingClientRect().height)
  }
}
