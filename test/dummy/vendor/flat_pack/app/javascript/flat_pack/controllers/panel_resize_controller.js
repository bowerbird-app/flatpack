import { Controller } from "@hotwired/stimulus"

const NUDGE = 16

export default class extends Controller {
  static targets = ["handle"]
  static values = {
    storageKey: String,
    collapses: Boolean
  }

  connect() {
    this.bounds = { min: NaN, max: NaN, defaultWidth: NaN }
    this.dragging = false
    this.liveWidth = null
    this.onPointerMove = this.onPointerMove.bind(this)
    this.onPointerUp = this.onPointerUp.bind(this)
    this.onWindowResize = () => this.refreshBounds()
    window.addEventListener("resize", this.onWindowResize)
    this.refreshBounds()
    this.paintStored()
    if (this.element.dataset.flatPackPanelResized !== "true") this.writeAria()
  }

  disconnect() {
    window.removeEventListener("resize", this.onWindowResize)
    if (this.dragging) this.stopDrag()
  }

  start(event) {
    if (this.desktopLocked() || !event || event.button !== 0 || this.dragging) return
    this.refreshBounds()
    if (!this.boundsReady()) return
    if (typeof event.preventDefault === "function") event.preventDefault()

    const handle = event.currentTarget || (this.hasHandleTarget ? this.handleTarget : null)
    if (handle && handle.dataset) handle.dataset.pointerFocus = "true"
    this.snapshotWidth = this.element.style.getPropertyValue("--fp-panel-width")
    this.snapshotResized = this.element.dataset.flatPackPanelResized
    this.originX = event.clientX
    this.originWidth = this.element.getBoundingClientRect().width
    this.direction = this.edgeDirection()
    this.liveWidth = null
    this.collapsedFromDrag = false
    this.dragging = true
    this.pointerId = event.pointerId
    this.captureTarget = handle
    this.element.style.setProperty("transition-property", "none", "important")
    this.capture(handle, event.pointerId)
    if (handle && typeof handle.addEventListener === "function") {
      handle.addEventListener("pointermove", this.onPointerMove)
      handle.addEventListener("pointerup", this.onPointerUp)
      handle.addEventListener("pointercancel", this.onPointerUp)
    }
  }

  nudge(event) {
    if (this.desktopLocked() || !event) return
    if (event.key !== "ArrowLeft" && event.key !== "ArrowRight") return
    if (typeof event.preventDefault === "function") event.preventDefault()
    this.refreshBounds()
    if (!this.boundsReady()) return

    const step = (event.key === "ArrowRight" ? NUDGE : -NUDGE) * this.edgeDirection()
    const current = this.currentWidth()
    const proposed = current + step
    if (proposed < this.bounds.min && this.collapsesValue) {
      this.collapse()
      return
    }

    const next = Math.round(this.clamp(proposed))
    if (next === Math.round(current)) return
    this.applyWidth(next)
    this.persist(next)
  }

  reset(event) {
    if (this.desktopLocked()) return
    if (event && typeof event.preventDefault === "function") event.preventDefault()
    this.refreshBounds()
    this.clearStoredWidth()
    this.element.style.removeProperty("--fp-panel-width")
    delete this.element.dataset.flatPackPanelResized
    this.liveWidth = null
    this.writeAria(this.bounds.defaultWidth)
  }

  refreshBounds() {
    this.bounds = {
      min: this.resolve("--fp-panel-min"),
      max: this.resolve("--fp-panel-max"),
      defaultWidth: this.resolve("--fp-panel-default")
    }
  }

  paintStored() {
    const stored = this.readStored()
    if (!/^\d+$/.test(stored || "")) return
    const raw = parseInt(stored, 10)
    this.applyWidth(this.boundsReady() ? this.clamp(raw) : raw)
  }

  onPointerMove(event) {
    if (!this.dragging || this.collapsedFromDrag) return
    if (event && event.pointerId != null && this.pointerId != null && event.pointerId !== this.pointerId) return

    const proposed = this.originWidth + (event.clientX - this.originX) * this.direction
    if (proposed < this.bounds.min && this.collapsesValue) {
      this.collapseFromDrag()
      return
    }
    this.applyWidth(this.clamp(proposed))
  }

  onPointerUp(event) {
    if (!this.dragging) return
    if (event && event.pointerId != null && this.pointerId != null && event.pointerId !== this.pointerId) return

    const collapsed = this.collapsedFromDrag
    const width = this.liveWidth
    this.stopDrag()
    if (collapsed || !Number.isFinite(width)) return
    this.persist(Math.round(width))
  }

  applyWidth(px) {
    const next = Math.round(px)
    this.liveWidth = next
    this.element.style.setProperty("--fp-panel-width", `${next}px`)
    this.element.dataset.flatPackPanelResized = "true"
    this.writeAria(next)
  }

  collapse() {
    this.element.dispatchEvent(new CustomEvent("flat-pack:collapse-rail", { bubbles: true }))
  }

