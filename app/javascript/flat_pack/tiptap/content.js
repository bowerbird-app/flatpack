const EMPTY_DOCUMENT = {
  type: "doc",
  content: [{ type: "paragraph" }]
}

function cloneEmptyDocument() {
  return JSON.parse(JSON.stringify(EMPTY_DOCUMENT))
}

export function parseInitialContent(rawValue, format) {
  if (format === "html") {
    return rawValue?.trim().length ? rawValue : "<p></p>"
  }

  if (!rawValue?.trim().length) {
    return cloneEmptyDocument()
  }

  try {
    return JSON.parse(rawValue)
  } catch (_error) {
    return buildPlainTextDocument(rawValue)
  }
}

export function buildPlainTextDocument(text) {
  if (!text?.trim().length) {
    return cloneEmptyDocument()
  }

  return {
    type: "doc",
    content: [
      {
        type: "paragraph",
        content: [{ type: "text", text }]
      }
    ]
  }
}

export function serializeEditorContent(editor, format) {
  return format === "html" ? editor.getHTML() : JSON.stringify(editor.getJSON())
}

export function editorCharacterCount(editor) {
  return editor?.storage?.characterCount?.characters?.() ?? editor?.getText?.().length ?? 0
}

export function editorIsEmpty(editor) {
  if (!editor) return true
  if (typeof editor.isEmpty === "boolean") return editor.isEmpty

  return editor.getText().trim().length === 0
}
