import { Controller } from "@hotwired/stimulus"

const IGNORED_FIELD_NAMES = new Set(["authenticity_token", "utf8", "_method"])

function fieldPair(name, value) {
  return `${encodeURIComponent(name)}=${encodeURIComponent(String(value))}`
}

function formSnapshot(form) {
  const parts = []
  const elements = form.elements ? Array.from(form.elements) : []

  elements.forEach((element) => {
    const tag = (element.tagName || "").toUpperCase()
    if (tag !== "INPUT" && tag !== "SELECT" && tag !== "TEXTAREA") return
    if (!element.name || element.disabled) return
    if (IGNORED_FIELD_NAMES.has(element.name)) return

    const type = (element.type || "").toLowerCase()
    if (type === "submit" || type === "button" || type === "reset" || type === "image") return

    if (type === "checkbox" || type === "radio") {
      if (!element.checked) return
      parts.push(fieldPair(element.name, element.value))
      return
    }

    if (type === "file") {
      const files = element.files ? Array.from(element.files) : []
      if (files.length === 0) {
        parts.push(fieldPair(element.name, ""))
        return
      }

      files.forEach((file) => {
        parts.push(fieldPair(element.name, `${file.name}:${file.size}:${file.lastModified}`))
      })
      return
    }

    if (tag === "SELECT" && element.multiple) {
      const selected = element.selectedOptions ? Array.from(element.selectedOptions) : []
      selected.forEach((option) => parts.push(fieldPair(element.name, option.value)))
      return
    }

    parts.push(fieldPair(element.name, element.value ?? ""))
  })

  return parts.join("&")
}

export default class extends Controller {
  static targets = ["submit"]

  static values = {
    savedStyle: { type: String, default: "default" },
    unsavedStyle: { type: String, default: "primary" }
  }

  connect() {
    this.baselineReady = false
    this.userEdited = false
    this.onEdit = () => {
      if (!this.baselineReady) return
      this.userEdited = true
      this.applyStyle()
    }
    this.onReset = () => {
      if (typeof requestAnimationFrame === "function") {
        requestAnimationFrame(() => this.applyStyle())
        return
      }

      queueMicrotask(() => this.applyStyle())
    }
    this.onSubmitEnd = (event) => {
      if (!this.baselineReady) return
      if (event.detail && event.detail.success) {
        this.baseline = formSnapshot(this.element)
        this.userEdited = false
      }
      this.applyStyle()
    }

    this.element.addEventListener("input", this.onEdit)
    this.element.addEventListener("change", this.onEdit)
    this.element.addEventListener("reset", this.onReset)
    this.element.addEventListener("turbo:submit-end", this.onSubmitEnd)

    queueMicrotask(() => this.captureBaseline())

    if (typeof requestAnimationFrame === "function") {
      this.frame = requestAnimationFrame(() => {
        if (!this.userEdited) this.captureBaseline()
      })
    }
  }

  disconnect() {
    this.element.removeEventListener("input", this.onEdit)
    this.element.removeEventListener("change", this.onEdit)
    this.element.removeEventListener("reset", this.onReset)
    this.element.removeEventListener("turbo:submit-end", this.onSubmitEnd)

    if (this.frame && typeof cancelAnimationFrame === "function") {
      cancelAnimationFrame(this.frame)
    }
  }

  captureBaseline() {
    this.baseline = formSnapshot(this.element)
    this.baselineReady = true
    this.applyStyle()
  }

  applyStyle() {
    if (!this.baselineReady) return

    const unsaved = formSnapshot(this.element) !== this.baseline
    const style = unsaved ? this.unsavedStyleValue : this.savedStyleValue
    this.submitTargets.forEach((target) => {
      target.setAttribute("data-fp-style", style)
    })
  }
}
