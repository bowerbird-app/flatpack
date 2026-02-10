import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["icon"]

  connect() {
    this.applyStoredTheme()
  }

  toggle() {
    const currentTheme = this.getCurrentTheme()
    const newTheme = currentTheme === "dark" ? "light" : "dark"
    this.setTheme(newTheme)
  }

  getCurrentTheme() {
    return document.documentElement.classList.contains("dark") ? "dark" : "light"
  }

  setTheme(theme) {
    // Store preference
    localStorage.setItem("flatpack-theme", theme)
    
    // Apply theme
    if (theme === "dark") {
      document.documentElement.classList.remove("light")
      document.documentElement.classList.add("dark")
    } else {
      document.documentElement.classList.remove("dark")
      document.documentElement.classList.add("light")
    }
  }

  applyStoredTheme() {
    const storedTheme = localStorage.getItem("flatpack-theme")
    
    if (storedTheme) {
      this.setTheme(storedTheme)
    } else {
      // Default to system preference
      const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches
      this.setTheme(prefersDark ? "dark" : "light")
    }
  }
}
