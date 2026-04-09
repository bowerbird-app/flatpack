import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["searchInput", "results", "emptyState", "outputField", "formFields"]

  static values = {
    pickerId: String,
    items: Array,
    selectionMode: { type: String, default: "multiple" },
    modal: { type: Boolean, default: true },
    autoConfirm: { type: Boolean, default: false },
    acceptedKinds: Array,
    searchable: { type: Boolean, default: false },
    searchMode: { type: String, default: "local" },
    searchEndpoint: String,
    searchParam: { type: String, default: "q" },
    outputMode: { type: String, default: "event" },
    outputTarget: String,
    form: Object,
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
    this.#syncFormFields()
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

    const wasSelected = this.selectedIds.has(itemId)

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

    // Custom selection indicators need a rerender to reflect checked state.
    if (this.#resultsNeedSelectionRefresh()) {
      this.#renderResults(this.filteredItems)
    }

    this.#syncOutputField()
    this.#syncFormFields()
    this.#autoConfirmSelectionIfNeeded({ selected: control.checked, wasSelected })
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

    const wasSelected = this.selectedIds.has(itemId)

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
    this.#syncFormFields()
    this.#autoConfirmSelectionIfNeeded({ selected: true, wasSelected })
  }

  clearSelection() {
    this.selectedIds.clear()
    this.element.querySelectorAll("input[data-item-id]").forEach((input) => {
      if (input instanceof HTMLInputElement) {
        input.checked = false
      }
    })
    this.#syncOutputField()
    this.#syncFormFields()
  }

  confirmSelection() {
    this.#emitConfirmSelection()
  }

  #emitConfirmSelection({ closeModal = false } = {}) {
    const selection = this.#selectedItems()
    this.#syncOutputField(selection)
    this.#syncFormFields(selection)

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

    if (closeModal) {
      this.#closeModal()
    }
  }

  #autoConfirmSelectionIfNeeded({ selected = false, wasSelected = false } = {}) {
    if (this.selectionModeValue !== "single" || !this.autoConfirmValue || !selected || wasSelected) {
      return
    }

    this.#emitConfirmSelection({ closeModal: this.modalValue })

    if (this.#hasFormMode()) {
      this.#submitForm()
    }
  }

  #closeModal() {
    if (!this.modalValue) {
      return
    }

    const modalElement = this.element.closest("[data-controller~='flat-pack--modal']")
    if (!(modalElement instanceof HTMLElement)) {
      return
    }

    const controller = this.application.getControllerForElementAndIdentifier(modalElement, "flat-pack--modal")
    if (controller && typeof controller.close === "function") {
      controller.close()
    }
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
    const kind = this.#normalizedKind(item.kind)
    const title = this.#escapeHtml(String(item.title || item.label || item.name || "Untitled"))
    const thumbnailUrl = String(item.thumbnail_url || "")
    const description = this.#escapeHtml(String(item.description || ""))
    const rightText = this.#escapeHtml(String(item.right_text || ""))
    const isSelected = this.selectedIds.has(String(item.id))
    const isChecked = isSelected ? "checked" : ""
    const controlType = this.selectionModeValue === "single" ? "radio" : "checkbox"
    const controlName = `picker_${this.#escapeHtml(this.pickerIdValue)}_selection`
    const hasThumbnailPreview = Boolean(thumbnailUrl)
    const controlClass = hasThumbnailPreview
      ? "sr-only"
      : (controlType === "checkbox" ? this.#checkboxInputClasses() : "mt-1 cursor-pointer")
    const leadingSlot = this.#listLeadingSlotMarkup(item, { isSelected, title })
    const descriptionMarkup = description
      ? `<span class="mt-1 block text-xs text-(--surface-muted-content-color)">${description}</span>`
      : ""
    const rightTextMarkup = rightText
      ? `<span class="shrink-0 text-right text-xs text-(--surface-muted-content-color)">${rightText}</span>`
      : ""

    return `
      <div class="flat-pack-checkbox-wrapper">
        <label class="flex cursor-pointer items-start gap-3 rounded-md border border-(--surface-border-color) bg-(--surface-background-color) p-3 transition-colors duration-base hover:bg-(--list-item-hover-background-color)">
          <input
            type="${controlType}"
            name="${controlName}"
            class="${controlClass}"
            data-item-id="${itemId}"
            ${isChecked}
            data-action="change->flat-pack--picker#handleSelectionChange"
          >
          ${leadingSlot}
          <span class="min-w-0 flex-1">
            <span class="block truncate text-sm font-medium text-(--surface-content-color)">${title}</span>
            ${descriptionMarkup}
          </span>
          ${rightTextMarkup}
        </label>
      </div>
    `
  }

  #listLeadingSlotMarkup(item, { isSelected = false, title = "Untitled" } = {}) {
    const thumbnailUrl = this.#escapeHtml(String(item.thumbnail_url || ""))

    if (thumbnailUrl) {
      return `
        <span class="relative inline-flex h-14 w-20 shrink-0 overflow-hidden rounded">
          ${this.#selectionIndicatorMarkup(isSelected, "left-2 top-2")}
          <img src="${thumbnailUrl}" alt="${title} preview" class="h-14 w-20 rounded object-cover" loading="lazy">
        </span>`
    }

    const icon = this.#escapeHtml(String(item.icon || ""))
    if (!icon) {
      return this.#listFallbackPreviewMarkup(this.#normalizedKind(item.kind), item)
    }

    return `
      <span class="inline-flex h-10 w-10 shrink-0 items-center justify-center rounded-md bg-(--surface-subtle-background-color) text-(--surface-muted-content-color)">
        <svg
          class="h-5 w-5"
          viewBox="0 0 24 24"
          aria-hidden="true"
          data-controller="flat-pack--icon"
          data-flat-pack--icon-name-value="${icon}"
          data-flat-pack--icon-variant-value="outline"
        ></svg>
      </span>
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

  #selectionIndicatorMarkup(isSelected, positionClasses = "") {
    const indicatorClasses = this.#selectionIndicatorClasses(isSelected)

    return `
      <span
        class="pointer-events-none absolute z-10 inline-flex h-5 w-5 items-center justify-center rounded-full border-2 border-white text-white ring-1 ${this.#escapeHtml(positionClasses)} ${indicatorClasses}"
        data-picker-selection-indicator
      >
        <span class="h-1.5 w-1.5 rounded-full bg-white ${isSelected ? "opacity-100" : "opacity-0"}"></span>
      </span>
    `
  }

  #gridItemMarkup(item) {
    const itemId = this.#escapeHtml(String(item.id))
    const kind = this.#normalizedKind(item.kind)
    const label = this.#escapeHtml(String(item.title || item.label || item.name || "Untitled"))
    const name = this.#escapeHtml(String(item.name || ""))
    const contentType = this.#escapeHtml(String(item.contentType || ""))
    const byteSize = Number.isFinite(item.byteSize) ? item.byteSize : ""
    const thumbnailUrl = this.#escapeHtml(String(item.thumbnail_url || ""))
    const description = this.#escapeHtml(String(item.description || ""))
    const path = this.#escapeHtml(String(item.path || ""))
    const badge = this.#escapeHtml(String(item.badge || ""))
    const isChecked = this.selectedIds.has(String(item.id)) ? "checked" : ""
    const indicatorClasses = this.#selectionIndicatorClasses(this.selectedIds.has(String(item.id)))
    const isPressed = this.selectedIds.has(String(item.id)) ? "true" : "false"

    const preview = kind === "image" && thumbnailUrl
      ? `<img src="${thumbnailUrl}" alt="${label} preview" class="h-28 w-full rounded-md object-cover" loading="lazy">`
      : this.#gridFallbackPreviewMarkup(kind, item)

    const badgeMarkup = badge
      ? `<span class="pointer-events-none absolute left-3 top-3 z-10 inline-flex items-center rounded-full bg-black/55 px-2 py-1 text-[11px] font-medium text-white">${badge}</span>`
      : ""

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
        ${badgeMarkup}
        ${preview}
        <span class="hidden"
          data-kind="${this.#escapeHtml(kind)}"
          data-name="${name}"
          data-content-type="${contentType}"
          data-byte-size="${byteSize}"
          data-thumbnail-url="${thumbnailUrl}"
          data-description="${description}"
          data-path="${path}"
          data-badge="${badge}">
        </span>
      </button>
    `
  }

  #selectionIndicatorClasses(isSelected) {
    return isSelected
      ? "bg-(--primary-color) ring-(--primary-color)"
      : "bg-black/30 ring-black/20"
  }

  #listFallbackPreviewMarkup(kind, item) {
    return ""
  }

  #gridFallbackPreviewMarkup(kind, item) {
    if (kind === "file") {
      const label = this.#escapeHtml(String(item.label || item.name || "Untitled"))
      const meta = this.#escapeHtml(this.#metaText(item))

      return `
        <span class="flex h-28 w-full flex-col justify-center rounded-md bg-(--surface-subtle-background-color) px-4 text-left">
          <span class="truncate text-sm font-medium text-(--surface-content-color)">${label}</span>
          <span class="mt-1 truncate text-xs text-(--surface-muted-content-color)">${meta}</span>
        </span>
      `
    }

    return `<span class="inline-flex h-28 w-full items-center justify-center rounded-md bg-(--surface-subtle-background-color) text-sm text-(--surface-muted-content-color)">${this.#kindPreviewToken(kind, item)}</span>`
  }

  #resultsContainerClass() {
    if (this.#isGridLayout()) {
      return "grid grid-cols-2 gap-3 sm:grid-cols-3"
    }

    return "space-y-2"
  }

  #resultsNeedSelectionRefresh() {
    return this.#isGridLayout() || this.resultsTarget.querySelector("[data-picker-selection-indicator]") !== null
  }

  #isGridLayout() {
    return this.resultsLayoutValue === "grid"
  }

  #metaText(item) {
    const parts = []

    if (item.kind === "record") {
      if (item.path) {
        parts.push(item.path)
      }

      if (item.meta) {
        parts.push(item.meta)
      }

      return parts.join(" • ")
    }

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
        title: item.title || item.label,
        name: item.name,
        contentType: item.contentType || null,
        byteSize: Number.isFinite(item.byteSize) ? item.byteSize : null,
        thumbnail_url: item.thumbnail_url || null,
        icon: item.icon || null,
        description: item.description || null,
        right_text: item.right_text || null,
        path: item.path || null,
        badge: item.badge || null,
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

  #syncFormFields(selection = null) {
    if (!this.#hasFormMode() || !this.hasFormFieldsTarget) {
      return
    }

    const selected = selection || this.#selectedItems()
    const formConfig = this.formValue || {}
    const fieldName = this.#fieldInputName(formConfig)

    if (!fieldName) {
      this.formFieldsTarget.innerHTML = ""
      return
    }

    if (formConfig.valueMode === "json") {
      this.formFieldsTarget.innerHTML = this.#hiddenInputMarkup(fieldName, JSON.stringify(selected))
      return
    }

    const values = this.#selectedFormValues(selected, formConfig)

    if (formConfig.valueMode === "id") {
      this.formFieldsTarget.innerHTML = this.#hiddenInputMarkup(fieldName, values[0] || "")
      return
    }

    this.formFieldsTarget.innerHTML = values
      .map((value) => this.#hiddenInputMarkup(`${fieldName}[]`, value))
      .join("")
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
      const kind = this.#normalizedKind(source.kind)
      const label = source.label || source.title || source.name || `Item ${index + 1}`
      const byteSize = this.#normalizeByteSize(source.byteSize ?? source.byte_size)
      const contentType = source.contentType || source.content_type || null
      const thumbnailUrl = source.thumbnail_url || null
      const description = this.#displayDescription(source, kind, { contentType, byteSize })
      return {
        id,
        kind,
        label,
        title: source.title || label,
        name: source.name || label || `item-${index + 1}`,
        contentType,
        byteSize,
        thumbnail_url: thumbnailUrl,
        icon: this.#displayIcon(source, kind, thumbnailUrl),
        description,
        right_text: this.#displayRightText(source),
        path: source.path || null,
        badge: source.badge || null,
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
      item.title,
      item.label,
      item.name,
      item.contentType,
      item.description,
      item.right_text,
      item.path,
      item.badge,
      item.meta,
      item.icon,
      item.kind
    ].join(" ").toLowerCase()

    return haystack.includes(query.toLowerCase())
  }

  #normalizedKind(kind) {
    const value = String(kind || "")

    if (["image", "file", "record"].includes(value)) {
      return value
    }

    return "file"
  }

  #kindPreviewToken(kind, item) {
    if (kind === "image") {
      return "IMG"
    }

    if (kind === "record") {
      return String(item.badge || "REC").slice(0, 6).toUpperCase()
    }

    return "FILE"
  }

  #normalizeByteSize(value) {
    if (Number.isFinite(value)) {
      return value
    }

    const parsed = Number.parseInt(value, 10)
    return Number.isFinite(parsed) && parsed > 0 ? parsed : null
  }

  #displayDescription(source, kind, { contentType = null, byteSize = null } = {}) {
    const explicitDescription = source.description || null
    const path = source.path || null

    if (explicitDescription || path) {
      return [explicitDescription, path].filter(Boolean).join(" • ")
    }

    if (kind === "record") {
      return null
    }

    return [contentType, Number.isFinite(byteSize) ? this.#humanSize(byteSize) : null]
      .filter(Boolean)
      .join(" • ") || null
  }

  #displayRightText(source) {
    return source.right_text || source.meta || source.badge || null
  }

  #displayIcon(source, kind, thumbnailUrl) {
    if (source.icon) {
      return source.icon
    }

    if (thumbnailUrl) {
      return null
    }

    if (kind === "image") {
      return "photo"
    }

    if (kind === "record") {
      return "folder"
    }

    return "document-text"
  }

  #escapeHtml(value) {
    return String(value)
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;")
      .replaceAll("'", "&#39;")
  }

  #selectedFormValues(selection, formConfig) {
    return selection
      .map((item) => this.#valueAtPath(item, formConfig.valuePath || "id"))
      .filter((value) => value !== null && value !== undefined && String(value) !== "")
      .map((value) => String(value))
  }

  #valueAtPath(item, path) {
    return String(path || "id")
      .split(".")
      .filter(Boolean)
      .reduce((current, key) => {
        if (current === null || current === undefined || typeof current !== "object") {
          return undefined
        }

        return current[key]
      }, item)
  }

  #fieldInputName(formConfig) {
    const field = String(formConfig.field || "").trim()
    if (!field) {
      return ""
    }

    const scope = String(formConfig.scope || "").trim()
    return scope ? `${scope}[${field}]` : field
  }

  #hiddenInputMarkup(name, value) {
    return `<input type="hidden" name="${this.#escapeHtml(name)}" value="${this.#escapeHtml(value)}">`
  }

  #hasFormMode() {
    return this.hasFormValue && Boolean(this.formValue?.field)
  }

  #submitForm() {
    const form = this.element.closest("form")
    if (!(form instanceof HTMLFormElement)) {
      return
    }

    form.requestSubmit()
  }
}
