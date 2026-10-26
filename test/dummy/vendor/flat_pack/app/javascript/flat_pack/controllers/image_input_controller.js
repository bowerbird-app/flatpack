import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "empty", "preview", "overlay", "clear", "remove"]
  static values = {
    initialSrc: String,
    clearable: { type: Boolean, default: true }
  }

  connect() {
    this.dragCounter = 0
    this.objectUrl = null
    this.state = this.initialSrcValue ? "persisted" : "empty"
  }

  disconnect() {
    this.revokeObjectUrl()
  }

  choose(event) {
    const file = event.target.files && event.target.files[0]
    if (!file) return
    if (!this.matchesAccept(file)) {
      this.inputTarget.value = ""
      return
    }

    this.applyFile(file)
  }

  dragOver(event) {
    event.preventDefault()
    if (event.dataTransfer) event.dataTransfer.dropEffect = "copy"
  }

  dragEnter(event) {
    event.preventDefault()
    this.dragCounter += 1
    this.element.classList.add("is-dropping")
  }

  dragLeave(event) {
    event.preventDefault()
    this.dragCounter -= 1
    if (this.dragCounter === 0) this.element.classList.remove("is-dropping")
  }

  drop(event) {
    event.preventDefault()
    this.dragCounter = 0
    this.element.classList.remove("is-dropping")

    const files = Array.from(event.dataTransfer ? event.dataTransfer.files : [])
    const file = files.find((candidate) => this.matchesAccept(candidate))
    if (!file) return

    const transfer = new DataTransfer()
    transfer.items.add(file)
    this.inputTarget.files = transfer.files
    this.applyFile(file)
  }

  clear(event) {
    event.preventDefault()
    event.stopPropagation()
    this.inputTarget.value = ""
    this.revokeObjectUrl()

    if (this.state === "selected" && this.initialSrcValue) {
      this.showPersisted()
      this.setRemove("0")
      this.state = "persisted"
      this.dispatchClear({removed: false, reverted: true})
      return
    }

    if (this.state === "selected" || this.state === "persisted") {
      if (this.state === "persisted") this.initialSrcValue = ""
      this.showEmpty()
      this.setRemove("1")
      this.state = "empty"
      this.dispatchClear({removed: true, reverted: false})
    }
  }

  applyFile(file) {
    this.revokeObjectUrl()
    this.objectUrl = URL.createObjectURL(file)
    this.showSelected()
    this.setRemove("0")
    this.state = "selected"
  }

  showEmpty() {
    this.emptyTarget.hidden = false
    this.previewTarget.hidden = true
    this.previewTarget.removeAttribute("src")
    this.overlayTarget.hidden = true
    if (this.hasClearTarget) this.clearTarget.hidden = true
  }

  showPersisted() {
    this.emptyTarget.hidden = true
    this.previewTarget.hidden = false
    this.previewTarget.src = this.initialSrcValue
    this.overlayTarget.hidden = false
    if (this.hasClearTarget) this.clearTarget.hidden = false
  }

  showSelected() {
    this.emptyTarget.hidden = true
    this.previewTarget.hidden = false
    this.previewTarget.src = this.objectUrl
    this.overlayTarget.hidden = false
    if (this.hasClearTarget) this.clearTarget.hidden = false
  }

  setRemove(value) {
    if (!this.hasRemoveTarget) return

    this.removeTarget.value = value
  }

  revokeObjectUrl() {
    if (!this.objectUrl) return

    URL.revokeObjectURL(this.objectUrl)
    this.objectUrl = null
  }

  dispatchClear(detail) {
    this.element.dispatchEvent(new CustomEvent("flat-pack:image-input:clear", {
      bubbles: true,
      detail
    }))
  }

  matchesAccept(file) {
    const accept = this.inputTarget.accept || ""
    const tokens = accept.split(",").map((token) => token.trim().toLowerCase()).filter((token) => token.length > 0)
    if (tokens.length === 0) return true

    const type = String(file.type || "").toLowerCase()
    const name = String(file.name || "").toLowerCase()

    return tokens.some((token) => {
      if (token.endsWith("/*")) return type.startsWith(token.slice(0, -1))
      if (token.startsWith(".")) return name.endsWith(token)
      return type === token
    })
  }
}
