import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fileInput"]

  static values = {
    threadSelector: { type: String, default: "[data-flat-pack--chat-scroll-target='messages']" },
    endpoint: String,
    method: { type: String, default: "post" }
  }

  connect() {
    this.selectedFiles = []
  }

  openFilePicker(event) {
    event.preventDefault()

    if (!this.hasFileInputTarget) {
      return
    }

    this.fileInputTarget.click()
  }

  handleFileSelection(event) {
    const files = Array.from(event.target?.files || [])
    this.selectedFiles = files
  }

  async submit(event) {
    event.preventDefault()

    const textarea = this.#textarea()
    if (!textarea) {
      return
    }

    const body = textarea.value.trim()
    const attachments = this.#selectedAttachments()

    if (!body && attachments.length === 0) {
      return
    }

    const threadElement = this.#threadElement()
    if (!threadElement) {
      return
    }

    const optimisticElement = this.#buildOptimisticMessageElement(body, attachments)
    threadElement.append(optimisticElement)

    textarea.value = ""
    textarea.dispatchEvent(new Event("input", { bubbles: true }))
    this.#clearSelectedFiles()

    const submitButton = this.#submitButton()
    if (submitButton) {
      submitButton.disabled = true
    }

    this.#notifyNewMessage(threadElement)

    try {
      const payload = this.#payloadFor(body, attachments)
      const response = await this.#sendMessage(payload, optimisticElement)
      this.#confirmMessage(optimisticElement, response)
      this.#dispatchLifecycleEvent("flat-pack:chat:message:confirmed", {
        payload,
        response,
        optimisticElement
      })
    } catch (error) {
      this.#failMessage(optimisticElement)
      this.#dispatchLifecycleEvent("flat-pack:chat:message:failed", {
        error,
        optimisticElement
      })
    } finally {
      if (submitButton) {
        submitButton.disabled = false
      }
      this.#notifyNewMessage(threadElement)
    }
  }

  #textarea() {
    return this.element.querySelector("textarea")
  }

  #submitButton() {
    return this.element.querySelector("button[type='submit']")
  }

  #threadElement() {
    let currentElement = this.element

    while (currentElement) {
      const match = currentElement.querySelector(this.threadSelectorValue)
      if (match) {
        return match
      }

      currentElement = currentElement.parentElement
    }

    return document.querySelector(this.threadSelectorValue)
  }

  #buildOptimisticMessageElement(body, attachments) {
    const timestamp = this.#timeLabel()
    const bodyMarkup = body ? `<div class="wrap-break-word whitespace-pre-line">${this.#escapeHtml(body)}</div>` : ""
    const attachmentsMarkup = this.#attachmentMarkup(attachments)

    const wrapper = document.createElement("div")
    wrapper.className = "flex items-start gap-0 flex-row-reverse"
    wrapper.dataset.flatPackChatSenderTempId = `${Date.now()}-${Math.floor(Math.random() * 10_000)}`

    wrapper.innerHTML = `
      <div class="flex-1 min-w-0 space-y-1">
        <div class="space-y-1">
          <div class="flex justify-end" data-chat-message-state="sending">
            <div data-flat-pack-chat-sender-bubble class="relative px-4 py-2 rounded-2xl max-w-[75%] sm:max-w-[500px] shadow-sm bg-(--chat-message-outgoing-background-color) text-(--chat-message-outgoing-text-color) opacity-60">
              ${bodyMarkup}
              ${attachmentsMarkup}
              <div class="mt-1 [--chat-message-meta-color:var(--chat-message-outgoing-meta-color)] [--chat-read-receipt-color:var(--chat-message-outgoing-read-receipt-color)]">
                <div data-flat-pack-chat-sender-meta class="flex items-center gap-1.5 text-xs">
                  <span class="text-xs text-(--chat-message-meta-color)">${this.#escapeHtml(timestamp)}</span>
                  <span class="text-xs text-(--chat-message-meta-color)">Sending...</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    `

    return wrapper
  }

  #payloadFor(body, attachments) {
    return {
      body,
      chatGroupId: this.element.dataset.threadId,
      attachments,
      clientTempId: this.#tempId(),
      submittedAt: new Date().toISOString()
    }
  }

  #selectedAttachments() {
    return this.selectedFiles.map((file) => ({
      kind: file.type.startsWith("image/") ? "image" : "file",
      name: file.name,
      contentType: file.type || null,
      byteSize: Number.isFinite(file.size) ? file.size : null
    }))
  }

  #clearSelectedFiles() {
    this.selectedFiles = []

    if (this.hasFileInputTarget) {
      this.fileInputTarget.value = ""
    }
  }

  #attachmentMarkup(attachments) {
    if (!attachments || attachments.length === 0) {
      return ""
    }

    const items = attachments.map((attachment) => this.#singleAttachmentMarkup(attachment)).join("")
    return `<div class="mt-2 space-y-2">${items}</div>`
  }

  #singleAttachmentMarkup(attachment) {
    const kind = attachment.kind === "image" ? "image" : "file"
    const meta = this.#attachmentMeta(attachment)
    const icon = kind === "image" ? "🖼" : "📎"

    return `
      <div class="inline-flex w-fit max-w-full items-center gap-3 border border-(--chat-attachment-border-color) rounded-lg p-3">
        <div class="shrink-0 text-base">${icon}</div>
        <div class="min-w-0">
          <div class="text-sm font-medium text-(--chat-attachment-text-color) truncate max-w-[32ch]">${this.#escapeHtml(attachment.name || "Attachment")}</div>
          ${meta ? `<div class="text-xs text-(--chat-attachment-meta-color) truncate max-w-[32ch]">${this.#escapeHtml(meta)}</div>` : ""}
        </div>
      </div>
    `
  }

  #attachmentMeta(attachment) {
    const parts = []

    if (attachment.contentType) {
      parts.push(attachment.contentType)
    }

    if (typeof attachment.byteSize === "number" && Number.isFinite(attachment.byteSize)) {
      parts.push(this.#humanSize(attachment.byteSize))
    }

    return parts.join(" • ")
  }

  #humanSize(bytes) {
    if (bytes < 1024) {
      return `${bytes} B`
    }

    const units = ["KB", "MB", "GB"]
    let value = bytes / 1024
    let unitIndex = 0

    while (value >= 1024 && unitIndex < units.length - 1) {
      value /= 1024
      unitIndex += 1
    }

    return `${value.toFixed(value >= 10 ? 0 : 1)} ${units[unitIndex]}`
  }

  #sendMessage(payload, optimisticElement) {
    let providedPromise = null

    const sendEvent = new CustomEvent("flat-pack:chat:send", {
      bubbles: true,
      cancelable: true,
      detail: {
        payload,
        form: this.element,
        optimisticElement,
        respondWith: (promiseLike) => {
          providedPromise = Promise.resolve(promiseLike)
        }
      }
    })

    this.element.dispatchEvent(sendEvent)

    if (providedPromise) {
      return providedPromise
    }

    if (this.hasEndpointValue) {
      return this.#postToEndpoint(payload)
    }

    return Promise.resolve({ body: payload.body, state: "sent" })
  }

  async #postToEndpoint(payload) {
    const response = await fetch(this.endpointValue, {
      method: this.methodValue.toUpperCase(),
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
        "X-CSRF-Token": this.#csrfToken()
      },
      body: JSON.stringify({ message: payload })
    })

    if (!response.ok) {
      throw new Error(`Request failed with ${response.status}`)
    }

    return response.json().catch(() => ({}))
  }

  #confirmMessage(optimisticElement, response) {
    if (response && typeof response.html === "string" && response.html.trim().length > 0) {
      optimisticElement.outerHTML = response.html
      return
    }

    const messageStateElement = optimisticElement.querySelector("[data-chat-message-state]")
    if (messageStateElement) {
      messageStateElement.dataset.chatMessageState = response?.state || "sent"
    }

    const bubbleElement = optimisticElement.querySelector("[data-flat-pack-chat-sender-bubble]")
    if (bubbleElement) {
      bubbleElement.classList.remove("opacity-60", "opacity-50", "border-2", "border-[var(--chat-message-failed-color)]")
    }

    const metaElement = optimisticElement.querySelector("[data-flat-pack-chat-sender-meta]")
    if (metaElement) {
      const timestamp = this.#escapeHtml(response?.timestamp || this.#timeLabel())
      metaElement.innerHTML = `<span class="text-xs text-(--chat-message-meta-color)">${timestamp}</span>`
    }
  }

  #failMessage(optimisticElement) {
    const messageStateElement = optimisticElement.querySelector("[data-chat-message-state]")
    if (messageStateElement) {
      messageStateElement.dataset.chatMessageState = "failed"
    }

    const bubbleElement = optimisticElement.querySelector("[data-flat-pack-chat-sender-bubble]")
    if (bubbleElement) {
      bubbleElement.classList.remove("opacity-60")
      bubbleElement.classList.add("opacity-50", "border-2", "border-[var(--chat-message-failed-color)]")
    }

    const metaElement = optimisticElement.querySelector("[data-flat-pack-chat-sender-meta]")
    if (metaElement) {
      metaElement.innerHTML = "<span class='text-xs text-(--chat-message-failed-color)'>Failed to send</span>"
    }
  }

  #notifyNewMessage(threadElement, { forceScroll = false } = {}) {
    const scrollContainer = threadElement.closest("[data-controller*='flat-pack--chat-scroll']")
    if (!scrollContainer) {
      return
    }

    scrollContainer.dispatchEvent(new CustomEvent("flat-pack:chat:message-appended", { bubbles: true }))

    const controller = this.application.getControllerForElementAndIdentifier(scrollContainer, "flat-pack--chat-scroll")
    if (forceScroll && controller && typeof controller.scrollToBottom === "function") {
      controller.scrollToBottom()
      return
    }

    if (controller && typeof controller.newMessageAdded === "function") {
      controller.newMessageAdded()
    }
  }

  #dispatchLifecycleEvent(name, detail) {
    this.element.dispatchEvent(new CustomEvent(name, { bubbles: true, detail }))
  }

  #timeLabel() {
    return new Date().toLocaleTimeString([], { hour: "numeric", minute: "2-digit" })
  }

  #csrfToken() {
    return document.querySelector("meta[name='csrf-token']")?.content || ""
  }

  #escapeHtml(value) {
    return String(value)
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;")
      .replaceAll("'", "&#39;")
  }

  #tempId() {
    if (globalThis.crypto && typeof globalThis.crypto.randomUUID === "function") {
      return globalThis.crypto.randomUUID()
    }

    return `tmp-${Date.now()}-${Math.floor(Math.random() * 10_000)}`
  }
}