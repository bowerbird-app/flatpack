/**
 * FlatPack TipTap Bubble Menu
 *
 * Populates the server-rendered `.flat-pack-richtext-bubble-menu` container
 * with inline formatting buttons after the TipTap editor is created.
 *
 * TipTap's BubbleMenu extension (configured in extension_registry.js) handles
 * show/hide and positioning. This module is responsible only for the DOM
 * content (the interactive buttons inside the menu).
 *
 * The BubbleMenu follows TipTap UI's convention of a floating pill of inline
 * mark controls that appear on text selection. FlatPack themes it with
 * CSS variables from the gem's design system.
 */

// ── SVG Icons (same subset as toolbar, kept local to avoid cross-module state) ──

const ICONS = {
  bold:      `<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" aria-hidden="true"><path d="M6 4h8a4 4 0 010 8H6z"/><path d="M6 12h9a4 4 0 010 8H6z"/></svg>`,
  italic:    `<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" aria-hidden="true"><line x1="19" y1="4" x2="10" y2="4"/><line x1="14" y1="20" x2="5" y2="20"/><line x1="15" y1="4" x2="9" y2="20"/></svg>`,
  underline: `<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" aria-hidden="true"><path d="M6 3v7a6 6 0 0012 0V3"/><line x1="4" y1="21" x2="20" y2="21"/></svg>`,
  strike:    `<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" aria-hidden="true"><line x1="5" y1="12" x2="19" y2="12"/><path d="M16 6C16 6 14.5 4 12 4s-5 1-5 4c0 2 1.5 3 4 3.5"/><path d="M8 18c0 0 1.5 2 4 2s5-1 5-4"/></svg>`,
  code:      `<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><polyline points="16 18 22 12 16 6"/><polyline points="8 6 2 12 8 18"/></svg>`,
  highlight: `<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M9.06 11.9l8.07-8.06a2.85 2.85 0 114.03 4.03l-8.06 8.08M5 20l-1 1 1-5 8-8 4 4-8 8"/><line x1="3" y1="21" x2="22" y2="21"/></svg>`,
  link:      `<svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M10 13a5 5 0 007.54.54l3-3a5 5 0 00-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 00-7.54-.54l-3 3a5 5 0 007.07 7.07l1.71-1.71"/></svg>`,
}

// ── Button factory ────────────────────────────────────────────────────────────

function bubbleButton({ label, icon, onClick }) {
  const btn = document.createElement("button")
  btn.type = "button"
  btn.className = "flat-pack-richtext-bubble-btn"
  btn.setAttribute("aria-label", label)
  btn.setAttribute("title", label)
  btn.innerHTML = icon
  btn.addEventListener("mousedown", (e) => {
    // Use mousedown + preventDefault so the editor doesn't lose focus
    e.preventDefault()
    onClick()
  })
  return btn
}

// ── Separator ─────────────────────────────────────────────────────────────────

function separator() {
  const sep = document.createElement("div")
  sep.className = "flat-pack-richtext-bubble-sep"
  sep.setAttribute("aria-hidden", "true")
  return sep
}

// ── Public API ────────────────────────────────────────────────────────────────

/**
 * Populate the bubble menu DOM element with inline formatting controls.
 *
 * Must be called after the TipTap Editor has been created (i.e. inside onCreate).
 * The BubbleMenu extension is already configured in extension_registry.js with
 * this element; here we only fill in its content.
 *
 * @param {Element} menuEl - The `.flat-pack-richtext-bubble-menu` container
 * @param {Editor}  editor - TipTap Editor instance
 * @param {object}  opts   - Rich text options (deserialized from Ruby)
 */
