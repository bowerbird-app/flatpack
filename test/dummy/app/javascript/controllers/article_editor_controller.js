import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["editBtn", "saveBtn", "cancelBtn", "displayContent", "balloonToolbar", "imageInput"]
  static values  = { updateUrl: String, uploadUrl: String }

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
    event.preventDefault()
  }

  triggerImageUpload() {
    // Save the current selection so we can restore it after the file dialog
    const sel = document.getSelection()
    this.#savedRange = (sel && sel.rangeCount > 0) ? sel.getRangeAt(0).cloneRange() : null
    this.imageInputTarget.value = ""
    this.imageInputTarget.click()
  }

  async imageInputChanged() {
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
      alert(err.error || "Image upload failed.")
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
    const cmd = event.currentTarget.dataset.command
    if (["h1", "h2", "h3", "h4", "h5", "h6", "blockquote", "p"].includes(cmd)) {
      const current = document.queryCommandValue("formatBlock").toLowerCase()
      document.execCommand("formatBlock", false, current === cmd ? "p" : cmd)
    } else if (cmd === "link") {
      // Image selected — wrap/unwrap via DOM
      if (this.#selectedImage) {
        const img = this.#selectedImage
        const existingAnchor = img.closest("a")
        if (existingAnchor) {
          const url = prompt("Edit URL (leave blank to remove):", existingAnchor.href)
          if (url === "") {
            existingAnchor.replaceWith(img)
          } else if (url !== null) {
            existingAnchor.href = url
          }
        } else {
          const url = prompt("Enter URL:", "https://")
          if (url) {
            const a = document.createElement("a")
            a.href = url
            img.replaceWith(a)
            a.appendChild(img)
          }
        }
        return
      }
      // Text selection — use execCommand
      const anchor = document.getSelection()?.anchorNode?.parentElement?.closest("a")
      if (anchor) {
        const url = prompt("Edit URL (leave blank to remove):", anchor.href)
        if (url === "") document.execCommand("unlink", false, null)
        else if (url !== null) document.execCommand("createLink", false, url)
      } else {
        const url = prompt("Enter URL:", "https://")
        if (url) document.execCommand("createLink", false, url)
      }
    } else {
      document.execCommand(cmd, false, null)
    }
    this.displayContentTarget.focus()
  }

  #handleImageClick(event) {
    if (event.target.tagName !== "IMG") {
      this.#selectedImage = null
      return
    }
    event.preventDefault()
    this.#selectedImage = event.target
    const toolbar = this.balloonToolbarTarget
    const rect = event.target.getBoundingClientRect()
    toolbar.hidden = false
    toolbar.style.display = "flex"
    const tw = toolbar.getBoundingClientRect().width
    const th = toolbar.getBoundingClientRect().height
    toolbar.style.left = `${Math.max(4, rect.left + rect.width / 2 - tw / 2)}px`
    toolbar.style.top  = `${Math.max(4, rect.top - th - 8)}px`
  }

  #handleSelection() {
    const sel = document.getSelection()
    const toolbar = this.balloonToolbarTarget

    if (!sel || sel.isCollapsed || !this.displayContentTarget.contains(sel.anchorNode)) {
      // Don't hide toolbar if an image is selected via click
      if (!this.#selectedImage) {
        toolbar.hidden = true
        toolbar.style.display = "none"
      }
      return
    }
    this.#selectedImage = null

    const range = sel.getRangeAt(0)
    const rect  = range.getBoundingClientRect()

    toolbar.hidden = false
    toolbar.style.display = "flex"

    // Reflect active formatting states
    const blockVal = document.queryCommandValue("formatBlock").toLowerCase()
    toolbar.querySelectorAll("[data-command]").forEach(btn => {
      const cmd = btn.dataset.command
      let active = false
      if (["bold", "italic", "underline", "strikeThrough"].includes(cmd)) {
        try { active = document.queryCommandState(cmd) } catch (_) {}
      } else if (["h1", "h2", "h3", "blockquote"].includes(cmd)) {
        active = blockVal === cmd
      }
      btn.classList.toggle("is-active", active)
    })

    const tw   = toolbar.getBoundingClientRect().width
    const th   = toolbar.getBoundingClientRect().height
    const left = Math.max(4, rect.left + rect.width / 2 - tw / 2)
    const top  = Math.max(4, rect.top - th - 8)

    toolbar.style.left = `${left}px`
    toolbar.style.top  = `${top}px`
  }

  async save() {
    const body = new FormData()
    body.append("article[body]", this.displayContentTarget.innerHTML)
    body.append("article[body_format]", "html")
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
      alert("Save failed. Please try again.")
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
    this.balloonToolbarTarget.hidden = true
    this.balloonToolbarTarget.style.display = "none"
    this.editBtnTarget.hidden   = false
    this.saveBtnTarget.hidden   = true
    this.cancelBtnTarget.hidden = true
  }
}
