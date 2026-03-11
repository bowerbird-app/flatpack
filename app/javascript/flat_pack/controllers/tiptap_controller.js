/**
 * FlatPack TipTap Rich Text Editor — Stimulus Controller
 *
 * Identifier: flat-pack--tiptap
 *
 * This controller manages the full lifecycle of a TipTap rich text editor
 * instance mounted inside a FlatPack::TextArea component rendered with
 * `rich_text: true`.
 *
 * Responsibilities:
 *   - Initialize the TipTap Editor with extensions from the registry
 *   - Populate the toolbar, bubble menu, and floating menu DOM regions
 *   - Synchronize editor content to the hidden submission field
 *   - Handle Turbo navigation (connect/disconnect lifecycle is clean)
 *   - Apply aria attributes to the ProseMirror contenteditable element
 *   - Surface disabled, readonly, required, and error states
 *
 * Data values passed from Ruby (see TextArea::Component#rich_text_wrapper_attributes):
 *   options        — JSON-encoded RichTextOptions hash
 *   editorId       — ID to assign to the ProseMirror element (for label association)
 *   placeholder    — Placeholder text (may also be set in options)
 *   disabled       — Boolean; prevents editing
 *   required       — Boolean; surfaced via aria-required
 *   hasError       — Boolean; triggers aria-invalid
 *   errorId        — ID of the error message element for aria-describedby
 *   value          — Initial content (JSON string or HTML string)
 */

import { Controller }            from "@hotwired/stimulus"
import { Editor }                from "@tiptap/core"
import { buildExtensions }       from "flat_pack/tiptap/extension_registry"
import { buildToolbar,
         updateToolbarState }    from "flat_pack/tiptap/toolbar"
import { buildBubbleMenu,
         refreshBubbleMenuState } from "flat_pack/tiptap/bubble_menu"

export default class extends Controller {
  static targets = [
    "editorContainer",  // ProseMirror mounts here
    "hiddenField",      // synchronized submission field
    "toolbar",          // toolbar button container
    "bubbleMenu",       // bubble menu container (positioned by TipTap)
    "floatingMenu",     // floating menu container (positioned by TipTap)
    "characterCount",   // character count display
  ]

  static values = {
    options:      { type: Object,  default: {} },
    editorId:     { type: String,  default: "" },
    placeholder:  { type: String,  default: "" },
    disabled:     { type: Boolean, default: false },
    required:     { type: Boolean, default: false },
    hasError:     { type: Boolean, default: false },
    errorId:      { type: String,  default: "" },
    value:        { type: String,  default: "" },
  }

  // ── Lifecycle ───────────────────────────────────────────────────────────────

  connect() {
    // Guard: prevent duplicate initialization on Turbo page-restore or
    // reconnect without a preceding disconnect (rare but possible).
    if (this._editor) return
    this.#initEditor()
  }

  disconnect() {
    this.#destroyEditor()
  }

  // ── Private ─────────────────────────────────────────────────────────────────

  async #initEditor() {
    const opts = this.optionsValue

    // Resolve effective placeholder: component-level prop takes precedence
    const placeholder = this.placeholderValue || opts.placeholder || "Start writing…"

    // Snapshot DOM element references NOW — before TipTap's BubbleMenu/FloatingMenu
    // extensions run their onCreate hooks, which use Tippy.js to teleport those
    // elements to <body>. After teleportation Stimulus no longer considers them
    // descendants of this.element, so has*Target returns false.
    const toolbarEl      = this.hasToolbarTarget          ? this.toolbarTarget          : null
    const bubbleMenuEl   = this.hasBubbleMenuTarget       ? this.bubbleMenuTarget       : null
    const floatingMenuEl = this.hasFloatingMenuTarget     ? this.floatingMenuTarget     : null
    const charCountEl    = this.hasCharacterCountTarget   ? this.characterCountTarget   : null
    const hiddenFieldEl  = this.hasHiddenFieldTarget      ? this.hiddenFieldTarget      : null
    const containerEl    = this.editorContainerTarget

    const extConfig = {
      opts,
      placeholder,
      bubbleMenuElement:   bubbleMenuEl,
      floatingMenuElement: floatingMenuEl,
    }

    let extensions
    try {
      extensions = await buildExtensions(extConfig)
    } catch (err) {
      console.error("[FlatPack TipTap] Failed to build extensions:", err)
      return
    }

    const editable = !this.disabledValue && !opts.readonly

    this._editor = new Editor({
      element:    containerEl,
      extensions,
      content:    this.#parseInitialContent(opts),
      editable,
      autofocus:  opts.autofocus || false,

      editorProps: {
        attributes: {
          id:               this.editorIdValue || undefined,
          role:             "textbox",
          "aria-multiline": "true",
          "aria-required":  this.requiredValue ? "true" : "false",
          "aria-invalid":   this.hasErrorValue ? "true" : "false",
          ...(this.hasErrorValue && this.errorIdValue
            ? { "aria-describedby": this.errorIdValue }
            : {}),
          ...(opts.readonly || this.disabledValue
            ? { "aria-readonly": "true" }
            : {}),
        },
      },

      onCreate: ({ editor }) => {
        this.#syncContentEl(editor, opts, hiddenFieldEl)
        this.#updateCharacterCountEl(editor, opts, charCountEl)
        this.#buildMenusEl(editor, opts, bubbleMenuEl, floatingMenuEl)
        updateToolbarState(toolbarEl, editor)
      },

      onUpdate: ({ editor }) => {
        this.#syncContentEl(editor, opts, hiddenFieldEl)
        this.#updateCharacterCountEl(editor, opts, charCountEl)
        updateToolbarState(toolbarEl, editor)
      },

      onSelectionUpdate: ({ editor }) => {
        updateToolbarState(toolbarEl, editor)
        refreshBubbleMenuState(bubbleMenuEl, editor)
      },

      onFocus: () => {
        this.element.classList.add("flat-pack-richtext--focused")
      },

      onBlur: () => {
        this.element.classList.remove("flat-pack-richtext--focused")
      },
    })

