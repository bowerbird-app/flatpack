/**
 * FlatPack TipTap Extension Registry
 *
 * Maps Ruby-side preset names and rich_text_options config to arrays of
 * TipTap extension instances for use by the tiptap_controller.
 *
 * Preset definitions (mirror of RichTextOptions::VALID_PRESETS in Ruby):
 *
 *   minimal  — StarterKit, Placeholder, BubbleMenu, CharacterCount,
 *              Link, Underline, TextAlign
 *
 *   content  — minimal + Highlight, TextStyle, Color, BackgroundColor (via TextStyle),
 *              Typography, Image, CodeBlockLowlight, TaskList, TaskItem,
 *              Table, TableRow, TableCell, TableHeader
 *
 *   full     — content + Subscript, Superscript, FontFamily, Mention,
 *              YouTube, Audio, Details, DetailsContent, DetailsSummary,
 *              Mathematics, Emoji, TrailingNode, UniqueID, Focus,
 *              ListKeymap, FloatingMenu (when enabled)
 *
 * All imports are dynamic so that missing CDN pins result in a graceful
 * console warning rather than a hard parse-time error for extensions outside
 * the active preset.
 *
 * ── Framework-specific TipTap wrappers (NOT applicable to FlatPack) ─────────
 *
 * The following are React/Vue component wrappers provided by TipTap's UI
 * package. FlatPack uses vanilla JS + Stimulus and integrates the underlying
 * TipTap core extensions directly. These wrappers are documented here for
 * completeness but are never imported or used at runtime:
 *
 *   - @tiptap-ui/react / Drag Handle React   → use @tiptap/extension-drag-handle
 *   - @tiptap-ui/vue  / Drag Handle Vue       → use @tiptap/extension-drag-handle
 *
 * Open-source extensions documented but not always imported (may require Pro
 * plan or optional packages — see docs/components/inputs.md):
 *   InvisibleCharacters, TableOfContents, Selection, FileHandler
 */

// ── Helpers ──────────────────────────────────────────────────────────────────

/**
 * Safely dynamic-import a TipTap package.
 * Returns null and logs a warning if the module is not available.
 */
async function tryImport(specifier) {
  try {
    return await import(specifier)
  } catch (err) {
    console.warn(`[FlatPack TipTap] Could not load extension "${specifier}". ` +
      "Ensure it is pinned in config/importmap.rb or installed via npm.", err)
    return null
  }
}

// ── Extension builders ────────────────────────────────────────────────────────

/**
 * Builds the minimal-preset extension array.
 * All extensions here are required for the default rich text experience.
 */
async function buildMinimalExtensions(config) {
  const { StarterKit }           = await import("@tiptap/starter-kit")
  const { Placeholder }          = await import("@tiptap/extension-placeholder")
  const { CharacterCount }       = await import("@tiptap/extension-character-count")
  const { Link }                 = await import("@tiptap/extension-link")
  const { Underline }            = await import("@tiptap/extension-underline")
  const { TextAlign }            = await import("@tiptap/extension-text-align")

  const preset = config.opts?.preset || "minimal"
  const isContentOrFull = preset === "content" || preset === "full"
  const isFullWithCollab = preset === "full" && config.opts?.collaboration

  const extensions = [
    StarterKit.configure({
      // Disable CodeBlock when CodeBlockLowlight will be added (content/full)
      // to prevent "extension already registered" errors.
      codeBlock: isContentOrFull ? false : {},
      // Disable History when Collaboration is used (full preset with collab),
      // as Collaboration provides its own undo/redo.
      history: isFullWithCollab ? false : {},
    }),

    Placeholder.configure({
      placeholder: config.placeholder || "Start writing…",
    }),

    Link.configure({
      openOnClick:       false,   // prevent navigation inside editor
      autolink:          true,
      HTMLAttributes:    { rel: "noopener noreferrer", target: null },
    }),

    Underline,

    TextAlign.configure({
      types: ["heading", "paragraph"],
    }),
  ]

  // CharacterCount — included if enabled in options
  if (config.opts.character_count) {
    const maxChars = config.opts.max_characters || undefined
    extensions.push(
      maxChars
        ? CharacterCount.configure({ limit: maxChars })
        : CharacterCount
    )
  }

  // BubbleMenu — uses TipTap's positioning engine with a Ruby-rendered container
  if (config.opts.bubble_menu && config.bubbleMenuElement) {
    const { BubbleMenu } = await import("@tiptap/extension-bubble-menu")
    extensions.push(
      BubbleMenu.configure({
        element:      config.bubbleMenuElement,
        tippyOptions: { duration: 120, placement: "top" },
        // Show bubble menu on text selections (not node selections like images)
        shouldShow: ({ editor, view, state, oldState, from, to }) => {
          return from !== to && !editor.isActive("image")
        },
      })
    )
  }

  // FloatingMenu — shown at empty paragraphs; only included if enabled
  if (config.opts.floating_menu && config.floatingMenuElement) {
    const { FloatingMenu } = await import("@tiptap/extension-floating-menu")
    extensions.push(
      FloatingMenu.configure({
        element:      config.floatingMenuElement,
        tippyOptions: { duration: 120, placement: "left" },
      })
    )
  }

  return extensions
}

