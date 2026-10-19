/**
 * Clipboard primitives for flat-pack--clipboard.
 *
 * navigator.clipboard.writeText runs in a secure context. When that API is
 * missing, the page is insecure, or writeText rejects, writing falls back to
 * a hidden textarea and document.execCommand("copy").
 *
 * A share button can call navigator.share({ text }) first. When the browser
 * has no share sheet, call writeClipboardText(text). Resolve the same
 * text / target / anchor sources with readClipboardSource, then paint
 * data-fp-clipboard-state the way the copy button already does.
 */

export const CLIPBOARD_COPIED_EVENT = "flat-pack:clipboard:copied"
export const CLIPBOARD_ERROR_EVENT = "flat-pack:clipboard:error"

export async function writeClipboardText(text) {
  if (canUseAsyncClipboard()) {
    try {
      await navigator.clipboard.writeText(text)
      return true
    } catch {
      // writeText can reject even when the method exists. Fall through.
    }
  }

  return writeWithHiddenTextarea(text)
}

export function readClipboardSource({ source, text, target, href, root, location } = {}) {
  if (source === "anchor") {
    const url = absoluteAnchorUrl(href, location)
    if (!url) return { status: "ignore", text: "", element: null }
    return { status: "ok", text: url, element: null }
  }

  if (source === "target") {
    const element = resolveCopyTarget(target, root)
    if (!element) return { status: "missing", text: "", element: null }
    return { status: "ok", text: textFromElement(element), element }
  }

  if (text == null) return { status: "missing", text: "", element: null }
  return { status: "ok", text: String(text), element: null }
}

export function absoluteAnchorUrl(href, location) {
  if (!href || !String(href).startsWith("#")) return null

  const base = location?.href
  if (!base) return null

  const url = new URL(base)
  url.hash = String(href).slice(1)
  return url.toString()
}

export function resolveCopyTarget(target, root = document) {
  const value = String(target || "").trim()
  if (!value) return null

  try {
    if (isSelector(value)) {
      return root?.querySelector?.(value) || document.querySelector(value)
    }

    const byId = document.getElementById(value)
    if (byId) return byId

    const escaped = cssEscape(value)
    return root?.querySelector?.(`#${escaped}`) || document.querySelector(`#${escaped}`)
  } catch {
    return null
  }
}

export function textFromElement(element) {
  if (!element) return ""

  const tag = String(element.tagName || "").toUpperCase()
  if (tag === "INPUT" || tag === "TEXTAREA" || tag === "SELECT") {
    return element.value == null ? "" : String(element.value)
  }

  return element.textContent == null ? "" : String(element.textContent)
}

function canUseAsyncClipboard() {
  return typeof navigator !== "undefined" &&
    !!navigator.clipboard &&
    typeof navigator.clipboard.writeText === "function" &&
    globalThis.isSecureContext !== false
}

function writeWithHiddenTextarea(text) {
  const textarea = document.createElement("textarea")
  textarea.value = text
  textarea.setAttribute("readonly", "")
  textarea.setAttribute("aria-hidden", "true")
  textarea.tabIndex = -1
  textarea.style.position = "fixed"
  textarea.style.top = "0"
  textarea.style.left = "0"
  textarea.style.width = "1px"
  textarea.style.height = "1px"
  textarea.style.padding = "0"
  textarea.style.border = "0"
  textarea.style.opacity = "0"
  textarea.style.pointerEvents = "none"

  document.body.appendChild(textarea)

  try {
    textarea.focus()
    textarea.select()
    if (typeof textarea.setSelectionRange === "function") {
      textarea.setSelectionRange(0, String(text).length)
    }

    return document.execCommand("copy")
  } catch {
    return false
  } finally {
    textarea.remove()
  }
}

function isSelector(value) {
  return value.startsWith("#") ||
    value.startsWith(".") ||
    value.startsWith("[") ||
    /[\s>+~]/.test(value)
}

function cssEscape(value) {
  if (globalThis.CSS?.escape) return CSS.escape(value)
  return String(value).replace(/[^a-zA-Z0-9_-]/g, (character) => `\\${character}`)
}
