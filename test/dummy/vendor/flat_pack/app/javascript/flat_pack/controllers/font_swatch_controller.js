// FlatPack Font Swatch Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["trigger", "swatch", "input", "menu", "option"]

  connect() {
    this.syncFace()
    this.observeMenuOpenState()
  }

  disconnect() {
    this.menuOpenObserver?.disconnect()
  }

  select(event) {
    event.preventDefault()
    event.stopPropagation()

    const button = event.currentTarget
    const value = button.dataset.value
    const label = button.dataset.label || value || "Font"

    if (this.hasInputTarget) {
      this.inputTarget.value = value
    }

    if (this.hasSwatchTarget) {
      this.swatchTarget.style.fontFamily = value
    }

    this.updateOptionSelection(value)
    this.updateAccessibleName(label)
    this.updateTooltip(label)
    this.closeMenu()

    this.element.dispatchEvent(
      new CustomEvent("font-swatch:change", {
        detail: { value, label },
        bubbles: true
      })
    )
  }

  syncFace() {
    if (!this.hasInputTarget || !this.hasSwatchTarget) return

    this.swatchTarget.style.fontFamily = this.inputTarget.value
  }

  updateOptionSelection(value) {
    if (!this.hasOptionTarget) return

    this.optionTargets.forEach((option) => {
      option.setAttribute("aria-selected", (option.dataset.value === value).toString())
    })
  }

  updateAccessibleName(label) {
    if (!this.hasTriggerTarget) return

    this.triggerTarget.setAttribute("aria-label", label)
  }

  updateTooltip(label) {
    const tooltip = this.element.querySelector('[role="tooltip"]')
    if (tooltip) {
      tooltip.textContent = label
    }
  }

  closeMenu() {
    const popoverElement = this.element.querySelector('[data-controller~="flat-pack--popover"]')
    if (!popoverElement) return

    const popover = this.application.getControllerForElementAndIdentifier(
      popoverElement,
      "flat-pack--popover"
    )
    popover?.close()
    this.syncTooltipVisibility()
  }

  observeMenuOpenState() {
    if (!this.hasTriggerTarget) return

    this.syncTooltipVisibility()
    this.menuOpenObserver = new MutationObserver(() => this.syncTooltipVisibility())
    this.menuOpenObserver.observe(this.triggerTarget, {
      attributes: true,
      attributeFilter: ["aria-expanded"]
    })
  }

  syncTooltipVisibility() {
    const open = this.triggerTarget?.getAttribute("aria-expanded") === "true"
    const tooltip = this.element.querySelector('[role="tooltip"]')
    if (!tooltip) return

    if (open) {
      tooltip.classList.add("hidden")
      tooltip.style.opacity = "0"
    }
  }
}
