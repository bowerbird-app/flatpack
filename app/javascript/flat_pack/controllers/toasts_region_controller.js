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

    const { style, text, timeout } = trigger.dataset

    this.appendToast({
      style: style || "info",
      text,
      timeout: this.parseTimeout(timeout)
    })
  }

  resolveTriggerElement(event) {
    if (event.currentTarget?.dataset?.text) return event.currentTarget

    // When the listener is delegated, currentTarget may be the controller root.
    if (event.target instanceof Element) {
      return event.target.closest('[data-action*="flat-pack--toasts-region#addToast"]')
    }

    return null
  }

  addToastFromEvent(event) {
    const detail = event.detail || {}

    this.appendToast({
      style: detail.style || "info",
      text: detail.text,
      timeout: this.parseTimeout(detail.timeout)
    })
  }

  appendToast({ style, text, timeout }) {
    if (!text) return

    const toast = this.buildToastElement({ style, text, timeout })
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

  buildToastElement({ style, text, timeout }) {
    const normalizedStyle = this.normalizeStyle(style)

    const template = this.templateForStyle(normalizedStyle)
    if (!(template instanceof HTMLTemplateElement)) return null

    const toast = template.content.firstElementChild?.cloneNode(true)
    if (!(toast instanceof HTMLElement)) return null

    this.applyToastContent(toast, text)
    this.applyToastTimeout(toast, timeout)

    return toast
  }

  templateForStyle(style) {
    switch (style) {
      case "success":
        return this.hasSuccessTemplateTarget ? this.successTemplateTarget : null
      case "warning":
        return this.hasWarningTemplateTarget ? this.warningTemplateTarget : null
      case "danger":
        return this.hasErrorTemplateTarget ? this.errorTemplateTarget : null
      default:
        return this.hasInfoTemplateTarget ? this.infoTemplateTarget : null
    }
  }

  applyToastContent(toast, text) {
    const messageElement = toast.querySelector("p.flex-1")
    if (messageElement) messageElement.textContent = text
  }

  applyToastTimeout(toast, timeout) {
    toast.setAttribute("data-flat-pack--toast-timeout-value", String(timeout))
  }

  normalizeStyle(style) {
    const allowedStyles = ["info", "success", "warning", "danger"]
    return allowedStyles.includes(style) ? style : "info"
  }
}