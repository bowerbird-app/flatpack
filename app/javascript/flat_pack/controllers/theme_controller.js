import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    mode: String
  }

  connect() {
    // Load theme from localStorage or use provided mode
    this.currentMode = localStorage.getItem("flatpack-theme") || this.modeValue || "auto"
    this.applyTheme()

    // Listen for system preference changes
    this.mediaQuery = window.matchMedia("(prefers-color-scheme: dark)")
    this.handleSystemChange = this.handleSystemChange.bind(this)
    this.mediaQuery.addEventListener("change", this.handleSystemChange)
  }

  disconnect() {
    if (this.mediaQuery) {
      this.mediaQuery.removeEventListener("change", this.handleSystemChange)
    }
  }

  toggle() {
    // Cycle through modes: auto → light → dark → auto
    const modes = ["auto", "light", "dark"]
    const currentIndex = modes.indexOf(this.currentMode)
    const nextIndex = (currentIndex + 1) % modes.length
    this.currentMode = modes[nextIndex]

    // Save to localStorage
    localStorage.setItem("flatpack-theme", this.currentMode)

    // Apply theme
    this.applyTheme()
  }

  applyTheme() {
    const html = document.documentElement

    // Remove existing theme classes
    html.classList.remove("light", "dark")

    if (this.currentMode === "light") {
      html.classList.add("light")
    } else if (this.currentMode === "dark") {
      html.classList.add("dark")
    } else {
      // Auto mode: check system preference
      if (this.mediaQuery && this.mediaQuery.matches) {
        html.classList.add("dark")
      } else {
        html.classList.add("light")
      }
    }
  }

  handleSystemChange() {
    // Only react to system changes in auto mode
    if (this.currentMode === "auto") {
      this.applyTheme()
    }
  }
}
