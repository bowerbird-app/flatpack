import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]
  static values = {
    activeClasses: String,
    inactiveClasses: String
  }

  connect() {
    this.activeClasses = this.parseClasses(this.activeClassesValue)
    this.inactiveClasses = this.parseClasses(this.inactiveClassesValue)
    this.syncPressedState()
  }

  activate(event) {
    this.setActiveButton(event.currentTarget)
  }

  setActiveButton(activeButton) {
    this.buttonTargets.forEach((button) => {
      const isActive = button === activeButton

      button.classList.remove(...(isActive ? this.inactiveClasses : this.activeClasses))
      button.classList.add(...(isActive ? this.activeClasses : this.inactiveClasses))
      button.setAttribute("aria-pressed", isActive ? "true" : "false")
    })
  }

  syncPressedState() {
    const activeButton = this.buttonTargets.find((button) => button.getAttribute("aria-pressed") === "true") || this.buttonTargets[0]
    if (activeButton) this.setActiveButton(activeButton)
  }

  parseClasses(classValue) {
    return classValue.split(/\s+/).filter(Boolean)
  }
}