let runtimePromise

const STARTER_KIT_KEYS = new Set([
  "bold",
  "code",
  "italic",
  "strike",
  "blockquote",
  "bullet_list",
  "ordered_list",
  "list_item",
  "document",
  "hard_break",
  "heading",
  "horizontal_rule",
  "paragraph",
  "text",
  "dropcursor",
  "gapcursor",
  "undo_redo"
])

const LIST_KIT_KEYS = new Set(["bullet_list", "ordered_list", "list_item", "task_item", "task_list"])
const TABLE_KIT_KEYS = new Set(["table", "table_row", "table_header", "table_cell"])
const TEXT_STYLE_KIT_KEYS = new Set(["text_style", "color", "background_color", "font_family", "font_size", "line_height"])

export async function loadTipTapRuntime() {
  if (!runtimePromise) {
    runtimePromise = Promise.all([
      import("@tiptap/core"),
      import("@tiptap/starter-kit"),
      import("@tiptap/extensions"),
      import("lowlight")
    ]).then(([core, starterKit, extensions, lowlight]) => ({
      Editor: core.Editor,
      StarterKit: starterKit.default || starterKit,
      extensions,
      lowlight
    }))
  }

  return runtimePromise
}

function extensionExport(runtime, ...names) {
  for (const name of names) {
    if (runtime.extensions[name]) return runtime.extensions[name]
  }

  return null
}

function configureIfPossible(Extension, value, optionsBuilder) {
  if (!Extension) return null
  if (typeof Extension.configure !== "function") return Extension

  return Extension.configure(optionsBuilder?.(value) ?? {})
}

function starterKitOptions(config) {
  return {
    bold: config.extensions.bold === false ? false : undefined,
    italic: config.extensions.italic === false ? false : undefined,
    strike: config.extensions.strike === false ? false : undefined,
    code: config.extensions.code === false ? false : undefined,
    blockquote: config.extensions.blockquote === false ? false : undefined,
    bulletList: config.extensions.bullet_list === false ? false : undefined,
    orderedList: config.extensions.ordered_list === false ? false : undefined,
    listItem: config.extensions.list_item === false ? false : undefined,
    document: config.extensions.document === false ? false : undefined,
    hardBreak: config.extensions.hard_break === false ? false : undefined,
    heading: config.extensions.heading === false ? false : undefined,
    horizontalRule: config.extensions.horizontal_rule === false ? false : undefined,
    paragraph: config.extensions.paragraph === false ? false : undefined,
    text: config.extensions.text === false ? false : undefined,
    dropcursor: config.extensions.dropcursor === false ? false : undefined,
    gapcursor: config.extensions.gapcursor === false ? false : undefined,
    history: config.extensions.undo_redo === false ? false : undefined
  }
}

function resolveMentionItems(config) {
  const items = Array.isArray(config?.items) ? config.items : []

  return items.map((item) => {
    if (typeof item === "string") {
      return { id: item, label: item }
    }

    return {
      id: item.id || item.label || item.value,
      label: item.label || item.id || item.value
    }
  })
}

function lowlightAdapter(runtime) {
  if (typeof runtime.lowlight?.createLowlight !== "function") return null

  return runtime.lowlight.createLowlight(runtime.lowlight.common || {})
}

