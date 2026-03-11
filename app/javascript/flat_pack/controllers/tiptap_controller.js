import { Controller } from "@hotwired/stimulus"

import { runCommand, updateCommandButtons } from "flat_pack/tiptap/commands"
import { editorCharacterCount, editorIsEmpty, parseInitialContent, serializeEditorContent } from "flat_pack/tiptap/content"
import { buildExtensions, loadTipTapRuntime } from "flat_pack/tiptap/extension_registry"
const SAFE_URL_PROTOCOLS = new Set(["http:", "https:", "mailto:", "tel:"])

export default class extends Controller {
  static targets = ["editor", "input", "toolbar", "bubbleMenu", "floatingMenu", "count", "error"]
  static values = {
    config: String,
    minCharacters: Number,
    maxCharacters: Number
  }

  connect() {
    this.form = this.element.closest("form")
    this.onFormSubmit = this.handleFormSubmit.bind(this)
    this.form?.addEventListener("submit", this.onFormSubmit)
    this.initializeEditor()
  }

  disconnect() {
    this.form?.removeEventListener("submit", this.onFormSubmit)
    this.destroyEditor()
  }

  focus(event) {
    event?.preventDefault()
    this.editor?.commands.focus()
  }

  async runToolbarAction(event) {
    event.preventDefault()

    const button = event.currentTarget
    const command = button.dataset.flatPackTiptapCommand
    const value = button.dataset.flatPackTiptapValue

    if (this.fallbackMode) {
      await this.runFallbackCommand(command, value)
    } else {
      await runCommand(
        this.editor,
        command,
        value,
        {
          promptForUrl: this.promptForUrl.bind(this),
          promptForColor: this.promptForColor.bind(this),
          pickAndInsertImage: this.pickAndInsertImage.bind(this)
        }
      )
    }

    this.syncInput()
    this.refreshUi()
  }

  resolveRuntimeReference(key) {
    if (!key) return null

    return window.FlatPack?.tiptapRuntime?.[key] || null
  }

  async handleUploadFiles(files, { pos } = {}) {
    if (!files?.length || !this.config.uploads?.endpoint) return false

    const responses = await Promise.all(Array.from(files).map((file) => this.uploadFile(file)))
    const urls = responses.filter(Boolean)
    if (!urls.length) return false

    urls.forEach(({ url, file }) => {
      if (file.type.startsWith("image/")) {
        this.editor.chain().focus().setImage({ src: url }).run()
      } else if (pos && typeof this.editor.chain().focus().insertContentAt === "function") {
        this.editor.chain().focus().insertContentAt(pos, [{ type: "text", text: file.name }]).run()
      } else {
        this.editor.chain().focus().insertContent(file.name).run()
      }
    })

    this.syncInput()
    this.refreshUi()
    return true
  }

  async pickAndInsertImage() {
    if (!this.config.uploads?.endpoint) return false

    const input = document.createElement("input")
    input.type = "file"
    input.accept = this.acceptedUploadTypes()

    const file = await new Promise((resolve) => {
      input.addEventListener("change", () => resolve(input.files?.[0] || null), { once: true })
      input.click()
    })

    if (!file) return false

    const uploaded = await this.uploadFile(file)
    if (!uploaded?.url) return false

    this.editor.chain().focus().setImage({ src: uploaded.url }).run()
    return true
  }

  handleFormSubmit(event) {
    if (this.config.disabled) return

    this.syncInput()

    if (this.config.required && editorIsEmpty(this.editor)) {
      event.preventDefault()
      this.showError("Please fill out this field.")
      this.focus()
      return
    }

    this.clearError()
  }

  initializeEditor() {
    this.destroyEditor()

    loadTipTapRuntime()
      .then((runtime) => {
        this.runtime = runtime
        this.initializeTipTapEditor(runtime)
      })
      .catch((error) => {
        console.warn("[FlatPack::TipTap] Falling back to the built-in contenteditable runtime", error)
        this.initializeFallbackEditor()
      })
  }

  destroyEditor() {
    if (this.fallbackMode) {
      this.editorTarget.removeEventListener("input", this.onFallbackInput)
      this.editorTarget.removeEventListener("mouseup", this.onFallbackSelectionChange)
      this.editorTarget.removeEventListener("keyup", this.onFallbackSelectionChange)
      this.fallbackMode = false
      this.editor = null
      return
    }

    if (!this.editor) return

    this.editor.destroy()
    this.editor = null
  }

