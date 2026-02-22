// FlatPack File Input Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "fileList", "preview", "validationError"]
  static values = {
    maxSize: Number,
    preview: { type: Boolean, default: true },
    multiple: { type: Boolean, default: false }
  }

  connect() {
    this.dragCounter = 0
  }

  clickInput(event) {
    event.preventDefault()
    this.inputTarget.click()
  }

  handleFiles(event) {
    const files = Array.from(event.target.files)
    this.processFiles(files)
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

    const files = Array.from(event.dataTransfer.files)
    
    // Update the file input with dropped files
    const dataTransfer = new DataTransfer()
    files.forEach(file => dataTransfer.items.add(file))
    this.inputTarget.files = dataTransfer.files

    this.processFiles(files)
  }

  processFiles(files) {
    // Clear any previous validation errors
    this.clearError()
    
    // Validate files
    const validFiles = files.filter(file => this.validateFile(file))

    if (validFiles.length === 0) {
      return
    }

    // Show file list
    this.displayFileList(validFiles)

    // Show preview if enabled and files are images
    if (this.previewValue) {
      this.displayPreview(validFiles)
    }
  }

  validateFile(file) {
    // Check file size if max_size is set
    if (this.hasMaxSizeValue && file.size > this.maxSizeValue) {
      this.showError(`File "${file.name}" exceeds maximum size of ${this.formatFileSize(this.maxSizeValue)}`)
      return false
    }

    return true
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
    div.className = "flex items-center justify-between p-3 bg-[var(--surface-bg-color)] border border-[var(--surface-border-color)] rounded-[var(--radius-md)]"

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
    path.setAttribute("stroke-width", "2")
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
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12" />
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
    const dt = new DataTransfer()
    const files = Array.from(this.inputTarget.files)

    files.forEach((file, i) => {
      if (i !== index) {
        dt.items.add(file)
      }
    })

    this.inputTarget.files = dt.files

    // Refresh display
    if (this.inputTarget.files.length > 0) {
      this.processFiles(Array.from(this.inputTarget.files))
    } else {
      if (this.hasFileListTarget) {
        this.fileListTarget.classList.add("hidden")
      }
      if (this.hasPreviewTarget) {
        this.previewTarget.classList.add("hidden")
      }
    }
  }

  formatFileSize(bytes) {
    if (bytes < 1024) {
      return `${bytes}B`
    } else if (bytes < 1024 * 1024) {
      return `${(bytes / 1024).toFixed(1)}KB`
    } else {
      return `${(bytes / (1024 * 1024)).toFixed(1)}MB`
    }
  }

  showError(message) {
    if (this.hasValidationErrorTarget) {
      this.validationErrorTarget.textContent = message
      this.validationErrorTarget.classList.remove("hidden")
      
      // Auto-hide error after 5 seconds
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
