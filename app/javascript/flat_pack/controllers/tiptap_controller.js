import { Controller } from "@hotwired/stimulus"
import { Editor } from "@tiptap/core"
import { buildExtensions } from "../tiptap/extension_registry"
import { refreshToolbarState, runCommand, syncSubmissionField, updateCharacterCount } from "../tiptap/ui"

export default class extends Controller {
  static targets = ["editor", "input", "toolbar", "bubbleMenu", "floatingMenu", "count"]
  static values = {
    config: String,
    submitOnEnter: { type: Boolean, default: false }
  }

  async connect() {
    if (this.editor) return

    this.config = this.#parseConfig()
    const extensions = await buildExtensions(this.config, {
      bubbleMenu: this.hasBubbleMenuTarget ? this.bubbleMenuTarget : null,
      floatingMenu: this.hasFloatingMenuTarget ? this.floatingMenuTarget : null
    })

    this.handleKeydown = this.#handleKeydown.bind(this)

    this.editor = new Editor({
      element: this.editorTarget,
      extensions,
      content: this.#initialContent(),
      editable: !(this.config.disabled || this.config.readonly),
      autofocus: this.config.autofocus ? "end" : false,
      editorProps: {
        attributes: {
          class: "flat-pack-tiptap-prosemirror",
          role: "textbox",
          "aria-multiline": "true"
        }
      },
      onCreate: () => this.#syncState(),
      onUpdate: () => this.#syncState(),
      onSelectionUpdate: () => this.#syncState()
    })

    if (this.submitOnEnterValue && !this.config.readonly && !this.config.disabled) {
      this.editorTarget.addEventListener("keydown", this.handleKeydown)
    }

    this.#syncState()
  }

  disconnect() {
    if (this.submitOnEnterValue && this.handleKeydown) {
      this.editorTarget.removeEventListener("keydown", this.handleKeydown)
    }

    if (this.editor) {
      this.editor.destroy()
      this.editor = null
    }
  }

  runCommand(event) {
    event.preventDefault()
    if (!this.editor || this.config.readonly || this.config.disabled) return

    const command = event.currentTarget.dataset.flatPackTiptapCommand
    runCommand(this.editor, command)
    this.#syncState()
  }

  #parseConfig() {
    try {
      return JSON.parse(this.configValue || "{}")
    } catch (error) {
      console.warn("[flat-pack-tiptap] Invalid rich text config", error)
      return {}
    }
  }

  #initialContent() {
    if (!this.hasInputTarget || !this.inputTarget.value) return null

    if (this.config.format === "html") return this.inputTarget.value

    try {
      return JSON.parse(this.inputTarget.value)
    } catch (_error) {
      return null
    }
  }

  #syncState() {
    if (!this.editor) return

    syncSubmissionField(this.editor, this.hasInputTarget ? this.inputTarget : null, this.config.format)
    updateCharacterCount(
      this.editor,
      this.hasCountTarget ? this.countTarget : null,
      Number.isFinite(this.config.max_characters) ? this.config.max_characters : undefined
    )

    if (this.hasToolbarTarget) refreshToolbarState(this.toolbarTarget, this.editor, this.config.readonly || this.config.disabled)
    if (this.hasBubbleMenuTarget) refreshToolbarState(this.bubbleMenuTarget, this.editor, this.config.readonly || this.config.disabled)
    if (this.hasFloatingMenuTarget) refreshToolbarState(this.floatingMenuTarget, this.editor, this.config.readonly || this.config.disabled)
  }

  #handleKeydown(event) {
    if (event.key !== "Enter" || event.shiftKey) return

    const form = this.element.closest("form")
    if (!form) return

    event.preventDefault()
    form.requestSubmit()
  }
}
