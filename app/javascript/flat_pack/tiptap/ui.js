const activeStateCheckers = {
  bold: (editor) => editor.isActive("bold"),
  italic: (editor) => editor.isActive("italic"),
  underline: (editor) => editor.isActive("underline"),
  strike: (editor) => editor.isActive("strike"),
  code: (editor) => editor.isActive("code"),
  highlight: (editor) => editor.isActive("highlight"),
  heading: (editor) => editor.isActive("heading", { level: 2 }),
  blockquote: (editor) => editor.isActive("blockquote"),
  bullet_list: (editor) => editor.isActive("bulletList"),
  ordered_list: (editor) => editor.isActive("orderedList"),
  task_list: (editor) => editor.isActive("taskList"),
  link: (editor) => editor.isActive("link"),
  table: (editor) => editor.isActive("table"),
  align_left: (editor) => editor.isActive({ textAlign: "left" }),
  align_center: (editor) => editor.isActive({ textAlign: "center" }),
  align_right: (editor) => editor.isActive({ textAlign: "right" })
}

const commands = {
  bold: (editor) => editor.chain().focus().toggleBold().run(),
  italic: (editor) => editor.chain().focus().toggleItalic().run(),
  underline: (editor) => editor.chain().focus().toggleUnderline().run(),
  strike: (editor) => editor.chain().focus().toggleStrike().run(),
  code: (editor) => editor.chain().focus().toggleCode().run(),
  highlight: (editor) => editor.chain().focus().toggleHighlight().run(),
  heading: (editor) => editor.chain().focus().toggleHeading({ level: 2 }).run(),
  blockquote: (editor) => editor.chain().focus().toggleBlockquote().run(),
  bullet_list: (editor) => editor.chain().focus().toggleBulletList().run(),
  ordered_list: (editor) => editor.chain().focus().toggleOrderedList().run(),
  task_list: (editor) => editor.chain().focus().toggleTaskList().run(),
  table: (editor) => editor.chain().focus().insertTable({ rows: 3, cols: 3, withHeaderRow: true }).run(),
  image: (editor) => {
    const source = window.prompt("Image URL")
    if (!source) return false
    return editor.chain().focus().setImage({ src: source }).run()
  },
  link: (editor) => {
    const previous = editor.getAttributes("link").href || ""
    const href = window.prompt("Link URL", previous)
    if (href === null) return false
    if (href.trim() === "") {
      return editor.chain().focus().unsetLink().run()
    }

    return editor.chain().focus().extendMarkRange("link").setLink({ href }).run()
  },
  undo: (editor) => editor.chain().focus().undo().run(),
  redo: (editor) => editor.chain().focus().redo().run(),
  align_left: (editor) => editor.chain().focus().setTextAlign("left").run(),
  align_center: (editor) => editor.chain().focus().setTextAlign("center").run(),
  align_right: (editor) => editor.chain().focus().setTextAlign("right").run(),
  color: (editor) => {
    const color = window.prompt("Text color", "#1f2937")
    if (!color) return false
    return editor.chain().focus().setColor(color).run()
  },
  background_color: (editor) => {
    const color = window.prompt("Highlight color", "#fde68a")
    if (!color) return false
    if (typeof editor.chain().focus().setBackgroundColor === "function") {
      return editor.chain().focus().setBackgroundColor(color).run()
    }

    return editor.chain().focus().toggleHighlight({ color }).run()
  }
}

export function runCommand(editor, command) {
  const handler = commands[command]
  if (!handler) return false

  return handler(editor)
}

export function refreshToolbarState(scope, editor, disabled = false) {
  if (!scope) return

  scope.querySelectorAll("[data-flat-pack--tiptap-command]").forEach((button) => {
    const command = button.dataset.flatPackTiptapCommand
    const active = activeStateCheckers[command]?.(editor) || false

    button.disabled = disabled
    button.dataset.active = active ? "true" : "false"
    button.classList.toggle("bg-[var(--color-primary)]", active)
    button.classList.toggle("text-[var(--color-primary-text)]", active)
  })
}

export function syncSubmissionField(editor, input, format) {
  if (!input) return

  input.value = format === "html"
    ? editor.getHTML()
    : JSON.stringify(editor.getJSON())
}

export function updateCharacterCount(editor, countTarget, maxCharacters) {
  if (!countTarget) return

  const count = editor.storage?.characterCount?.characters?.() ?? editor.getText().length
  const hasMax = Number.isFinite(maxCharacters)
  const outOfBounds = hasMax && count > maxCharacters

  countTarget.textContent = hasMax ? `${count}/${maxCharacters} characters` : `${count} characters`
  countTarget.classList.toggle("text-[var(--color-warning-border)]", outOfBounds)
  countTarget.classList.toggle("text-[var(--surface-muted-content-color)]", !outOfBounds)
}
