// FlatPack Slide Indicator Stimulus Controller
// Shared by Tabs, Button::Pill, and Segmented Buttons.
// Positions one indicator to the active item and moves it on --duration-base.
import { Controller } from "@hotwired/stimulus"
import { prefersReducedMotion, motionDuration, motionTransition } from "controllers/flat_pack/reduced_motion"

const READY_CLASS = "is-ready"
const INSTANT_CLASS = "is-instant"
const UNDERLINE_HEIGHT_PX = 2

export default class extends Controller {
  static targets = ["indicator", "item"]
  static values = {
    kind: { type: String, default: "pill" }
  }

  connect() {
    this.boundOnClick = this.onClick.bind(this)
    this.boundSyncInstant = () => this.sync({ animate: false })
    this.visitTimer = null
    this.frame = null
    this.hasPositioned = false

    this.boundTurboSync = () => this.sync({ animate: false })
    this.element.addEventListener("click", this.boundOnClick)
    this.observeTurbo()
    this.observeMutations()
    this.observeResize()
    this.observeFonts()
    this.observeScroll()

    this.sync({ animate: false })
  }

  disconnect() {
    this.element.removeEventListener("click", this.boundOnClick)
    this.element.removeEventListener("scroll", this.boundSyncInstant)
    this.releaseTurbo()
    this.mutationObserver?.disconnect()
    this.resizeObserver?.disconnect()
    this.clearVisitTimer()

    if (this.frame) {
      cancelAnimationFrame(this.frame)
      this.frame = null
    }
  }

  itemTargetConnected(item) {
    this.resizeObserver?.observe(item)
    this.mutationObserver?.observe(item, {
      attributes: true,
      attributeFilter: ["aria-selected", "aria-current", "aria-pressed", "class"]
    })
    this.scheduleSync(false)
  }

  itemTargetDisconnected() {
    this.scheduleSync(false)
  }

  onClick(event) {
    const item = this.itemFromEvent(event)
    if (!item) return

    if (item.getAttribute("role") === "tab") {
      this.sync({ animate: true, item })
      return
    }

    if (item.hasAttribute("aria-pressed")) {
      this.selectPressedItem(item)
      return
    }

    this.selectLinkItem(item)

    if (!this.shouldIntercept(event, item)) return

    event.preventDefault()
    this.visitAfterMove(item)
  }