  syncInput() {
    if (!this.editor || !this.hasInputTarget) return

    this.inputTarget.value = this.fallbackMode
      ? this.serializeFallbackContent()
      : serializeEditorContent(this.editor, this.config.format)
    this.inputTarget.dispatchEvent(new Event("input", { bubbles: true }))
    this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))
    this.updateCharacterCount()
  }

  refreshUi() {
    if (this.hasToolbarTarget) {
      updateCommandButtons(this.toolbarTarget, this.editor, { disabled: !this.editor?.isEditable })
    }

    if (this.hasBubbleMenuTarget) {
      updateCommandButtons(this.bubbleMenuTarget, this.editor, { disabled: this.fallbackMode ? this.config.disabled || this.config.readonly : !this.editor?.isEditable })
    }

    if (this.hasFloatingMenuTarget) {
      updateCommandButtons(this.floatingMenuTarget, this.editor, { disabled: !this.editor?.isEditable })
    }

    if (this.fallbackMode) {
      this.updateFallbackBubbleMenu()
    }

    this.updateCharacterCount()
  }

  updateCharacterCount() {
    if (!this.config.character_count || !this.hasCountTarget) return

    const count = this.fallbackMode
      ? this.editorTarget.innerText.length
      : editorCharacterCount(this.editor)
    const hasMax = this.hasMaxCharactersValue
    const belowMin = this.hasMinCharactersValue && count < this.minCharactersValue
    const aboveMax = hasMax && count > this.maxCharactersValue

    this.countTarget.textContent = hasMax
      ? `${count}/${this.maxCharactersValue} characters`
      : `${count} characters`

    this.countTarget.classList.toggle("text-[var(--color-warning-border)]", belowMin || aboveMax)
    this.countTarget.classList.toggle("text-[var(--surface-muted-content-color)]", !(belowMin || aboveMax))
  }

  showError(message) {
    const errorNode = this.errorNode()
    if (!errorNode) return

    errorNode.textContent = message
    errorNode.classList.remove("hidden")
    this.editorTarget.classList.add("border-warning")
    this.editorTarget.setAttribute("aria-invalid", "true")
  }

  clearError() {
    const errorNode = this.errorNode(false)
    if (errorNode) {
      errorNode.classList.add("hidden")
      errorNode.textContent = ""
    }

    this.editorTarget.classList.remove("border-warning")
    if (!this.config.error_id) {
      this.editorTarget.removeAttribute("aria-invalid")
    }
  }

  errorNode(createWhenMissing = true) {
    if (this.hasErrorTarget) return this.errorTarget
    if (!createWhenMissing || !this.config.error_id) return null

    const node = document.createElement("p")
    node.id = this.config.error_id
    node.className = "mt-1 text-sm text-warning"
    node.dataset.flatPackTiptapTarget = "error"
    this.element.appendChild(node)
    return node
  }

  async uploadFile(file) {
    if (!file) return null

    if (Array.isArray(this.config.uploads?.accepted_types) && this.config.uploads.accepted_types.length > 0) {
      const matchesAcceptedType = this.config.uploads.accepted_types.some((type) => file.type === type || file.name.endsWith(type.replace("*", "")))
      if (!matchesAcceptedType) return null
    }

    if (this.config.uploads?.max_size && file.size > Number(this.config.uploads.max_size)) {
      return null
    }

    const formData = new FormData()
    formData.append(this.config.uploads.field_name || "file", file)

    const response = await fetch(this.config.uploads.endpoint, {
      method: (this.config.uploads.method || "POST").toUpperCase(),
      body: formData,
      credentials: "same-origin",
      headers: {
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']")?.content || ""
      }
    })

    if (!response.ok) return null

    const payload = await response.json().catch(async () => ({ url: await response.text() }))
    const url = this.normalizeUrl(payload.url || payload.location || payload.src)
    if (!url) return null

    return { url, file }
  }

  acceptedUploadTypes() {
    const accepted = this.config.uploads?.accepted_types
    return Array.isArray(accepted) && accepted.length > 0 ? accepted.join(",") : "image/*"
  }

  async promptForUrl(kind, currentValue = "") {
    const message = kind === "image" ? "Enter an image URL" : "Enter a link URL"
    const value = window.prompt(message, currentValue || "")
    if (value === null) return null

    return this.normalizeUrl(value)
  }

  async promptForColor(kind) {
    const label = kind === "background" ? "Enter a background color" : "Enter a text color"
    return window.prompt(`${label} as a hex value (for example #4f46e5)`, "#4f46e5")
  }

  normalizeUrl(value) {
    const trimmed = value?.trim()
    if (!trimmed) return ""

    // Allow same-origin relative paths for app-managed uploads/assets.
    if (trimmed.startsWith("/")) return trimmed

    try {
      const parsed = new URL(trimmed, window.location.origin)
      // Reject dangerous schemes such as javascript: and vbscript: while allowing
      // the same safe protocols already accepted by FlatPack link-like components.
      return SAFE_URL_PROTOCOLS.has(parsed.protocol) ? parsed.toString() : null
    } catch (_error) {
      return null
    }
  }

  get config() {
    if (!this._config) {
      this._config = JSON.parse(this.configValue)
    }

    return this._config
  }

  initializeTipTapEditor(runtime) {
    this.fallbackMode = false
    this.editor = new runtime.Editor({
      element: this.editorTarget,
      extensions: buildExtensions(runtime, this.config, this),
      content: parseInitialContent(this.inputTarget.value, this.config.format),
      editable: !this.config.readonly && !this.config.disabled,
      autofocus: this.config.autofocus ? "end" : false,
      editorProps: {
        attributes: {
          class: "ProseMirror prose prose-sm max-w-none min-h-[8rem] focus:outline-none",
          "aria-label": this.editorTarget.getAttribute("aria-label") || this.editorTarget.getAttribute("aria-labelledby") || "Rich text editor"
        }
      },
      onCreate: () => {
        this.editorTarget.classList.add("ProseMirror")
        this.syncInput()
        this.refreshUi()
      },
      onUpdate: () => {
        this.syncInput()
        this.refreshUi()
        this.clearError()
      },
      onSelectionUpdate: () => this.refreshUi()
    })
  }

  initializeFallbackEditor() {
    this.fallbackMode = true
    this.editor = {
      isEditable: !(this.config.readonly || this.config.disabled),
      getText: () => this.editorTarget.innerText,
      getHTML: () => this.editorTarget.innerHTML,
      getJSON: () => this.fallbackJsonDocument(),
      commands: {
        focus: () => this.editorTarget.focus()
      }
    }

    this.editorTarget.classList.add("ProseMirror")
    this.editorTarget.contentEditable = String(!(this.config.readonly || this.config.disabled))
    this.editorTarget.innerHTML = this.initialFallbackMarkup()

    this.onFallbackInput = () => {
      this.syncInput()
      this.refreshUi()
      this.clearError()
    }
    this.onFallbackSelectionChange = () => this.refreshUi()

    this.editorTarget.addEventListener("input", this.onFallbackInput)
    this.editorTarget.addEventListener("mouseup", this.onFallbackSelectionChange)
    this.editorTarget.addEventListener("keyup", this.onFallbackSelectionChange)

    this.syncInput()
    this.refreshUi()
  }

  async runFallbackCommand(command, value) {
    this.editorTarget.focus()

    switch (command) {
      case "bold":
        document.execCommand("bold")
        break
      case "italic":
        document.execCommand("italic")
        break
      case "underline":
        document.execCommand("underline")
        break
      case "strike":
        document.execCommand("strikeThrough")
        break
      case "blockquote":
        document.execCommand("formatBlock", false, "blockquote")
        break
      case "bulletList":
        document.execCommand("insertUnorderedList")
        break
      case "orderedList":
        document.execCommand("insertOrderedList")
        break
      case "heading":
        document.execCommand("formatBlock", false, `h${value || 2}`)
        break
      case "link": {
        const href = await this.promptForUrl("link")
        if (href) {
          document.execCommand("createLink", false, href)
        }
        break
      }
      case "image": {
        const uploaded = await this.pickAndInsertImage()
        if (!uploaded) {
          const src = await this.promptForUrl("image")
          if (src) {
            document.execCommand("insertImage", false, src)
          }
        }
        break
      }
      case "table":
        document.execCommand(
          "insertHTML",
          false,
          "<table><tbody><tr><th>Column</th><th>Value</th></tr><tr><td>Bubble Menu</td><td>Built in</td></tr></tbody></table>"
        )
        break
      case "undo":
        document.execCommand("undo")
        break
      case "redo":
        document.execCommand("redo")
        break
      case "textAlign":
        document.execCommand(`justify${value ? value.charAt(0).toUpperCase() + value.slice(1) : "Left"}`)
        break
      case "color": {
        const color = await this.promptForColor("text")
        if (color) document.execCommand("foreColor", false, color)
        break
      }
      case "backgroundColor": {
        const color = await this.promptForColor("background")
        if (color) document.execCommand("hiliteColor", false, color)
        break
      }
      default:
        break
    }
  }

  updateFallbackBubbleMenu() {
    if (!this.hasBubbleMenuTarget) return

    const selection = window.getSelection()
    const selectedText = selection?.toString()?.trim()
    const withinEditor = selection?.anchorNode && this.editorTarget.contains(selection.anchorNode)

    this.bubbleMenuTarget.classList.toggle("hidden", !(withinEditor && selectedText))
    this.bubbleMenuTarget.classList.toggle("flex", Boolean(withinEditor && selectedText))
  }

  initialFallbackMarkup() {
    if (this.config.format === "html") {
      return this.inputTarget.value || "<p></p>"
    }

    try {
      const content = JSON.parse(this.inputTarget.value)
      return this.jsonContentToHtml(content)
    } catch (_error) {
      return this.inputTarget.value || "<p></p>"
    }
  }

  jsonContentToHtml(node) {
    if (!node) return "<p></p>"

    if (Array.isArray(node)) {
      return node.map((child) => this.jsonContentToHtml(child)).join("")
    }

    const content = this.jsonContentToHtml(node.content)

    switch (node.type) {
      case "doc":
        return content || "<p></p>"
      case "paragraph":
        return `<p>${content}</p>`
      case "heading":
        return `<h${node.attrs?.level || 2}>${content}</h${node.attrs?.level || 2}>`
      case "text":
        return node.text || ""
      case "bulletList":
        return `<ul>${content}</ul>`
      case "orderedList":
        return `<ol>${content}</ol>`
      case "listItem":
        return `<li>${content}</li>`
      case "table":
        return `<table><tbody>${content}</tbody></table>`
      case "tableRow":
        return `<tr>${content}</tr>`
      case "tableHeader":
        return `<th>${content}</th>`
      case "tableCell":
        return `<td>${content}</td>`
      default:
        return content
    }
  }

  serializeFallbackContent() {
    return this.config.format === "html"
      ? this.editorTarget.innerHTML
      : JSON.stringify(this.fallbackJsonDocument())
  }

  fallbackJsonDocument() {
    const children = Array.from(this.editorTarget.childNodes)
      .map((node) => this.serializeFallbackNode(node))
      .filter(Boolean)

    return {
      type: "doc",
      content: children.length > 0 ? children : [{ type: "paragraph" }]
    }
  }

  serializeFallbackNode(node) {
    if (node.nodeType === Node.TEXT_NODE) {
      const text = node.textContent.trim()
      return text ? { type: "text", text } : null
    }

    if (node.nodeType !== Node.ELEMENT_NODE) return null

    const content = Array.from(node.childNodes).map((child) => this.serializeFallbackNode(child)).filter(Boolean)
    const tagName = node.tagName.toLowerCase()

    switch (tagName) {
      case "p":
        return { type: "paragraph", content }
      case "h1":
      case "h2":
      case "h3":
        return { type: "heading", attrs: { level: Number(tagName.replace("h", "")) }, content }
      case "ul":
        return { type: "bulletList", content }
      case "ol":
        return { type: "orderedList", content }
      case "li":
        return { type: "listItem", content }
      case "table":
        return { type: "table", content: Array.from(node.querySelectorAll(":scope > tbody > tr")).map((row) => this.serializeFallbackNode(row)).filter(Boolean) }
      case "tr":
        return { type: "tableRow", content }
      case "th":
        return { type: "tableHeader", content }
      case "td":
        return { type: "tableCell", content }
      default:
        return content.length === 1 ? content[0] : { type: "paragraph", content }
    }
  }
}
