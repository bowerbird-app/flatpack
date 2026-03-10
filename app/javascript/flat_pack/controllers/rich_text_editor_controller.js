import { Controller } from "@hotwired/stimulus"

const DEFAULT_BALLOON_TOOLBAR = ["Bold", "Italic", "Link", "Unlink", "BulletedList", "NumberedList", "Blockquote"]
const DEFAULT_EXTRA_PLUGINS = ["balloontoolbar"]
const DEFAULT_REMOVE_PLUGINS = ["elementspath", "resize"]

export default class extends Controller {
  static targets = ["textarea"]
  static values = {
    config: String,
    mode: { type: String, default: "inline" }
  }

  connect() {
    this.form = this.textareaTarget.closest("form")
    this.boundHandleFormSubmit = this.handleFormSubmit.bind(this)

    if (this.form) {
      this.form.addEventListener("submit", this.boundHandleFormSubmit)
    }

    if (this.textareaTarget.disabled) {
      return
    }

    if (!window.CKEDITOR || typeof window.CKEDITOR.inline !== "function") {
      console.warn("[FlatPack] CKEDITOR global is missing. Include the self-hosted CKEditor script before importmap boot to enable rich text fields.")
      return
    }

    this.createEditorHost()
    this.initializeEditor()
  }

  disconnect() {
    if (this.form) {
      this.form.removeEventListener("submit", this.boundHandleFormSubmit)
    }

    this.stopObservingTextarea()
    this.destroyEditor()
    this.removeEditorHost()
  }

  handleFormSubmit() {
    this.flushValue({ dispatchInput: false, dispatchChange: false })
  }

  createEditorHost() {
    this.removeEditorHost()

    this.editorHost = document.createElement("div")
    this.editorHost.id = `${this.textareaTarget.id}_rich_text_editor`
    this.editorHost.className = `${this.textareaTarget.className} fp-rich-text-editor`
    this.editorHost.contentEditable = "true"
    this.editorHost.dataset.richTextEditorHost = "true"
    this.editorHost.setAttribute("role", "textbox")
    this.editorHost.setAttribute("aria-multiline", "true")
    this.editorHost.innerHTML = this.textareaTarget.value

    this.applyHostPresentation(this.parsedConfig)
    this.applyHostAccessibility()

    this.textareaTarget.insertAdjacentElement("afterend", this.editorHost)
  }

  initializeEditor() {
    window.CKEDITOR.disableAutoInline = true

    this.editor = window.CKEDITOR.inline(this.editorHost, this.ckeditorConfig)
    this.editor.on("instanceReady", () => {
      this.hideTextarea()
      this.applyBalloonToolbarContexts()
      this.flushValue({ dispatchInput: false, dispatchChange: false })
      this.syncHostValidationState()
      this.startObservingTextarea()
    })
    this.editor.on("change", () => this.flushValue({ dispatchInput: true, dispatchChange: true }))
    this.editor.on("blur", () => this.flushValue({ dispatchInput: true, dispatchChange: true, dispatchBlur: true }))
  }

  destroyEditor() {
    if (!this.editor) {
      return
    }

    this.flushValue({ dispatchInput: false, dispatchChange: false })
    this.editor.destroy()
    this.editor = null
  }

  removeEditorHost() {
    if (!this.editorHost) {
      this.textareaTarget.style.removeProperty("display")
      return
    }

    this.editorHost.remove()
    this.editorHost = null
    this.textareaTarget.style.removeProperty("display")
  }

  hideTextarea() {
    this.textareaTarget.style.display = "none"
  }

  flushValue({ dispatchInput = true, dispatchChange = true, dispatchBlur = false } = {}) {
    if (!this.editor) {
      return
    }

    this.textareaTarget.value = this.editor.getData()

    if (dispatchInput) {
      this.textareaTarget.dispatchEvent(new Event("input", { bubbles: true }))
    }

    if (dispatchChange) {
      this.textareaTarget.dispatchEvent(new Event("change", { bubbles: true }))
    }

    if (dispatchBlur) {
      this.textareaTarget.dispatchEvent(new Event("blur"))
    }

    this.syncHostValidationState()
  }

  startObservingTextarea() {
    this.stopObservingTextarea()

    this.textareaObserver = new MutationObserver(() => this.syncHostValidationState())
    this.textareaObserver.observe(this.textareaTarget, {
      attributes: true,
      attributeFilter: ["aria-invalid", "aria-describedby", "class", "style", "disabled"]
    })
  }

  stopObservingTextarea() {
    this.textareaObserver?.disconnect()
    this.textareaObserver = null
  }

