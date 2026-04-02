import { Controller } from "@hotwired/stimulus"

const ACCEPTED_KINDS = ["image", "file", "record"]

export default class extends Controller {
  static targets = ["searchInput", "results", "emptyState", "outputField", "formFields"]

  static values = {
    config: Object
  }

  connect() {
    this.config = this.#normalizedConfig()
    this.state = this.#buildState()
    this.debounceTimer = null
    this.abortController = null

    this.#renderResults()
    this.#syncOutputs()
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

    if (!this.config.search.enabled) {
      return
    }

    if (this.config.search.mode === "remote") {
      this.#searchRemote(query)
      return
    }

    this.state.visibleItems = this.#filterLocalItems(query)
    this.#renderResults()
  }

  handleSelectionChange(event) {
    const control = event?.target
    if (!(control instanceof HTMLInputElement)) {
      return
    }

    const item = this.#visibleItemById(control.dataset.itemId)
    if (!item) {
      return
    }

    const wasSelected = this.#isSelected(item.id)
    this.#setItemSelected(item, control.checked)
    this.#syncSelectionState()
    this.#autoConfirmSelectionIfNeeded({ selected: control.checked, wasSelected })
  }

  selectGridItem(event) {
    const trigger = event?.currentTarget
    if (!(trigger instanceof HTMLElement)) {
      return
    }

    const item = this.#visibleItemById(trigger.dataset.itemId)
    if (!item) {
      return
    }

    const wasSelected = this.#isSelected(item.id)
    const nextSelected = this.config.selection.mode === "single" ? true : !wasSelected

    this.#setItemSelected(item, nextSelected)
    this.#syncSelectionState()
    this.#autoConfirmSelectionIfNeeded({ selected: nextSelected, wasSelected })
  }

  clearSelection() {
    this.state.selectedItems.clear()
    this.#syncSelectionState()
  }

  confirmSelection() {
    this.#emitConfirmSelection()
  }

  #emitConfirmSelection({ closeModal = false } = {}) {
    const selection = this.#selectedItems()
    this.#syncOutputs(selection)

    this.element.dispatchEvent(new CustomEvent("flat-pack:picker:confirm", {
      bubbles: true,
      detail: {
        pickerId: this.config.pickerId,
        selection,
        selectionMode: this.config.selection.mode,
        acceptedKinds: this.config.selection.acceptedKinds,
        context: this.config.context
      }
    }))

