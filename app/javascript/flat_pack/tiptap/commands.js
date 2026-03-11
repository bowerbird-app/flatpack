function normalizeColor(value) {
  const trimmed = value?.trim()
  if (!trimmed) return null

  return /^#([0-9a-f]{3}|[0-9a-f]{6})$/i.test(trimmed) ? trimmed : null
}

export async function runCommand(editor, command, value, context = {}) {
  if (!editor) return false

  switch (command) {
    case "bold":
      return editor.chain().focus().toggleBold().run()
    case "italic":
      return editor.chain().focus().toggleItalic().run()
    case "underline":
      return editor.chain().focus().toggleUnderline().run()
    case "strike":
      return editor.chain().focus().toggleStrike().run()
    case "code":
      return editor.chain().focus().toggleCode().run()
    case "highlight":
      return editor.chain().focus().toggleHighlight().run()
    case "heading":
      return editor.chain().focus().toggleHeading({ level: Number(value || 2) }).run()
    case "blockquote":
      return editor.chain().focus().toggleBlockquote().run()
    case "bulletList":
      return editor.chain().focus().toggleBulletList().run()
    case "orderedList":
      return editor.chain().focus().toggleOrderedList().run()
    case "taskList":
      return editor.chain().focus().toggleTaskList().run()
    case "link": {
      const href = await context.promptForUrl?.("link", editor.getAttributes("link")?.href)
      if (href === null) {
        return false
      }

      if (href === "") {
        return editor.chain().focus().unsetLink().run()
      }

      return editor.chain().focus().extendMarkRange("link").setLink({ href }).run()
    }
    case "image": {
      const insertedByUpload = await context.pickAndInsertImage?.()
      if (insertedByUpload) return true

      const src = await context.promptForUrl?.("image")
      if (!src) return false

      return editor.chain().focus().setImage({ src }).run()
    }
    case "table":
      return editor.chain().focus().insertTable({ rows: 3, cols: 3, withHeaderRow: true }).run()
    case "undo":
      return editor.chain().focus().undo().run()
    case "redo":
      return editor.chain().focus().redo().run()
    case "textAlign":
      return editor.chain().focus().setTextAlign(value || "left").run()
    case "color": {
      const color = normalizeColor(await context.promptForColor?.("text"))
      if (!color) return false

      return editor.chain().focus().setColor(color).run()
    }
    case "backgroundColor": {
      const color = normalizeColor(await context.promptForColor?.("background"))
      if (!color) return false

      if (typeof editor.chain().focus().setBackgroundColor === "function") {
        return editor.chain().focus().setBackgroundColor(color).run()
      }

      if (typeof editor.chain().focus().setMark === "function") {
        return editor.chain().focus().setMark("textStyle", { backgroundColor: color }).run()
      }

      return false
    }
    default:
      return false
  }
}

function buttonState(editor, command, value) {
  if (!editor || typeof editor.isActive !== "function") {
    return false
  }

  switch (command) {
    case "bold":
    case "italic":
    case "underline":
    case "strike":
    case "code":
    case "highlight":
      return editor.isActive(command)
    case "heading":
      return editor.isActive("heading", { level: Number(value || 2) })
    case "blockquote":
      return editor.isActive("blockquote")
    case "bulletList":
      return editor.isActive("bulletList")
    case "orderedList":
      return editor.isActive("orderedList")
    case "taskList":
      return editor.isActive("taskList")
    case "link":
      return editor.isActive("link")
    case "textAlign":
      return editor.isActive({ textAlign: value || "left" })
    default:
      return false
  }
}

export function updateCommandButtons(container, editor, { disabled = false } = {}) {
  if (!container || !editor) return

  container.querySelectorAll("[data-flat-pack--tiptap-command]").forEach((button) => {
    const command = button.dataset.flatPackTiptapCommand
    const value = button.dataset.flatPackTiptapValue
    const active = buttonState(editor, command, value)

    button.setAttribute("aria-pressed", String(active))
    button.disabled = disabled
    button.classList.toggle("bg-[var(--surface-muted-background-color)]", active)
    button.classList.toggle("border-primary", active)
    button.classList.toggle("opacity-60", disabled)
  })
}
