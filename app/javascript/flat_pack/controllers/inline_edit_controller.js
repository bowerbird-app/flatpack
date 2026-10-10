import { Controller } from "@hotwired/stimulus"
import { flatPackCopy } from "flat_pack/copy"
import { prefersReducedMotion, motionDuration } from "controllers/flat_pack/reduced_motion"
import {
  applyFormat,
  hideToolbar,
  keepSelection as preventToolbarFocusLoss,
  placeCaretFromPoint,
  updateToolbarFromSelection
} from "controllers/flat_pack/exec_command_bubble"

const SAVED_HOLD_MS = 900

export default class extends Controller {
  static targets = ["surface", "field", "status", "spinner", "tick", "live", "bubble"]
  static values = {
    name: String,
    mode: { type: String, default: "text" },
    updateUrl: { type: String, default: "" },
    method: { type: String, default: "patch" },
    required: { type: Boolean, default: false },
    saveOnBlur: { type: Boolean, default: true },
    maxlength: { type: Number, default: 0 },
    label: { type: String, default: "" },
    placeholder: { type: String, default: "" }
  }

  #editing = false
  #saving = false
  #savedSnapshot = null
  #selectionHandler = null
  #savedHoldTimer = null
  #pointerActivated = false

  connect() {
    this.decorateSurface()
    this.syncEmpty()
    this.syncField()
  }

  disconnect() {
    this.teardownEditing({ restore: false })
    this.clearSavedHold()
  }

  get surface() {
    if (this.hasSurfaceTarget) return this.surfaceTarget
    return this.findSurface()
  }

  findSurface() {
    return this.element.querySelector("[data-inline-edit-target]")
      || this.element.querySelector("h1, h2, h3, h4, h5, h6")
      || this.element.querySelector("p")
      || this.element
  }

  decorateSurface() {
    const surface = this.surface
    if (!surface) return

    surface.classList.add("fp-inline-edit__surface")
    surface.setAttribute("data-flat-pack--inline-edit-target", "surface")
    surface.setAttribute("role", "textbox")
    surface.setAttribute("tabindex", surface.getAttribute("tabindex") || "0")
    surface.setAttribute("aria-label", this.labelValue)
    surface.setAttribute("data-placeholder", this.placeholderValue)
    if (this.modeValue !== "text") surface.setAttribute("aria-multiline", "true")
    if (this.requiredValue) surface.setAttribute("aria-required", "true")
    if (this.hasLiveTarget) surface.setAttribute("aria-describedby", this.liveTarget.id)
    if (this.modeValue !== "rich") surface.setAttribute("spellcheck", "false")
  }

  onClick(event) {
    if (event.target?.closest?.(".flat-pack-richtext-bubble-menu")) return
    if (!this.surface?.contains(event.target) && event.target !== this.surface) return

    this.#pointerActivated = true
    this.activate({ clientX: event.clientX, clientY: event.clientY })
  }

  onFocusIn(event) {
    if (!this.surface || !this.surface.contains(event.target) && event.target !== this.surface) return
    this.element.classList.add("is-focused")
  }

  onFocusOut(event) {
    if (this.element.contains(event.relatedTarget)) return
    this.element.classList.remove("is-focused")
    if (this.#editing && this.saveOnBlurValue) {
      this.commit()
    }
  }

  onKeydown(event) {
    if (event.target?.closest?.(".flat-pack-richtext-bubble-menu")) return
    if (!this.surface || (!this.surface.contains(event.target) && event.target !== this.surface)) return

    if (!this.#editing) {
      if (event.key === "Enter") {
        event.preventDefault()
        this.activate()
      }
      return
    }

    if (event.key === "Escape") {
      event.preventDefault()
      this.cancel()
      return
    }

    if (this.modeValue === "text") {
      if (event.key === "Enter") {
        event.preventDefault()
        this.commit()
      } else if (event.key === "Tab") {
        this.commit()
      }
      return
    }

    if ((event.metaKey || event.ctrlKey) && event.key === "Enter") {
      event.preventDefault()
      this.commit()
    }
  }

  keepSelection(event) {
    preventToolbarFocusLoss(event)
  }

  format(event) {
    applyFormat(event.currentTarget.dataset.command, { editorEl: this.surface })
    this.syncEmpty()
    this.syncField()
  }

