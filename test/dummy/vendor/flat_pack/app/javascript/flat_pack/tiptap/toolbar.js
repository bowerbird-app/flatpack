/**
 * FlatPack TipTap Toolbar
 *
 * Builds and manages the rich text toolbar DOM inside the server-rendered
 * `.flat-pack-richtext-toolbar` container.
 *
 * FlatPack uses TipTap's editor.chain().focus().<command>().run() API for all
 * toolbar actions. TipTap UI (the upstream React-based component library) is not
 * applicable in this vanilla JS + Stimulus integration. FlatPack themes the
 * toolbar using CSS variables that match the gem's design system.
 *
 * ── Toolbar presets ──────────────────────────────────────────────────────────
 *
 *   minimal  — Bold, Italic, Underline | Undo, Redo
 *   standard — Bold, Italic, Underline, Strike, Code | H1–H3 | BulletList,
 *              OrderedList | Blockquote | Undo, Redo
 *   full     — All of standard + TaskList, TextAlign, Link, Image, Table,
 *              Highlight, Color (when enabled)
 *   none     — No toolbar rendered (handled in Ruby before this is called)
 *   custom   — Array of tool names supplied via rich_text_options[:toolbar]
 */

// ── Inline link/image popovers (replaces window.prompt) ─────────────────────

function closeLinkPopover() {
  document.querySelector(".flat-pack-rt-link-popover")?.remove()
}

function showLinkPopover(editor, anchorEl) {
  // Toggle: close if already open
  if (document.querySelector(".flat-pack-rt-link-popover")) {
    closeLinkPopover()
    return
  }

  const prev = editor.getAttributes("link").href || ""

  const popover = document.createElement("div")
  popover.className = "flat-pack-rt-link-popover"
  popover.setAttribute("role", "dialog")
  popover.setAttribute("aria-label", "Insert link")

  const input = Object.assign(document.createElement("input"), {
    type: "url",
    className: "flat-pack-rt-link-input",
    placeholder: "https://",
    value: prev,
  })

  const applyBtn = Object.assign(document.createElement("button"), {
    type: "button",
    className: "flat-pack-rt-link-apply-btn",
    textContent: "Apply",
  })

  const removeBtn = Object.assign(document.createElement("button"), {
    type: "button",
    className: "flat-pack-rt-link-remove-btn",
    textContent: "Remove",
  })

  popover.appendChild(input)
  popover.appendChild(applyBtn)
  if (prev) popover.appendChild(removeBtn)

  // Position fixed relative to viewport
  document.body.appendChild(popover)
  const rect = anchorEl.getBoundingClientRect()
  // Prevent popover from going off-screen on the right
  const popW = popover.offsetWidth || 280
  const left = Math.min(rect.left, window.innerWidth - popW - 8)
  popover.style.top  = `${rect.bottom + 4}px`
  popover.style.left = `${Math.max(8, left)}px`

  input.focus()
  input.select()

  const apply = () => {
    const raw = input.value.trim()
    if (raw) {
      const href = /^https?:\/\//i.test(raw) ? raw : `https://${raw}`
      editor.chain().focus().extendMarkRange("link").setLink({ href }).run()
    } else {
      editor.chain().focus().extendMarkRange("link").unsetLink().run()
    }
    closeLinkPopover()
  }

  applyBtn.addEventListener("click", apply)
  removeBtn.addEventListener("click", () => {
    editor.chain().focus().extendMarkRange("link").unsetLink().run()
    closeLinkPopover()
  })
  input.addEventListener("keydown", (ev) => {
    if (ev.key === "Enter")  { ev.preventDefault(); apply() }
    if (ev.key === "Escape") { ev.preventDefault(); closeLinkPopover(); editor.commands.focus() }
  })

  // Close when clicking outside the popover
  const onOutside = (ev) => {
    if (!popover.contains(ev.target) && ev.target !== anchorEl) {
      closeLinkPopover()
      document.removeEventListener("mousedown", onOutside)
    }
  }
  setTimeout(() => document.addEventListener("mousedown", onOutside), 0)
}

