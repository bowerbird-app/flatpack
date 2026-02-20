import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toggle"]

  connect() {
    this.applyTheme(this.currentTheme())
  }

  toggle(event) {
    const isDark = event.target.checked
    const theme = isDark ? "dark" : "light"

    localStorage.setItem(this.storageKey, theme)
    this.applyTheme(theme)
  }

  currentTheme() {
    const storedTheme = localStorage.getItem(this.storageKey)

    if (storedTheme === "dark" || storedTheme === "light") {
      return storedTheme
    }

    return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light"
  }

  applyTheme(theme) {
    const root = document.documentElement
    const isDark = theme === "dark"

    root.classList.toggle("dark", isDark)
    root.classList.toggle("light", !isDark)

    if (this.hasToggleTarget) {
      this.toggleTarget.checked = isDark
    }
  }

  get storageKey() {
    return "flatpack-dummy-theme"
  }
}
