import { flatPackCopy } from "flat_pack/copy"

const BLOCK_COMMANDS = ["h1", "h2", "h3", "h4", "h5", "h6", "blockquote", "p"]
const TOGGLE_COMMANDS = ["bold", "italic", "underline", "strikeThrough"]
const BLOCK_STATE_COMMANDS = ["h1", "h2", "h3", "blockquote"]

export function keepSelection(event) {
  event.preventDefault()
}

export function showToolbar(toolbar) {
  if (!toolbar) return
  toolbar.hidden = false
  toolbar.style.display = "flex"
}

export function hideToolbar(toolbar) {
  if (!toolbar) return
  toolbar.hidden = true
  toolbar.style.display = "none"
}

export function placeToolbarAboveRect(toolbar, rect) {
  if (!toolbar || !rect) return
  const tw = toolbar.getBoundingClientRect().width
  const th = toolbar.getBoundingClientRect().height
  toolbar.style.left = `${Math.max(4, rect.left + rect.width / 2 - tw / 2)}px`
  toolbar.style.top = `${Math.max(4, rect.top - th - 8)}px`
}

export function applyFormat(command, { editorEl, selectedImage = null } = {}) {
  if (BLOCK_COMMANDS.includes(command)) {
    const current = document.queryCommandValue("formatBlock").toLowerCase()
    document.execCommand("formatBlock", false, current === command ? "p" : command)
  } else if (command === "link") {
    applyLink(selectedImage)
  } else {
    document.execCommand(command, false, null)
  }
  editorEl?.focus()
}

function applyLink(selectedImage) {
  if (selectedImage) {
    const existingAnchor = selectedImage.closest("a")
    if (existingAnchor) {
      const url = prompt(flatPackCopy("content_editor.edit_url"), existingAnchor.href)
      if (url === "") {
        existingAnchor.replaceWith(selectedImage)
      } else if (url !== null) {
        existingAnchor.href = url
      }
    } else {
      const url = prompt(flatPackCopy("content_editor.enter_url"), "https://")
      if (url) {
        const anchor = document.createElement("a")
        anchor.href = url
        selectedImage.replaceWith(anchor)
        anchor.appendChild(selectedImage)
      }
    }
    return
  }

  const anchor = document.getSelection()?.anchorNode?.parentElement?.closest("a")
  if (anchor) {
    const url = prompt(flatPackCopy("content_editor.edit_url"), anchor.href)
    if (url === "") document.execCommand("unlink", false, null)
    else if (url !== null) document.execCommand("createLink", false, url)
  } else {
    const url = prompt(flatPackCopy("content_editor.enter_url"), "https://")
    if (url) document.execCommand("createLink", false, url)
  }
}

export function syncToolbarActiveState(toolbar) {
  if (!toolbar) return
  const blockVal = document.queryCommandValue("formatBlock").toLowerCase()
  toolbar.querySelectorAll("[data-command]").forEach((button) => {
    const command = button.dataset.command
    let active = false
    if (TOGGLE_COMMANDS.includes(command)) {
      try { active = document.queryCommandState(command) } catch (_) {}
    } else if (BLOCK_STATE_COMMANDS.includes(command)) {
      active = blockVal === command
    }
    button.classList.toggle("is-active", active)
  })
}

export function updateToolbarFromSelection(toolbar, editorEl, { selectedImage = null } = {}) {
  const selection = document.getSelection()

  if (!selection || selection.isCollapsed || !editorEl?.contains(selection.anchorNode)) {
    if (!selectedImage) hideToolbar(toolbar)
    return { selectedImage }
  }

  const range = selection.getRangeAt(0)
  const rect = range.getBoundingClientRect()
  showToolbar(toolbar)
  syncToolbarActiveState(toolbar)
  placeToolbarAboveRect(toolbar, rect)
  return { selectedImage: null }
}

export function placeToolbarOnImage(toolbar, image) {
  if (!toolbar || !image) return
  const rect = image.getBoundingClientRect()
  showToolbar(toolbar)
  placeToolbarAboveRect(toolbar, rect)
}

export function placeCaretFromPoint(element, clientX, clientY) {
  if (!element) return
  const selection = document.getSelection()
  if (!selection) return

  if (document.caretPositionFromPoint) {
    const position = document.caretPositionFromPoint(clientX, clientY)
    if (position?.offsetNode && element.contains(position.offsetNode)) {
      const range = document.createRange()
      range.setStart(position.offsetNode, position.offset)
      range.collapse(true)
      selection.removeAllRanges()
      selection.addRange(range)
      return
    }
  }

  if (document.caretRangeFromPoint) {
    const range = document.caretRangeFromPoint(clientX, clientY)
    if (range && element.contains(range.startContainer)) {
      selection.removeAllRanges()
      selection.addRange(range)
    }
  }
}
