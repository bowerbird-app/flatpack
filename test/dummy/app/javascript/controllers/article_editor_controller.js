import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["editBtn", "saveBtn", "cancelBtn"]
  static values  = { updateUrl: String }

  enableEditing() {
    const wrapper = this.element.querySelector("[data-controller='flat-pack--tiptap']")
    if (wrapper) {
      wrapper.setAttribute("data-flat-pack--tiptap-disabled-value", "false")
    }
    this.editBtnTarget.hidden   = true
    this.saveBtnTarget.hidden   = false
    this.cancelBtnTarget.hidden = false
  }

  async save() {
    const field = this.element.querySelector(
      "input[data-flat-pack--tiptap-target='hiddenField']"
    )
    if (!field) return

    const body = new FormData()
    body.append("article[body]", field.value)
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
    window.location.reload()
  }

  disableEditing() {
    const wrapper = this.element.querySelector("[data-controller='flat-pack--tiptap']")
    if (wrapper) {
      wrapper.setAttribute("data-flat-pack--tiptap-disabled-value", "true")
    }
    this.editBtnTarget.hidden   = false
    this.saveBtnTarget.hidden   = true
    this.cancelBtnTarget.hidden = true
  }
}
