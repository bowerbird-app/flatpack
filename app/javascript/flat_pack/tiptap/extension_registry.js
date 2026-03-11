import StarterKit from "@tiptap/starter-kit"
import Placeholder from "@tiptap/extension-placeholder"
import CharacterCount from "@tiptap/extension-character-count"
import Link from "@tiptap/extension-link"
import Underline from "@tiptap/extension-underline"
import Highlight from "@tiptap/extension-highlight"
import TextStyle from "@tiptap/extension-text-style"
import Color from "@tiptap/extension-color"
import TextAlign from "@tiptap/extension-text-align"
import BubbleMenu from "@tiptap/extension-bubble-menu"
import FloatingMenu from "@tiptap/extension-floating-menu"
import TaskList from "@tiptap/extension-task-list"
import TaskItem from "@tiptap/extension-task-item"
import Image from "@tiptap/extension-image"
import Table from "@tiptap/extension-table"
import TableRow from "@tiptap/extension-table-row"
import TableHeader from "@tiptap/extension-table-header"
import TableCell from "@tiptap/extension-table-cell"

const esmBundle = (packageName) => `https://esm.sh/${packageName}?bundle`

const advancedRegistry = {
  audio: { packageName: "@tiptap/extension-audio" },
  code_block_lowlight: { packageName: "@tiptap/extension-code-block-lowlight" },
  collaboration: { packageName: "@tiptap/extension-collaboration" },
  collaboration_caret: { packageName: "@tiptap/extension-collaboration-caret" },
  details: { packageName: "@tiptap/extension-details" },
  details_content: { packageName: "@tiptap/extension-details-content" },
  details_summary: { packageName: "@tiptap/extension-details-summary" },
  drag_handle: { packageName: "@tiptap/extension-drag-handle" },
  dropcursor: { packageName: "@tiptap/extension-dropcursor" },
  file_handler: { packageName: "@tiptap/extension-file-handler" },
  focus: { packageName: "@tiptap/extension-focus" },
  font_family: { packageName: "@tiptap/extension-font-family" },
  font_size: { packageName: "@tiptap/extension-font-size" },
  gapcursor: { packageName: "@tiptap/extension-gapcursor" },
  invisible_characters: { packageName: "@tiptap/extension-invisible-characters" },
  line_height: { packageName: "@tiptap/extension-line-height" },
  list_keymap: { packageName: "@tiptap/extension-list-keymap" },
  mathematics: { packageName: "@tiptap/extension-mathematics" },
  mention: { packageName: "@tiptap/extension-mention" },
  selection: { packageName: "@tiptap/extension-selection" },
  subscript: { packageName: "@tiptap/extension-subscript" },
  superscript: { packageName: "@tiptap/extension-superscript" },
  table_of_contents: { packageName: "@tiptap/extension-table-of-contents" },
  trailing_node: { packageName: "@tiptap/extension-trailing-node" },
  twitch: { packageName: "@tiptap/extension-twitch" },
  typography: { packageName: "@tiptap/extension-typography" },
  unique_id: { packageName: "@tiptap/extension-unique-id" },
  youtube: { packageName: "@tiptap/extension-youtube" },
  emoji: { packageName: "@tiptap/extension-emoji" },
  background_color: { packageName: "@tiptap/extension-background-color" }
}

const staticRegistry = {
  starter_kit: () => StarterKit.configure({
    heading: { levels: [1, 2, 3] }
  }),
  placeholder: (config) => Placeholder.configure({
    placeholder: config.placeholder || "Start writing…"
  }),
  character_count: (config) => CharacterCount.configure({
    limit: Number.isFinite(config.max_characters) ? config.max_characters : null
  }),
  link: () => Link.configure({
    openOnClick: false,
    autolink: true,
    defaultProtocol: "https"
  }),
  underline: () => Underline,
  highlight: () => Highlight.configure({ multicolor: true }),
  text_style: () => TextStyle,
  color: () => Color,
  text_align: () => TextAlign.configure({ types: ["heading", "paragraph"] }),
  bubble_menu: (_config, elements) => elements.bubbleMenu ? BubbleMenu.configure({ element: elements.bubbleMenu }) : null,
  floating_menu: (_config, elements) => elements.floatingMenu ? FloatingMenu.configure({ element: elements.floatingMenu }) : null,
  task_list: () => TaskList,
  task_item: () => TaskItem.configure({ nested: true }),
  image: () => Image,
  table: () => Table.configure({ resizable: true }),
  table_row: () => TableRow,
  table_header: () => TableHeader,
  table_cell: () => TableCell,
  table_kit: () => null,
  list_kit: () => null,
  list_keymap: () => null,
  undo_redo: () => null
}

function extensionEnabled(extensionConfig) {
  return extensionConfig !== false && extensionConfig !== null && extensionConfig !== undefined
}

function extensionOptions(extensionConfig) {
  return extensionConfig && typeof extensionConfig === "object" ? extensionConfig : {}
}

async function loadAdvancedExtension(key, config) {
  const definition = advancedRegistry[key]
  if (!definition) return null

  try {
    const module = await import(esmBundle(definition.packageName))
    const extension = module.default || module[key] || Object.values(module)[0]

    if (!extension) return null
    if (typeof extension.configure === "function") {
      return extension.configure(extensionOptions(config))
    }

    return extension
  } catch (error) {
    console.warn(`[FlatPack::TextArea] Unable to load TipTap extension ${key}`, error)
    return null
  }
}

export async function buildExtensions(config, elements = {}) {
  const extensions = []
  const configuredExtensions = config.extensions || {}
  const keys = Object.keys(configuredExtensions)

  for (const key of keys) {
    const extensionConfig = configuredExtensions[key]
    if (!extensionEnabled(extensionConfig)) continue

    if (staticRegistry[key]) {
      const extension = staticRegistry[key](config, elements)
      if (extension) extensions.push(extension)
      continue
    }

    const advancedExtension = await loadAdvancedExtension(key, extensionConfig)
    if (advancedExtension) extensions.push(advancedExtension)
  }

  if (!keys.includes("starter_kit")) {
    extensions.unshift(staticRegistry.starter_kit(config, elements))
  }

  return dedupeExtensions(extensions)
}

function dedupeExtensions(extensions) {
  const seen = new Set()

  return extensions.filter((extension) => {
    const name = extension?.name || extension?.config?.name || Math.random().toString(36)
    if (seen.has(name)) return false
    seen.add(name)
    return true
  })
}
