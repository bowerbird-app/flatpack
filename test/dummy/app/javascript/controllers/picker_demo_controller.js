import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["eventOutput", "lastPickerId"]

  handleConfirm(event) {
    const detail = event?.detail || {}
    const pickerId = String(detail.pickerId || "")
    const selection = Array.isArray(detail.selection) ? detail.selection : []

    const lastPickerTargets = this.#targetsForPicker(this.lastPickerIdTargets, pickerId)
    const eventOutputTargets = this.#targetsForPicker(this.eventOutputTargets, pickerId)

    lastPickerTargets.forEach((target) => {
      target.textContent = pickerId || "none"
    })

    if (eventOutputTargets.length === 0) {
      return
    }

    if (selection.length === 0) {
      eventOutputTargets.forEach((target) => {
        target.innerHTML = "<li class='text-(--surface-muted-content-color)'>No items selected.</li>"
      })
      return
    }

    const selectionMarkup = selection
      .map((item) => {
        const label = this.#escapeHtml(item.label || item.name || "Untitled")
        const kind = ["image", "record"].includes(item.kind) ? item.kind : "file"
        return `<li class='truncate text-(--surface-content-color)'>${label} <span class='text-(--surface-muted-content-color)'>(${kind})</span></li>`
      })
      .join("")

    eventOutputTargets.forEach((target) => {
      target.innerHTML = selectionMarkup
    })
  }

  #targetsForPicker(targets, pickerId) {
    return targets.filter((target) => target.dataset.pickerDemoOutputFor === pickerId)
  }

  #escapeHtml(value) {
    return String(value)
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;")
      .replaceAll("'", "&#39;")
  }
}
