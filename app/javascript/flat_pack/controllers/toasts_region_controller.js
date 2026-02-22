import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container"]

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
    const typeClasses = this.typeClasses(normalizedType)

    const toast = document.createElement("div")
    toast.setAttribute("role", "status")
    toast.setAttribute("aria-live", "polite")
    toast.setAttribute("aria-atomic", "true")
    toast.setAttribute("data-controller", "flat-pack--toast")
    toast.setAttribute("data-flat-pack--toast-timeout-value", String(timeout))
    toast.setAttribute("data-flat-pack--toast-dismissible-value", "true")
    toast.className = [
      "flex",
      "items-start",
      "gap-3",
      "p-4",
      "rounded-[var(--radius-md)]",
      "border",
      "shadow-lg",
      "z-[60]",
      "min-w-[300px]",
      "max-w-md",
      typeClasses.border,
      typeClasses.bg
    ].join(" ")

    const iconWrap = document.createElement("div")
    iconWrap.className = `flex-shrink-0 ${typeClasses.text}`
    iconWrap.innerHTML = this.iconSvg(normalizedType)

    const messageEl = document.createElement("p")
    messageEl.className = "flex-1 text-sm font-medium text-[var(--surface-content-color)]"
    messageEl.textContent = message

    const dismissButton = document.createElement("button")
    dismissButton.type = "button"
    dismissButton.className = this.dismissButtonClasses(normalizedType)
    dismissButton.setAttribute("aria-label", "Dismiss")
    dismissButton.setAttribute("data-action", "flat-pack--toast#dismiss")
    dismissButton.innerHTML = '<svg class="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path></svg>'

    toast.append(iconWrap, messageEl, dismissButton)
    return toast
  }

  normalizeType(type) {
    const allowedTypes = ["info", "success", "warning", "error"]
    return allowedTypes.includes(type) ? type : "info"
  }

  typeClasses(type) {
    const classes = {
      info: {
        border: "border-[var(--color-info-border)]",
        bg: "bg-[var(--surface-bg-color)]",
        text: "text-[var(--surface-content-color)]"
      },
      success: {
        border: "border-[var(--color-success-border)]",
        bg: "bg-[var(--surface-bg-color)]",
        text: "text-[var(--color-success-border)]"
      },
      warning: {
        border: "border-[var(--color-warning-border)]",
        bg: "bg-[var(--surface-bg-color)]",
        text: "text-[var(--color-warning-border)]"
      },
      error: {
        border: "border-[var(--color-destructive-border)]",
        bg: "bg-[var(--color-destructive-bg)]",
        text: "text-[var(--color-destructive-border)]"
      }
    }

    return classes[type]
  }

  dismissButtonClasses(type) {
    const base = "flex-shrink-0 transition-colors rounded-[var(--radius-sm)] p-1 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--color-ring)]"

    if (type === "error") {
      return `${base} bg-[var(--color-destructive-text)]/20 hover:bg-[var(--color-destructive-text)]/30 text-[var(--color-destructive-text)]`
    }

    return `${base} text-[var(--surface-muted-content-color)] hover:text-[var(--surface-content-color)]`
  }

  iconSvg(type) {
    switch (type) {
      case "success":
        return '<svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path></svg>'
      case "warning":
        return '<svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd"></path></svg>'
      case "error":
        return '<svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"></path></svg>'
      default:
        return '<svg class="w-5 h-5" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z" clip-rule="evenodd"></path></svg>'
    }
  }
}