import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["eventOutput"]

  handleConfirm(event) {
    const detail = event?.detail || {}
    const selection = Array.isArray(detail.selection) ? detail.selection : []

    if (!this.hasEventOutputTarget) {
      return
    }

    if (selection.length === 0) {
      this.eventOutputTarget.innerHTML = "<li class='text-(--surface-muted-content-color)'>No items selected.</li>"
      return
    }

    this.eventOutputTarget.innerHTML = selection
      .map((item) => {
        const label = this.#escapeHtml(item.label || item.name || "Untitled")
        const kind = item.kind === "image" ? "image" : "file"
        return `<li class='truncate text-(--surface-content-color)'>${label} <span class='text-(--surface-muted-content-color)'>(${kind})</span></li>`
      })
      .join("")
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