function showImagePopover(editor, anchorEl, opts) {
  if (document.querySelector(".flat-pack-rt-link-popover")) {
    closeLinkPopover()
    return
  }

  const uploadUrl = opts?.uploads?.url || null

  const popover = document.createElement("div")
  popover.className = "flat-pack-rt-link-popover"
  popover.setAttribute("role", "dialog")
  popover.setAttribute("aria-label", "Insert image")

  // When upload is available, stack sections vertically
  if (uploadUrl) {
    popover.style.flexDirection = "column"
    popover.style.alignItems = "stretch"
    popover.style.gap = "0"
  }

  // ── URL row (always shown) ────────────────────────────────────────────────
  const urlRow = document.createElement("div")
  urlRow.style.cssText = "display:flex;align-items:center;gap:6px;"

  const input = Object.assign(document.createElement("input"), {
    type: "url",
    className: "flat-pack-rt-link-input",
    placeholder: "Image URL (https://...)",
  })

  const applyBtn = Object.assign(document.createElement("button"), {
    type: "button",
    className: "flat-pack-rt-link-apply-btn",
    textContent: "Insert",
  })

  urlRow.appendChild(input)
  urlRow.appendChild(applyBtn)
  popover.appendChild(urlRow)

  // ── File upload section (only shown when upload URL is configured) ────────
  if (uploadUrl) {
    const divider = document.createElement("div")
    divider.textContent = "— or upload a file —"
    divider.style.cssText = "text-align:center;font-size:11px;color:var(--surface-muted-content-color);padding:6px 0 4px;"
    popover.appendChild(divider)

    const fileInput = Object.assign(document.createElement("input"), {
      type: "file",
      accept: "image/*",
    })
    fileInput.setAttribute("aria-label", "Upload image file")
    fileInput.style.cssText = "display:none;"

    const uploadBtn = document.createElement("button")
    uploadBtn.type = "button"
    uploadBtn.textContent = "Upload from computer"
    uploadBtn.style.cssText = "background:transparent;border:none;padding:0;font-size:12px;color:var(--surface-content-color);cursor:pointer;text-decoration:underline;width:100%;text-align:left;"
    uploadBtn.addEventListener("click", () => fileInput.click())

    const statusEl = document.createElement("div")
    statusEl.style.cssText = "font-size:11px;padding-top:4px;color:var(--surface-muted-content-color);display:none;"

    fileInput.addEventListener("change", async () => {
      const file = fileInput.files?.[0]
      if (!file) return

      statusEl.textContent = "Uploading…"
      statusEl.style.display = "block"

      const csrfToken = document.querySelector("meta[name=csrf-token]")?.content
      const formData = new FormData()
      formData.append("file", file)

      try {
        const res = await fetch(uploadUrl, {
          method: "POST",
          headers: csrfToken ? {"X-CSRF-Token": csrfToken} : {},
          body: formData,
        })

        if (!res.ok) {
          const err = await res.json().catch(() => ({}))
          statusEl.textContent = err.error || "Upload failed"
          return
        }

        const {url} = await res.json()
        if (url) {
          editor.chain().focus().setImage({src: url}).run()
          closeLinkPopover()
        }
      } catch {
        statusEl.textContent = "Upload failed — check your connection"
      }
    })

    popover.appendChild(fileInput)
    popover.appendChild(uploadBtn)
    popover.appendChild(statusEl)
  }

  document.body.appendChild(popover)
  const rect = anchorEl.getBoundingClientRect()
  const popW = popover.offsetWidth || 280
  const left = Math.min(rect.left, window.innerWidth - popW - 8)
  popover.style.top  = `${rect.bottom + 4}px`
  popover.style.left = `${Math.max(8, left)}px`

  input.focus()

  const apply = () => {
    const src = input.value.trim()
    if (src) editor.chain().focus().setImage({ src }).run()
    closeLinkPopover()
  }

  applyBtn.addEventListener("click", apply)
  input.addEventListener("keydown", (ev) => {
    if (ev.key === "Enter")  { ev.preventDefault(); apply() }
    if (ev.key === "Escape") { ev.preventDefault(); closeLinkPopover(); editor.commands.focus() }
  })

  const onOutside = (ev) => {
    if (!popover.contains(ev.target) && ev.target !== anchorEl) {
      closeLinkPopover()
      document.removeEventListener("mousedown", onOutside)
    }
  }
  setTimeout(() => document.addEventListener("mousedown", onOutside), 0)
}

