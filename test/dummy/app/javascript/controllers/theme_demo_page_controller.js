import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { theme: String }

  connect() {
    if (!this.hasThemeValue) return

    this.applyTheme(this.themeValue)
  }

  applyTheme(themeValue) {
    const root = document.documentElement
    let isDark = false

    if (themeValue === "system") {
      isDark = window.matchMedia("(prefers-color-scheme: dark)").matches
      if (isDark) {
        root.setAttribute("data-theme", "dark")
      } else {
        root.removeAttribute("data-theme")
      }

      localStorage.removeItem("flatpack-theme")
      localStorage.removeItem("flatpack-dummy-theme")
    } else {
      isDark = themeValue === "dark"

      if (themeValue === "light") {
        root.removeAttribute("data-theme")
      } else {
        root.setAttribute("data-theme", themeValue)
      }

      localStorage.setItem("flatpack-theme", themeValue)
      localStorage.setItem("flatpack-dummy-theme", themeValue)
    }

    root.classList.toggle("dark", isDark)
    root.classList.toggle("light", !isDark)

    window.dispatchEvent(new CustomEvent("flat-pack:theme-changed", {
      detail: { theme: themeValue }
    }))
  }
}
