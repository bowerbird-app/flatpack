import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "infoTemplate", "successTemplate", "warningTemplate", "errorTemplate"]

  connect() {
    this.boundAddToastFromEvent = this.addToastFromEvent.bind(this)
    document.addEventListener("toast:add", this.boundAddToastFromEvent)

    this.toastContainer = this.hasContainerTarget ? this.containerTarget : this.buildContainer()
    this.ensureContainerMountedToBody()
  }

  disconnect() {
    document.removeEventListener("toast:add", this.boundAddToastFromEvent)

    if (this.relocationState?.container?.isConnected) {
      const { container, parent, nextSibling } = this.relocationState

      if (parent?.isConnected) {
        if (nextSibling?.parentNode === parent) {
          parent.insertBefore(container, nextSibling)
        } else {
          parent.appendChild(container)
        }
      }
    }

    this.relocationState = null
  }

  addToast(event) {
    const trigger = this.resolveTriggerElement(event)
    if (!trigger) return

    const { type, message, timeout } = trigger.dataset

    this.appendToast({
      type: type || "info",
      message,
      timeout: this.parseTimeout(timeout)
    })
  }

  resolveTriggerElement(event) {
    if (event.currentTarget?.dataset?.message) return event.currentTarget

    // When the listener is delegated, currentTarget may be the controller root.
    if (event.target instanceof Element) {
      return event.target.closest('[data-action*="flat-pack--toasts-region#addToast"]')
    }

    return null
  }

  addToastFromEvent(event) {
    const detail = event.detail || {}

    this.appendToast({
      type: detail.type || "info",
      message: detail.message,
      timeout: this.parseTimeout(detail.timeout)
    })
  }

  appendToast({ type, message, timeout }) {
    if (!message) return

    const toast = this.buildToastElement({ type, message, timeout })
    if (!(toast instanceof HTMLElement)) return

    this.toastContainer.appendChild(toast)
  }

  buildContainer() {
    const container = document.createElement("div")
    container.className = "fixed z-[60] flex flex-col gap-3 pointer-events-none"
    container.style.top = "calc(72px + calc(var(--spacing) * 4))"
    container.style.right = "calc(var(--spacing) * 4)"
    container.setAttribute("aria-live", "polite")
    container.setAttribute("aria-atomic", "false")
    document.body.appendChild(container)
    return container
  }

  ensureContainerMountedToBody() {
    if (!this.toastContainer || this.toastContainer.parentElement === document.body) return

    this.relocationState = {
      container: this.toastContainer,
      parent: this.toastContainer.parentElement,
      nextSibling: this.toastContainer.nextSibling
    }

    document.body.appendChild(this.toastContainer)
  }

  parseTimeout(timeout) {
    const parsed = Number(timeout)
    return Number.isFinite(parsed) && parsed >= 0 ? parsed : 5000
  }

  buildToastElement({ type, message, timeout }) {
    const normalizedType = this.normalizeType(type)

    const template = this.templateForType(type)
    if (!(template instanceof HTMLTemplateElement)) return null

    const toast = template.content.firstElementChild?.cloneNode(true)
    if (!(toast instanceof HTMLElement)) return null

    this.applyToastContent(toast, message)
    this.applyToastTimeout(toast, timeout)

    return toast
  }

  templateForType(type) {
    switch (type) {
      case "success":
        return this.hasSuccessTemplateTarget ? this.successTemplateTarget : null
      case "warning":
        return this.hasWarningTemplateTarget ? this.warningTemplateTarget : null
      case "error":
        return this.hasErrorTemplateTarget ? this.errorTemplateTarget : null
      default:
        return this.hasInfoTemplateTarget ? this.infoTemplateTarget : null
    }
  }

  applyToastContent(toast, message) {
    const messageElement = toast.querySelector("p.flex-1")
    if (messageElement) messageElement.textContent = message
  }

  applyToastTimeout(toast, timeout) {
    toast.setAttribute("data-flat-pack--toast-timeout-value", String(timeout))
  }

  normalizeType(type) {
    const allowedTypes = ["info", "success", "warning", "error"]
    return allowedTypes.includes(type) ? type : "info"
  }
}