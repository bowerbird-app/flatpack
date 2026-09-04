// FlatPack Chat Layout Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "panel"]
  static values = {
    breakpoint: { type: Number, default: 640 }
  }

  connect() {
    this.mobileView = "sidebar"
    this.mediaQuery = window.matchMedia(`(min-width: ${this.breakpointValue}px)`)
    this.handleViewportChange = () => this.#syncViewport()

    if (this.mediaQuery.addEventListener) {
      this.mediaQuery.addEventListener("change", this.handleViewportChange)
    } else {
      this.mediaQuery.addListener(this.handleViewportChange)
    }

    this.#syncViewport()
  }

  disconnect() {
    if (!this.mediaQuery || !this.handleViewportChange) {
      return
    }

    if (this.mediaQuery.removeEventListener) {
      this.mediaQuery.removeEventListener("change", this.handleViewportChange)
    } else {
      this.mediaQuery.removeListener(this.handleViewportChange)
    }
  }

  openPanel(event) {
    if (this.#isSplit()) {
      return
    }

    const trigger = event.target.closest("a, button, [role='button']")
    if (!trigger || !this.sidebarTarget.contains(trigger)) {
      return
    }

    this.showPanel()
  }

  showPanel() {
    if (!this.hasSidebarTarget || !this.hasPanelTarget) {
      return
    }

    this.mobileView = "panel"
    this.sidebarTarget.classList.add("hidden")
    this.panelTarget.classList.remove("hidden")
    this.panelTarget.classList.add("flex")

    this.#scrollMessagesToBottom()
  }

  showSidebar() {
    if (!this.hasSidebarTarget || !this.hasPanelTarget) {
      return
    }

    this.mobileView = "sidebar"
    this.sidebarTarget.classList.remove("hidden")
    this.panelTarget.classList.add("hidden")
    this.panelTarget.classList.remove("flex")
  }

  #syncViewport() {
    if (!this.hasSidebarTarget || !this.hasPanelTarget) {
      return
    }

    if (this.#isSplit()) {
      this.sidebarTarget.classList.remove("hidden")
      this.panelTarget.classList.remove("hidden")
      this.panelTarget.classList.add("flex")
    } else if (this.mobileView === "panel") {
      this.showPanel()
    } else {
      this.showSidebar()
    }
  }

  #isSplit() {
    return this.mediaQuery?.matches
  }

  #scrollMessagesToBottom() {
    window.requestAnimationFrame(() => {
      const messages = this.panelTarget.querySelector("[data-flat-pack--chat-scroll-target='messages']")
      if (messages) {
        messages.scrollTop = messages.scrollHeight
      }
    })
  }
}
