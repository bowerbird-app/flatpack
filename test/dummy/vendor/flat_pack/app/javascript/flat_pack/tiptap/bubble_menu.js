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

function bubbleToolButton(def, editor, menuEl) {
  const btn = bubbleButton({
    label: def.label,
    icon: def.icon,
    onClick: () => {
      def.action(editor)
      refreshBubbleMenuState(menuEl, editor)
    },
  })

  btn.setAttribute("data-tool", def.name)
  return btn
}

function mergeBubbleToolDefinitions(defaults, extras) {
  const merged = []
  const seen = new Set()

  for (const def of [...defaults, ...extras]) {
    if (!def?.name) {
      console.warn("[FlatPack TipTap] Ignoring bubble menu tool definition without a name.")
      continue
    }

    if (seen.has(def.name)) {
      console.warn(`[FlatPack TipTap] Ignoring duplicate bubble menu tool \"${def.name}\".`)
      continue
    }

    seen.add(def.name)
    merged.push(def)
  }

  return merged
}

function buildDefaultBubbleTools(opts) {
  const preset = opts.preset || "minimal"
  const isContent = preset === "content" || preset === "full"
  const definitions = [
    {
      name: "bold",
      label: "Bold",
      icon: ICONS.bold,
      action: (e) => e.chain().focus().toggleBold().run(),
      isActive: (e) => e.isActive("bold"),
    },
    {
      name: "italic",
      label: "Italic",
      icon: ICONS.italic,
      action: (e) => e.chain().focus().toggleItalic().run(),
      isActive: (e) => e.isActive("italic"),
    },
    {
      name: "underline",
      label: "Underline",
      icon: ICONS.underline,
      action: (e) => e.chain().focus().toggleUnderline().run(),
      isActive: (e) => e.isActive("underline"),
    },
    { name: "sep-inline", type: "separator" },
    {
      name: "strike",
      label: "Strikethrough",
      icon: ICONS.strike,
      action: (e) => e.chain().focus().toggleStrike().run(),
      isActive: (e) => e.isActive("strike"),
    },
    {
      name: "code",
      label: "Inline code",
      icon: ICONS.code,
      action: (e) => e.chain().focus().toggleCode().run(),
      isActive: (e) => e.isActive("code"),
    },
  ]

  if (isContent) {
    definitions.push({
      name: "highlight",
      label: "Highlight",
      icon: ICONS.highlight,
      action: (e) => e.chain().focus().toggleHighlight().run(),
      isActive: (e) => e.isActive("highlight"),
    })
  }

  definitions.push(
    { name: "sep-link", type: "separator" },
    {
      name: "link",
      label: "Link",
      icon: ICONS.link,
      action: (e) => {
        const prev = e.getAttributes("link").href || ""
        const url = window.prompt("Enter link URL:", prev)
        if (url === null) return
        if (url === "") {
          e.chain().focus().extendMarkRange("link").unsetLink().run()
        } else {
          e.chain().focus().extendMarkRange("link").setLink({ href: url }).run()
        }
      },
      isActive: (e) => e.isActive("link"),
    }
  )

  return definitions
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
export function buildBubbleMenu(menuEl, editor, opts, extraTools = []) {
  if (!menuEl) return
  if (!opts.bubble_menu) return

  // Idempotent: skip if already populated (guard against TipTap re-init)
  if (menuEl.childElementCount > 0) return

  menuEl.setAttribute("role", "toolbar")
  menuEl.setAttribute("aria-label", "Text formatting")
  const toolDefinitions = mergeBubbleToolDefinitions(buildDefaultBubbleTools(opts), extraTools)
  menuEl._flatPackBubbleToolDefinitions = toolDefinitions

  for (const def of toolDefinitions) {
    if (def.type === "separator") {
      menuEl.appendChild(separator())
      continue
    }

    menuEl.appendChild(bubbleToolButton(def, editor, menuEl))
  }

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

  const toolDefinitions = menuEl._flatPackBubbleToolDefinitions || []

  menuEl.querySelectorAll("[data-tool]").forEach((btn) => {
    const def = toolDefinitions.find((entry) => entry.name === btn.getAttribute("data-tool"))
    if (!def) return

    const active = def.isActive?.(editor) || false
    btn.classList.toggle("is-active", active)
    btn.setAttribute("aria-pressed", active ? "true" : "false")
  })
}
