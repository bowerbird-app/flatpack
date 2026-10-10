import { Controller } from "@hotwired/stimulus"
import { flatPackCopy } from "flat_pack/copy"
import {
  applyFormat,
  hideToolbar,
  keepSelection as preventToolbarFocusLoss,
  placeToolbarOnImage,
  updateToolbarFromSelection
} from "controllers/flat_pack/exec_command_bubble"

export default class extends Controller {
  static targets = ["editBtn", "saveBtn", "cancelBtn", "displayContent", "balloonToolbar", "imageInput"]
  static values  = {
    updateUrl:      String,
    uploadUrl:      { type: String, default: "" },
    fieldName:      { type: String, default: "body" },
    fieldFormatName: { type: String, default: "body_format" },
    fieldFormat:    { type: String, default: "html" },
  }

  #savedContent = null
  #selectionHandler = null
  #savedRange = null
  #selectedImage = null
  #imageClickHandler = null

  enableEditing() {
    this.#savedContent = this.displayContentTarget.innerHTML
    this.displayContentTarget.contentEditable = "true"
    this.displayContentTarget.focus()
    this.editBtnTarget.hidden   = true
    this.saveBtnTarget.hidden   = false
    this.cancelBtnTarget.hidden = false

    this.#selectionHandler = this.#handleSelection.bind(this)
    document.addEventListener("selectionchange", this.#selectionHandler)

    this.#imageClickHandler = this.#handleImageClick.bind(this)
    this.displayContentTarget.addEventListener("click", this.#imageClickHandler)
  }

  keepSelection(event) {
    preventToolbarFocusLoss(event)
  }

  triggerImageUpload() {
    if (!this.uploadUrlValue) return
    // Save the current selection so we can restore it after the file dialog
    const sel = document.getSelection()
    this.#savedRange = (sel && sel.rangeCount > 0) ? sel.getRangeAt(0).cloneRange() : null
    this.imageInputTarget.value = ""
    this.imageInputTarget.click()
  }

  async imageInputChanged() {
    if (!this.uploadUrlValue) return
    const file = this.imageInputTarget.files[0]
    if (!file) return

    const csrfToken = document.querySelector("meta[name=csrf-token]")?.content
    const formData = new FormData()
    formData.append("file", file)

    const response = await fetch(this.uploadUrlValue, {
      method: "POST",
      headers: { "X-CSRF-Token": csrfToken },
      body: formData
    })

    if (!response.ok) {
      const err = await response.json().catch(() => ({}))
      alert(err.error || flatPackCopy("content_editor.image_upload_failed"))
      return
    }

    const { url } = await response.json()

    // Restore selection then insert image
    this.displayContentTarget.focus()
    if (this.#savedRange) {
      const sel = document.getSelection()
      sel.removeAllRanges()
      sel.addRange(this.#savedRange)
      this.#savedRange = null
    }
    document.execCommand("insertImage", false, url)
  }

  format(event) {
    applyFormat(event.currentTarget.dataset.command, {
      editorEl: this.displayContentTarget,
      selectedImage: this.#selectedImage
    })
  }

  async save() {
    const body = new FormData()
    body.append(this.fieldNameValue, this.displayContentTarget.innerHTML)
    body.append(this.fieldFormatNameValue, this.fieldFormatValue)
    body.append("_method", "patch")

    const csrfToken = document.querySelector("meta[name=csrf-token]")?.content
    if (!csrfToken) {
      console.error("CSRF token not found")
      return
    }

    const response = await fetch(this.updateUrlValue, {
      method: "POST",
      headers: {
        "X-CSRF-Token": csrfToken
      },
      body,
    })

    if (response.ok) {
      this.disableEditing()
    } else {
      alert(flatPackCopy("content_editor.save_failed"))
    }
  }

  cancel() {
    if (this.#savedContent !== null) {
      this.displayContentTarget.innerHTML = this.#savedContent
    }
    this.disableEditing()
  }

  disableEditing() {
    this.displayContentTarget.contentEditable = "false"
    this.#savedContent = null
    this.#selectedImage = null
    if (this.#imageClickHandler) {
      this.displayContentTarget.removeEventListener("click", this.#imageClickHandler)
      this.#imageClickHandler = null
    }
    if (this.#selectionHandler) {
      document.removeEventListener("selectionchange", this.#selectionHandler)
      this.#selectionHandler = null
    }
    hideToolbar(this.balloonToolbarTarget)
    this.editBtnTarget.hidden   = false
    this.saveBtnTarget.hidden   = true
    this.cancelBtnTarget.hidden = true
  }

  #handleImageClick(event) {
    if (event.target.tagName !== "IMG") {
      this.#selectedImage = null
      return
    }
    event.preventDefault()
    this.#selectedImage = event.target
    placeToolbarOnImage(this.balloonToolbarTarget, event.target)
  }

  #handleSelection() {
    const result = updateToolbarFromSelection(this.balloonToolbarTarget, this.displayContentTarget, {
      selectedImage: this.#selectedImage
    })
    this.#selectedImage = result.selectedImage
  }
}
