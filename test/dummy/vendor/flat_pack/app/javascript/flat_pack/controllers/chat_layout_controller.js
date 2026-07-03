// FlatPack Chat Layout Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "panel"]

  connect() {
    this.mediaQuery = window.matchMedia("(min-width: 768px)")
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
    if (this.#isDesktop()) {
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

    this.sidebarTarget.classList.add("hidden")
    this.panelTarget.classList.remove("hidden")
    this.panelTarget.classList.add("flex")

    this.#scrollMessagesToBottom()
  }

  showSidebar() {
    if (!this.hasSidebarTarget || !this.hasPanelTarget) {
      return
    }

    this.sidebarTarget.classList.remove("hidden")
    this.panelTarget.classList.add("hidden")
    this.panelTarget.classList.remove("flex")
  }

  #syncViewport() {
    if (!this.hasSidebarTarget || !this.hasPanelTarget) {
      return
    }

    if (this.#isDesktop()) {
      this.sidebarTarget.classList.remove("hidden")
      this.panelTarget.classList.remove("hidden")
      this.panelTarget.classList.add("flex")
    } else if (!this.panelTarget.classList.contains("flex")) {
      this.showSidebar()
    }
  }

  #isDesktop() {
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