export function buildBubbleMenu(menuEl, editor, opts) {
  if (!menuEl) return
  if (!opts.bubble_menu) return

  // Idempotent: skip if already populated (guard against TipTap re-init)
  if (menuEl.childElementCount > 0) return

  menuEl.setAttribute("role", "toolbar")
  menuEl.setAttribute("aria-label", "Text formatting")

  const preset = opts.preset || "minimal"
  const isContent = preset === "content" || preset === "full"

  // Core marks — always in bubble menu
  menuEl.appendChild(bubbleButton({
    label: "Bold",
    icon:  ICONS.bold,
    onClick: () => {
      editor.chain().focus().toggleBold().run()
      refreshBubbleMenuState(menuEl, editor)
    },
  }))

  menuEl.appendChild(bubbleButton({
    label: "Italic",
    icon:  ICONS.italic,
    onClick: () => {
      editor.chain().focus().toggleItalic().run()
      refreshBubbleMenuState(menuEl, editor)
    },
  }))

  menuEl.appendChild(bubbleButton({
    label: "Underline",
    icon:  ICONS.underline,
    onClick: () => {
      editor.chain().focus().toggleUnderline().run()
      refreshBubbleMenuState(menuEl, editor)
    },
  }))

  menuEl.appendChild(separator())

  menuEl.appendChild(bubbleButton({
    label: "Strikethrough",
    icon:  ICONS.strike,
    onClick: () => {
      editor.chain().focus().toggleStrike().run()
      refreshBubbleMenuState(menuEl, editor)
    },
  }))

  menuEl.appendChild(bubbleButton({
    label: "Inline code",
    icon:  ICONS.code,
    onClick: () => {
      editor.chain().focus().toggleCode().run()
      refreshBubbleMenuState(menuEl, editor)
    },
  }))

  // Highlight — available in content/full presets
  if (isContent) {
    menuEl.appendChild(bubbleButton({
      label: "Highlight",
      icon:  ICONS.highlight,
      onClick: () => {
        editor.chain().focus().toggleHighlight().run()
        refreshBubbleMenuState(menuEl, editor)
      },
    }))
  }

  menuEl.appendChild(separator())

  // Link
  menuEl.appendChild(bubbleButton({
    label: "Link",
    icon:  ICONS.link,
    onClick: () => {
      const prev = editor.getAttributes("link").href || ""
      // Using window.prompt as the minimal accessible approach.
      // Applications can override this by providing a custom link UI via
      // rich_text_options[:ui][:link_dialog] configuration (see docs).
      const url = window.prompt("Enter link URL:", prev)
      if (url === null) return
      if (url === "") {
        editor.chain().focus().extendMarkRange("link").unsetLink().run()
      } else {
        editor.chain().focus().extendMarkRange("link").setLink({ href: url }).run()
      }
      refreshBubbleMenuState(menuEl, editor)
    },
  }))

  // Initial state
  refreshBubbleMenuState(menuEl, editor)
}

/**
 * Refresh active/pressed state on all bubble menu buttons.
 * Called after every editor command and on selectionUpdate.
 *
 * @param {Element} menuEl
 * @param {Editor}  editor
 */
export function refreshBubbleMenuState(menuEl, editor) {
  if (!menuEl || !editor) return

  const STATE_MAP = {
    bold:      (e) => e.isActive("bold"),
    italic:    (e) => e.isActive("italic"),
    underline: (e) => e.isActive("underline"),
    strike:    (e) => e.isActive("strike"),
    code:      (e) => e.isActive("code"),
    highlight: (e) => e.isActive("highlight"),
    link:      (e) => e.isActive("link"),
  }

  menuEl.querySelectorAll('[aria-label]').forEach((btn) => {
    const label    = btn.getAttribute("aria-label")?.toLowerCase()
    const checker  = Object.entries(STATE_MAP).find(([, fn]) => {
      // Match by aria-label prefix (e.g. "bold" matches aria-label="Bold")
      return label === Object.keys(STATE_MAP).find((k) => k === label) ||
             label === "bold"       && STATE_MAP.bold(editor) !== undefined ||
             false
    })

    // Simpler approach: iterate known mark names and compare aria-label
    const markNames = Object.keys(STATE_MAP)
    const match = markNames.find((k) => label === k ||
      label === { bold: "bold", italic: "italic", underline: "underline",
                  strike: "strikethrough", code: "inline code",
                  highlight: "highlight", link: "link" }[k])

    if (match) {
      const active = STATE_MAP[match]?.(editor) || false
      btn.classList.toggle("is-active", active)
      btn.setAttribute("aria-pressed", active ? "true" : "false")
    }
  })
}
