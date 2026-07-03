import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fileInput", "pickerCheckbox"]

  static values = {
    threadSelector: { type: String, default: "[data-flat-pack--chat-scroll-target='messages']" },
    endpoint: String,
    optimisticEndpoint: String,
    method: { type: String, default: "post" },
    compositionMode: { type: String, default: "separate" },
    pickerScope: String,
    pickerIds: Array
  }

  connect() {
    this.selectedFiles = []
  }

  async handlePickerConfirm(event) {
    const detail = event?.detail || {}
    const selection = Array.isArray(detail.selection) ? detail.selection : []
    if (selection.length === 0) {
      return
    }

    // Ignore picker events unrelated to this chat form.
    if (!this.#pickerEventMatches(detail)) {
      return
    }

    const attachments = selection
      .map((item) => this.#attachmentFromDataset(item || {}))
      .filter(Boolean)

    if (attachments.length === 0) {
      return
    }

    await this.#sendFromComposer("", attachments, { clearComposer: false })
  }

  async addPickerAttachment(event) {
    event.preventDefault()

    const attachment = this.#attachmentFromDataset(event.currentTarget?.dataset || {})
    if (!attachment) {
      return
    }

    await this.#sendFromComposer("", [attachment], { clearComposer: false })
  }

  async addSelectedPickerAttachments(event) {
    event.preventDefault()

    const pickerKind = String(event.currentTarget?.dataset.pickerKind || "").trim()
    const attachments = this.#selectedPickerAttachments(pickerKind)

    if (attachments.length === 0) {
      return
    }

    await this.#sendFromComposer("", attachments, { clearComposer: false })
    this.clearPickerSelection(event)
  }

  clearPickerSelection(event) {
    const pickerKind = String(event?.currentTarget?.dataset?.pickerKind || "").trim()

    if (!this.hasPickerCheckboxTarget) {
      return
    }

    this.pickerCheckboxTargets.forEach((checkbox) => {
      if (!(checkbox instanceof HTMLInputElement)) {
        return
      }

      if (pickerKind && checkbox.dataset.attachmentKind !== pickerKind) {
        return
      }

      checkbox.checked = false
    })
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

    await this.#sendFromComposer(body, attachments)
  }

  async #sendFromComposer(body, attachments, { clearComposer = true } = {}) {
    const textarea = this.#textarea()
    if (!textarea) {
      return
    }

    const threadElement = this.#threadElement()
    if (!threadElement) {
      return
    }

    const optimisticElement = await this.#buildOptimisticMessageElement(body, attachments)
    threadElement.append(optimisticElement)

    if (clearComposer) {
      textarea.value = ""
      textarea.dispatchEvent(new Event("input", { bubbles: true }))
      this.#clearSelectedFiles()
    }

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

  async #buildOptimisticMessageElement(body, attachments) {
    const payload = {
      body,
      attachments,
      timestamp: this.#timeLabel(),
      state: "sending",
      direction: "outgoing"
    }

    const customElement = this.#optimisticElementFromEvent(payload)
    if (customElement) {
      return customElement
    }

    if (this.hasOptimisticEndpointValue) {
      const endpointElement = await this.#optimisticElementFromEndpoint(payload)
      if (endpointElement) {
        return endpointElement
      }
    }

    return this.#buildDefaultOptimisticMessageElement(payload)
  }

  #optimisticElementFromEvent(payload) {
    let providedElement = null

    const renderEvent = new CustomEvent("flat-pack:chat:render-optimistic", {
      bubbles: true,
      cancelable: true,
      detail: {
        payload,
        form: this.element,
        respondWith: (elementLike) => {
          providedElement = this.#coerceOptimisticElement(elementLike)
        }
      }
    })

    this.element.dispatchEvent(renderEvent)
    return providedElement
  }

  #coerceOptimisticElement(elementLike) {
    if (elementLike instanceof Element) {
      return elementLike
    }

    if (typeof elementLike === "string") {
      const template = document.createElement("template")
      template.innerHTML = elementLike.trim()

      if (template.content.childElementCount === 1) {
        return template.content.firstElementChild
      }

      if (template.content.childElementCount > 1) {
        const wrapper = document.createElement("div")
        wrapper.dataset.flatPackChatSenderOptimisticWrapper = ""
        wrapper.append(...Array.from(template.content.children))
        return wrapper
      }

      return null
    }

    return null
  }

  async #optimisticElementFromEndpoint(payload) {
    try {
      const response = await fetch(this.optimisticEndpointValue, {
        method: this.methodValue.toUpperCase(),
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
          "X-CSRF-Token": this.#csrfToken()
        },
        body: JSON.stringify({ message: payload })
      })

      if (!response.ok) {
        return null
      }

      const parsed = await response.json().catch(() => ({}))
      return this.#coerceOptimisticElement(parsed?.html)
    } catch (_error) {
      return null
    }
  }

  #buildDefaultOptimisticMessageElement(payload) {
    const record = document.createElement("div")
    record.className = "transition-[margin] duration-base"
    record.dataset.flatPackChatSenderTempId = `${Date.now()}-${Math.floor(Math.random() * 10_000)}`
    record.dataset.flatPackChatRecord = "true"
    record.dataset.flatPackChatRecordSender = "You"
    record.dataset.flatPackChatRecordDirection = "outgoing"

    const group = document.createElement("div")
    group.className = "flex items-start gap-0 flex-row-reverse"
    group.dataset.flatPackChatGroup = "true"
    group.dataset.flatPackChatGroupDirection = "outgoing"

    const column = document.createElement("div")
    column.className = "flex-1 min-w-0 space-y-1"

    const stack = document.createElement("div")
    stack.className = "space-y-1"

    const messageState = document.createElement("div")
    messageState.className = "flex justify-end"
    messageState.dataset.chatMessageState = payload.state

    const surface = document.createElement("div")
    surface.className = "flex flex-col items-end"

    const fileAttachments = []
    const mediaAttachments = []

    ;(payload.attachments || []).forEach((attachment) => {
      const node = this.#buildAttachmentNode(attachment)
      if (!node) {
        return
      }

      if (attachment.kind === "image" && attachment.thumbnailUrl) {
        mediaAttachments.push(node)
      } else {
        fileAttachments.push(node)
      }
    })

    if (payload.body || fileAttachments.length > 0) {
      const bubble = document.createElement("div")
      bubble.dataset.flatPackChatSenderBubble = ""
      bubble.className = "relative px-4 py-2 rounded-2xl max-w-[75%] sm:max-w-[500px] shadow-sm bg-[var(--chat-message-outgoing-background-color)] text-[var(--chat-message-outgoing-text-color)] opacity-60"

      if (payload.body) {
        const bodyNode = document.createElement("div")
        bodyNode.className = "break-words whitespace-pre-line"
        bodyNode.textContent = payload.body
        bubble.append(bodyNode)
      }

      const attachmentsContainer = this.#wrapAttachmentNodes(fileAttachments, "mt-2 space-y-2")
      if (attachmentsContainer) {
        bubble.append(attachmentsContainer)
      }

      surface.append(bubble)
    }

    const mediaContainer = this.#wrapAttachmentNodes(mediaAttachments, "mt-2 space-y-2 max-w-[75%] sm:max-w-[500px]")
    if (mediaContainer) {
      surface.append(mediaContainer)
    }

    const metaWrapper = document.createElement("div")
    metaWrapper.className = "mt-1 w-full flex justify-end [--chat-message-meta-color:var(--chat-message-outgoing-meta-color)] [--chat-read-receipt-color:var(--chat-message-outgoing-read-receipt-color)]"

    const meta = document.createElement("div")
    meta.dataset.flatPackChatSenderMeta = ""
    meta.className = "flex items-center gap-1.5 text-xs"
    this.#renderMetaContent(meta, payload.timestamp, payload.state)
    metaWrapper.append(meta)
    surface.append(metaWrapper)

    messageState.append(surface)
    stack.append(messageState)
    column.append(stack)
    group.append(column)
    record.append(group)

    return record
  }

  #payloadFor(body, attachments) {
    return {
      body,
      compositionMode: this.compositionModeValue,
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

  #selectedPickerAttachments(pickerKind) {
    if (!this.hasPickerCheckboxTarget) {
      return []
    }

    return this.pickerCheckboxTargets
      .filter((checkbox) => checkbox.checked)
      .filter((checkbox) => !pickerKind || checkbox.dataset.attachmentKind === pickerKind)
      .map((checkbox) => this.#attachmentFromDataset(checkbox.dataset))
      .filter(Boolean)
  }

  #attachmentFromDataset(dataset) {
    const name = String(dataset.attachmentName || dataset.name || "").trim()
    if (!name) {
      return null
    }

    const kind = (dataset.attachmentKind || dataset.kind) === "image" ? "image" : "file"
    const byteSizeRaw = dataset.attachmentByteSize || dataset.byteSize
    const parsedByteSize = Number.parseInt(byteSizeRaw, 10)

    return {
      kind,
      name,
      contentType: dataset.attachmentContentType || dataset.contentType || null,
      byteSize: Number.isFinite(parsedByteSize) ? parsedByteSize : null,
      thumbnailUrl: dataset.attachmentThumbnailUrl || dataset.thumbnailUrl || null
    }
  }

  #clearSelectedFiles() {
    this.selectedFiles = []

    if (this.hasFileInputTarget) {
      this.fileInputTarget.value = ""
    }
  }

  #wrapAttachmentNodes(nodes, className) {
    if (!nodes || nodes.length === 0) {
      return null
    }

    const container = document.createElement("div")
    container.className = className
    container.append(...nodes)
    return container
  }

  #buildAttachmentNode(attachment) {
    const kind = attachment.kind === "image" ? "image" : "file"
    const meta = this.#attachmentMeta(attachment)

    if (kind === "image" && attachment.thumbnailUrl) {
      return this.#buildImageAttachmentNode(attachment)
    }

    const wrapper = document.createElement("div")
    wrapper.className = "inline-flex w-fit max-w-full items-center gap-3 border border-[var(--chat-attachment-border-color)] rounded-lg bg-[var(--chat-attachment-background-color)] p-3"

    const icon = document.createElement("div")
    icon.className = "flex-shrink-0"
    icon.append(this.#buildFileIcon())

    const body = document.createElement("div")
    body.className = "min-w-0"

    const name = document.createElement("div")
    name.className = "text-sm font-medium text-[var(--chat-attachment-text-color)] truncate max-w-[32ch]"
    name.textContent = attachment.name || "Attachment"

    body.append(name)

    if (meta) {
      const metaNode = document.createElement("div")
      metaNode.className = "text-xs text-[var(--chat-attachment-meta-color)] truncate max-w-[32ch]"
      metaNode.textContent = meta
      body.append(metaNode)
    }

    wrapper.append(icon, body)
    return wrapper
  }

  #buildImageAttachmentNode(attachment) {
    const frame = document.createElement("div")
    frame.className = "rounded-lg overflow-hidden max-w-sm w-full border border-[var(--chat-attachment-border-color)]"

    const image = document.createElement("img")
    image.src = attachment.thumbnailUrl
    image.alt = attachment.name || "Attachment"
    image.loading = "lazy"
    image.className = "w-full h-full object-cover"
    frame.append(image)

    if (!attachment.thumbnailUrl) {
      return frame
    }

    const link = document.createElement("a")
    link.href = attachment.thumbnailUrl
    link.target = "_blank"
    link.rel = "noopener noreferrer"
    link.append(frame)
    return link
  }

  #buildFileIcon() {
    const svg = document.createElementNS("http://www.w3.org/2000/svg", "svg")
    svg.setAttribute("xmlns", "http://www.w3.org/2000/svg")
    svg.setAttribute("viewBox", "0 0 20 20")
    svg.setAttribute("fill", "currentColor")
    svg.setAttribute("class", "h-8 w-8 text-[var(--chat-attachment-icon-color)]")

    const path = document.createElementNS("http://www.w3.org/2000/svg", "path")
    path.setAttribute("fill-rule", "evenodd")
    path.setAttribute("clip-rule", "evenodd")
    path.setAttribute("d", "M4 4a2 2 0 012-2h4.586A2 2 0 0112 2.586L15.414 6A2 2 0 0116 7.414V16a2 2 0 01-2 2H6a2 2 0 01-2-2V4z")
    svg.append(path)

    return svg
  }

  #renderMetaContent(metaElement, timestamp, state) {
    metaElement.replaceChildren()

    if (timestamp) {
      const timestampNode = document.createElement("span")
      timestampNode.className = "text-xs text-[var(--chat-message-meta-color)]"
      timestampNode.textContent = timestamp
      metaElement.append(timestampNode)
    }

    const indicator = this.#buildMetaStateIndicator(state)
    if (indicator) {
      metaElement.append(indicator)
    }
  }

  #buildMetaStateIndicator(state) {
    switch (state) {
      case "sending":
        return this.#buildTextMetaNode("Sending...")
      case "failed":
        return this.#buildFailedMetaNode()
      case "read":
        return this.#buildReadMetaNode()
      case "sent":
        return this.#buildSentMetaNode()
      default:
        return null
    }
  }

  #buildTextMetaNode(text) {
    const node = document.createElement("span")
    node.className = "text-xs text-[var(--chat-message-meta-color)]"
    node.textContent = text
    return node
  }

  #buildSentMetaNode() {
    const node = document.createElement("span")
    node.className = "text-xs text-[var(--chat-message-meta-color)]"
    node.append(this.#buildMetaIcon("M7.78 13.78a.75.75 0 01-1.06 0L3.22 10.28a.75.75 0 111.06-1.06l2.97 2.97 8.47-8.47a.75.75 0 111.06 1.06z", "h-3 w-3 inline"))
    return node
  }

  #buildReadMetaNode() {
    const node = document.createElement("span")
    node.className = "text-xs text-[var(--chat-read-receipt-color)]"
    node.append(this.#buildMetaIcon("M0 11l2-2 5 5L18 3l2 2L7 18z", "h-3 w-3 inline"))
    return node
  }

  #buildFailedMetaNode() {
    const node = document.createElement("span")
    node.className = "text-xs text-[var(--chat-message-failed-color)] flex items-center gap-1"
    node.append(this.#buildMetaIcon("M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z", "h-3 w-3", true))
    node.append(document.createTextNode("Failed"))
    return node
  }

  #buildMetaIcon(pathData, className, evenOdd = false) {
    const svg = document.createElementNS("http://www.w3.org/2000/svg", "svg")
    svg.setAttribute("xmlns", "http://www.w3.org/2000/svg")
    svg.setAttribute("viewBox", "0 0 20 20")
    svg.setAttribute("fill", "currentColor")
    svg.setAttribute("class", className)

    const path = document.createElementNS("http://www.w3.org/2000/svg", "path")
    if (evenOdd) {
      path.setAttribute("fill-rule", "evenodd")
      path.setAttribute("clip-rule", "evenodd")
    }
    path.setAttribute("d", pathData)
    svg.append(path)

    return svg
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

  #pickerEventMatches(detail) {
    const pickerId = String(detail?.pickerId || "").trim()

    if (this.hasPickerIdsValue && Array.isArray(this.pickerIdsValue) && this.pickerIdsValue.length > 0) {
      if (!pickerId) {
        return false
      }

      return this.pickerIdsValue.includes(pickerId)
    }

    const context = detail?.context || {}
    const contextScope = String(context.scope || context.target || "").trim()
    const expectedScope = String(this.pickerScopeValue || "").trim()

    if (expectedScope.length > 0) {
      return contextScope === expectedScope
    }

    // If this sender is unscoped, ignore explicitly scoped picker events.
    if (contextScope.length > 0) {
      return false
    }

    return true
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
      this.#renderMetaContent(metaElement, response?.timestamp || this.#timeLabel(), response?.state || "sent")
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
      this.#renderMetaContent(metaElement, null, "failed")
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

  #tempId() {
    if (globalThis.crypto && typeof globalThis.crypto.randomUUID === "function") {
      return globalThis.crypto.randomUUID()
    }

    return `tmp-${Date.now()}-${Math.floor(Math.random() * 10_000)}`
  }
}