// FlatPack Dark Mode Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sunIcon", "moonIcon"]

  connect() {
    console.log("FlatPack Dark Mode controller connected")
    this.loadTheme()
    this.updateIcons()
    
    // Listen for system theme changes
    this.mediaQuery = window.matchMedia("(prefers-color-scheme: dark)")
    this.mediaQuery.addEventListener("change", () => {
      if (!this.hasManualPreference()) {
        this.updateIcons()
      }
    })
  }

  disconnect() {
    if (this.mediaQuery) {
      this.mediaQuery.removeEventListener("change", this.handleSystemThemeChange)
    }
  }

  // Toggle between light/dark/system
  toggle() {
    const currentTheme = this.getCurrentTheme()
    
    if (currentTheme === "light") {
      this.setTheme("dark")
    } else if (currentTheme === "dark") {
      this.setTheme("system")
    } else {
      this.setTheme("light")
    }
  }

  // Set theme (light/dark/system)
  setTheme(theme) {
    if (theme === "system") {
      localStorage.removeItem("flatpack-theme")
    } else {
      localStorage.setItem("flatpack-theme", theme)
    }
    this.applyTheme(theme)
    this.updateIcons()
  }

  // Get current theme
  getCurrentTheme() {
    const stored = localStorage.getItem("flatpack-theme")
    if (stored) return stored
    
    // If no manual preference, check system
    return this.getSystemTheme()
  }

  // Get system theme preference
  getSystemTheme() {
    return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light"
  }

  // Check if user has manual preference
  hasManualPreference() {
    return localStorage.getItem("flatpack-theme") !== null
  }

  // Apply theme to document
  applyTheme(theme) {
    const actualTheme = theme === "system" ? this.getSystemTheme() : theme
    
    if (actualTheme === "dark") {
      document.documentElement.classList.add("dark")
    } else {
      document.documentElement.classList.remove("dark")
    }
  }

  // Load theme on connect
  loadTheme() {
    const theme = this.getCurrentTheme()
    this.applyTheme(theme)
  }

  // Update icon visibility
  updateIcons() {
    if (!this.hasSunIconTarget || !this.hasMoonIconTarget) return

    const currentTheme = this.getCurrentTheme()
    const actualTheme = currentTheme === "system" ? this.getSystemTheme() : currentTheme

    if (actualTheme === "dark") {
      // Show sun icon (to switch to light)
      this.sunIconTarget.style.opacity = "1"
      this.moonIconTarget.style.opacity = "0"
    } else {
      // Show moon icon (to switch to dark)
      this.sunIconTarget.style.opacity = "0"
      this.moonIconTarget.style.opacity = "1"
    }
  }
}