// ── SVG icons (inline, accessible) ───────────────────────────────────────────

const ICONS = {
  bold:          `<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" aria-hidden="true"><path d="M6 4h8a4 4 0 010 8H6z"/><path d="M6 12h9a4 4 0 010 8H6z"/></svg>`,
  italic:        `<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" aria-hidden="true"><line x1="19" y1="4" x2="10" y2="4"/><line x1="14" y1="20" x2="5" y2="20"/><line x1="15" y1="4" x2="9" y2="20"/></svg>`,
  underline:     `<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" aria-hidden="true"><path d="M6 3v7a6 6 0 0012 0V3"/><line x1="4" y1="21" x2="20" y2="21"/></svg>`,
  strike:        `<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5" aria-hidden="true"><line x1="5" y1="12" x2="19" y2="12"/><path d="M16 6C16 6 14.5 4 12 4s-5 1-5 4c0 2 1.5 3 4 3.5"/><path d="M8 18c0 0 1.5 2 4 2s5-1 5-4"/></svg>`,
  code:          `<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><polyline points="16 18 22 12 16 6"/><polyline points="8 6 2 12 8 18"/></svg>`,
  h1:            `<span aria-hidden="true" style="font-weight:700;font-size:12px;line-height:1">H1</span>`,
  h2:            `<span aria-hidden="true" style="font-weight:700;font-size:12px;line-height:1">H2</span>`,
  h3:            `<span aria-hidden="true" style="font-weight:700;font-size:12px;line-height:1">H3</span>`,
  bulletList:    `<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><line x1="9" y1="6" x2="20" y2="6"/><line x1="9" y1="12" x2="20" y2="12"/><line x1="9" y1="18" x2="20" y2="18"/><circle cx="4" cy="6" r="1.5" fill="currentColor" stroke="none"/><circle cx="4" cy="12" r="1.5" fill="currentColor" stroke="none"/><circle cx="4" cy="18" r="1.5" fill="currentColor" stroke="none"/></svg>`,
  orderedList:   `<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><line x1="10" y1="6" x2="21" y2="6"/><line x1="10" y1="12" x2="21" y2="12"/><line x1="10" y1="18" x2="21" y2="18"/><text x="2" y="8" font-size="7" fill="currentColor" stroke="none">1.</text><text x="2" y="14" font-size="7" fill="currentColor" stroke="none">2.</text><text x="2" y="20" font-size="7" fill="currentColor" stroke="none">3.</text></svg>`,
  taskList:      `<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><polyline points="9 11 12 14 20 6"/><path d="M20 12v6a2 2 0 01-2 2H6a2 2 0 01-2-2V6a2 2 0 012-2h9"/></svg>`,
  blockquote:    `<svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor" stroke="none" aria-hidden="true"><path d="M3 21c3 0 7-1 7-8V5c0-1.25-.756-2.017-2-2H4c-1.25 0-2 .75-2 1.972V11c0 1.25.75 2 2 2 1 0 1 0 1 1v1c0 1-1 2-2 2s-1 .008-1 1.031V20c0 1 0 1 1 1z"/><path d="M15 21c3 0 7-1 7-8V5c0-1.25-.757-2.017-2-2h-4c-1.25 0-2 .75-2 1.972V11c0 1.25.75 2 2 2h.75c0 2.25.25 4-2.75 4v3c0 1 0 1 1 1z"/></svg>`,
  alignLeft:     `<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><line x1="3" y1="6" x2="21" y2="6"/><line x1="3" y1="12" x2="15" y2="12"/><line x1="3" y1="18" x2="18" y2="18"/></svg>`,
  alignCenter:   `<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><line x1="3" y1="6" x2="21" y2="6"/><line x1="6" y1="12" x2="18" y2="12"/><line x1="4" y1="18" x2="20" y2="18"/></svg>`,
  alignRight:    `<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><line x1="3" y1="6" x2="21" y2="6"/><line x1="9" y1="12" x2="21" y2="12"/><line x1="6" y1="18" x2="21" y2="18"/></svg>`,
  highlight:     `<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M9.06 11.9l8.07-8.06a2.85 2.85 0 114.03 4.03l-8.06 8.08M5 20l-1 1 1-5 8-8 4 4-8 8"/><line x1="3" y1="21" x2="22" y2="21"/></svg>`,
  link:          `<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><path d="M10 13a5 5 0 007.54.54l3-3a5 5 0 00-7.07-7.07l-1.72 1.71"/><path d="M14 11a5 5 0 00-7.54-.54l-3 3a5 5 0 007.07 7.07l1.71-1.71"/></svg>`,
  image:         `<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><rect x="3" y="3" width="18" height="18" rx="2"/><circle cx="8.5" cy="8.5" r="1.5"/><polyline points="21 15 16 10 5 21"/></svg>`,
  table:         `<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><rect x="3" y="3" width="18" height="18" rx="2"/><line x1="3" y1="9" x2="21" y2="9"/><line x1="3" y1="15" x2="21" y2="15"/><line x1="9" y1="3" x2="9" y2="21"/><line x1="15" y1="3" x2="15" y2="21"/></svg>`,
  undo:          `<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><polyline points="9 14 4 9 9 4"/><path d="M20 20v-7a4 4 0 00-4-4H4"/></svg>`,
  redo:          `<svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" aria-hidden="true"><polyline points="15 14 20 9 15 4"/><path d="M4 20v-7a4 4 0 014-4h12"/></svg>`,
  separator:     `<div class="flat-pack-richtext-toolbar-sep" aria-hidden="true"></div>`,
}