    // Build toolbar after editor is created
    if (toolbarEl && opts.toolbar !== "none") {
      buildToolbar(toolbarEl, this._editor, opts)
    }
  }

  #destroyEditor() {
    if (this._editor) {
      this._editor.destroy()
      this._editor = null
    }
    // Clear toolbar DOM so a subsequent connect() rebuilds it cleanly.
    // Use querySelectorAll instead of Stimulus targets because Tippy may have
    // teleported bubble/floating menu elements outside this.element.
    this.element.querySelectorAll('[data-flat-pack--tiptap-target="toolbar"]').forEach(el => { el.innerHTML = "" })
    this.element.querySelectorAll('[data-flat-pack--tiptap-target="bubbleMenu"]').forEach(el => { el.innerHTML = "" })
    this.element.querySelectorAll('[data-flat-pack--tiptap-target="floatingMenu"]').forEach(el => { el.innerHTML = "" })
    // Also clean up any teleported elements still in <body> from Tippy
    document.querySelectorAll('.tippy-box [data-flat-pack--tiptap-target]').forEach(el => { el.innerHTML = "" })
  }

  // ── Content management ───────────────────────────────────────────────────────

  #parseInitialContent(opts) {
    const raw    = this.valueValue
    const format = opts.format || "json"

    if (!raw || raw === "") return ""

    if (format === "json") {
      try {
        return JSON.parse(raw)
      } catch {
        // Not valid JSON — fall back to treating as plain text paragraph
        console.warn("[FlatPack TipTap] Initial value is not valid JSON; treating as plain text.")
        return `<p>${raw}</p>`
      }
    }

    // HTML format — pass directly; TipTap will parse it
    return raw
  }

  #syncContent(editor, opts) {
    this.#syncContentEl(editor, opts, this.hasHiddenFieldTarget ? this.hiddenFieldTarget : null)
  }

  #syncContentEl(editor, opts, hiddenFieldEl) {
    if (!hiddenFieldEl) return
    if (opts.readonly || this.disabledValue) return

    const format = opts.format || "json"
    hiddenFieldEl.value = format === "html"
      ? editor.getHTML()
      : JSON.stringify(editor.getJSON())
  }

  #updateCharacterCount(editor, opts) {
    this.#updateCharacterCountEl(editor, opts, this.hasCharacterCountTarget ? this.characterCountTarget : null)
  }

  #updateCharacterCountEl(editor, opts, charCountEl) {
    if (!charCountEl) return

    const storage = editor.storage.characterCount
    if (!storage) return

    const count = storage.characters()
    const limit = opts.max_characters || null

    charCountEl.textContent = limit
      ? `${count}/${limit} characters`
      : `${count} characters`

    const belowMin = opts.min_characters && count < opts.min_characters
    const aboveMax = limit && count > limit

    charCountEl.classList.toggle(
      "text-[var(--color-warning-border)]",
      !!(belowMin || aboveMax)
    )
    charCountEl.classList.toggle(
      "text-[var(--surface-muted-content-color)]",
      !(belowMin || aboveMax)
    )
  }

  // ── Menu builders ─────────────────────────────────────────────────────────

  #buildMenus(editor, opts) {
    this.#buildMenusEl(
      editor, opts,
      this.hasBubbleMenuTarget   ? this.bubbleMenuTarget   : null,
      this.hasFloatingMenuTarget ? this.floatingMenuTarget : null
    )
  }

  #buildMenusEl(editor, opts, bubbleMenuEl, floatingMenuEl) {
    // Bubble menu: element was passed to BubbleMenu extension and may have been
    // teleported by Tippy. Use the stored ref, not a fresh Stimulus target lookup.
    if (bubbleMenuEl && opts.bubble_menu) {
      buildBubbleMenu(bubbleMenuEl, editor, opts)
    }
    if (floatingMenuEl && opts.floating_menu) {
      this.#buildFloatingMenuEl(editor, floatingMenuEl)
    }
  }

  #buildFloatingMenu(editor, opts) {
    const el = this.hasFloatingMenuTarget ? this.floatingMenuTarget : null
    if (!el) return
    this.#buildFloatingMenuEl(editor, el)
  }

  #buildFloatingMenuEl(editor, el) {
    if (!el || el.childElementCount > 0) return

    el.setAttribute("role", "menu")
    el.setAttribute("aria-label", "Insert content")

    const actions = [
      { label: "Heading 1",    fn: () => editor.chain().focus().setHeading({ level: 1 }).run() },
      { label: "Heading 2",    fn: () => editor.chain().focus().setHeading({ level: 2 }).run() },
      { label: "Bullet list",  fn: () => editor.chain().focus().toggleBulletList().run() },
      { label: "Ordered list", fn: () => editor.chain().focus().toggleOrderedList().run() },
      { label: "Blockquote",   fn: () => editor.chain().focus().toggleBlockquote().run() },
    ]

    actions.forEach(({ label, fn }) => {
      const btn = document.createElement("button")
      btn.type = "button"
      btn.className = "flat-pack-richtext-floating-btn"
      btn.setAttribute("role", "menuitem")
      btn.textContent = label
      btn.addEventListener("mousedown", (e) => {
        e.preventDefault()
        fn()
      })
      el.appendChild(btn)
    })
  }
}
