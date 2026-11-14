import { Controller } from "@hotwired/stimulus"

// Host-only listener. Flatpack picks files and dispatches the change event.
// This page logs the names and moves its own progress bar.
export default class extends Controller {
  static targets = ["log"]

  selected(event) {
    const files = Array.from(event.detail && event.detail.files ? event.detail.files : [])
    const names = files.map((file) => file.name)
    console.log("flat-pack:file-input:change", names)

    if (this.hasLogTarget) {
      this.logTarget.textContent = names.length === 0 ? "No files." : names.join(", ")
    }

    this.paintProgress(event, files)
  }

  paintProgress(event, files) {
    const host = event.target.closest("[data-file-input-host='progress']")
    if (!host) return

    const percent = files.length === 0 ? 0 : 40
    const fill = host.querySelector(".fp-progress-fill")
    const bar = host.querySelector("[role='progressbar']")
    if (fill) fill.style.width = `${percent}%`
    if (bar) bar.setAttribute("aria-valuenow", String(percent))
    const caption = fill && fill.querySelector(".sr-only")
    if (caption) caption.textContent = `${percent}%`
  }
}
