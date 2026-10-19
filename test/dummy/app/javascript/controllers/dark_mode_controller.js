import { Controller } from "@hotwired/stimulus"
import { composeThemeAttribute, readPickerThemeNames, themeListIncludes } from "controllers/flat_pack/theme_attribute"

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

    if (theme && theme !== "system") {
      return theme
    }

    return window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light"
  }

  applyTheme(theme) {
    const root = document.documentElement
    const nextAttribute = composeThemeAttribute(root.getAttribute("data-theme"), theme, this.ownedThemeNames())

    if (nextAttribute) {
      root.setAttribute("data-theme", nextAttribute)
    } else {
      root.removeAttribute("data-theme")
    }

    const isDark = themeListIncludes(nextAttribute, "dark")
    root.classList.toggle("dark", isDark)
    root.classList.toggle("light", !isDark)

    if (this.hasToggleTarget) {
      this.toggleTarget.checked = isDark
    }
  }

  ownedThemeNames() {
    const pickerNames = readPickerThemeNames(document)
    return pickerNames.length ? pickerNames : ["light", "dark", "ocean", "rounded", "sunrise"]
  }

  get storageKey() {
    return "flatpack-theme"
  }

  get legacyStorageKey() {
    return "flatpack-dummy-theme"
  }
}
