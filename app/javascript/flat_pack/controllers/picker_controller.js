import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["searchInput", "results", "emptyState", "outputField"]

  static values = {
    pickerId: String,
    items: Array,
    selectionMode: { type: String, default: "multiple" },
    acceptedKinds: Array,
    searchable: { type: Boolean, default: false },
    searchMode: { type: String, default: "local" },
    searchEndpoint: String,
    searchParam: { type: String, default: "q" },
    outputMode: { type: String, default: "event" },
    outputTarget: String,
    context: Object,
    emptyStateText: { type: String, default: "No assets found" },
    resultsLayout: { type: String, default: "list" }
  }

  connect() {
    this.filteredItems = this.#baseItems()
    this.selectedIds = new Set()
    this.debounceTimer = null
    this.abortController = null
    this.#renderResults(this.filteredItems)
    this.#syncOutputField()
  }

  disconnect() {
    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer)
    }

    if (this.abortController) {
      this.abortController.abort()
    }
  }

  search(event) {
    const query = String(event?.target?.value || "").trim()

    if (!this.searchableValue) {
      return
    }

    if (this.searchModeValue === "remote") {
      this.#searchRemote(query)
      return
    }

    this.filteredItems = this.#baseItems().filter((item) => this.#matchesQuery(item, query))
    this.#renderResults(this.filteredItems)
  }

  handleSelectionChange(event) {
    const control = event?.target
    if (!(control instanceof HTMLInputElement)) {
      return
    }

    const itemId = String(control.dataset.itemId || "")
    if (!itemId) {
      return
    }

    if (this.selectionModeValue === "single") {
      this.selectedIds.clear()
      if (control.checked) {
        this.selectedIds.add(itemId)
      }

      this.element.querySelectorAll("input[data-item-id]").forEach((input) => {
        if (!(input instanceof HTMLInputElement)) {
          return
        }
        input.checked = input.dataset.itemId === itemId && control.checked
      })
    } else if (control.checked) {
      this.selectedIds.add(itemId)
    } else {
      this.selectedIds.delete(itemId)
    }

    // Grid indicators are custom markup, so refresh cards to reflect checked state.
    if (this.#isGridLayout()) {
      this.#renderResults(this.filteredItems)
    }

    this.#syncOutputField()
  }

  selectGridItem(event) {
    const trigger = event?.currentTarget
    if (!(trigger instanceof HTMLElement)) {
      return
    }

    const itemId = String(trigger.dataset.itemId || "")
    if (!itemId) {
      return
    }

    if (this.selectionModeValue === "single") {
      this.selectedIds.clear()
      this.selectedIds.add(itemId)
    } else if (this.selectedIds.has(itemId)) {
      this.selectedIds.delete(itemId)
    } else {
      this.selectedIds.add(itemId)
    }

    this.#renderResults(this.filteredItems)
    this.#syncOutputField()
  }

  clearSelection() {
    this.selectedIds.clear()
    this.element.querySelectorAll("input[data-item-id]").forEach((input) => {
      if (input instanceof HTMLInputElement) {
        input.checked = false
      }
    })
    this.#syncOutputField()
  }

  confirmSelection() {
    const selection = this.#selectedItems()
    this.#syncOutputField(selection)

    this.element.dispatchEvent(new CustomEvent("flat-pack:picker:confirm", {
      bubbles: true,
      detail: {
        pickerId: this.pickerIdValue,
        selection,
        selectionMode: this.selectionModeValue,
        acceptedKinds: this.acceptedKindsValue,
        context: this.contextValue || {}
      }
    }))
  }

  #searchRemote(query) {
    if (!this.hasSearchEndpointValue) {
      return
    }

    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer)
    }

    this.debounceTimer = setTimeout(async () => {
      if (this.abortController) {
        this.abortController.abort()
      }

      this.abortController = new AbortController()

      const url = new URL(this.searchEndpointValue, window.location.origin)
      url.searchParams.set(this.searchParamValue, query)
      if (this.acceptedKindsValue.length > 0) {
        url.searchParams.set("kinds", this.acceptedKindsValue.join(","))
      }

      try {
        const response = await fetch(url.toString(), {
          method: "GET",
          headers: { Accept: "application/json" },
          signal: this.abortController.signal
        })

        if (!response.ok) {
          return
        }

        const payload = await response.json()
        this.filteredItems = this.#normalizeItems(payload?.items || [])
        this.#renderResults(this.filteredItems)
      } catch (error) {
        if (error?.name !== "AbortError") {
          this.filteredItems = []
          this.#renderResults(this.filteredItems)
        }
      }
    }, 250)
  }

  #renderResults(items) {
    if (!this.hasResultsTarget) {
      return
    }

    this.resultsTarget.className = this.#resultsContainerClass()

    const markup = items.map((item) => this.#itemMarkup(item)).join("")
    this.resultsTarget.innerHTML = markup

    if (this.hasEmptyStateTarget) {
      if (items.length === 0) {
        this.emptyStateTarget.textContent = this.emptyStateTextValue
        this.emptyStateTarget.classList.remove("hidden")
        this.emptyStateTarget.classList.add("flex")
      } else {
        this.emptyStateTarget.classList.add("hidden")
        this.emptyStateTarget.classList.remove("flex")
      }
    }
  }

  #itemMarkup(item) {
    if (this.#isGridLayout()) {
      return this.#gridItemMarkup(item)
    }

    return this.#listItemMarkup(item)
  }

  #listItemMarkup(item) {
    const itemId = this.#escapeHtml(String(item.id))
    const kind = item.kind === "image" ? "image" : "file"
    const label = this.#escapeHtml(String(item.label || item.name || "Untitled"))
    const name = this.#escapeHtml(String(item.name || ""))
    const contentType = this.#escapeHtml(String(item.contentType || ""))
    const byteSize = Number.isFinite(item.byteSize) ? item.byteSize : ""
    const thumbnailUrl = this.#escapeHtml(String(item.thumbnailUrl || ""))
    const isChecked = this.selectedIds.has(String(item.id)) ? "checked" : ""
    const controlType = this.selectionModeValue === "single" ? "radio" : "checkbox"
    const controlName = `picker_${this.#escapeHtml(this.pickerIdValue)}_selection`
    const controlClass = controlType === "checkbox" ? this.#checkboxInputClasses() : "mt-1 cursor-pointer"
    const meta = this.#escapeHtml(this.#metaText(item))

    const preview = kind === "image" && thumbnailUrl
      ? `<img src="${thumbnailUrl}" alt="${label} preview" class="h-14 w-20 rounded object-cover" loading="lazy">`
      : `<span class="inline-flex h-10 w-10 items-center justify-center rounded border border-(--surface-border-color) text-sm text-(--surface-muted-content-color)">${kind === "image" ? "IMG" : "FILE"}</span>`

    return `
      <div class="flat-pack-checkbox-wrapper">
        <label class="flex cursor-pointer items-start gap-3 rounded-md border border-(--surface-border-color) bg-(--surface-background-color) p-3">
          <input
            type="${controlType}"
            name="${controlName}"
            class="${controlClass}"
            data-item-id="${itemId}"
            ${isChecked}
            data-action="change->flat-pack--picker#handleSelectionChange"
          >
          ${preview}
          <span class="min-w-0 flex-1 ml-(--checkbox-label-gap)">
            <span class="block truncate text-sm font-medium text-(--surface-content-color)">${label}</span>
            <span class="block truncate text-xs text-(--surface-muted-content-color)">${meta}</span>
          </span>
          <span class="hidden"
            data-kind="${this.#escapeHtml(kind)}"
            data-name="${name}"
            data-content-type="${contentType}"
            data-byte-size="${byteSize}"
            data-thumbnail-url="${thumbnailUrl}">
          </span>
        </label>
      </div>
    `
  }

  #checkboxInputClasses() {
    return [
      "flat-pack-checkbox",
      "h-[var(--checkbox-size)] w-[var(--checkbox-size)]",
      "rounded-[var(--checkbox-radius)]",
      "border",
      "bg-[var(--surface-background-color)]",
      "accent-primary",
      "text-primary",
      "checked:bg-primary checked:border-primary",
      "transition-colors duration-base",
      "focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 focus:rounded-[var(--checkbox-radius)]",
      "cursor-pointer",
      "disabled:opacity-50 disabled:cursor-not-allowed",
      "border-[var(--surface-border-color)]"
    ].join(" ")
  }

  #gridItemMarkup(item) {
    const itemId = this.#escapeHtml(String(item.id))
    const kind = item.kind === "image" ? "image" : "file"
    const label = this.#escapeHtml(String(item.label || item.name || "Untitled"))
    const name = this.#escapeHtml(String(item.name || ""))
    const contentType = this.#escapeHtml(String(item.contentType || ""))
    const byteSize = Number.isFinite(item.byteSize) ? item.byteSize : ""
    const thumbnailUrl = this.#escapeHtml(String(item.thumbnailUrl || ""))
    const isChecked = this.selectedIds.has(String(item.id)) ? "checked" : ""
    const indicatorClasses = this.selectedIds.has(String(item.id))
      ? "bg-(--primary-color) ring-(--primary-color)"
      : "bg-black/30 ring-black/20"
    const isPressed = this.selectedIds.has(String(item.id)) ? "true" : "false"

    const preview = kind === "image" && thumbnailUrl
      ? `<img src="${thumbnailUrl}" alt="${label} preview" class="h-28 w-full rounded-md object-cover" loading="lazy">`
      : `<span class="inline-flex h-28 w-full items-center justify-center rounded-md bg-(--surface-subtle-background-color) text-sm text-(--surface-muted-content-color)">${kind === "image" ? "IMG" : "FILE"}</span>`

    return `
      <button
          type="button"
          class="relative block w-full cursor-pointer"
          aria-pressed="${isPressed}"
          data-item-id="${itemId}"
          data-action="click->flat-pack--picker#selectGridItem"
        >
        <span class="pointer-events-none absolute bottom-3 right-3 z-10 inline-flex h-5 w-5 items-center justify-center rounded-full border-2 border-white text-white ring-1 ${indicatorClasses}">
          <span class="h-1.5 w-1.5 rounded-full bg-white ${isChecked ? "opacity-100" : "opacity-0"}"></span>
        </span>
        ${preview}
        <span class="hidden"
          data-kind="${this.#escapeHtml(kind)}"
          data-name="${name}"
          data-content-type="${contentType}"
          data-byte-size="${byteSize}"
          data-thumbnail-url="${thumbnailUrl}">
        </span>
      </button>
    `
  }

  #resultsContainerClass() {
    if (this.#isGridLayout()) {
      return "grid grid-cols-2 gap-3 sm:grid-cols-3"
    }

    return "space-y-2"
  }

  #isGridLayout() {
    return this.resultsLayoutValue === "grid"
  }

  #metaText(item) {
    const parts = []

    if (item.contentType) {
      parts.push(item.contentType)
    }

    if (Number.isFinite(item.byteSize)) {
      parts.push(this.#humanSize(item.byteSize))
    }

    if (item.meta) {
      parts.push(item.meta)
    }

    return parts.join(" • ")
  }

  #humanSize(bytes) {
    if (bytes < 1024) {
      return `${bytes} B`
    }

    const units = ["KB", "MB", "GB"]
    let value = bytes / 1024
    let unitIndex = 0

    while (value >= 1024 && unitIndex < units.length - 1) {
      value /= 1024
      unitIndex += 1
    }

    return `${value.toFixed(value >= 10 ? 0 : 1)} ${units[unitIndex]}`
  }

  #selectedItems() {
    const base = [...this.#baseItems(), ...this.filteredItems]
    const index = new Map(base.map((item) => [String(item.id), item]))

    return [...this.selectedIds]
      .map((id) => index.get(id))
      .filter(Boolean)
      .map((item) => ({
        id: item.id,
        kind: item.kind,
        label: item.label,
        name: item.name,
        contentType: item.contentType || null,
        byteSize: Number.isFinite(item.byteSize) ? item.byteSize : null,
        thumbnailUrl: item.thumbnailUrl || null,
        meta: item.meta || null,
        payload: item.payload || {}
      }))
  }

  #syncOutputField(selection = null) {
    if (this.outputModeValue !== "field") {
      return
    }

    const selected = selection || this.#selectedItems()
    const encoded = JSON.stringify(selected)

    if (this.hasOutputTargetValue && this.outputTargetValue) {
      const targetElement = document.querySelector(this.outputTargetValue)
      if (targetElement) {
        targetElement.value = encoded
      }
    }

    if (this.hasOutputFieldTarget) {
      this.outputFieldTarget.value = encoded
    }
  }

  #baseItems() {
    return this.#normalizeItems(this.itemsValue || []).filter((item) => {
      if (!Array.isArray(this.acceptedKindsValue) || this.acceptedKindsValue.length === 0) {
        return true
      }

      return this.acceptedKindsValue.includes(item.kind)
    })
  }

  #normalizeItems(items) {
    return (Array.isArray(items) ? items : []).map((item, index) => {
      const source = item || {}
      const id = source.id || `picker-item-${index}`
      return {
        id,
        kind: source.kind === "image" ? "image" : "file",
        label: source.label || source.name || `Item ${index + 1}`,
        name: source.name || source.label || `item-${index + 1}`,
        contentType: source.contentType || null,
        byteSize: Number.isFinite(source.byteSize) ? source.byteSize : null,
        thumbnailUrl: source.thumbnailUrl || null,
        meta: source.meta || null,
        payload: source.payload || {}
      }
    })
  }

  #matchesQuery(item, query) {
    if (!query) {
      return true
    }

    const haystack = [
      item.label,
      item.name,
      item.contentType,
      item.meta,
      item.kind
    ].join(" ").toLowerCase()

    return haystack.includes(query.toLowerCase())
  }

  #escapeHtml(value) {
    return String(value)
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;")
      .replaceAll("'", "&#39;")
  }
}