import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "dropdown", "results", "noResults", "loading"]
  static values = {
    url: String,
    param: { type: String, default: "q" },
    minCharacters: { type: Number, default: 2 },
    debounce: { type: Number, default: 250 }
  }

  connect() {
    this.debounceTimer = null
    this.abortController = null
    this.handleOutsideClick = this.handleOutsideClick.bind(this)
    document.addEventListener("click", this.handleOutsideClick)
  }

  disconnect() {
    document.removeEventListener("click", this.handleOutsideClick)
    this.clearDebounce()
    this.abortPendingRequest()
  }

  search() {
    const query = this.inputTarget.value.trim()

    if (query.length < this.minCharactersValue) {
      this.resetResults()
      this.close()
      return
    }

    this.showLoading()
    this.open()

    this.clearDebounce()
    this.debounceTimer = setTimeout(() => {
      this.fetchResults(query)
    }, this.debounceValue)
  }

  open() {
    this.dropdownTarget.classList.remove("hidden")
    this.inputTarget.setAttribute("aria-expanded", "true")
  }

  close() {
    this.dropdownTarget.classList.add("hidden")
    this.inputTarget.setAttribute("aria-expanded", "false")
  }

  handleKeydown(event) {
    if (event.key === "Escape") {
      this.close()
      this.inputTarget.blur()
    }
  }

  handleOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  async fetchResults(query) {
    this.abortPendingRequest()
    this.abortController = new AbortController()

    try {
      const url = new URL(this.urlValue, window.location.origin)
      url.searchParams.set(this.paramValue, query)

      const response = await fetch(url.toString(), {
        headers: { Accept: "application/json" },
        signal: this.abortController.signal
      })

      if (!response.ok) {
        throw new Error(`Search request failed: ${response.status}`)
      }

      const payload = await response.json()
      const results = Array.isArray(payload) ? payload : (payload.results || [])
      this.renderResults(results)
    } catch (error) {
      if (error.name !== "AbortError") {
        this.renderResults([])
      }
    }
  }

  renderResults(results) {
    this.hideLoading()
    this.resultsTarget.replaceChildren()

    if (results.length === 0) {
      this.noResultsTarget.classList.remove("hidden")
      this.open()
      return
    }

    this.noResultsTarget.classList.add("hidden")

    results.forEach((result) => {
      this.resultsTarget.append(this.buildResultItem(result))
    })

    this.open()
  }

  buildResultItem(result) {
    const listItem = document.createElement("li")
    listItem.className = "border-b border-[var(--color-border)] last:border-b-0"

    const link = document.createElement("a")
    link.className = "block px-3 py-2 hover:bg-[var(--color-muted)] focus:outline-none focus:bg-[var(--color-muted)]"
    link.href = result.url || "#"

    const title = document.createElement("div")
    title.className = "text-sm font-medium text-[var(--color-text)]"
    title.textContent = result.title || result.label || "Result"
    link.append(title)

    if (result.description) {
      const description = document.createElement("div")
      description.className = "mt-0.5 text-xs text-[var(--color-text-muted)]"
      description.textContent = result.description
      link.append(description)
    }

    listItem.append(link)
    return listItem
  }

  resetResults() {
    this.resultsTarget.replaceChildren()
    this.noResultsTarget.classList.add("hidden")
    this.hideLoading()
  }

  showLoading() {
    this.loadingTarget.classList.remove("hidden")
    this.noResultsTarget.classList.add("hidden")
    this.resultsTarget.replaceChildren()
  }

  hideLoading() {
    this.loadingTarget.classList.add("hidden")
  }

  clearDebounce() {
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer)
      this.debounceTimer = null
    }
  }

  abortPendingRequest() {
    if (this.abortController) {
      this.abortController.abort()
      this.abortController = null
    }
  }
}
