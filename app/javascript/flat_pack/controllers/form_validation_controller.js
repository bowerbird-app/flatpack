// FlatPack Form Validation Stimulus Controller
import { Controller } from "@hotwired/stimulus"

const MESSAGE_KEYS = {
  valueMissing: "required",
  typeMismatch: "typeMismatch",
  patternMismatch: "patternMismatch",
  tooShort: "tooShort",
  tooLong: "tooLong",
  rangeUnderflow: "rangeUnderflow",
  rangeOverflow: "rangeOverflow",
  stepMismatch: "stepMismatch",
  badInput: "badInput"
}

export default class extends Controller {
  static values = {
    errorId: String,
    type: String
  }

  connect() {
    this.initialDescribedBy = this.element.getAttribute("aria-describedby") || ""
    this.initialBorderColor = this.element.style.borderColor || ""
    this.onValidate = this.validate.bind(this)
    this.onInvalid = this.invalid.bind(this)

    this.element.addEventListener("input", this.onValidate)
    this.element.addEventListener("blur", this.onValidate)
    this.element.addEventListener("change", this.onValidate)
    this.element.addEventListener("invalid", this.onInvalid)
  }

  disconnect() {
    this.element.removeEventListener("input", this.onValidate)
    this.element.removeEventListener("blur", this.onValidate)
    this.element.removeEventListener("change", this.onValidate)
    this.element.removeEventListener("invalid", this.onInvalid)
  }

  validate() {
    if (!this.isElementValid()) {
      this.showError(this.validationMessage())
      return
    }

    this.clearError()
  }

  invalid(event) {
    event.preventDefault()
    this.showError(this.validationMessage())
  }

  isElementValid() {
    if (this.typeValue === "custom-select-hidden") {
      if (!this.element.required) return true
      return this.element.value.trim().length > 0
    }

    if (typeof this.element.checkValidity === "function") {
      this.element.setCustomValidity("")
      return this.element.checkValidity()
    }

    return true
  }

  validationMessage() {
    if (this.typeValue === "custom-select-hidden") {
      if (this.element.required && this.element.value.trim().length === 0) {
        return this.messageOverride("required") || "Please select an option."
      }

      return "Invalid selection."
    }

    const validity = this.element.validity
    if (!validity) return "Invalid value."

    for (const [flag, messageKey] of Object.entries(MESSAGE_KEYS)) {
      if (validity[flag]) {
        return this.messageOverride(messageKey) || this.element.validationMessage
      }
    }

    if (validity.customError) {
      return this.messageOverride("customError") || this.element.validationMessage
    }

    return this.element.validationMessage || "Invalid value."
  }

  messageOverride(key) {
    const dataKey = `flatPackMessage${key.charAt(0).toUpperCase()}${key.slice(1)}`
    return this.element.dataset[dataKey]
  }

  showError(message) {
    const errorNode = this.errorNode()
    if (!errorNode) return

    errorNode.textContent = message
    errorNode.classList.remove("hidden")

    // Apply a visible invalid border for JS-driven validation states.
    this.element.classList.add("border-warning")
    this.element.style.borderColor = "var(--color-warning)"

    this.element.setAttribute("aria-invalid", "true")
    this.syncDescribedBy(errorNode.id)
  }

  clearError() {
    const errorNode = this.errorNode(false)
    if (errorNode) {
      errorNode.classList.add("hidden")
      errorNode.textContent = ""
    }

    this.element.classList.remove("border-warning")
    if (this.initialBorderColor) {
      this.element.style.borderColor = this.initialBorderColor
    } else {
      this.element.style.removeProperty("border-color")
    }

    this.element.removeAttribute("aria-invalid")
    if (this.initialDescribedBy) {
      this.element.setAttribute("aria-describedby", this.initialDescribedBy)
    } else {
      this.element.removeAttribute("aria-describedby")
    }
  }

  errorNode(createWhenMissing = true) {
    if (this.hasErrorIdValue) {
      const existing = document.getElementById(this.errorIdValue)
      if (existing) return existing
    }

    if (!createWhenMissing || !this.hasErrorIdValue) return null

    const node = document.createElement("p")
    node.id = this.errorIdValue
    node.className = "mt-1 text-sm text-warning hidden"

    const container = this.errorContainer()
    if (container) {
      container.appendChild(node)
      return node
    }

    return null
  }

  errorContainer() {
    if (!(this.element instanceof HTMLElement)) {
      return null
    }

    if (this.element.type === "checkbox") {
      return this.element.closest(".flat-pack-checkbox-wrapper") || this.element.parentElement
    }

    if (this.element.type === "radio") {
      return this.element.closest(".flat-pack-radio-group-wrapper") || this.element.parentElement
    }

    return this.element.parentElement
  }

  syncDescribedBy(errorId) {
    const existing = (this.element.getAttribute("aria-describedby") || "").split(/\s+/).filter(Boolean)
    if (!existing.includes(errorId)) {
      existing.push(errorId)
    }

    this.element.setAttribute("aria-describedby", existing.join(" "))
  }
}
