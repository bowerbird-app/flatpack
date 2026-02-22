import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]

  static THEME_CHANGED_EVENT = "flat-pack:theme-changed"

  connect() {
    this.boundHandleThemeChanged = this.handleThemeChanged.bind(this)
    window.addEventListener(this.constructor.THEME_CHANGED_EVENT, this.boundHandleThemeChanged)
    this.selectByTheme(this.currentTheme())
  }

  disconnect() {
    window.removeEventListener(this.constructor.THEME_CHANGED_EVENT, this.boundHandleThemeChanged)
  }

  select(event) {
    const theme = event.currentTarget.dataset.themeValue || "system"
    this.selectByTheme(theme)
  }

  currentTheme() {
    const savedTheme = localStorage.getItem("flatpack-theme")

    if (["light", "dark", "ocean", "rounded"].includes(savedTheme)) {
      return savedTheme
    }

    return "system"
  }

  selectByTheme(theme) {
    this.tabTargets.forEach((tab) => {
      const isActive = tab.dataset.themeValue === theme

      tab.setAttribute("aria-selected", isActive ? "true" : "false")
      tab.setAttribute("tabindex", isActive ? "0" : "-1")

      tab.classList.toggle("bg-[var(--surface-bg-color)]", isActive)
      tab.classList.toggle("text-primary", isActive)
      tab.classList.toggle("border-b-2", isActive)
      tab.classList.toggle("border-primary", isActive)
      tab.classList.toggle("-mb-px", isActive)

      tab.classList.toggle("text-[var(--surface-muted-content-color)]", !isActive)
      tab.classList.toggle("hover:text-[var(--surface-content-color)]", !isActive)
      tab.classList.toggle("hover:bg-[var(--surface-muted-bg-color)]", !isActive)
    })

    this.panelTargets.forEach((panel) => {
      panel.classList.toggle("hidden", panel.dataset.theme !== theme)
    })
  }

  handleThemeChanged(event) {
    const theme = event.detail?.theme
    if (!theme) return

    this.selectByTheme(theme)
  }
}