/**
 * Builds the content-preset extension array (superset of minimal).
 */
async function buildContentExtensions(config) {
  const base = await buildMinimalExtensions(config)

  const [
    highlightMod,
    textStyleMod,
    colorMod,
    typographyMod,
    imageMod,
    codeLowlightMod,
    taskListMod,
    taskItemMod,
    tableMod,
    tableRowMod,
    tableCellMod,
    tableHeaderMod,
  ] = await Promise.all([
    tryImport("@tiptap/extension-highlight"),
    tryImport("@tiptap/extension-text-style"),
    tryImport("@tiptap/extension-color"),
    tryImport("@tiptap/extension-typography"),
    tryImport("@tiptap/extension-image"),
    tryImport("@tiptap/extension-code-block-lowlight"),
    tryImport("@tiptap/extension-task-list"),
    tryImport("@tiptap/extension-task-item"),
    tryImport("@tiptap/extension-table"),
    tryImport("@tiptap/extension-table-row"),
    tryImport("@tiptap/extension-table-cell"),
    tryImport("@tiptap/extension-table-header"),
  ])

  const additions = []

  if (highlightMod)     additions.push(highlightMod.Highlight.configure({ multicolor: true }))
  if (textStyleMod)     additions.push(textStyleMod.TextStyle)
  if (colorMod && textStyleMod) additions.push(colorMod.Color)
  if (typographyMod)    additions.push(typographyMod.Typography)
  if (imageMod)         additions.push(imageMod.Image.configure({ inline: false, allowBase64: false }))
  if (codeLowlightMod)  additions.push(codeLowlightMod.CodeBlockLowlight)
  if (taskListMod)      additions.push(taskListMod.TaskList)
  if (taskItemMod)      additions.push(taskItemMod.TaskItem.configure({ nested: true }))

  // Table extensions — all four must be present together
  if (tableMod && tableRowMod && tableCellMod && tableHeaderMod) {
    // tableHeaderMod uses .TableHeader export
    additions.push(
      tableMod.Table.configure({ resizable: true }),
      tableRowMod.TableRow,
      tableCellMod.TableCell,
      tableHeaderMod.TableHeader,
    )
  }

  return [...base, ...additions]
}

/**
 * Builds the full-preset extension array (superset of content).
 */