  shouldIntercept(event, item) {
    if (item.tagName !== "A") return false
    if (event.defaultPrevented) return false
    if (event.button != null && event.button !== 0) return false
    if (event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return false
    if (item.target && item.target !== "_self") return false
    if (item.hasAttribute("download")) return false

    const href = item.getAttribute("href")
    return href != null && href !== ""
  }

  selectPressedItem(item) {
    const prior = this.itemTargets.map((el) => [el, el.getAttribute("aria-pressed")])
    const anchor = this.pressedItem() || this.activeItem()

    this.itemTargets.forEach((el) => {
      const isSelected = el === item
      this.applyClasses(el, isSelected)
      el.setAttribute("aria-pressed", isSelected ? "true" : "false")
    })
    this.sync({ animate: true, item })

    const change = new CustomEvent("flat-pack--segmented-buttons:change", {
      bubbles: true,
      cancelable: true,
      detail: { index: this.itemTargets.indexOf(item), button: item }
    })
    if (this.element.dispatchEvent(change)) return

    prior.forEach(([el, pressed]) => {
      if (pressed == null) el.removeAttribute("aria-pressed")
      else el.setAttribute("aria-pressed", pressed)
      this.applyClasses(el, pressed === "true")
    })
    this.sync({ animate: false, item: anchor })
  }

  pressedItem() {
    return this.itemTargets.find((el) => el.getAttribute("aria-pressed") === "true") || null
  }

  selectLinkItem(item) {
    this.itemTargets.forEach((el) => {
      const isSelected = el === item
      this.applyClasses(el, isSelected)

      if (isSelected) {
        el.setAttribute("aria-current", "page")
      } else {
        el.removeAttribute("aria-current")
      }
    })

    this.sync({ animate: true, item })
  }

  applyClasses(el, active) {
    const activeClasses = this.parseClasses(el.dataset.flatPackSlideIndicatorActiveClasses)
    const inactiveClasses = this.parseClasses(el.dataset.flatPackSlideIndicatorInactiveClasses)
    if (activeClasses.length === 0 && inactiveClasses.length === 0) return

    el.classList.remove(...activeClasses)
    el.classList.remove(...inactiveClasses)
    el.classList.add(...(active ? activeClasses : inactiveClasses))
  }

  sync({ animate = true, item } = {}) {
    if (!this.hasIndicatorTarget) return

    const target = item || this.activeItem()
    if (!target) return

    const box = this.measure(target)
    const indicator = this.indicatorTarget
    const instant = !animate || !this.hasPositioned || prefersReducedMotion()

    indicator.classList.toggle(INSTANT_CLASS, instant)
    indicator.style.transition = instant
      ? "none"
      : motionTransition(["transform", "width", "height"], { duration: "base", easing: "standard" })

    this.writeBox(indicator, box)

    if (!this.hasPositioned) {
      void indicator.offsetWidth
      indicator.classList.add(READY_CLASS)
      this.element.classList.add(READY_CLASS)
      this.hasPositioned = true
    }
  }

  writeBox(indicator, box) {
    const underline = this.kindValue === "underline"
    const width = box.width
    const height = underline ? UNDERLINE_HEIGHT_PX : box.height
    const top = underline ? box.top + box.height - UNDERLINE_HEIGHT_PX : box.top

    indicator.style.width = `${width}px`
    indicator.style.height = `${height}px`
    indicator.style.transform = `translate(${box.left}px, ${top}px)`
  }

  measure(item) {
    const list = this.element
    const listRect = list.getBoundingClientRect()
    const itemRect = item.getBoundingClientRect()

    return {
      left: itemRect.left - listRect.left + list.scrollLeft,
      top: itemRect.top - listRect.top + list.scrollTop,
      width: itemRect.width,
      height: itemRect.height
    }
  }

  activeItem() {
    return (
      this.itemTargets.find((el) => el.getAttribute("aria-selected") === "true") ||
      this.itemTargets.find((el) => el.getAttribute("aria-current") === "page") ||
      this.itemTargets.find((el) => el.getAttribute("aria-pressed") === "true") ||
      this.itemTargets[0]
    )
  }

  visitAfterMove(item) {
    const href = item.href
    const wait = prefersReducedMotion() ? 0 : motionDuration("base")

    this.clearVisitTimer()

    const go = () => {
      this.visitTimer = null
      this.navigate(href)
    }

    if (wait === 0) {
      go()
      return
    }

    this.visitTimer = setTimeout(go, wait)
  }

  navigate(href) {
    if (globalThis.Turbo?.visit) {
      globalThis.Turbo.visit(href)
      return
    }

    globalThis.location.href = href
  }

  itemFromEvent(event) {
    const path = typeof event.composedPath === "function" ? event.composedPath() : []
    const node = path.find((entry) => this.itemTargets.includes(entry))
    if (node) return node

    const target = event.target
    if (!target || typeof target.closest !== "function") return null

    return this.itemTargets.find((item) => item === target || item.contains(target)) || null
  }

  observeMutations() {
    if (typeof MutationObserver === "undefined") return

    this.mutationObserver = new MutationObserver(() => this.scheduleSync(true))
    this.itemTargets.forEach((item) => {
      this.mutationObserver.observe(item, {
        attributes: true,
        attributeFilter: ["aria-selected", "aria-current", "aria-pressed"]
      })
    })
  }

  observeResize() {
    if (typeof ResizeObserver === "undefined") return

    this.resizeObserver = new ResizeObserver(() => this.scheduleSync(false))
    this.resizeObserver.observe(this.element)
    this.itemTargets.forEach((item) => this.resizeObserver.observe(item))
  }

  observeFonts() {
    const fonts = globalThis.document?.fonts
    if (!fonts?.ready || typeof fonts.ready.then !== "function") return

    fonts.ready.then(() => this.sync({ animate: false }))
  }

  observeScroll() {
    this.element.addEventListener("scroll", this.boundSyncInstant, { passive: true })
  }

  observeTurbo() {
    const doc = globalThis.document
    if (!this.boundTurboSync || typeof doc?.addEventListener !== "function") return

    doc.addEventListener("turbo:render", this.boundTurboSync)
    doc.addEventListener("turbo:load", this.boundTurboSync)
  }

  releaseTurbo() {
    const doc = globalThis.document
    if (!this.boundTurboSync || typeof doc?.removeEventListener !== "function") return

    doc.removeEventListener("turbo:render", this.boundTurboSync)
    doc.removeEventListener("turbo:load", this.boundTurboSync)
  }

  scheduleSync(animate) {
    if (this.frame) cancelAnimationFrame(this.frame)

    this.frame = requestAnimationFrame(() => {
      this.frame = null
      this.sync({ animate })
    })
  }

  clearVisitTimer() {
    if (!this.visitTimer) return

    clearTimeout(this.visitTimer)
    this.visitTimer = null
  }

  parseClasses(classString) {
    return (classString || "").split(/\s+/).filter(Boolean)
  }
}
