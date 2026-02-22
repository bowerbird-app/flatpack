import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select"]

  static THEME_CHANGED_EVENT = "flat-pack:theme-changed"

  get storageKey() {
    return 'flatpack-theme'
  }

  get legacyStorageKey() {
    return 'flatpack-dummy-theme'
  }

  connect() {
    this.boundHandleThemeChanged = this.handleThemeChanged.bind(this)
    window.addEventListener(this.constructor.THEME_CHANGED_EVENT, this.boundHandleThemeChanged)

    const savedTheme = localStorage.getItem(this.storageKey)
    if (savedTheme) {
      this.applyTheme(savedTheme)
      this.syncSelect(savedTheme)
    } else {
      // No explicit user preference saved: keep current/system theme behavior.
      this.syncSelect('system')
    }
  }

  disconnect() {
    window.removeEventListener(this.constructor.THEME_CHANGED_EVENT, this.boundHandleThemeChanged)
  }

  switch(event) {
    const themeValue = event.currentTarget.dataset.themeValue || event.currentTarget.value || 'system'

    this.applyTheme(themeValue)
    this.syncSelect(themeValue)
    this.broadcastThemeChange(themeValue)
  }

  applyTheme(themeValue) {
    const root = document.documentElement
    let isDark = false

    if (themeValue === 'system') {
      isDark = window.matchMedia('(prefers-color-scheme: dark)').matches

      if (isDark) {
        root.setAttribute('data-theme', 'dark')
      } else {
        root.removeAttribute('data-theme')
      }

      localStorage.removeItem(this.storageKey)
      localStorage.removeItem(this.legacyStorageKey)
    } else {
      isDark = themeValue === 'dark'

      if (themeValue === 'light') {
        root.removeAttribute('data-theme')
      } else {
        root.setAttribute('data-theme', themeValue)
      }

      localStorage.setItem(this.storageKey, themeValue)
      localStorage.setItem(this.legacyStorageKey, themeValue)
    }

    // Keep legacy class selectors in sync for components that still use them.
    root.classList.toggle('dark', isDark)
    root.classList.toggle('light', !isDark)
  }

  syncSelect(themeValue) {
    if (!this.hasSelectTarget) return

    this.selectTarget.value = themeValue
  }

  handleThemeChanged(event) {
    const themeValue = event.detail?.theme
    if (!themeValue) return

    this.syncSelect(themeValue)
  }

  broadcastThemeChange(themeValue) {
    window.dispatchEvent(new CustomEvent(this.constructor.THEME_CHANGED_EVENT, {
      detail: {theme: themeValue}
    }))
  }
}