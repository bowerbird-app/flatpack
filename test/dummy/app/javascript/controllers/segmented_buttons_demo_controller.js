import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button"]
  static values = {
    activeStyle: String,
    inactiveStyle: { type: String, default: "secondary" },
    activePressClass: String,
    inactivePressClass: String
  }

  connect() {
    this.syncPressedState()
  }

  activate(event) {
    this.setActiveButton(event.currentTarget)
  }

  setActiveButton(activeButton) {
    this.buttonTargets.forEach((button) => {
      const isActive = button === activeButton

      button.dataset.fpStyle = isActive ? this.activeStyleValue : this.inactiveStyleValue
      button.classList.remove("fp-button-raised", "fp-button-flat")
      button.classList.add(isActive ? this.activePressClassValue : this.inactivePressClassValue)
      button.setAttribute("aria-pressed", isActive ? "true" : "false")
    })
  }

  syncPressedState() {
    const activeButton = this.buttonTargets.find((button) => button.getAttribute("aria-pressed") === "true") || this.buttonTargets[0]
    if (activeButton) this.setActiveButton(activeButton)
  }
}
