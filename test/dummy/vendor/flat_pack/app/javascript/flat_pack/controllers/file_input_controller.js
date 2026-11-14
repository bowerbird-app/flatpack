// FlatPack File Input Stimulus Controller
import { Controller } from "@hotwired/stimulus"
import { flatPackCopy } from "flat_pack/copy"

const CHANGE_EVENT = "flat-pack:file-input:change"

export default class extends Controller {
  static targets = ["input", "fileList", "preview", "validationError", "limitMessage", "button"]
  static values = {
    maxSize: Number,
    preview: { type: Boolean, default: true },
    multiple: { type: Boolean, default: false },
    maxFiles: Number,
    limitMessage: String,
    showList: { type: Boolean, default: true }
  }

  connect() {
    this.dragCounter = 0
    this.acceptedFiles = []
  }

  clickInput(event) {
    event.preventDefault()
    if (this.inputTarget.disabled) return
    this.inputTarget.click()
  }

  handleFiles(event) {
    const files = Array.from(event.target.files || [])
    this.processFiles(files)
    if (this.hasButtonTarget && typeof this.buttonTarget.focus === "function") {
      this.buttonTarget.focus()
    }
  }

  dragOver(event) {
    event.preventDefault()
    event.dataTransfer.dropEffect = "copy"
  }

  dragEnter(event) {
    event.preventDefault()
    this.dragCounter++
    this.element.classList.add("border-[var(--color-primary)]")
    this.element.classList.add("bg-[var(--color-primary)]/5")
  }

  dragLeave(event) {
    event.preventDefault()
    this.dragCounter--
    if (this.dragCounter === 0) {
      this.element.classList.remove("border-[var(--color-primary)]")
      this.element.classList.remove("bg-[var(--color-primary)]/5")
    }
  }

  drop(event) {
    event.preventDefault()
    this.dragCounter = 0
    this.element.classList.remove("border-[var(--color-primary)]")
    this.element.classList.remove("bg-[var(--color-primary)]/5")

    const files = Array.from(event.dataTransfer ? event.dataTransfer.files : [])
    this.processFiles(files)
  }

  processFiles(files) {
    this.clearError()

    const selected = Array.from(files || [])
    const capped = this.capSelection(selected)
    const validFiles = []
    capped.forEach((file) => {
      if (this.validateFile(file)) validFiles.push(file)
    })

    this.acceptedFiles = validFiles
    this.dispatchChange(validFiles)
    this.renderSelection()
  }

  capSelection(files) {
    if (!this.hasMaxFilesValue || files.length <= this.maxFilesValue) {
      this.clearLimitMessage()
      return files
    }

    this.showLimitMessage()
    return files.slice(0, this.maxFilesValue)
  }

  dispatchChange(files) {
    this.element.dispatchEvent(new CustomEvent(CHANGE_EVENT, {
      bubbles: true,
      detail: { files: files.slice() }
    }))
  }

  validateFile(file) {
    if (this.hasMaxSizeValue && file.size > this.maxSizeValue) {
      this.showError(flatPackCopy("file_input.size_exceeded", {name: file.name, size: this.formatFileSize(this.maxSizeValue)}))
      return false
    }

    return true
  }

  renderSelection() {
    if (!this.showListValue) return

    const files = this.acceptedFiles || []
    if (files.length === 0) {
      this.hideSelection()
      return
    }

    this.displayFileList(files)
    if (this.previewValue) {
      this.displayPreview(files)
    } else if (this.hasPreviewTarget) {
      this.previewTarget.innerHTML = ""
      this.previewTarget.classList.add("hidden")
    }
  }

  hideSelection() {
    if (this.hasFileListTarget) {
      this.fileListTarget.innerHTML = ""
      this.fileListTarget.classList.add("hidden")
    }
    if (this.hasPreviewTarget) {
      this.previewTarget.innerHTML = ""
      this.previewTarget.classList.add("hidden")
    }
  }

  displayFileList(files) {
    if (!this.hasFileListTarget) return

    this.fileListTarget.innerHTML = ""
    this.fileListTarget.classList.remove("hidden")

    files.forEach((file, index) => {
      const fileItem = this.createFileItem(file, index)
      this.fileListTarget.appendChild(fileItem)
    })
  }