  syncHostValidationState() {
    if (!this.editorHost) {
      return
    }

    const invalid = this.textareaTarget.getAttribute("aria-invalid") === "true" || this.textareaTarget.classList.contains("border-warning")
    this.editorHost.classList.toggle("border-warning", invalid)

    if (invalid) {
      this.editorHost.setAttribute("aria-invalid", "true")
    } else {
      this.editorHost.removeAttribute("aria-invalid")
    }

    const describedBy = this.textareaTarget.getAttribute("aria-describedby")
    if (describedBy) {
      this.editorHost.setAttribute("aria-describedby", describedBy)
    } else {
      this.editorHost.removeAttribute("aria-describedby")
    }

    this.editorHost.style.borderColor = this.textareaTarget.style.borderColor
  }

  applyHostPresentation(config) {
    if (config.placeholder) {
      this.editorHost.dataset.placeholder = config.placeholder
    }

    if (config.height) {
      this.editorHost.style.minHeight = config.height
    }
  }

  applyHostAccessibility() {
    if (this.textareaTarget.required) {
      this.editorHost.setAttribute("aria-required", "true")
    }

    const label = this.findLabel()
    if (label) {
      this.editorHost.setAttribute("aria-label", label.textContent.trim())
    } else if (this.textareaTarget.placeholder) {
      this.editorHost.setAttribute("aria-label", this.textareaTarget.placeholder)
    }
  }

  findLabel() {
    if (!this.textareaTarget.id) {
      return null
    }

    if (typeof CSS !== "undefined" && typeof CSS.escape === "function") {
      return document.querySelector(`label[for="${CSS.escape(this.textareaTarget.id)}"]`)
    }

    return document.querySelector(`label[for="${this.textareaTarget.id.replace(/"/g, '\\"')}"]`)
  }

  applyBalloonToolbarContexts() {
    const balloonButtons = this.mergedConfig.balloonToolbar
    if (!this.editor?.balloonToolbars || balloonButtons.length === 0) {
      return
    }

    this.editor.balloonToolbars.create({
      buttons: balloonButtons.join(","),
      refresh: (editor) => {
        const selection = editor.getSelection()
        if (!selection) {
          return false
        }

        const ranges = selection.getRanges()
        return ranges.length > 0 && !ranges[0].collapsed
      }
    })

    const linkButtons = balloonButtons.filter((button) => ["Link", "Unlink"].includes(button))
    if (linkButtons.length > 0) {
      this.editor.balloonToolbars.create({
        buttons: linkButtons.join(","),
        cssSelector: "a[href]",
        priority: window.CKEDITOR.plugins.balloontoolbar.PRIORITY.HIGH
      })
    }
  }

  get parsedConfig() {
    if (this.cachedParsedConfig) {
      return this.cachedParsedConfig
    }

    if (!this.hasConfigValue) {
      this.cachedParsedConfig = {}
      return this.cachedParsedConfig
    }

    try {
      this.cachedParsedConfig = JSON.parse(this.configValue)
    } catch (error) {
      console.warn("[FlatPack] Failed to parse rich text editor config JSON.", error)
      this.cachedParsedConfig = {}
    }

    return this.cachedParsedConfig
  }

  get mergedConfig() {
    if (this.cachedMergedConfig) {
      return this.cachedMergedConfig
    }

    const parsedConfig = this.parsedConfig
    this.cachedMergedConfig = {
      ...parsedConfig,
      balloonToolbar: parsedConfig.balloonToolbar || DEFAULT_BALLOON_TOOLBAR,
      extraPlugins: this.mergeStringLists(DEFAULT_EXTRA_PLUGINS, parsedConfig.extraPlugins),
      removePlugins: this.mergeStringLists(DEFAULT_REMOVE_PLUGINS, parsedConfig.removePlugins),
      toolbarGroups: parsedConfig.toolbarGroups || [
        { name: "basicstyles", groups: ["basicstyles", "cleanup"] },
        { name: "paragraph", groups: ["list", "blocks"] },
        { name: "links" }
      ]
    }

    return this.cachedMergedConfig
  }

  get ckeditorConfig() {
    const { balloonToolbar, height, ...ckeditorConfig } = this.mergedConfig

    return {
      ...ckeditorConfig,
      extraPlugins: this.listValueForCkeditor(ckeditorConfig.extraPlugins),
      removePlugins: this.listValueForCkeditor(ckeditorConfig.removePlugins)
    }
  }

  mergeStringLists(defaultValues, customValues) {
    return [...new Set([...(defaultValues || []), ...(customValues || [])])]
  }

  listValueForCkeditor(value) {
    return Array.isArray(value) ? value.join(",") : value
  }
}
