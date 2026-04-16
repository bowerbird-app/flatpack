// FlatPack Form Validation Stimulus Controller
import { Controller } from "@hotwired/stimulus"

const DEFAULT_BORDER_CLASS = "border-[var(--surface-border-color)]"

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

const DEFAULT_MESSAGES = {
  required: "Please fill out this field.",
  typeMismatch: "Please enter a valid value.",
  patternMismatch: "Please match the requested format.",
  tooShort: "Please lengthen this text.",
  tooLong: "Please shorten this text.",
  rangeUnderflow: "Value is too low.",
  rangeOverflow: "Value is too high.",
  stepMismatch: "Please enter a valid step value.",
  badInput: "Please enter a valid value.",
  customError: "Invalid value."
}

export default class extends Controller {
  static values = {
    errorId: String,
    type: String
  }

  connect() {
    this.initialValue = this.element.value
    this.initialDescribedBy = this.element.getAttribute("aria-describedby") || ""
    this.initialBorderColor = this.element.style.borderColor || ""
    this.initialHasDefaultBorderClass = this.element.classList.contains(DEFAULT_BORDER_CLASS)
    this.initialErrorState = this.captureInitialErrorState()
    this.baseDescribedBy = this.describedByWithoutError(this.initialDescribedBy)
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
        return this.messageOverride(messageKey) || this.element.validationMessage || this.defaultMessage(messageKey)
      }
    }

    if (validity.customError) {
      return this.messageOverride("customError") || this.element.validationMessage || this.defaultMessage("customError")
    }

    return this.element.validationMessage || "Invalid value."
  }

  messageOverride(key) {
    const dataKey = `flatPackMessage${key.charAt(0).toUpperCase()}${key.slice(1)}`
    return (this.element.dataset || {})[dataKey]
  }

  showError(message) {
    const errorNode = this.errorNode()
    if (!errorNode) return

    errorNode.textContent = message
    errorNode.classList.add("text-warning")
    errorNode.classList.remove("hidden")

    // Apply a visible invalid border for JS-driven validation states.
    this.element.classList.add("border-warning")
    this.element.style.borderColor = "var(--color-warning)"

    this.element.setAttribute("aria-invalid", "true")
    this.syncDescribedBy(errorNode.id)
  }

  clearError() {
    const errorNode = this.errorNode(false)
    const shouldRestoreInitialError = this.shouldRestoreInitialError()

    if (errorNode) {
      if (shouldRestoreInitialError) {
        errorNode.className = this.initialErrorState.className
        errorNode.textContent = this.initialErrorState.textContent

        if (this.initialErrorState.hidden) {
          errorNode.classList.add("hidden")
        } else {
          errorNode.classList.remove("hidden")
        }
      } else {
        errorNode.classList.add("hidden")
        errorNode.textContent = ""
      }
    }

    if (shouldRestoreInitialError) {
      this.element.classList.add("border-warning")
      if (this.initialHasDefaultBorderClass) {
        this.element.classList.add(DEFAULT_BORDER_CLASS)
      }
    } else {
      this.element.classList.remove("border-warning")
      this.element.classList.add(DEFAULT_BORDER_CLASS)
    }

    if (this.initialBorderColor) {
      this.element.style.borderColor = this.initialBorderColor
    } else {
      this.element.style.removeProperty("border-color")
    }

    if (shouldRestoreInitialError) {
      this.element.setAttribute("aria-invalid", "true")
    } else {
      this.element.removeAttribute("aria-invalid")
    }

    if (shouldRestoreInitialError && this.initialDescribedBy) {
      this.element.setAttribute("aria-describedby", this.initialDescribedBy)
    } else if (this.baseDescribedBy) {
      this.element.setAttribute("aria-describedby", this.baseDescribedBy)
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

  captureInitialErrorState() {
    const errorNode = this.errorNode(false)
    if (!errorNode) return null

    return {
      className: errorNode.className,
      hidden: errorNode.classList.contains("hidden"),
      textContent: errorNode.textContent
    }
  }

  defaultMessage(key) {
    return DEFAULT_MESSAGES[key] || "Invalid value."
  }

  shouldRestoreInitialError() {
    return Boolean(this.initialErrorState) && this.element.value === this.initialValue
  }

  describedByWithoutError(describedBy) {
    return describedBy
      .split(/\s+/)
      .filter(Boolean)
      .filter((token) => token !== this.errorIdValue)
      .join(" ")
  }

  syncDescribedBy(errorId) {
    const existing = (this.element.getAttribute("aria-describedby") || "").split(/\s+/).filter(Boolean)
    if (!existing.includes(errorId)) {
      existing.push(errorId)
    }

    this.element.setAttribute("aria-describedby", existing.join(" "))
  }
}