const REGISTRY = {
  starter_kit: {
    build: (runtime, _value, context) => runtime.StarterKit.configure(starterKitOptions(context.config))
  },
  placeholder: {
    build: (runtime, _value, context) => configureIfPossible(
      extensionExport(runtime, "Placeholder"),
      _value,
      () => ({ placeholder: context.config.placeholder || "" })
    )
  },
  bubble_menu: {
    build: (runtime, _value, context) => context.hasBubbleMenuTarget ? configureIfPossible(
      extensionExport(runtime, "BubbleMenu"),
      _value,
      () => ({ element: context.bubbleMenuTarget })
    ) : null
  },
  floating_menu: {
    build: (runtime, _value, context) => context.hasFloatingMenuTarget ? configureIfPossible(
      extensionExport(runtime, "FloatingMenu"),
      _value,
      () => ({ element: context.floatingMenuTarget })
    ) : null
  },
  character_count: {
    build: (runtime, _value, context) => configureIfPossible(
      extensionExport(runtime, "CharacterCount"),
      _value,
      () => context.hasMaxCharactersValue ? { limit: context.maxCharactersValue } : {}
    )
  },
  link: {
    build: (runtime) => configureIfPossible(
      extensionExport(runtime, "Link"),
      true,
      () => ({
        openOnClick: false,
        autolink: true,
        defaultProtocol: "https"
      })
    )
  },
  underline: { build: (runtime) => extensionExport(runtime, "Underline") },
  highlight: { build: (runtime) => extensionExport(runtime, "Highlight") },
  text_style: { build: (runtime) => extensionExport(runtime, "TextStyle") },
  text_align: {
    build: (runtime) => configureIfPossible(
      extensionExport(runtime, "TextAlign"),
      true,
      () => ({ types: ["heading", "paragraph"] })
    )
  },
  color: { build: (runtime) => extensionExport(runtime, "Color") },
  background_color: { build: (runtime) => extensionExport(runtime, "BackgroundColor") },
  typography: { build: (runtime) => extensionExport(runtime, "Typography") },
  list_kit: { build: (runtime) => extensionExport(runtime, "ListKit") },
  table_kit: {
    build: (runtime, value) => configureIfPossible(
      extensionExport(runtime, "TableKit"),
      value,
      (settings) => settings && settings !== true ? settings : {}
    )
  },
  image: {
    build: (runtime) => configureIfPossible(
      extensionExport(runtime, "Image"),
      true,
      () => ({ allowBase64: false })
    )
  },
  code_block: { build: (runtime) => extensionExport(runtime, "CodeBlock") },
  code_block_lowlight: {
    build: (runtime) => {
      const Extension = extensionExport(runtime, "CodeBlockLowlight")
      const lowlight = lowlightAdapter(runtime)
      if (!Extension || !lowlight) return null

      return Extension.configure({ lowlight })
    }
  },
  task_list: { build: (runtime) => extensionExport(runtime, "TaskList") },
  task_item: { build: (runtime) => configureIfPossible(extensionExport(runtime, "TaskItem"), true, () => ({ nested: true })) },
  file_handler: {
    build: (runtime, _value, context) => configureIfPossible(
      extensionExport(runtime, "FileHandler"),
      _value,
      () => ({
        onDrop: (_editor, files, pos) => context.handleUploadFiles(files, { pos }),
        onPaste: (_editor, files) => context.handleUploadFiles(files)
      })
    )
  },
  text_style_kit: { build: (runtime) => extensionExport(runtime, "TextStyleKit") },
  font_family: { build: (runtime) => extensionExport(runtime, "FontFamily") },
  font_size: { build: (runtime) => extensionExport(runtime, "FontSize") },
  line_height: { build: (runtime) => extensionExport(runtime, "LineHeight") },
  mention: {
    build: (runtime, value) => {
      const Extension = extensionExport(runtime, "Mention")
      if (!Extension) return null

      const items = resolveMentionItems(value)
      const suggestionLimit = Number(value?.suggestion_limit || 5)

      return Extension.configure({
        HTMLAttributes: { class: "flat-pack-rich-text-mention" },
        suggestion: {
          char: value?.trigger || "@",
          items: ({ query }) => items
            .filter((item) => item.label.toLowerCase().includes(query.toLowerCase()))
            .slice(0, suggestionLimit)
        }
      })
    }
  },
  mathematics: { build: (runtime) => extensionExport(runtime, "Mathematics") },
  emoji: { build: (runtime) => extensionExport(runtime, "Emoji") },
  audio: { build: (runtime) => extensionExport(runtime, "Audio") },
  youtube: { build: (runtime) => extensionExport(runtime, "Youtube", "YouTube") },
  twitch: { build: (runtime) => extensionExport(runtime, "Twitch") },
  details: { build: (runtime) => extensionExport(runtime, "Details") },
  details_content: { build: (runtime) => extensionExport(runtime, "DetailsContent") },
  details_summary: { build: (runtime) => extensionExport(runtime, "DetailsSummary") },
  table_of_contents: { build: (runtime) => extensionExport(runtime, "TableOfContents") },
  collaboration: {
    build: (runtime, value, context) => {
      const Extension = extensionExport(runtime, "Collaboration")
      if (!Extension) return null

      const document = context.resolveRuntimeReference(value?.document_key)
      if (!document) return null

      return Extension.configure({ document })
    }
  },
  collaboration_caret: {
    build: (runtime, value, context) => {
      const Extension = extensionExport(runtime, "CollaborationCaret", "CollaborationCursor")
      if (!Extension) return null

      const provider = context.resolveRuntimeReference(value?.provider_key)
      if (!provider) return null

      return Extension.configure({
        provider,
        user: {
          name: value?.user_name || "Collaborator",
          color: value?.user_color || "#6366f1"
        }
      })
    }
  },
  drag_handle: { build: (runtime) => extensionExport(runtime, "DragHandle") },
  invisible_characters: { build: (runtime) => extensionExport(runtime, "InvisibleCharacters") },
  unique_id: { build: (runtime) => extensionExport(runtime, "UniqueID", "UniqueId") },
  focus: { build: (runtime) => extensionExport(runtime, "Focus") },
  selection: { build: (runtime) => extensionExport(runtime, "Selection") },
  trailing_node: { build: (runtime) => extensionExport(runtime, "TrailingNode") },
  gapcursor: { build: (runtime) => extensionExport(runtime, "Gapcursor", "GapCursor") },
  dropcursor: { build: (runtime) => extensionExport(runtime, "Dropcursor", "DropCursor") },
  list_keymap: { build: (runtime) => extensionExport(runtime, "ListKeymap", "ListKeyMap") },
  bold: { build: (runtime) => extensionExport(runtime, "Bold") },
  code: { build: (runtime) => extensionExport(runtime, "Code") },
  italic: { build: (runtime) => extensionExport(runtime, "Italic") },
  strike: { build: (runtime) => extensionExport(runtime, "Strike") },
  subscript: { build: (runtime) => extensionExport(runtime, "Subscript") },
  superscript: { build: (runtime) => extensionExport(runtime, "Superscript") },
  blockquote: { build: (runtime) => extensionExport(runtime, "Blockquote") },
  bullet_list: { build: (runtime) => extensionExport(runtime, "BulletList") },
  document: { build: (runtime) => extensionExport(runtime, "Document") },
  hard_break: { build: (runtime) => extensionExport(runtime, "HardBreak") },
  heading: { build: (runtime) => extensionExport(runtime, "Heading") },
  horizontal_rule: { build: (runtime) => extensionExport(runtime, "HorizontalRule") },
  list_item: { build: (runtime) => extensionExport(runtime, "ListItem") },
  ordered_list: { build: (runtime) => extensionExport(runtime, "OrderedList") },
  paragraph: { build: (runtime) => extensionExport(runtime, "Paragraph") },
  table: { build: (runtime) => extensionExport(runtime, "Table") },
  table_cell: { build: (runtime) => extensionExport(runtime, "TableCell") },
  table_header: { build: (runtime) => extensionExport(runtime, "TableHeader") },
  table_row: { build: (runtime) => extensionExport(runtime, "TableRow") },
  text: { build: (runtime) => extensionExport(runtime, "Text") }
}

function managedByKit(key, config) {
  if (config.extensions.starter_kit && STARTER_KIT_KEYS.has(key)) return true
  if (config.extensions.list_kit && LIST_KIT_KEYS.has(key)) return true
  if (config.extensions.table_kit && TABLE_KIT_KEYS.has(key)) return true
  if (config.extensions.text_style_kit && TEXT_STYLE_KIT_KEYS.has(key)) return true

  return false
}

export function buildExtensions(runtime, config, context) {
  const extensions = []

  Object.entries(config.extensions || {}).forEach(([key, value]) => {
    if (!value) return
    if (managedByKit(key, config) && !["starter_kit", "list_kit", "table_kit", "text_style_kit"].includes(key)) return

    const entry = REGISTRY[key]
    if (!entry) return

    try {
      const extension = entry.build(runtime, value, context)
      if (Array.isArray(extension)) {
        extension.filter(Boolean).forEach((item) => extensions.push(item))
      } else if (extension) {
        extensions.push(extension)
      }
    } catch (error) {
      console.warn(`[FlatPack::TipTap] Failed to initialize extension "${key}"`, error)
    }
  })

  return extensions
}