  createFileItem(file, index) {
    const div = document.createElement("div")
    div.className = "flex items-center justify-between p-3 bg-[var(--surface-background-color)] border border-[var(--surface-border-color)] rounded-[var(--radius-md)]"

    const fileInfo = document.createElement("div")
    fileInfo.className = "flex items-center flex-1 min-w-0"

    const fileIcon = this.createFileIcon()
    const fileName = document.createElement("div")
    fileName.className = "text-sm text-[var(--surface-content-color)] truncate"
    fileName.textContent = file.name

    const fileSize = document.createElement("div")
    fileSize.className = "text-xs text-[var(--surface-muted-content-color)]"
    fileSize.textContent = this.formatFileSize(file.size)

    fileInfo.appendChild(fileIcon)
    const textContainer = document.createElement("div")
    textContainer.className = "flex-1 min-w-0 mx-4"
    textContainer.appendChild(fileName)
    textContainer.appendChild(fileSize)
    fileInfo.appendChild(textContainer)

    const removeButton = this.createRemoveButton(index)

    div.appendChild(fileInfo)
    div.appendChild(removeButton)

    return div
  }

  createFileIcon() {
    const icon = document.createElementNS("http://www.w3.org/2000/svg", "svg")
    icon.setAttribute("class", "h-8 w-8 text-[var(--surface-muted-content-color)] flex-shrink-0")
    icon.setAttribute("fill", "none")
    icon.setAttribute("viewBox", "0 0 24 24")
    icon.setAttribute("stroke", "currentColor")

    const path = document.createElementNS("http://www.w3.org/2000/svg", "path")
    path.setAttribute("stroke-linecap", "round")
    path.setAttribute("stroke-linejoin", "round")
    path.setAttribute("stroke-width", "1.5")
    path.setAttribute("d", "M7 21h10a2 2 0 002-2V9.414a1 1 0 00-.293-.707l-5.414-5.414A1 1 0 0012.586 3H7a2 2 0 00-2 2v14a2 2 0 002 2z")

    icon.appendChild(path)
    return icon
  }

  createRemoveButton(index) {
    const button = document.createElement("button")
    button.type = "button"
    button.className = "text-[var(--surface-muted-content-color)] hover:text-[var(--color-warning-border)] transition-colors"
    button.innerHTML = `
      <svg class="h-5 w-5" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="1.5" d="M6 18L18 6M6 6l12 12" />
      </svg>
    `
    button.addEventListener("click", () => this.removeFile(index))
    return button
  }

  displayPreview(files) {
    if (!this.hasPreviewTarget) return

    this.previewTarget.innerHTML = ""
    this.previewTarget.classList.remove("hidden")

    files.forEach(file => {
      if (file.type.startsWith("image/")) {
        const reader = new FileReader()
        reader.onload = (e) => {
          const img = document.createElement("img")
          img.src = e.target.result
          img.className = "w-full h-24 object-cover rounded-[var(--radius-md)] border border-[var(--surface-border-color)]"
          this.previewTarget.appendChild(img)
        }
        reader.readAsDataURL(file)
      }
    })
  }

  removeFile(index) {
    const remaining = (this.acceptedFiles || []).filter((_, i) => i !== index)
    this.acceptedFiles = remaining
    this.clearLimitMessage()
    this.clearError()
    this.dispatchChange(remaining)
    this.renderSelection()
  }

  formatFileSize(bytes) {
    if (bytes < 1024) {
      return flatPackCopy("file_input.size_bytes", {count: bytes})
    } else if (bytes < 1024 * 1024) {
      return flatPackCopy("file_input.size_kilobytes", {count: (bytes / 1024).toFixed(1)})
    } else {
      return flatPackCopy("file_input.size_megabytes", {count: (bytes / (1024 * 1024)).toFixed(1)})
    }
  }

  showLimitMessage() {
    if (!this.hasLimitMessageTarget) return

    this.limitMessageTarget.textContent = this.hasLimitMessageValue ? this.limitMessageValue : ""
    this.limitMessageTarget.classList.remove("hidden")
  }

  clearLimitMessage() {
    if (!this.hasLimitMessageTarget) return

    this.limitMessageTarget.textContent = ""
    this.limitMessageTarget.classList.add("hidden")
  }

  showError(message) {
    if (this.hasValidationErrorTarget) {
      this.validationErrorTarget.textContent = message
      this.validationErrorTarget.classList.remove("hidden")

      setTimeout(() => {
        this.validationErrorTarget.classList.add("hidden")
      }, 5000)
    } else {
      console.error(message)
    }
  }

  clearError() {
    if (this.hasValidationErrorTarget) {
      this.validationErrorTarget.classList.add("hidden")
      this.validationErrorTarget.textContent = ""
    }
  }
}
