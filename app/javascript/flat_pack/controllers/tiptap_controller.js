import { Controller } from "@hotwired/stimulus"
import * as TiptapCore from "@tiptap/core"

import { runCommand, updateCommandButtons } from "../tiptap/commands"
import { editorCharacterCount, editorIsEmpty, parseInitialContent, serializeEditorContent } from "../tiptap/content"
import { buildExtensions } from "../tiptap/extension_registry"

const { Editor } = TiptapCore
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
    await runCommand(
      this.editor,
      button.dataset.flatPackTiptapCommand,
      button.dataset.flatPackTiptapValue,
      {
        promptForUrl: this.promptForUrl.bind(this),
        promptForColor: this.promptForColor.bind(this),
        pickAndInsertImage: this.pickAndInsertImage.bind(this)
      }
    )

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

    this.editor = new Editor({
      element: this.editorTarget,
      extensions: buildExtensions(this.config, this),
      content: parseInitialContent(this.inputTarget.value, this.config.format),
      editable: !this.config.readonly && !this.config.disabled,
      autofocus: this.config.autofocus ? "end" : false,
      editorProps: {
        attributes: {
          class: "prose prose-sm max-w-none min-h-[8rem] focus:outline-none",
          "aria-label": this.editorTarget.getAttribute("aria-label") || this.editorTarget.getAttribute("aria-labelledby") || "Rich text editor"
        }
      },
      onCreate: () => {
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

  destroyEditor() {
    if (!this.editor) return

    this.editor.destroy()
    this.editor = null
  }

  syncInput() {
    if (!this.editor || !this.hasInputTarget) return

    this.inputTarget.value = serializeEditorContent(this.editor, this.config.format)
    this.inputTarget.dispatchEvent(new Event("input", { bubbles: true }))
    this.inputTarget.dispatchEvent(new Event("change", { bubbles: true }))
    this.updateCharacterCount()
  }

  refreshUi() {
    if (this.hasToolbarTarget) {
      updateCommandButtons(this.toolbarTarget, this.editor, { disabled: !this.editor?.isEditable })
    }

    if (this.hasBubbleMenuTarget) {
      updateCommandButtons(this.bubbleMenuTarget, this.editor, { disabled: !this.editor?.isEditable })
    }

    if (this.hasFloatingMenuTarget) {
      updateCommandButtons(this.floatingMenuTarget, this.editor, { disabled: !this.editor?.isEditable })
    }

    this.updateCharacterCount()
  }

  updateCharacterCount() {
    if (!this.config.character_count || !this.hasCountTarget) return

    const count = editorCharacterCount(this.editor)
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

    if (trimmed.startsWith("/")) return trimmed

    try {
      const parsed = new URL(trimmed, window.location.origin)
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
}
