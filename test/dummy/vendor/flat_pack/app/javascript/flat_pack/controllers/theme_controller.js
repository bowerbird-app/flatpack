import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select"]
  static values = {
    themes: Array,
    storageKey: { type: String, default: "flatpack-theme" },
    legacyStorageKey: { type: String, default: "flatpack-dummy-theme" }
  }

  static THEME_CHANGED_EVENT = "flat-pack:theme-changed"

  connect() {
    this.boundHandleThemeChanged = this.handleThemeChanged.bind(this)
    window.addEventListener(this.constructor.THEME_CHANGED_EVENT, this.boundHandleThemeChanged)

    const savedTheme = localStorage.getItem(this.storageKeyValue)
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
    const selectedLabel = event.currentTarget.dataset.themeLabel || event.currentTarget.textContent?.trim() || null

    this.applyTheme(themeValue)
    this.syncSelect(themeValue, selectedLabel)
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

      localStorage.removeItem(this.storageKeyValue)
      localStorage.removeItem(this.legacyStorageKeyValue)
    } else {
      isDark = themeValue === 'dark'

      if (themeValue === 'light') {
        root.removeAttribute('data-theme')
      } else {
        root.setAttribute('data-theme', themeValue)
      }

      localStorage.setItem(this.storageKeyValue, themeValue)
      localStorage.setItem(this.legacyStorageKeyValue, themeValue)
    }

    // Keep legacy class selectors in sync for components that still use them.
    root.classList.toggle('dark', isDark)
    root.classList.toggle('light', !isDark)
  }

  syncSelect(themeValue, selectedLabel = null) {
    this.syncDropdownLabel(themeValue, selectedLabel)

    if (!this.hasSelectTarget) return

    this.selectTarget.value = themeValue
  }

  syncDropdownLabel(themeValue, selectedLabel = null) {
    const triggerLabel = this.themeTriggerLabel
    if (!triggerLabel) return

    triggerLabel.textContent = this.themeLabel(themeValue, selectedLabel)
  }

  themeLabel(themeValue, selectedLabel = null) {
    const matchedOption = this.themeOptions.find((option) => option.value === themeValue)
    if (matchedOption?.label) return matchedOption.label
    if (selectedLabel) return selectedLabel

    return this.humanizeThemeValue(themeValue)
  }

  get themeOptions() {
    const providedThemes = this.hasThemesValue ? this.themesValue : this.defaultThemeOptions()

    return providedThemes
      .map((option) => this.normalizeThemeOption(option))
      .filter(Boolean)
  }

  defaultThemeOptions() {
    return [
      { value: 'system', label: 'System' },
      { value: 'light', label: 'Light' },
      { value: 'dark', label: 'Dark' },
      { value: 'ocean', label: 'Ocean' },
      { value: 'rounded', label: 'Rounded' }
    ]
  }

  normalizeThemeOption(option) {
    if (typeof option === 'string' && option.trim().length > 0) {
      return { value: option, label: this.humanizeThemeValue(option) }
    }

    if (option && typeof option === 'object' && typeof option.value === 'string' && option.value.trim().length > 0) {
      return {
        value: option.value,
        label: option.label || this.humanizeThemeValue(option.value)
      }
    }

    return null
  }

  humanizeThemeValue(themeValue) {
    return (themeValue || 'system')
      .replace(/[-_]+/g, ' ')
      .replace(/\b\w/g, (character) => character.toUpperCase())
  }

  get themeTriggerLabel() {
    return this.element.querySelector('[data-flat-pack--button-dropdown-target="trigger"] span')
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