async function buildFullExtensions(config) {
  const base = await buildContentExtensions(config)

  const [
    subscriptMod,
    superscriptMod,
    fontFamilyMod,
    mentionMod,
    youtubeMod,
    audioMod,
    detailsMod,
    detailsContentMod,
    detailsSummaryMod,
    trailingNodeMod,
    uniqueIdMod,
    focusMod,
    listKeymapMod,
    collaborationMod,
    collaborationCursorMod,
    dragHandleMod,
    listKitmapMod,
    // Note: the packages below may require TipTap Pro or optional dependencies.
    // They are included here for full-preset support. If unavailable, they are
    // silently skipped (tryImport returns null).
    mathematicsMod,
    emojiMod,
    invisibleCharsMod,
    tableOfContentsMod,
  ] = await Promise.all([
    tryImport("@tiptap/extension-subscript"),
    tryImport("@tiptap/extension-superscript"),
    tryImport("@tiptap/extension-font-family"),
    tryImport("@tiptap/extension-mention"),
    tryImport("@tiptap/extension-youtube"),
    tryImport("@tiptap/extension-audio"),
    tryImport("@tiptap/extension-details"),
    tryImport("@tiptap/extension-details-content"),
    tryImport("@tiptap/extension-details-summary"),
    tryImport("@tiptap/extension-trailing-node"),
    tryImport("@tiptap/extension-unique-id"),
    tryImport("@tiptap/extension-focus"),
    tryImport("@tiptap/extension-list-keymap"),
    tryImport("@tiptap/extension-collaboration"),
    tryImport("@tiptap/extension-collaboration-cursor"),
    // Drag Handle — vanilla JS core. React/Vue wrappers from @tiptap-ui are
    // NOT used; FlatPack wires drag-handle through Stimulus instead.
    tryImport("@tiptap/extension-drag-handle"),
    tryImport("@tiptap/extension-list-keymap"),
    // Optional/Pro packages — graceful skip if unavailable
    tryImport("@tiptap/extension-mathematics"),
    tryImport("@tiptap/extension-emoji"),
    tryImport("@tiptap/extension-invisible-characters"),
    tryImport("@tiptap/extension-table-of-contents"),
  ])

  const additions = []

  if (subscriptMod)     additions.push(subscriptMod.Subscript)
  if (superscriptMod)   additions.push(superscriptMod.Superscript)
  if (fontFamilyMod)    additions.push(fontFamilyMod.FontFamily)

  if (mentionMod) {
    const mentionConfig = typeof config.opts.mentions === "object"
      ? config.opts.mentions
      : {}
    additions.push(
      mentionMod.Mention.configure({
        HTMLAttributes: { class: "flat-pack-richtext-mention" },
        suggestion:     mentionConfig.suggestion || {},
      })
    )
  }

  if (youtubeMod) additions.push(youtubeMod.Youtube.configure({ controls: true }))
  if (audioMod)   additions.push(audioMod.Audio)

  if (detailsMod && detailsContentMod && detailsSummaryMod) {
    additions.push(
      detailsMod.Details,
      detailsContentMod.DetailsContent,
      detailsSummaryMod.DetailsSummary,
    )
  }

  if (trailingNodeMod) additions.push(trailingNodeMod.TrailingNode)
  if (uniqueIdMod)     additions.push(uniqueIdMod.UniqueID.configure({ types: ["heading", "paragraph"] }))
  if (focusMod)        additions.push(focusMod.Focus.configure({ className: "flat-pack-richtext-focus", mode: "all" }))
  if (listKeymapMod)   additions.push(listKeymapMod.ListKeymap)

  // Collaboration — requires an external Y.js provider; enable when configured
  const collabConfig = typeof config.opts.collaboration === "object"
    ? config.opts.collaboration
    : null
  if (collaborationMod && collabConfig?.provider) {
    additions.push(collaborationMod.Collaboration.configure({ document: collabConfig.ydoc }))
    if (collaborationCursorMod && collabConfig.provider) {
      additions.push(
        collaborationCursorMod.CollaborationCursor.configure({
          provider: collabConfig.provider,
          user:     collabConfig.user || { name: "Anonymous", color: "#6366f1" },
        })
      )
    }
  }

  // Drag Handle — vanilla JS; React/Vue wrappers not used (see file header)
  if (dragHandleMod) additions.push(dragHandleMod.DragHandle)

  // Optional packages (may be Pro or require extra deps)
  if (mathematicsMod)      additions.push(mathematicsMod.Mathematics)
  if (emojiMod)            additions.push(emojiMod.Emoji)
  if (invisibleCharsMod)   additions.push(invisibleCharsMod.InvisibleCharacters)
  if (tableOfContentsMod)  additions.push(tableOfContentsMod.TableOfContents)

  return [...base, ...additions]
}

// ── Public API ────────────────────────────────────────────────────────────────

/**
 * Build the TipTap extension array based on config.opts.preset and options.
 *
 * @param {object} config
 * @param {object} config.opts            - Rich text options (from Ruby)
 * @param {string} config.placeholder     - Placeholder text
 * @param {Element|null} config.bubbleMenuElement   - DOM element for bubble menu
 * @param {Element|null} config.floatingMenuElement - DOM element for floating menu
 * @returns {Promise<Extension[]>}
 */
export async function buildExtensions(config) {
  const preset = config.opts.preset || "minimal"

  switch (preset) {
    case "full":    return buildFullExtensions(config)
    case "content": return buildContentExtensions(config)
    case "minimal":
    default:        return buildMinimalExtensions(config)
  }
}
