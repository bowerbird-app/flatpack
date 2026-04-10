import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "chips", "template"]

  handleKeydown(event) {
    if (event.key !== "Enter") return

    event.preventDefault()

    const text = event.target.value.trim()
    if (!text) return

    this.addChip(text)
    this.inputTarget.value = ""
  }

  addChip(text) {
    const value = this.slugify(text)
    const existingValues = this.chipsTarget.querySelectorAll("[data-flat-pack--chip-value-value]")

    if ([...existingValues].some((element) => element.dataset.flatPackChipValueValue === value)) {
      return
    }

    const markup = this.templateTarget.innerHTML
      .replaceAll("__TAG_TEXT__", this.escapeHtml(text))
      .replaceAll("__TAG_VALUE__", this.escapeHtml(value))

    this.chipsTarget.insertAdjacentHTML("beforeend", markup)
  }

  slugify(value) {
    return String(value)
      .trim()
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/(^-|-$)/g, "")
  }

  escapeHtml(value) {
    return String(value)
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;")
      .replaceAll("'", "&#39;")
  }
}