  activate({ clientX, clientY } = {}) {
    if (this.#editing || this.#saving) return
    const surface = this.surface
    if (!surface) return

    this.#savedSnapshot = this.readValue()
    this.#editing = true
    this.element.classList.add("is-editing")
    this.element.classList.remove("is-error")
    surface.setAttribute("contenteditable", this.contentEditableValue())
    surface.setAttribute("aria-invalid", "false")
    this.clearLive()
    surface.focus()

    if (this.#pointerActivated && clientX != null && clientY != null) {
      placeCaretFromPoint(surface, clientX, clientY)
    }

    this.#pointerActivated = false
    this.bindPaste()
    this.bindInput()

    if (this.modeValue === "rich" && this.hasBubbleTarget) {
      this.#selectionHandler = () => {
        updateToolbarFromSelection(this.bubbleTarget, surface)
      }
      document.addEventListener("selectionchange", this.#selectionHandler)
    }
  }

  cancel() {
    const snapshot = this.#savedSnapshot
    this.writeValue(snapshot)
    this.teardownEditing({ restore: false })
    this.syncField(snapshot ?? "")
    this.syncEmpty()
    this.surface?.focus()
  }

  async commit() {
    if (!this.#editing || this.#saving) return

    const value = this.readValue()
    const validationError = this.validate(value)
    if (validationError) {
      this.fail(validationError, { revert: false })
      return
    }

    const detail = { name: this.nameValue, value, url: this.updateUrlValue || null }
    const saveEvent = this.dispatch("save", { prefix: "flat-pack:inline-edit", cancelable: true, detail })
    if (saveEvent.defaultPrevented) return

    this.syncField(value)

    if (!this.updateUrlValue) {
      this.#savedSnapshot = value
      this.succeed()
      return
    }

    this.#saving = true
    this.showSpinner()
    this.announce(flatPackCopy("inline_edit.saving"))

    try {
      const response = await this.saveRemote(value)
      if (!response.ok) {
        throw new Error(flatPackCopy("inline_edit.save_failed"))
      }
      await this.applyTurboStream(response)
      this.#savedSnapshot = value
      this.succeed()
      this.dispatch("saved", { prefix: "flat-pack:inline-edit", detail })
    } catch (error) {
      this.fail(error.message || flatPackCopy("inline_edit.save_failed"), { revert: true })
      this.dispatch("error", {
        prefix: "flat-pack:inline-edit",
        detail: { ...detail, message: error.message }
      })
    }
  }

  validate(value) {
    const empty = this.modeValue === "rich" ? this.plainText(value).trim() === "" : value.trim() === ""
    if (this.requiredValue && empty) return flatPackCopy("inline_edit.required")
    if (this.maxlengthValue > 0 && this.plainText(value).length > this.maxlengthValue) {
      return flatPackCopy("inline_edit.too_long")
    }
    return null
  }

  async saveRemote(value) {
    const csrfToken = document.querySelector("meta[name=csrf-token], meta[name='csrf-token']")?.content
    const body = new URLSearchParams()
    body.set(this.nameValue, value)
    const method = (this.methodValue || "patch").toLowerCase()
    if (method !== "post") body.set("_method", method)

    return fetch(this.updateUrlValue, {
      method: "POST",
      headers: {
        "X-CSRF-Token": csrfToken || "",
        Accept: "text/vnd.turbo-stream.html, text/html, application/json",
        "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8"
      },
      body,
      credentials: "same-origin"
    })
  }

  async applyTurboStream(response) {
    const contentType = response.headers.get("content-type") || ""
    if (!contentType.includes("turbo-stream")) return
    const html = await response.text()
    if (html && globalThis.Turbo?.renderStreamMessage) {
      globalThis.Turbo.renderStreamMessage(html)
    }
  }

  succeed() {
    this.#saving = false
    this.teardownEditing({ restore: false })
    this.showTick()
    this.announce(flatPackCopy("inline_edit.saved"))
    this.clearSavedHold()
    const hold = prefersReducedMotion() ? 0 : motionDuration("slow") || SAVED_HOLD_MS
    this.#savedHoldTimer = globalThis.setTimeout(() => {
      this.hideStatus()
      this.element.classList.remove("is-saved")
    }, hold || SAVED_HOLD_MS)
  }

