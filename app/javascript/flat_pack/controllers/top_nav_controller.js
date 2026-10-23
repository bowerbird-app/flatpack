import { Controller } from "@hotwired/stimulus"

// Frosts the shell's top bar after the page or the nearest overflow pane has scrolled.
// The row inside the bar does not fold. A child that collapses owns that.
export default class extends Controller {
  connect() {
    this.boundHandleScroll = this.handleScroll.bind(this)
    this.scrollports = this.collectScrollports()

    this.scrollports.forEach((port) => {
      port.addEventListener("scroll", this.boundHandleScroll, {passive: true})
    })
    this.updateScrolled()
  }

  disconnect() {
    this.scrollports?.forEach((port) => {
      port.removeEventListener("scroll", this.boundHandleScroll)
    })
    this.scrollports = []
  }

  collectScrollports() {
    if (this.element.closest?.("[data-flat-pack-layout-scroll]")?.dataset?.flatPackLayoutScroll === "page") {
      return [window]
    }

    const ports = new Set()
    ports.add(window)

    const sibling = this.element.nextElementSibling
    if (this.isScrollable(sibling)) ports.add(sibling)

    let node = this.element.parentElement
    while (node && node !== document.body && node !== document.documentElement) {
      if (this.isScrollable(node)) ports.add(node)
      node = node.parentElement
    }

    return Array.from(ports)
  }

  isScrollable(node) {
    if (!node || node.nodeType !== 1) return false

    const style = window.getComputedStyle(node)
    const overflowY = style.overflowY

    return overflowY === "auto" || overflowY === "scroll" || overflowY === "overlay"
  }

  handleScroll() {
    this.updateScrolled()
  }

  pageHasScrolled() {
    return this.scrollports.some((port) => {
      if (port === window) {
        return (window.scrollY || document.documentElement.scrollTop || 0) > 0
      }

      return (port.scrollTop || 0) > 0
    })
  }

  updateScrolled() {
    this.element.dataset.scrolled = this.pageHasScrolled() ? "true" : "false"
  }
}
