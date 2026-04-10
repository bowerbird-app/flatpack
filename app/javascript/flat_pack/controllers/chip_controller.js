// FlatPack Chip Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["chip"]
  static values = {
    value: String,
    removeUrl: String,
    removeMethod: { type: String, default: "post" },
    removeParams: { type: Object, default: {} }
  }

  async remove(event) {
    event?.preventDefault()

    if (this.removing) return

    this.removing = true
    this.setRemoveButtonState(true)

    try {
      if (this.removeUrl()) {
        await this.performRemoveRequest()
      }

      this.animateRemoval()
    } catch (error) {
      this.removing = false
      this.setRemoveButtonState(false)
      this.dispatchRemoveFailed(error)
    }
  }

  toggle(event) {
    // Toggle aria-pressed
    const currentPressed = this.element.getAttribute("aria-pressed") === "true"
    const newPressed = !currentPressed
    this.element.setAttribute("aria-pressed", String(newPressed))

    // Toggle selected class (ring-2 ring-[var(--color-ring)])
    this.element.classList.toggle("ring-2")
    this.element.classList.toggle("ring-[var(--color-ring)]")

    // Emit chip:toggled event
    const toggleEvent = new CustomEvent("chip:toggled", {
      bubbles: true,
      detail: {
        value: this.valueValue,
        selected: newPressed,
        element: this.element
      }
    })
    this.element.dispatchEvent(toggleEvent)
  }

  animateRemoval() {
    this.chipTarget.style.transition = "opacity 200ms ease-out, transform 200ms ease-out"
    this.chipTarget.style.opacity = "0"
    this.chipTarget.style.transform = "scale(0.8)"

    setTimeout(() => {
      const event = new CustomEvent("chip:removed", {
        bubbles: true,
        detail: {
          value: this.valueValue,
          element: this.chipTarget
        }
      })
      this.element.dispatchEvent(event)
      this.element.remove()
    }, 200)
  }

  async performRemoveRequest() {
    const method = this.removeMethod().toLowerCase()

    if (method === "get") {
      return this.performGetRemoveRequest()
    }

    return this.performPostRemoveRequest()
  }

  async performGetRemoveRequest() {
    const url = new URL(this.removeUrl(), window.location.origin)
    this.appendParams(url.searchParams, this.removeParams())

    const response = await fetch(url.toString(), {
      method: "GET",
      headers: { Accept: "application/json" }
    })

    if (!response.ok) {
      throw new Error(`Chip remove request failed: ${response.status}`)
    }
  }

  async performPostRemoveRequest() {
    const csrfToken = document.querySelector("meta[name='csrf-token']")?.content || ""
    const headers = {
      "Content-Type": "application/json",
      Accept: "application/json"
    }

    if (csrfToken) {
      headers["X-CSRF-Token"] = csrfToken
    }

    const response = await fetch(this.removeUrl(), {
      method: "POST",
      headers,
      body: JSON.stringify(this.removeParams())
    })

    if (!response.ok) {
      throw new Error(`Chip remove request failed: ${response.status}`)
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

  dispatchRemoveFailed(error) {
    this.element.dispatchEvent(new CustomEvent("chip:remove-failed", {
      bubbles: true,
      detail: {
        value: this.valueValue,
        element: this.chipTarget,
        error: error.message
      }
    }))
  }

  setRemoveButtonState(disabled) {
    const button = this.element.querySelector("button[aria-label='Remove']")
    if (!button) return

    button.disabled = disabled
    button.setAttribute("aria-busy", disabled ? "true" : "false")
  }

  removeUrl() {
    return this.hasRemoveUrlValue ? this.removeUrlValue : this.element.dataset.flatPackChipRemoveUrlValue
  }

  removeMethod() {
    return this.hasRemoveMethodValue ? this.removeMethodValue : (this.element.dataset.flatPackChipRemoveMethodValue || "post")
  }

  removeParams() {
    if (this.hasRemoveParamsValue) {
      return this.removeParamsValue
    }

    const rawParams = this.element.dataset.flatPackChipRemoveParamsValue
    if (!rawParams) {
      return {}
    }

    try {
      return JSON.parse(rawParams)
    } catch {
      return {}
    }
  }
}