// ── Tool definitions ──────────────────────────────────────────────────────────

function toolButton({ name, label, icon, action, isActive, isDisabled }) {
  const btn = document.createElement("button")
  btn.type = "button"
  btn.setAttribute("aria-label", label)
  btn.setAttribute("title", label)
  btn.setAttribute("data-tool", name)
  btn.className = "flat-pack-richtext-toolbar-btn"
  btn.innerHTML = icon
  btn.addEventListener("click", (e) => {
    e.preventDefault()
    // Pass the button element so actions can anchor popovers to it
    action(btn)
    // Only re-focus the button for non-popover actions (popovers focus their own input)
    if (!document.querySelector(".flat-pack-rt-link-popover")) btn.focus()
  })
  return btn
}

function mergeToolDefinitions(defaults, extras, scope) {
  const merged = []
  const seen = new Set()

  for (const def of [...defaults, ...extras]) {
    if (!def?.name) {
      console.warn(`[FlatPack TipTap] Ignoring ${scope} tool definition without a name.`)
      continue
    }

    if (seen.has(def.name)) {
      console.warn(`[FlatPack TipTap] Ignoring duplicate ${scope} tool \"${def.name}\".`)
      continue
    }

    seen.add(def.name)
    merged.push(def)
  }

  return merged
}

