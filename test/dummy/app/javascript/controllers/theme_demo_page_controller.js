import { Controller } from "@hotwired/stimulus"
import { composeThemeAttribute, readPickerThemeNames, themeListIncludes } from "controllers/flat_pack/theme_attribute"

export default class extends Controller {
  static values = { theme: String }

  connect() {
    if (!this.hasThemeValue) return

    this.applyTheme(this.themeValue)
  }

  applyTheme(themeValue) {
    const root = document.documentElement
    const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches
    const nextBase = themeValue === "system" ? (prefersDark ? "dark" : "light") : themeValue
    const pickerNames = readPickerThemeNames(document)
    const owned = pickerNames.length ? pickerNames : ["light", "dark", "ocean", "rounded"]
    const nextAttribute = composeThemeAttribute(root.getAttribute("data-theme"), nextBase, owned)

    if (nextAttribute) {
      root.setAttribute("data-theme", nextAttribute)
    } else {
      root.removeAttribute("data-theme")
    }

    if (themeValue === "system") {
      localStorage.removeItem("flatpack-theme")
      localStorage.removeItem("flatpack-dummy-theme")
    } else {
      localStorage.setItem("flatpack-theme", themeValue)
      localStorage.setItem("flatpack-dummy-theme", themeValue)
    }

    const isDark = themeListIncludes(nextAttribute, "dark")
    root.classList.toggle("dark", isDark)
    root.classList.toggle("light", !isDark)

    window.dispatchEvent(new CustomEvent("flat-pack:theme-changed", {
      detail: { theme: themeValue }
    }))
  }
}
