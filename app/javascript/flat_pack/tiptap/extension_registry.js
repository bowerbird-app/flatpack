import StarterKit from "@tiptap/starter-kit"
import * as TiptapExtensions from "@tiptap/extensions"
import * as LowlightModule from "lowlight"

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

function extensionExport(...names) {
  for (const name of names) {
    if (TiptapExtensions[name]) return TiptapExtensions[name]
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

function lowlightAdapter() {
  if (typeof LowlightModule.createLowlight !== "function") return null

  return LowlightModule.createLowlight(LowlightModule.common || {})
}

const REGISTRY = {
  starter_kit: {
    build: (_value, context) => StarterKit.configure(starterKitOptions(context.config))
  },
  placeholder: {
    build: (_value, context) => configureIfPossible(
      extensionExport("Placeholder"),
      _value,
      () => ({ placeholder: context.config.placeholder || "" })
    )
  },
  bubble_menu: {
    build: (_value, context) => context.hasBubbleMenuTarget ? configureIfPossible(
      extensionExport("BubbleMenu"),
      _value,
      () => ({ element: context.bubbleMenuTarget })
    ) : null
  },
  floating_menu: {
    build: (_value, context) => context.hasFloatingMenuTarget ? configureIfPossible(
      extensionExport("FloatingMenu"),
      _value,
      () => ({ element: context.floatingMenuTarget })
    ) : null
  },
  character_count: {
    build: (_value, context) => configureIfPossible(
      extensionExport("CharacterCount"),
      _value,
      () => context.hasMaxCharactersValue ? { limit: context.maxCharactersValue } : {}
    )
  },
  link: {
    build: () => configureIfPossible(
      extensionExport("Link"),
      true,
      () => ({
        openOnClick: false,
        autolink: true,
        defaultProtocol: "https"
      })
    )
  },
  underline: { build: () => extensionExport("Underline") },
  highlight: { build: () => extensionExport("Highlight") },
  text_style: { build: () => extensionExport("TextStyle") },
  text_align: {
    build: () => configureIfPossible(
      extensionExport("TextAlign"),
      true,
      () => ({ types: ["heading", "paragraph"] })
    )
  },
  color: { build: () => extensionExport("Color") },
  background_color: { build: () => extensionExport("BackgroundColor") },
  typography: { build: () => extensionExport("Typography") },
  list_kit: { build: () => extensionExport("ListKit") },
  table_kit: {
    build: (value) => configureIfPossible(
      extensionExport("TableKit"),
      value,
      (settings) => settings && settings !== true ? settings : {}
    )
  },
  image: {
    build: () => configureIfPossible(
      extensionExport("Image"),
      true,
      () => ({ allowBase64: false })
    )
  },
  code_block: { build: () => extensionExport("CodeBlock") },
  code_block_lowlight: {
    build: () => {
      const Extension = extensionExport("CodeBlockLowlight")
      const lowlight = lowlightAdapter()
      if (!Extension || !lowlight) return null

      return Extension.configure({ lowlight })
    }
  },
  task_list: { build: () => extensionExport("TaskList") },
  task_item: { build: () => configureIfPossible(extensionExport("TaskItem"), true, () => ({ nested: true })) },
  file_handler: {
    build: (_value, context) => configureIfPossible(
      extensionExport("FileHandler"),
      _value,
      () => ({
        onDrop: (_editor, files, pos) => context.handleUploadFiles(files, { pos }),
        onPaste: (_editor, files) => context.handleUploadFiles(files)
      })
    )
  },
  text_style_kit: { build: () => extensionExport("TextStyleKit") },
  font_family: { build: () => extensionExport("FontFamily") },
  font_size: { build: () => extensionExport("FontSize") },
  line_height: { build: () => extensionExport("LineHeight") },
  mention: {
    build: (value) => {
      const Extension = extensionExport("Mention")
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
  mathematics: { build: () => extensionExport("Mathematics") },
  emoji: { build: () => extensionExport("Emoji") },
  audio: { build: () => extensionExport("Audio") },
  youtube: { build: () => extensionExport("Youtube", "YouTube") },
  twitch: { build: () => extensionExport("Twitch") },
  details: { build: () => extensionExport("Details") },
  details_content: { build: () => extensionExport("DetailsContent") },
  details_summary: { build: () => extensionExport("DetailsSummary") },
  table_of_contents: { build: () => extensionExport("TableOfContents") },
  collaboration: {
    build: (value, context) => {
      const Extension = extensionExport("Collaboration")
      if (!Extension) return null

      const document = context.resolveRuntimeReference(value?.document_key)
      if (!document) return null

      return Extension.configure({ document })
    }
  },
  collaboration_caret: {
    build: (value, context) => {
      const Extension = extensionExport("CollaborationCaret", "CollaborationCursor")
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
  drag_handle: { build: () => extensionExport("DragHandle") },
  invisible_characters: { build: () => extensionExport("InvisibleCharacters") },
  unique_id: { build: () => extensionExport("UniqueID", "UniqueId") },
  focus: { build: () => extensionExport("Focus") },
  selection: { build: () => extensionExport("Selection") },
  trailing_node: { build: () => extensionExport("TrailingNode") },
  gapcursor: { build: () => extensionExport("Gapcursor", "GapCursor") },
  dropcursor: { build: () => extensionExport("Dropcursor", "DropCursor") },
  list_keymap: { build: () => extensionExport("ListKeymap", "ListKeyMap") },
  bold: { build: () => extensionExport("Bold") },
  code: { build: () => extensionExport("Code") },
  italic: { build: () => extensionExport("Italic") },
  strike: { build: () => extensionExport("Strike") },
  subscript: { build: () => extensionExport("Subscript") },
  superscript: { build: () => extensionExport("Superscript") },
  blockquote: { build: () => extensionExport("Blockquote") },
  bullet_list: { build: () => extensionExport("BulletList") },
  document: { build: () => extensionExport("Document") },
  hard_break: { build: () => extensionExport("HardBreak") },
  heading: { build: () => extensionExport("Heading") },
  horizontal_rule: { build: () => extensionExport("HorizontalRule") },
  list_item: { build: () => extensionExport("ListItem") },
  ordered_list: { build: () => extensionExport("OrderedList") },
  paragraph: { build: () => extensionExport("Paragraph") },
  table: { build: () => extensionExport("Table") },
  table_cell: { build: () => extensionExport("TableCell") },
  table_header: { build: () => extensionExport("TableHeader") },
  table_row: { build: () => extensionExport("TableRow") },
  text: { build: () => extensionExport("Text") }
}

function managedByKit(key, config) {
  if (config.extensions.starter_kit && STARTER_KIT_KEYS.has(key)) return true
  if (config.extensions.list_kit && LIST_KIT_KEYS.has(key)) return true
  if (config.extensions.table_kit && TABLE_KIT_KEYS.has(key)) return true
  if (config.extensions.text_style_kit && TEXT_STYLE_KIT_KEYS.has(key)) return true

  return false
}

export function buildExtensions(config, context) {
  const extensions = []

  Object.entries(config.extensions || {}).forEach(([key, value]) => {
    if (!value) return
    if (managedByKit(key, config) && !["starter_kit", "list_kit", "table_kit", "text_style_kit"].includes(key)) return

    const entry = REGISTRY[key]
    if (!entry) return

    try {
      const extension = entry.build(value, context)
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

export function supportedExtensionKeys() {
  return Object.keys(REGISTRY)
}