// Each entry: { name, label, icon, action(editor), isActive?(editor), presets }
const DEFAULT_TOOL_DEFINITIONS = [
  // Inline marks
  {
    name: "bold",
    label: "Bold",
    icon: ICONS.bold,
    presets: ["minimal", "standard", "full"],
    action: (e) => e.chain().focus().toggleBold().run(),
    isActive: (e) => e.isActive("bold"),
  },
  {
    name: "italic",
    label: "Italic",
    icon: ICONS.italic,
    presets: ["minimal", "standard", "full"],
    action: (e) => e.chain().focus().toggleItalic().run(),
    isActive: (e) => e.isActive("italic"),
  },
  {
    name: "underline",
    label: "Underline",
    icon: ICONS.underline,
    presets: ["minimal", "standard", "full"],
    action: (e) => e.chain().focus().toggleUnderline().run(),
    isActive: (e) => e.isActive("underline"),
  },
  { name: "sep1", presets: ["standard", "full"], type: "separator" },
  {
    name: "strike",
    label: "Strikethrough",
    icon: ICONS.strike,
    presets: ["standard", "full"],
    action: (e) => e.chain().focus().toggleStrike().run(),
    isActive: (e) => e.isActive("strike"),
  },
  {
    name: "code",
    label: "Inline code",
    icon: ICONS.code,
    presets: ["standard", "full"],
    action: (e) => e.chain().focus().toggleCode().run(),
    isActive: (e) => e.isActive("code"),
  },
  {
    name: "highlight",
    label: "Highlight",
    icon: ICONS.highlight,
    presets: ["full"],
    action: (e) => e.chain().focus().toggleHighlight().run(),
    isActive: (e) => e.isActive("highlight"),
  },
  { name: "sep2", presets: ["standard", "full"], type: "separator" },
  // Headings
  {
    name: "h1",
    label: "Heading 1",
    icon: ICONS.h1,
    presets: ["standard", "full"],
    action: (e) => e.chain().focus().toggleHeading({ level: 1 }).run(),
    isActive: (e) => e.isActive("heading", { level: 1 }),
  },
  {
    name: "h2",
    label: "Heading 2",
    icon: ICONS.h2,
    presets: ["standard", "full"],
    action: (e) => e.chain().focus().toggleHeading({ level: 2 }).run(),
    isActive: (e) => e.isActive("heading", { level: 2 }),
  },
  {
    name: "h3",
    label: "Heading 3",
    icon: ICONS.h3,
    presets: ["standard", "full"],
    action: (e) => e.chain().focus().toggleHeading({ level: 3 }).run(),
    isActive: (e) => e.isActive("heading", { level: 3 }),
  },
  { name: "sep3", presets: ["standard", "full"], type: "separator" },
  // Lists
  {
    name: "bulletList",
    label: "Bullet list",
    icon: ICONS.bulletList,
    presets: ["standard", "full"],
    action: (e) => e.chain().focus().toggleBulletList().run(),
    isActive: (e) => e.isActive("bulletList"),
  },
  {
    name: "orderedList",
    label: "Numbered list",
    icon: ICONS.orderedList,
    presets: ["standard", "full"],
    action: (e) => e.chain().focus().toggleOrderedList().run(),
    isActive: (e) => e.isActive("orderedList"),
  },
  {
    name: "taskList",
    label: "Task list",
    icon: ICONS.taskList,
    presets: ["full"],
    action: (e) => e.chain().focus().toggleTaskList().run(),
    isActive: (e) => e.isActive("taskList"),
  },
  { name: "sep4", presets: ["standard", "full"], type: "separator" },
  // Block-level formatting
  {
    name: "blockquote",
    label: "Blockquote",
    icon: ICONS.blockquote,
    presets: ["standard", "full"],
    action: (e) => e.chain().focus().toggleBlockquote().run(),
    isActive: (e) => e.isActive("blockquote"),
  },
  // Text alignment (full only)
  {
    name: "alignLeft",
    label: "Align left",
    icon: ICONS.alignLeft,
    presets: ["full"],
    action: (e) => e.chain().focus().setTextAlign("left").run(),
    isActive: (e) => e.isActive({ textAlign: "left" }),
  },
  {
    name: "alignCenter",
    label: "Align center",
    icon: ICONS.alignCenter,
    presets: ["full"],
    action: (e) => e.chain().focus().setTextAlign("center").run(),
    isActive: (e) => e.isActive({ textAlign: "center" }),
  },
  {
    name: "alignRight",
    label: "Align right",
    icon: ICONS.alignRight,
    presets: ["full"],
    action: (e) => e.chain().focus().setTextAlign("right").run(),
    isActive: (e) => e.isActive({ textAlign: "right" }),
  },
  // Rich content (full only)
  {
    name: "link",
    label: "Insert/edit link",
    icon: ICONS.link,
    presets: ["full"],
    action: (e, btnEl) => showLinkPopover(e, btnEl),
    isActive: (e) => e.isActive("link"),
  },
  {
    name: "image",
    label: "Insert image",
    icon: ICONS.image,
    presets: ["full"],
    // opts is injected by buildToolbar so upload config can flow through
    action: (e, btnEl, opts) => showImagePopover(e, btnEl, opts),
    isActive: () => false,
  },
  {
    name: "table",
    label: "Insert table",
    icon: ICONS.table,
    presets: ["full"],
    action: (e) => e.chain().focus().insertTable({ rows: 3, cols: 3, withHeaderRow: true }).run(),
    isActive: (e) => e.isActive("table"),
  },
  // sep5 also applies to minimal to visually separate formatting buttons from history
  { name: "sep5", presets: ["minimal", "standard", "full"], type: "separator" },
  // History
  {
    name: "undo",
    label: "Undo",
    icon: ICONS.undo,
    presets: ["minimal", "standard", "full"],
    action: (e) => e.chain().focus().undo().run(),
    isActive: () => false,
    isDisabled: (e) => !e.can().undo(),
  },
  {
    name: "redo",
    label: "Redo",
    icon: ICONS.redo,
    presets: ["minimal", "standard", "full"],
    action: (e) => e.chain().focus().redo().run(),
    isActive: () => false,
    isDisabled: (e) => !e.can().redo(),
  },
]

