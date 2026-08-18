import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "dropdown", "results", "noResults", "loading"]
  static values = {
    url: String,
    param: { type: String, default: "q" },
    minCharacters: { type: Number, default: 2 },
    debounce: { type: Number, default: 250 },
    items: { type: Array, default: [] }
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

    if (this.itemsValue.length > 0) {
      this.renderResults(this.filterLocalItems(query))
      return
    }

    this.clearDebounce()
    this.debounceTimer = setTimeout(() => {
      this.showLoading()
      this.fetchResults(query)
    }, this.debounceValue)
  }

  filterLocalItems(query) {
    const normalizedQuery = query.toLowerCase()

    return this.itemsValue
      .map((item) => ({item, score: this.scoreItem(item, normalizedQuery)}))
      .filter(({score}) => score > 0)
      .sort((left, right) => {
        if (right.score !== left.score) return right.score - left.score
        const leftTitle = String(left.item.title || left.item.label || "")
        const rightTitle = String(right.item.title || right.item.label || "")
        return leftTitle.localeCompare(rightTitle)
      })
      .slice(0, 10)
      .map(({item}) => item)
  }

  scoreItem(item, query) {
    const title = String(item.title || item.label || "").toLowerCase()
    const description = String(item.description || "").toLowerCase()
    const titleWords = this.searchWords(title)
    const descriptionWords = this.searchWords(description)

    if (title === query) return 100
    if (title.startsWith(query)) return 90
    if (title.includes(query)) return 80
    if (titleWords.some((word) => word.startsWith(query))) return 70
    if (description === query || description.startsWith(query)) return 40
    if (query.includes(" ") && description.includes(query)) return 30
    if (descriptionWords.some((word) => word === query || word === `${query}s`)) return 20

    return 0
  }

  searchWords(text) {
    return text.split(/[^a-z0-9]+/).filter(Boolean)
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
    listItem.className = "border-b border-[var(--search-result-divider-color)] last:border-b-0"

    const link = document.createElement("a")
    link.className = "block px-3 py-2 hover:bg-[var(--search-result-hover-background-color)] focus:outline-none focus:bg-[var(--search-result-hover-background-color)]"
    link.href = result.url || "#"

    const title = document.createElement("div")
    title.className = "text-sm font-medium text-[var(--search-result-title-color)]"
    title.textContent = result.title || result.label || "Result"
    link.append(title)

    if (result.description) {
      const description = document.createElement("div")
      description.className = "mt-0.5 text-xs text-[var(--search-result-description-color)]"
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
