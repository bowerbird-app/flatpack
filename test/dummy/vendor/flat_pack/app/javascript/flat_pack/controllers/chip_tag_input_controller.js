import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "chips", "template"]
  static values = {
    autoSubmit: { type: Boolean, default: false },
    addUrl: String,
    addMethod: { type: String, default: "post" },
    addParams: { type: Object, default: {} }
  }

  async handleKeydown(event) {
    if (event.key !== "Enter") return

    event.preventDefault()

    const text = event.target.value.trim()
    if (!text) return

    const payload = this.buildChipPayload(text)
    if (this.chipExists(payload.value)) {
      return
    }

    try {
      if (this.requestModeEnabled()) {
        await this.performAddRequest(payload)
      }

      const element = this.insertChip(payload)
      this.dispatchAdded(payload, element)
      this.inputTarget.value = ""
    } catch (error) {
      this.dispatchAddFailed(payload, error)
    }
  }

  buildChipPayload(text) {
    return {
      text,
      value: this.slugify(text)
    }
  }

  chipExists(value) {
    const existingValues = this.chipsTarget.querySelectorAll("[data-flat-pack--chip-value-value]")

    return [...existingValues].some((element) => element.dataset.flatPackChipValueValue === value)
  }

  insertChip(payload) {
    const markup = this.templateTarget.innerHTML
      .replaceAll("__TAG_TEXT__", this.escapeHtml(payload.text))
      .replaceAll("__TAG_VALUE__", this.escapeHtml(payload.value))

    this.chipsTarget.insertAdjacentHTML("beforeend", markup)

    const chips = this.chipsTarget.querySelectorAll("[data-flat-pack--chip-value-value]")
    return chips[chips.length - 1] || null
  }

  requestModeEnabled() {
    return this.autoSubmitValue && this.hasAddUrlValue
  }

  async performAddRequest(payload) {
    const method = this.addMethodValue.toLowerCase()

    if (method === "get") {
      return this.performGetAddRequest(payload)
    }

    return this.performPostAddRequest(payload)
  }

  async performGetAddRequest(payload) {
    const url = new URL(this.addUrlValue, window.location.origin)
    this.appendParams(url.searchParams, this.requestPayload(payload))

    const response = await fetch(url.toString(), {
      method: "GET",
      headers: { Accept: "application/json" }
    })

    if (!response.ok) {
      throw new Error(`Chip add request failed: ${response.status}`)
    }
  }

  async performPostAddRequest(payload) {
    const csrfToken = document.querySelector("meta[name='csrf-token']")?.content || ""
    const headers = {
      "Content-Type": "application/json",
      Accept: "application/json"
    }

    if (csrfToken) {
      headers["X-CSRF-Token"] = csrfToken
    }

    const response = await fetch(this.addUrlValue, {
      method: "POST",
      headers,
      body: JSON.stringify(this.requestPayload(payload))
    })

    if (!response.ok) {
      throw new Error(`Chip add request failed: ${response.status}`)
    }
  }

  requestPayload(payload) {
    return {
      ...this.addParamsValue,
      text: payload.text,
      value: payload.value
    }
  }

  appendParams(searchParams, params, prefix = null) {
    if (Array.isArray(params)) {
      params.forEach((value) => {
        this.appendParams(searchParams, value, `${prefix}[]`)
      })
      return
    }

    if (params && typeof params === "object") {
      Object.entries(params).forEach(([key, value]) => {
        const paramKey = prefix ? `${prefix}[${key}]` : key
        this.appendParams(searchParams, value, paramKey)
      })
      return
    }

    if (prefix && params != null) {
      searchParams.append(prefix, String(params))
    }
  }

  dispatchAdded(payload, element) {
    this.element.dispatchEvent(new CustomEvent("chip:added", {
      bubbles: true,
      detail: {
        text: payload.text,
        value: payload.value,
        element
      }
    }))
  }

  dispatchAddFailed(payload, error) {
    this.element.dispatchEvent(new CustomEvent("chip:add-failed", {
      bubbles: true,
      detail: {
        text: payload.text,
        value: payload.value,
        error: error.message
      }
    }))
  }

  slugify(value) {
    return String(value)
      .trim()
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/(^-|-$)/g, "")
  }

  escapeHtml(value) {
    return String(value)
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;")
      .replaceAll("'", "&#39;")
  }
}