    if (closeModal) {
      this.#closeModal()
    }
  }

  #autoConfirmSelectionIfNeeded({ selected = false, wasSelected = false } = {}) {
    if (this.config.selection.mode !== "single" || !this.config.selection.autoConfirm || !selected || wasSelected) {
      return
    }

    this.#emitConfirmSelection({ closeModal: this.config.presentation.modal })

    if (this.#hasFormMode()) {
      this.#submitForm()
    }
  }

  #closeModal() {
    if (!this.config.presentation.modal) {
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
    if (!this.config.search.endpoint) {
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

      const url = new URL(this.config.search.endpoint, window.location.origin)
      url.searchParams.set(this.config.search.param, query)

      if (this.config.selection.acceptedKinds.length > 0) {
        url.searchParams.set("kinds", this.config.selection.acceptedKinds.join(","))
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
        this.state.visibleItems = this.#normalizeItems(payload?.items || [])
        this.#rememberItems(this.state.visibleItems)
        this.#renderResults()
      } catch (error) {
        if (error?.name !== "AbortError") {
          this.state.visibleItems = []
          this.#renderResults()
        }
      }
    }, 250)
  }

  #syncSelectionState() {
    this.#renderResults()
    this.#syncOutputs()
  }

  #syncOutputs(selection = this.#selectedItems()) {
    this.#syncOutputField(selection)
    this.#syncFormFields(selection)
  }

  #renderResults() {
    if (!this.hasResultsTarget) {
      return
    }

    const items = this.state.visibleItems
    this.resultsTarget.className = this.#resultsContainerClass()
    this.resultsTarget.innerHTML = items.map((item) => this.#itemMarkup(item)).join("")

    if (!this.hasEmptyStateTarget) {
      return
    }

    if (items.length === 0) {
      this.emptyStateTarget.textContent = this.config.emptyStateText
      this.emptyStateTarget.classList.remove("hidden")
      this.emptyStateTarget.classList.add("flex")
      return
    }

    this.emptyStateTarget.classList.add("hidden")
    this.emptyStateTarget.classList.remove("flex")
  }

  #itemMarkup(item) {
    const view = this.#itemView(item)
    return this.#isGridLayout() ? this.#gridItemMarkup(view) : this.#listItemMarkup(view)
  }

  #listItemMarkup(view) {
    const preview = view.hasThumbnailPreview
      ? `
        <span class="relative inline-flex h-14 w-20 shrink-0 overflow-hidden rounded">
          ${this.#selectionIndicatorMarkup(view.isSelected, "left-2 top-2")}
          <img src="${view.thumbnailUrl}" alt="${view.label} preview" class="h-14 w-20 rounded object-cover" loading="lazy">
        </span>`
      : this.#listFallbackPreviewMarkup(view)

    const recordDescription = view.kind === "record" && view.description
      ? `<span class="mt-1 block truncate text-xs text-(--surface-muted-content-color)">${view.description}</span>`
      : ""

    const badgeMarkup = view.badge
      ? `<span class="inline-flex shrink-0 items-center rounded-full bg-(--surface-subtle-background-color) px-2 py-1 text-[11px] font-medium text-(--surface-muted-content-color)">${view.badge}</span>`
      : ""

    return `
      <div class="flat-pack-checkbox-wrapper">
        <label class="flex cursor-pointer items-start gap-3 rounded-md border border-(--surface-border-color) bg-(--surface-background-color) p-3 transition-colors duration-base hover:bg-[var(--list-item-hover-background-color)]">
          <input
            type="${view.controlType}"
            name="${view.controlName}"
            class="${view.controlClass}"
            data-item-id="${view.id}"
            ${view.isChecked}
            data-action="change->flat-pack--picker#handleSelectionChange"
          >
          ${preview}
          <span class="min-w-0 flex-1">
            <span class="block truncate text-sm font-medium text-(--surface-content-color)">${view.label}</span>
            ${recordDescription}
            <span class="block truncate text-xs text-(--surface-muted-content-color)">${view.meta}</span>
          </span>
          ${badgeMarkup}
        </label>
      </div>
    `
  }

  #gridItemMarkup(view) {
    const preview = view.kind === "image" && view.thumbnailUrl
      ? `<img src="${view.thumbnailUrl}" alt="${view.label} preview" class="h-28 w-full rounded-md object-cover" loading="lazy">`
      : this.#gridFallbackPreviewMarkup(view)

    const badgeMarkup = view.badge
      ? `<span class="pointer-events-none absolute left-3 top-3 z-10 inline-flex items-center rounded-full bg-black/55 px-2 py-1 text-[11px] font-medium text-white">${view.badge}</span>`
      : ""

    return `
      <button
          type="button"
          class="relative block w-full cursor-pointer"
          aria-pressed="${view.isPressed}"
          data-item-id="${view.id}"
          data-action="click->flat-pack--picker#selectGridItem"
        >
        <span class="pointer-events-none absolute bottom-3 right-3 z-10 inline-flex h-5 w-5 items-center justify-center rounded-full border-2 border-white text-white ring-1 ${this.#selectionIndicatorClasses(view.isSelected)}">
          <span class="h-1.5 w-1.5 rounded-full bg-white ${view.isSelected ? "opacity-100" : "opacity-0"}"></span>
        </span>
        ${badgeMarkup}
        ${preview}
      </button>
    `
  }

  #listFallbackPreviewMarkup(_view) {
    return ""
  }

  #gridFallbackPreviewMarkup(view) {
    if (view.kind === "file") {
      return `
        <span class="flex h-28 w-full flex-col justify-center rounded-md bg-(--surface-subtle-background-color) px-4 text-left">
          <span class="truncate text-sm font-medium text-(--surface-content-color)">${view.label}</span>
          <span class="mt-1 truncate text-xs text-(--surface-muted-content-color)">${view.meta}</span>
        </span>
      `
    }

    return `<span class="inline-flex h-28 w-full items-center justify-center rounded-md bg-(--surface-subtle-background-color) text-sm text-(--surface-muted-content-color)">${this.#kindPreviewToken(view.kind, view.badge)}</span>`
  }

  #itemView(item) {
    const isSelected = this.#isSelected(item.id)
    const hasThumbnailPreview = item.kind === "image" && Boolean(item.thumbnailUrl)
    const controlType = this.config.selection.mode === "single" ? "radio" : "checkbox"

    return {
      id: this.#escapeHtml(item.id),
      kind: this.#escapeHtml(item.kind),
      label: this.#escapeHtml(item.label),
      name: this.#escapeHtml(item.name),
      contentType: this.#escapeHtml(item.contentType || ""),
      byteSize: Number.isFinite(item.byteSize) ? item.byteSize : "",
      thumbnailUrl: this.#escapeHtml(item.thumbnailUrl || ""),
      description: this.#escapeHtml(item.description || ""),
      path: this.#escapeHtml(item.path || ""),
      badge: this.#escapeHtml(item.badge || ""),
      meta: this.#escapeHtml(this.#metaText(item)),
      hasThumbnailPreview,
      isSelected,
      isChecked: isSelected ? "checked" : "",
      isPressed: isSelected ? "true" : "false",
      controlType,
      controlName: `picker_${this.#escapeHtml(this.config.pickerId)}_selection`,
      controlClass: hasThumbnailPreview
        ? "sr-only"
        : (controlType === "checkbox" ? this.#checkboxInputClasses() : "mt-1 cursor-pointer")
    }
  }

  #selectionIndicatorMarkup(isSelected, positionClasses = "") {
    return `
      <span
        class="pointer-events-none absolute z-10 inline-flex h-5 w-5 items-center justify-center rounded-full border-2 border-white text-white ring-1 ${this.#escapeHtml(positionClasses)} ${this.#selectionIndicatorClasses(isSelected)}"
        data-picker-selection-indicator
      >
        <span class="h-1.5 w-1.5 rounded-full bg-white ${isSelected ? "opacity-100" : "opacity-0"}"></span>
      </span>
    `
  }

  #selectionIndicatorClasses(isSelected) {
    return isSelected
      ? "bg-(--primary-color) ring-(--primary-color)"
      : "bg-black/30 ring-black/20"
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

  #resultsContainerClass() {
    return this.#isGridLayout() ? "grid grid-cols-2 gap-3 sm:grid-cols-3" : "space-y-2"
  }

  #isGridLayout() {
    return this.config.presentation.resultsLayout === "grid"
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
    return [...this.state.selectedItems.values()].map((item) => ({
      id: item.id,
      kind: item.kind,
      label: item.label,
      name: item.name,
      contentType: item.contentType || null,
      byteSize: Number.isFinite(item.byteSize) ? item.byteSize : null,
      thumbnailUrl: item.thumbnailUrl || null,
      description: item.description || null,
      path: item.path || null,
      badge: item.badge || null,
      meta: item.meta || null,
      payload: item.payload || {}
    }))
  }

  #syncOutputField(selection) {
    if (this.config.output.mode !== "field") {
      return
    }

    const encoded = JSON.stringify(selection)

    if (this.config.output.target) {
      const targetElement = document.querySelector(this.config.output.target)
      if (targetElement) {
        targetElement.value = encoded
      }
    }

    if (this.hasOutputFieldTarget) {
      this.outputFieldTarget.value = encoded
    }
  }

  #syncFormFields(selection) {
    if (!this.#hasFormMode() || !this.hasFormFieldsTarget) {
      return
    }

    const formConfig = this.config.output.form
    const fieldName = this.#fieldInputName(formConfig)

    if (!fieldName) {
      this.formFieldsTarget.innerHTML = ""
      return
    }

    if (formConfig.valueMode === "json") {
      this.formFieldsTarget.innerHTML = this.#hiddenInputMarkup(fieldName, JSON.stringify(selection))
      return
    }

    const values = this.#selectedFormValues(selection, formConfig)

    if (formConfig.valueMode === "id") {
      this.formFieldsTarget.innerHTML = this.#hiddenInputMarkup(fieldName, values[0] || "")
      return
    }

    this.formFieldsTarget.innerHTML = values
      .map((value) => this.#hiddenInputMarkup(`${fieldName}[]`, value))
      .join("")
  }

  #buildState() {
    const baseItems = this.#normalizeItems(this.config.items)

    return {
      baseItems,
      visibleItems: [...baseItems],
      selectedItems: new Map()
    }
  }

  #filterLocalItems(query) {
    return this.state.baseItems.filter((item) => this.#matchesQuery(item, query))
  }

  #normalizeItems(items) {
    return (Array.isArray(items) ? items : [])
      .map((item, index) => this.#normalizeItem(item, index))
      .filter(Boolean)
      .filter((item) => this.#acceptsKind(item.kind))
  }

  #normalizeItem(item, index) {
    const source = this.#normalizeSource(item)
    const name = this.#pickValue(source, ["name"])

    if (!name) {
      return null
    }

    return {
      id: this.#pickValue(source, ["id"]) || `picker-item-${index}`,
      kind: this.#normalizedKind(this.#pickRawValue(source, ["kind"])),
      label: this.#pickValue(source, ["label"]) || name,
      name,
      contentType: this.#pickValue(source, ["contentType", "content_type"]),
      byteSize: this.#normalizeSize(this.#pickRawValue(source, ["byteSize", "byte_size"])),
      thumbnailUrl: this.#pickValue(source, ["thumbnailUrl", "thumbnail_url"]),
      description: this.#pickValue(source, ["description"]),
      path: this.#pickValue(source, ["path"]),
      badge: this.#pickValue(source, ["badge"]),
      meta: this.#pickValue(source, ["meta"]),
      payload: this.#normalizePayload(this.#pickRawValue(source, ["payload"]))
    }
  }

  #normalizePayload(payload) {
    if (!payload || typeof payload !== "object" || Array.isArray(payload)) {
      return {}
    }

    return Object.entries(payload).reduce((result, [key, value]) => {
      result[String(key)] = this.#normalizePayloadValue(value)
      return result
    }, {})
  }

  #normalizePayloadValue(value) {
    if (Array.isArray(value)) {
      return value.map((item) => this.#normalizePayloadValue(item))
    }

    if (value && typeof value === "object") {
      return Object.entries(value).reduce((result, [key, nestedValue]) => {
        result[String(key)] = this.#normalizePayloadValue(nestedValue)
        return result
      }, {})
    }

    return value
  }

  #normalizeSource(item) {
    return item && typeof item === "object" ? item : {}
  }

  #pickValue(source, keys) {
    const value = this.#pickRawValue(source, keys)

    if (value === null || value === undefined) {
      return null
    }

    if (typeof value === "string") {
      const trimmed = value.trim()
      return trimmed === "" ? null : trimmed
    }

    return value
  }

  #pickRawValue(source, keys) {
    for (const key of keys) {
      if (Object.prototype.hasOwnProperty.call(source, key)) {
        return source[key]
      }
    }

    return undefined
  }

  #acceptsKind(kind) {
    return this.config.selection.acceptedKinds.length === 0 || this.config.selection.acceptedKinds.includes(kind)
  }

  #matchesQuery(item, query) {
    if (!query) {
      return true
    }

    const haystack = [
      item.label,
      item.name,
      item.contentType,
      item.description,
      item.path,
      item.badge,
      item.meta,
      item.kind
    ].join(" ").toLowerCase()

    return haystack.includes(query.toLowerCase())
  }

  #normalizedKind(kind) {
    const value = String(kind || "")
    return ACCEPTED_KINDS.includes(value) ? value : "file"
  }

  #normalizeSize(value) {
    const parsed = Number.parseInt(value, 10)
    return Number.isFinite(parsed) && parsed > 0 ? parsed : null
  }

  #setItemSelected(item, selected) {
    const itemId = String(item.id)

    if (this.config.selection.mode === "single") {
      this.state.selectedItems.clear()
      if (selected) {
        this.state.selectedItems.set(itemId, item)
      }
      return
    }

    if (selected) {
      this.state.selectedItems.set(itemId, item)
    } else {
      this.state.selectedItems.delete(itemId)
    }
  }

  #rememberItems(items) {
    items.forEach((item) => {
      const itemId = String(item.id)

      if (this.state.selectedItems.has(itemId)) {
        this.state.selectedItems.set(itemId, item)
      }
    })
  }

  #visibleItemById(itemId) {
    const targetId = String(itemId || "")
    return this.state.visibleItems.find((item) => String(item.id) === targetId) || null
  }

  #isSelected(itemId) {
    return this.state.selectedItems.has(String(itemId))
  }

  #kindPreviewToken(kind, badge) {
    if (kind === "image") {
      return "IMG"
    }

    if (kind === "record") {
      return String(badge || "REC").slice(0, 6).toUpperCase()
    }

    return "FILE"
  }

  #fieldInputName(formConfig) {
    const field = String(formConfig?.field || "").trim()
    if (!field) {
      return ""
    }

    const scope = String(formConfig?.scope || "").trim()
    return scope ? `${scope}[${field}]` : field
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

  #hiddenInputMarkup(name, value) {
    return `<input type="hidden" name="${this.#escapeHtml(name)}" value="${this.#escapeHtml(value)}">`
  }

  #hasFormMode() {
    return Boolean(this.config.output.form?.field)
  }

  #submitForm() {
    const form = this.element.closest("form")
    if (!(form instanceof HTMLFormElement)) {
      return
    }

    form.requestSubmit()
  }

  #normalizedConfig() {
    const config = this.hasConfigValue && this.configValue ? this.configValue : {}

    return {
      pickerId: String(config.pickerId || ""),
      items: this.#normalizeSourceItems(config.items),
      presentation: {
        modal: Boolean(config.presentation?.modal),
        resultsLayout: config.presentation?.resultsLayout === "grid" ? "grid" : "list"
      },
      selection: {
        mode: config.selection?.mode === "single" ? "single" : "multiple",
        acceptedKinds: this.#normalizeAcceptedKinds(config.selection?.acceptedKinds),
        autoConfirm: Boolean(config.selection?.autoConfirm)
      },
      search: {
        enabled: Boolean(config.search?.enabled),
        mode: config.search?.mode === "remote" ? "remote" : "local",
        endpoint: String(config.search?.endpoint || ""),
        param: String(config.search?.param || "q")
      },
      output: {
        mode: config.output?.mode === "field" ? "field" : "event",
        target: String(config.output?.target || ""),
        form: this.#normalizeFormConfig(config.output?.form)
      },
      context: config.context && typeof config.context === "object" ? config.context : {},
      emptyStateText: String(config.emptyStateText || "No assets found")
    }
  }

  #normalizeSourceItems(items) {
    return Array.isArray(items) ? items : []
  }

  #normalizeAcceptedKinds(kinds) {
    const normalized = (Array.isArray(kinds) ? kinds : [])
      .map((kind) => this.#normalizedKind(kind))
      .filter((kind, index, array) => array.indexOf(kind) === index)

    return normalized.length > 0 ? normalized : [...ACCEPTED_KINDS]
  }

  #normalizeFormConfig(formConfig) {
    if (!formConfig || typeof formConfig !== "object") {
      return null
    }

    const field = String(formConfig.field || "").trim()
    if (!field) {
      return null
    }

    const valueMode = ["id", "ids", "json"].includes(String(formConfig.valueMode))
      ? String(formConfig.valueMode)
      : "id"

    return {
      field,
      scope: String(formConfig.scope || "").trim(),
      valueMode,
      valuePath: String(formConfig.valuePath || "id")
    }
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
