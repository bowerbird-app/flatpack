import { Controller } from "@hotwired/stimulus"

const ANIMATION_DURATION = 200

export default class extends Controller {
  static targets = ["panel", "button", "chevron"]
  static values = {
    defaultOpen: Boolean,
    groupId: String
  }

  connect() {
    this.disableTransitions()
    this.isOpen = this.initialOpenState()
    this.applyInitialState()
  }

  toggle() {
    if (this.isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.isOpen = true
    this.persistState()
    this.enableTransitions()

    // Update aria-expanded
    if (this.hasButtonTarget) {
      this.buttonTarget.setAttribute("aria-expanded", "true")
    }

    // Rotate chevron
    if (this.hasChevronTarget) {
      this.chevronTarget.style.transform = "rotate(0deg)"
    }

    // Expand panel with height animation
    if (this.hasPanelTarget) {
      const panel = this.panelTarget
      
      // Get the full height
      panel.style.maxHeight = "none"
      const height = panel.scrollHeight
      panel.style.maxHeight = "0"
      
      // Force reflow
      panel.offsetHeight
      
      // Animate to full height
      panel.style.maxHeight = `${height}px`
      
      // After transition, remove max-height constraint
      setTimeout(() => {
        if (this.isOpen) {
          panel.style.maxHeight = "none"
        }
      }, ANIMATION_DURATION)
    }
  }

  close() {
    this.isOpen = false
    this.persistState()
    this.enableTransitions()

    // Update aria-expanded
    if (this.hasButtonTarget) {
      this.buttonTarget.setAttribute("aria-expanded", "false")
    }

    // Rotate chevron
    if (this.hasChevronTarget) {
      this.chevronTarget.style.transform = "rotate(-90deg)"
    }

    // Collapse panel with height animation
    if (this.hasPanelTarget) {
      const panel = this.panelTarget
      
      // Set current height
      const height = panel.scrollHeight
      panel.style.maxHeight = `${height}px`
      
      // Force reflow
      panel.offsetHeight
      
      // Animate to zero
      panel.style.maxHeight = "0"
    }
  }

  applyInitialState() {
    if (this.hasButtonTarget) {
      this.buttonTarget.setAttribute("aria-expanded", this.isOpen ? "true" : "false")
    }

    if (this.hasChevronTarget) {
      this.chevronTarget.style.transform = this.isOpen ? "rotate(0deg)" : "rotate(-90deg)"
    }

    if (this.hasPanelTarget) {
      this.panelTarget.style.maxHeight = this.isOpen ? "none" : "0"
    }
  }

  initialOpenState() {
    const persistedState = this.readPersistedState()
    if (persistedState !== null) return persistedState

    return this.defaultOpenValue
  }

  persistState() {
    const key = this.persistenceKey()
    if (!key) return

    try {
      localStorage.setItem(key, this.isOpen ? "true" : "false")
    } catch {
      // Ignore storage errors (private mode / storage disabled)
    }
  }

  readPersistedState() {
    const key = this.persistenceKey()
    if (!key) return null

    try {
      const value = localStorage.getItem(key)
      if (value === null) return null

      return value === "true"
    } catch {
      return null
    }
  }

  persistenceKey() {
    if (!this.hasGroupIdValue || !this.groupIdValue) return null

    const layoutElement = this.element.closest('[data-flat-pack--sidebar-layout-storage-key-value]')
    const layoutStorageKey = layoutElement?.dataset?.flatPackSidebarLayoutStorageKeyValue || "default"

    return `flat-pack-sidebar-group:${layoutStorageKey}:${this.groupIdValue}`
  }

  disableTransitions() {
    if (this.hasPanelTarget) {
      this.panelTarget.style.transition = "none"
    }

    if (this.hasChevronTarget) {
      this.chevronTarget.style.transition = "none"
    }
  }

  enableTransitions() {
    if (this.hasPanelTarget) {
      this.panelTarget.style.transition = `max-height ${ANIMATION_DURATION}ms ease-in-out`
    }

    if (this.hasChevronTarget) {
      this.chevronTarget.style.transition = `transform ${ANIMATION_DURATION}ms ease-in-out`
    }
  }
}
