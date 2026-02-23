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
    const legacyTheme = localStorage.getItem(this.legacyStorageKey)
    const theme = storedTheme || legacyTheme

    if (theme === "dark" || theme === "light" || theme === "ocean" || theme === "rounded") {
      return theme
    }

    return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light"
  }

  applyTheme(theme) {
    const root = document.documentElement
    const isDark = theme === "dark"

    // Tailwind v4 theme variables are keyed by data-theme.
    if (theme === "light") {
      root.removeAttribute("data-theme")
    } else {
      root.setAttribute("data-theme", theme)
    }

    // Keep legacy classes for any selectors still relying on them.
    root.classList.toggle("dark", isDark)
    root.classList.toggle("light", !isDark)

    if (this.hasToggleTarget) {
      this.toggleTarget.checked = isDark
    }
  }

  get storageKey() {
    return "flatpack-theme"
  }

  get legacyStorageKey() {
    return "flatpack-dummy-theme"
  }
}
