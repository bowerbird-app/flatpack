import { Controller } from "@hotwired/stimulus"

// Submits wrapping forms when filter controls change.
export default class extends Controller {
  submitForm(event) {
    const form = event.target?.form

    if (!form) {
      return
    }

    if (typeof form.requestSubmit === "function") {
      form.requestSubmit()
      return
    }

    form.submit()
  }
}
