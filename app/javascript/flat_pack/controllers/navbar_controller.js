import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["topNav", "leftNav", "collapseIcon"]
  static values = {
    leftNavWidth: String,
    leftNavCollapsedWidth: String,
    topNavHeight: String,
    collapsed: Boolean
  }

  connect() {
    this.updateLeftNavWidth()
  }

  toggleLeftNav() {
    this.collapsedValue = !this.collapsedValue
    this.updateLeftNavWidth()
  }

  collapsedValueChanged() {
    this.updateLeftNavWidth()
    this.rotateCollapseIcon()
  }

  updateLeftNavWidth() {
    if (!this.hasLeftNavTarget) return

    const width = this.collapsedValue ? this.leftNavCollapsedWidthValue : this.leftNavWidthValue
    this.leftNavTarget.style.width = width
    
    // Update CSS variable for main content margin
    this.element.style.setProperty("--navbar-left-nav-width", width)
  }

  rotateCollapseIcon() {
    if (!this.hasCollapseIconTarget) return

    if (this.collapsedValue) {
      this.collapseIconTarget.style.transform = "rotate(180deg)"
    } else {
      this.collapseIconTarget.style.transform = "rotate(0deg)"
    }
  }
}