  fail(message, { revert }) {
    this.#saving = false
    if (revert) this.writeValue(this.#savedSnapshot)
    this.teardownEditing({ restore: false })
    this.element.classList.add("is-error")
    this.hideStatus()
    this.announce(message)
    this.surface?.setAttribute("aria-invalid", "true")
    this.syncField()
    this.syncEmpty()
  }

  teardownEditing() {
    const surface = this.surface
    this.#editing = false
    this.element.classList.remove("is-editing")
    if (surface) {
      surface.removeAttribute("contenteditable")
      surface.removeEventListener("paste", this.boundPaste)
      surface.removeEventListener("input", this.boundInput)
    }
    if (this.#selectionHandler) {
      document.removeEventListener("selectionchange", this.#selectionHandler)
      this.#selectionHandler = null
    }
    if (this.hasBubbleTarget) hideToolbar(this.bubbleTarget)
  }

  bindPaste() {
    this.boundPaste = this.onPaste.bind(this)
    this.surface.addEventListener("paste", this.boundPaste)
  }

  bindInput() {
    this.boundInput = this.onInput.bind(this)
    this.surface.addEventListener("input", this.boundInput)
  }

  onPaste(event) {
    if (this.modeValue === "rich") return
    event.preventDefault()
    let text = event.clipboardData?.getData("text/plain") || ""
    if (this.modeValue === "text") text = text.replace(/[\r\n]+/g, " ")
    document.execCommand("insertText", false, text)
  }

  onInput() {
    if (this.modeValue === "text") {
      const text = this.surface.innerText.replace(/[\r\n]+/g, " ")
      if (text !== this.surface.innerText) this.surface.innerText = text
    }
    if (this.maxlengthValue > 0) {
      const text = this.plainText(this.readValue())
      if (text.length > this.maxlengthValue) {
        this.writeValue(this.truncate(this.readValue(), this.maxlengthValue))
      }
    }
    this.syncEmpty()
    this.syncField()
  }

  readValue() {
    const surface = this.surface
    if (!surface) return ""
    if (this.modeValue === "rich") return surface.innerHTML
    if (this.modeValue === "plain") return this.plainFromSurface(surface)
    return (surface.innerText || surface.textContent || "").replace(/[\r\n]+/g, " ")
  }

  writeValue(value) {
    const surface = this.surface
    if (!surface) return
    if (this.modeValue === "rich") {
      surface.innerHTML = value || ""
      return
    }
    const text = value || ""
    surface.textContent = text
    surface.innerText = text
  }

  plainFromSurface(surface) {
    return (surface.innerText || surface.textContent || "").replace(/\r\n/g, "\n")
  }

  plainText(value) {
    if (this.modeValue !== "rich") return value || ""
    const scratch = document.createElement("div")
    scratch.innerHTML = value || ""
    return scratch.textContent || ""
  }

  truncate(value, limit) {
    if (this.modeValue === "rich") return this.plainText(value).slice(0, limit)
    return (value || "").slice(0, limit)
  }

  syncField(value = this.readValue()) {
    if (this.hasFieldTarget) this.fieldTarget.value = value
  }

  syncEmpty() {
    this.surface?.classList.toggle("is-empty", this.plainText(this.readValue()).trim() === "")
  }

  contentEditableValue() {
    if (this.modeValue === "rich") return "true"
    const probe = document.createElement("div")
    probe.setAttribute("contenteditable", "plaintext-only")
    return probe.contentEditable === "plaintext-only" ? "plaintext-only" : "true"
  }

  showSpinner() {
    this.positionStatus()
    this.element.classList.add("is-saving")
    this.element.classList.remove("is-saved")
    if (this.hasSpinnerTarget) this.spinnerTarget.hidden = false
    if (this.hasTickTarget) this.tickTarget.hidden = true
  }

  showTick() {
    this.positionStatus()
    this.element.classList.remove("is-saving")
    this.element.classList.add("is-saved")
    if (this.hasSpinnerTarget) this.spinnerTarget.hidden = true
    if (this.hasTickTarget) this.tickTarget.hidden = false
  }

  hideStatus() {
    this.element.classList.remove("is-saving")
    if (this.hasSpinnerTarget) this.spinnerTarget.hidden = true
    if (this.hasTickTarget) this.tickTarget.hidden = true
  }

  positionStatus() {
    if (!this.hasStatusTarget || !this.surface) return
    const rects = this.surface.getClientRects()
    const rect = rects[rects.length - 1] || this.surface.getBoundingClientRect()
    const wrap = this.element.getBoundingClientRect()
    this.statusTarget.style.left = `${rect.right - wrap.left + 8}px`
    this.statusTarget.style.top = `${rect.top - wrap.top + Math.max(0, (rect.height - 16) / 2)}px`
  }

  announce(message) {
    if (this.hasLiveTarget) this.liveTarget.textContent = message
  }

  clearLive() {
    if (this.hasLiveTarget) this.liveTarget.textContent = ""
  }

  clearSavedHold() {
    if (this.#savedHoldTimer) {
      globalThis.clearTimeout(this.#savedHoldTimer)
      this.#savedHoldTimer = null
    }
  }
}