// ── Public API ────────────────────────────────────────────────────────────────

/**
 * Populate the toolbar element with buttons appropriate for the given preset.
 *
 * @param {Element}  toolbarEl - The `.flat-pack-richtext-toolbar` container
 * @param {Editor}   editor    - TipTap Editor instance
 * @param {object}   opts      - Rich text options from Ruby (deserialized)
 */
export function buildToolbar(toolbarEl, editor, opts, extraTools = []) {
  if (!toolbarEl) return

  const preset        = opts.toolbar || "standard"
  const isCustom      = Array.isArray(preset)
  const effectiveSet  = isCustom ? new Set(preset) : null
  const toolDefinitions = mergeToolDefinitions(DEFAULT_TOOL_DEFINITIONS, extraTools, "toolbar")

  // Clear any previous content (guard against double-init)
  toolbarEl.innerHTML = ""
  toolbarEl._flatPackToolDefinitions = toolDefinitions

  for (const def of toolDefinitions) {
    // Skip separators that have no tools on either side (handled below)
    if (def.type === "separator") {
      const sep = document.createElement("div")
      sep.className = "flat-pack-richtext-toolbar-sep"
      sep.setAttribute("aria-hidden", "true")

      // Only include separator if in the matching preset group
      if (isCustom) {
        // Custom toolbar — omit separators unless explicitly named
        if (!effectiveSet.has(def.name)) continue
      } else {
        if (!def.presets.includes(preset)) continue
      }
      toolbarEl.appendChild(sep)
      continue
    }

    // Decide whether to include this tool
    let include = false
    if (isCustom) {
      include = effectiveSet.has(def.name)
    } else {
      include = def.presets.includes(preset)
    }

    if (!include) continue

    const btn = toolButton({
      name:       def.name,
      label:      def.label,
      icon:       def.icon,
      // btnEl is passed from toolButton's click handler so actions can anchor popovers
      // opts is forwarded so image/link actions can read upload config
      action:     (btnEl) => def.action(editor, btnEl, opts),
      isActive:   () => def.isActive?.(editor) || false,
      isDisabled: () => def.isDisabled?.(editor) || false,
    })

    toolbarEl.appendChild(btn)
  }

  // Initial state pass
  updateToolbarState(toolbarEl, editor)
}

/**
 * Refresh active/disabled classes on all toolbar buttons after a state change.
 *
 * @param {Element}  toolbarEl - The toolbar container
 * @param {Editor}   editor    - TipTap Editor instance
 */
export function updateToolbarState(toolbarEl, editor) {
  if (!toolbarEl || !editor) return

  const buttons = toolbarEl.querySelectorAll("[data-tool]")
  const toolDefinitions = toolbarEl._flatPackToolDefinitions || DEFAULT_TOOL_DEFINITIONS

  buttons.forEach((btn) => {
    const name = btn.getAttribute("data-tool")
    const def  = toolDefinitions.find((d) => d.name === name)
    if (!def) return

    const active   = def.isActive?.(editor) || false
    const disabled = def.isDisabled?.(editor) || false

    btn.classList.toggle("is-active",   active)
    btn.classList.toggle("is-disabled", disabled)
    btn.setAttribute("aria-pressed",    active ? "true" : "false")
    btn.disabled = disabled
  })
}
