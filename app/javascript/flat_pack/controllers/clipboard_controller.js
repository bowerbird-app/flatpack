import { Controller } from "@hotwired/stimulus"
import { flatPackCopy } from "flat_pack/copy"
import { prefersReducedMotion } from "controllers/flat_pack/reduced_motion"
import {
  CLIPBOARD_COPIED_EVENT,
  CLIPBOARD_ERROR_EVENT,
  readClipboardSource,
  writeClipboardText
} from "flat_pack/clipboard"

const REDUCED_MOTION_HOLD_MS = 600
const ERROR_COLOR = "var(--color-error)"

// Owns every copy in the kit. A later share button can import
// writeClipboardText and readClipboardSource from flat_pack/clipboard
// and reuse data-fp-clipboard-state. Copied keeps the control's colours
// and swaps the icon and label. Error uses the danger chrome.
export default class extends Controller {
  static targets = ["button", "label", "live"]
  static values = {
    text: String,
    target: String,
    source: { type: String, default: "auto" },
    feedback: { type: String, default: "button" },
    timeout: { type: Number, default: 2000 },
    icon: { type: String, default: "clipboard-document" },
    copiedLabel: String,
    errorLabel: String,
    emptyLabel: String,
    copiedAnnouncement: String,
    errorAnnouncement: String,
    emptyAnnouncement: String
  }

  connect() {
    this.idleText = this.hasLabelTarget ? this.labelTarget.textContent : ""
  }

  disconnect() {
    this.clearReset()
  }

  async copy(event) {
    const result = this.readSource()
    if (result.status === "ignore") return

    if (event?.target?.closest?.("button, a")) event.preventDefault()
    if (this.buttonElement()?.disabled || result.element?.disabled) return

    if (result.status === "missing") {
      this.fail("missing", "")
      return
    }

    if (!result.text) {
      this.fail("empty", "")
      return
    }

    const copied = await writeClipboardText(result.text)
    if (!copied) {
      this.fail("failed", result.text)
      return
    }

    if (this.sourceKind() === "anchor") {
      window.history.replaceState({}, "", result.text)
    }

    this.succeed(result.text)
  }

  succeed(text) {
    this.paint("copied")
    this.showLabel("copied")
    this.announce("copied")
    if (this.feedbackValue === "toast") this.dispatchToast("success", this.messageFor("copied"))
    this.dispatchResult(CLIPBOARD_COPIED_EVENT, { text })
    this.scheduleReset()
  }

  fail(reason, text) {
    const state = reason === "empty" ? "empty" : "error"
    this.paint(state)
    this.showLabel(state)
    this.announce(state)
    if (this.feedbackValue === "toast") {
      const style = reason === "empty" ? "warning" : "danger"
      this.dispatchToast(style, this.messageFor(state))
    }
    this.dispatchResult(CLIPBOARD_ERROR_EVENT, { text, reason })
    this.scheduleReset()
  }

  readSource() {
    return readClipboardSource({
      source: this.sourceKind(),
      text: this.hasTextValue ? this.textValue : null,
      target: this.hasTargetValue ? this.targetValue : "",
      href: this.anchorHref(),
      root: this.element,
      location: window.location
    })
  }

  sourceKind() {
    if (this.hasSourceValue && this.sourceValue && this.sourceValue !== "auto") return this.sourceValue
    if (this.hasTargetValue && this.targetValue) return "target"
    if (this.hasTextValue) return "text"
    if (this.element.matches?.("a[href^='#']")) return "anchor"
    return "text"
  }

  anchorHref() {
    if (this.element.matches?.("a")) return this.element.getAttribute("href")
    return this.element.querySelector?.("a[href]")?.getAttribute("href") || null
  }

  buttonElement() {
    if (this.hasButtonTarget) return this.buttonTarget
    if (this.element.matches?.("button, a")) return this.element
    return this.element.querySelector?.("button, a") || null
  }

  paint(state) {
    const button = this.buttonElement()
    if (!button) return

    const visual = state === "empty" ? "error" : state
    if (this.feedbackValue === "button") {
      button.setAttribute("data-fp-clipboard-state", visual)
      return
    }

    if (visual === "idle") {
      button.removeAttribute("data-fp-clipboard-state")
      button.style.color = ""
      this.swapIcon(this.iconValue || "clipboard-document")
      return
    }

    button.setAttribute("data-fp-clipboard-state", visual)
    button.style.color = visual === "error" ? ERROR_COLOR : ""
    this.swapIcon(visual === "copied" ? "check" : "exclamation-circle")
  }

  swapIcon(name) {
    const button = this.buttonElement()
    const icon = button?.querySelector?.("[data-flat-pack--icon-name-value]")
    if (!icon) return
    icon.setAttribute("data-flat-pack--icon-name-value", name)
  }

  showLabel(state) {
    if (!this.hasLabelTarget) return
    this.labelTarget.textContent = state === "idle"
      ? (this.idleText || this.labelFor("idle"))
      : this.labelFor(state)
  }

  announce(state) {
    if (this.feedbackValue === "toast" || !this.hasLiveTarget) return
    this.liveTarget.textContent = this.messageFor(state)
  }

  labelFor(state) {
    if (state === "copied") return this.valueOrCopy("copiedLabel", "clipboard.copied_label")
    if (state === "empty") return this.valueOrCopy("emptyLabel", "clipboard.nothing")
    if (state === "error") return this.valueOrCopy("errorLabel", "clipboard.error_label")
    return flatPackCopy("clipboard.copy")
  }

  messageFor(state) {
    if (state === "copied") return this.valueOrCopy("copiedAnnouncement", "clipboard.copied")
    if (state === "empty") return this.valueOrCopy("emptyAnnouncement", "clipboard.nothing")
    return this.valueOrCopy("errorAnnouncement", "clipboard.unable")
  }

  valueOrCopy(valueName, key) {
    const value = this[`${valueName}Value`]
    if (value) return value
    return flatPackCopy(key)
  }

  dispatchToast(style, text) {
    document.dispatchEvent(new CustomEvent("toast:add", {
      detail: {
        style,
        text,
        timeout: 3000
      }
    }))
  }

  dispatchResult(name, detail) {
    this.element.dispatchEvent(new CustomEvent(name, {
      bubbles: true,
      detail
    }))
  }

  scheduleReset() {
    this.clearReset()
    const timeout = this.resetDelay()
    if (!timeout) return
    this.resetTimer = window.setTimeout(() => this.resetState(), timeout)
  }

  resetDelay() {
    const timeout = Number.isFinite(this.timeoutValue) ? this.timeoutValue : 2000
    if (timeout <= 0) return 0
    if (prefersReducedMotion()) return Math.min(timeout, REDUCED_MOTION_HOLD_MS)
    return timeout
  }

  resetState() {
    this.resetTimer = null
    this.paint("idle")
    this.showLabel("idle")
    if (this.hasLiveTarget) this.liveTarget.textContent = ""
  }

  clearReset() {
    if (this.resetTimer == null) return
    window.clearTimeout(this.resetTimer)
    this.resetTimer = null
  }
}