  collapseFromDrag() {
    if (this.collapsedFromDrag) return
    this.collapsedFromDrag = true
    // The drag wrote an inline width storage does not have. Restore the
    // pre-drag value so expand matches the saved width.
    this.restoreSnapshot()
    this.collapse()
    this.stopDrag()
  }

  restoreSnapshot() {
    if (this.snapshotWidth) {
      this.element.style.setProperty("--fp-panel-width", this.snapshotWidth)
      if (this.snapshotResized) this.element.dataset.flatPackPanelResized = this.snapshotResized
      else delete this.element.dataset.flatPackPanelResized
    } else {
      this.element.style.removeProperty("--fp-panel-width")
      delete this.element.dataset.flatPackPanelResized
    }
    this.liveWidth = null
  }

  stopDrag() {
    this.dragging = false
    this.element.style.removeProperty("transition-property")
    const handle = this.captureTarget
    if (handle && typeof handle.removeEventListener === "function") {
      handle.removeEventListener("pointermove", this.onPointerMove)
      handle.removeEventListener("pointerup", this.onPointerUp)
      handle.removeEventListener("pointercancel", this.onPointerUp)
    }
    if (handle && document.activeElement === handle && typeof handle.blur === "function") handle.blur()
    if (handle && handle.dataset) delete handle.dataset.pointerFocus
    this.releaseCapture()
  }

  capture(handle, pointerId) {
    if (!handle || pointerId == null || typeof handle.setPointerCapture !== "function") return
    try {
      handle.setPointerCapture(pointerId)
    } catch {
      // The pointer can already be gone.
    }
  }

  releaseCapture() {
    const handle = this.captureTarget
    const pointerId = this.pointerId
    this.captureTarget = null
    this.pointerId = null
    if (!handle || pointerId == null || typeof handle.releasePointerCapture !== "function") return
    try {
      if (typeof handle.hasPointerCapture === "function" && !handle.hasPointerCapture(pointerId)) return
      handle.releasePointerCapture(pointerId)
    } catch {
      // The pointer can already be gone.
    }
  }

  writeAria(now) {
    if (!this.hasHandleTarget) return
    const handle = this.handleTarget
    const current = Number.isFinite(now) ? now : this.currentWidth()
    if (Number.isFinite(this.bounds.min)) handle.setAttribute("aria-valuemin", String(Math.round(this.bounds.min)))
    if (Number.isFinite(this.bounds.max)) handle.setAttribute("aria-valuemax", String(Math.round(this.bounds.max)))
    if (Number.isFinite(current)) handle.setAttribute("aria-valuenow", String(Math.round(current)))
  }

  currentWidth() {
    const inline = this.lengthPx(this.element.style.getPropertyValue("--fp-panel-width"))
    if (Number.isFinite(inline)) return inline
    return this.element.getBoundingClientRect().width
  }

  resolve(name) {
    const raw = getComputedStyle(this.element).getPropertyValue(name)
    const parsed = this.lengthPx(raw)
    if (Number.isFinite(parsed)) return parsed
    return this.measureLength(raw)
  }

  // A custom property often stays var() or calc() until it is used as a length.
  measureLength(raw) {
    const value = String(raw || "").trim()
    if (!value) return NaN

    const column = this.element
    const previous = column.style.getPropertyValue("width")
    const previousPriority = column.style.getPropertyPriority("width")
    column.style.setProperty("transition-property", "none", "important")
    column.style.setProperty("width", value, "important")
    const width = column.getBoundingClientRect().width
    if (previous) column.style.setProperty("width", previous, previousPriority)
    else column.style.removeProperty("width")
    if (!this.dragging) column.style.removeProperty("transition-property")
    return width
  }

  lengthPx(raw) {
    const value = String(raw || "").trim()
    const px = /^(-?[\d.]+)px$/.exec(value)
    if (px) return parseFloat(px[1])
    const rem = /^(-?[\d.]+)rem$/.exec(value)
    if (!rem) return NaN
    const root = parseFloat(getComputedStyle(document.documentElement).fontSize)
    return parseFloat(rem[1]) * root
  }

  clamp(px) {
    return Math.min(this.bounds.max, Math.max(this.bounds.min, px))
  }

  edgeDirection() {
    return this.element.dataset.mobileDrawerSide === "right" ? -1 : 1
  }

  boundsReady() {
    return Number.isFinite(this.bounds.min) && Number.isFinite(this.bounds.max)
  }

  desktopLocked() {
    return window.innerWidth < 768
  }

  readStored() {
    if (!this.hasStorageKeyValue || !this.storageKeyValue) return null
    try {
      return localStorage.getItem(this.storageKeyValue)
    } catch {
      return null
    }
  }

  persist(px) {
    if (!this.hasStorageKeyValue || !this.storageKeyValue) return
    try {
      localStorage.setItem(this.storageKeyValue, String(px))
    } catch {
      // Ignore storage errors (private mode / disabled storage)
    }
  }

  clearStoredWidth() {
    if (!this.hasStorageKeyValue || !this.storageKeyValue) return
    try {
      localStorage.removeItem(this.storageKeyValue)
    } catch {
      // Ignore storage errors (private mode / disabled storage)
    }
  }
}
