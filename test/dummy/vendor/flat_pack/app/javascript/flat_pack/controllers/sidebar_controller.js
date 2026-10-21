import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["collapse", "expand"]

  connect() {
    this.applyAria(this.readCollapsed())
    this.column = this.element.closest("[data-flat-pack--sidebar-layout-target='sidebar']")
    if (!this.column) return

    this.onLayoutCollapse = (event) => {
      this.applyAria(event.detail.collapsed)
    }
    this.column.addEventListener("flat-pack--sidebar-layout:collapse", this.onLayoutCollapse)
  }

  disconnect() {
    if (!this.column || !this.onLayoutCollapse) return
    this.column.removeEventListener("flat-pack--sidebar-layout:collapse", this.onLayoutCollapse)
  }

  readCollapsed() {
    const owner = this.element.closest("[data-flat-pack-sidebar-collapsed]") || this.element
    return owner.getAttribute("data-flat-pack-sidebar-collapsed") === "true"
  }

  applyAria(collapsed) {
    const expanded = collapsed ? "false" : "true"
    this.collapseTargets.forEach((node) => node.setAttribute("aria-expanded", expanded))
    this.expandTargets.forEach((node) => node.setAttribute("aria-expanded", expanded))
  }
}
