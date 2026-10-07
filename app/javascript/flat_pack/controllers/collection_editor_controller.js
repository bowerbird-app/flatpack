import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["list", "template", "empty", "addButton", "status"]
  static values = {
    templateIndex: {type: String, default: "NEW_RECORD"}
  }

  connect() {
    this.onDocumentClick = this.closeOnOutside.bind(this)
    this.onReordered = this.announceReorder.bind(this)
    document.addEventListener("click", this.onDocumentClick)
    this.element.addEventListener("list:reordered", this.onReordered)
    this.refreshEmpty()
  }

  disconnect() {
    document.removeEventListener("click", this.onDocumentClick)
    this.element.removeEventListener("list:reordered", this.onReordered)
  }

  add(event) {
    event.preventDefault()
    if (!this.hasTemplateTarget || !this.hasListTarget) return

    const index = this.uniqueIndex()
    const html = this.replaceTemplateIndex(this.templateTarget.innerHTML, this.templateIndexValue, index)
    const holder = document.createElement("div")
    holder.innerHTML = html.trim()
    const row = holder.querySelector("[data-collection-editor-row]")
    if (!row) return

    this.listTarget.append(row)
    this.refreshEmpty()
    this.showPanel(row)
    row.querySelector("[data-collection-editor-search]")?.focus()
  }

  remove(event) {
    event.preventDefault()
    const row = this.rowFrom(event)
    if (!row) return

    if (row.dataset.persisted === "true") {
      const field = row.querySelector("[data-collection-editor-destroy]")
      if (field) field.value = "1"
      row.dataset.collectionEditorDestroyed = "true"
      row.hidden = true
    } else {
      row.remove()
    }

    this.refreshEmpty()
    if (this.hasAddButtonTarget) this.addButtonTarget.focus()
  }

  openPicker(event) {
    const row = this.rowFrom(event)
    if (!row) return

    const panel = row.querySelector("[data-collection-editor-panel]")
    const wasHidden = Boolean(panel?.hidden)
    this.showPanel(row)
    if (wasHidden && event.type !== "focus") {
      row.querySelector("[data-collection-editor-search]")?.focus()
    }
  }

  search(event) {
    const row = this.rowFrom(event)
    if (!row) return

    const query = event.currentTarget.value || ""
    this.updateCreateLabel(row, query)
    window.clearTimeout(row._searchTimer)
    row._searchTimer = window.setTimeout(() => this.runSearch(row, query), 250)
  }

  searchKeydown(event) {
    const row = this.rowFrom(event)
    if (!row) return

    const options = this.options(row)
    if (event.key === "ArrowDown" || event.key === "ArrowUp") {
      event.preventDefault()
      if (options.length === 0) return

      const delta = event.key === "ArrowDown" ? 1 : -1
      const next = (row._activeIndex ?? -1) + delta
      this.setActive(row, Math.max(0, Math.min(options.length - 1, next)))
      return
    }

    if (event.key === "Enter") {
      event.preventDefault()
      const active = options[row._activeIndex]
      if (active) {
        this.applySelection(row, active.dataset)
        return
      }
      if (options.length === 1) {
        this.applySelection(row, options[0].dataset)
        return
      }
      if (options.length === 0 && this.searchMissed(row)) this.promptCreate(event)
    }

    if (event.key === "Escape") {
      event.preventDefault()
      this.closePanel(row)
    }
  }

  promptCreate(event) {
    event.preventDefault()
    const row = this.rowFrom(event)
    if (!row) return

    const fields = row.querySelector("[data-collection-editor-create-fields]")
    const query = row.querySelector("[data-collection-editor-search]")?.value || ""
    if (!fields || !fields.querySelector("[data-create-field]")) {
      this.create(event)
      return
    }

    fields.hidden = false
    const prompt = row.querySelector("[data-collection-editor-create-button]")
    if (prompt) prompt.hidden = true
    fields.querySelectorAll("[data-fill-from-query]").forEach((input) => {
      if (!input.value) input.value = query
    })
    fields.querySelector("[data-create-field]")?.focus()
  }

  async create(event) {
    event.preventDefault()
    const row = this.rowFrom(event)
    if (!row || !row.dataset.createUrl || row.dataset.creating === "true") return

    row.dataset.creating = "true"
    const body = new URLSearchParams()
    const query = row.querySelector("[data-collection-editor-search]")?.value || ""
    body.set(row.dataset.searchParam || "q", query)
    row.querySelectorAll("[data-create-field]").forEach((input) => {
      const key = input.dataset.createField
      if (key) body.set(key, input.value)
    })

    this.clearCreateError(row)

    try {
      const response = await fetch(row.dataset.createUrl, {
        method: "POST",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
          "X-CSRF-Token": this.csrfToken,
          Accept: "application/json"
        },
        body: body.toString(),
        credentials: "same-origin"
      })
      const payload = await response.json()
      const item = this.normalizeItem(payload?.item)

      if (!response.ok || payload?.ok === false || !item) {
        this.showCreateError(row, this.errorMessages(payload))
        return
      }

      this.applySelection(row, item)
    } catch (_error) {
      this.showCreateError(row, ["Could not create the record"])
    } finally {
      delete row.dataset.creating
    }
  }

  async runSearch(row, query) {
    const minimum = Number(row.dataset.minSearchLength || "1")
    if (query.trim().length < minimum) {
      this.renderResults(row, [])
      this.toggleNoResults(row, false)
      this.toggleSearchError(row, false)
      return
    }

    if (row._searchAbort) row._searchAbort.abort()

    if (!row.dataset.searchUrl) {
      const needle = query.trim().toLowerCase()
      const matches = this.localItems(row).filter((item) => {
        return `${item.title} ${item.description}`.toLowerCase().includes(needle)
      })
      this.renderResults(row, matches)
      this.toggleNoResults(row, matches.length === 0)
      this.toggleSearchError(row, false)
      return
    }

    const controller = new AbortController()
    row._searchAbort = controller
    const url = new URL(row.dataset.searchUrl, window.location.origin)
    url.searchParams.set(row.dataset.searchParam || "q", query.trim())

    try {
      const response = await fetch(url.toString(), {
        method: "GET",
        headers: {Accept: "application/json"},
        signal: controller.signal,
        credentials: "same-origin"
      })
      const payload = await response.json()
      const items = this.normalizeItems(payload)
      this.renderResults(row, items)
      this.toggleNoResults(row, items.length === 0)
      this.toggleSearchError(row, false)
    } catch (error) {
      if (error?.name === "AbortError") return
      this.renderResults(row, [])
      this.toggleNoResults(row, false)
      this.toggleSearchError(row, true)
    }
  }

  renderResults(row, items) {
    const list = row.querySelector("[data-collection-editor-results]")
    if (!list) return

    list.replaceChildren()
    row._activeIndex = -1
    row.querySelector("[data-collection-editor-search]")?.removeAttribute("aria-activedescendant")
    items.forEach((item) => list.append(this.optionElement(row, item)))
  }

  optionElement(row, item) {
    const option = document.createElement("button")
    option.type = "button"
    option.className = "flat-pack-collection-editor-option"
    option.setAttribute("role", "option")
    const list = row.querySelector("[data-collection-editor-results]")
    row._optionSerial = (row._optionSerial || 0) + 1
    option.id = `${list?.id || "collection-editor-option"}-${row._optionSerial}`
    option.dataset.id = item.id
    option.dataset.title = item.title
    option.dataset.description = item.description || ""

    const title = document.createElement("span")
    title.className = "flat-pack-collection-editor-option-title"
    title.textContent = item.title
    option.append(title)

    if (item.description) {
      const description = document.createElement("span")
      description.className = "flat-pack-collection-editor-option-description"
      description.textContent = item.description
      option.append(description)
    }

    option.addEventListener("click", (event) => {
      event.preventDefault()
      this.applySelection(row, option.dataset)
    })

    return option
  }

  applySelection(row, item) {
    const id = item.id || item.value || ""
    const title = item.title || item.label || ""
    const description = item.description || ""
    const association = row.querySelector("[data-collection-editor-association]")
    if (association) association.value = id

    const summary = row.querySelector("[data-collection-editor-summary]")
    if (summary) summary.hidden = false

    const titleNode = row.querySelector("[data-collection-editor-title]")
    if (titleNode) titleNode.textContent = title

    const descriptionNode = row.querySelector("[data-collection-editor-description]")
    if (descriptionNode) {
      descriptionNode.textContent = description
      descriptionNode.hidden = description.length === 0
    }

    const edit = row.querySelector("[data-collection-editor-edit]")
    if (edit && row.dataset.editUrlTemplate && id) {
      edit.href = row.dataset.editUrlTemplate.replace(":id", encodeURIComponent(id))
      edit.hidden = false
    }

    const change = row.querySelector("[data-collection-editor-change]")
    if (change) change.hidden = false

    const remove = row.querySelector("[data-collection-editor-remove]")
    if (remove && title) remove.setAttribute("aria-label", `Remove ${title}`)

    const handle = row.querySelector("[data-collection-editor-handle]")
    if (handle && title) handle.setAttribute("aria-label", `Reorder ${title}`)

    this.clearCreateError(row)
    this.closePanel(row, {force: true})
    change?.focus()

    row.dispatchEvent(new CustomEvent("collection-editor:selected", {
      bubbles: true,
      detail: {id, title, description}
    }))
  }

  showPanel(row) {
    const panel = row.querySelector("[data-collection-editor-panel]")
    if (panel) panel.hidden = false
    row.querySelector("[data-collection-editor-search]")?.setAttribute("aria-expanded", "true")
  }

  closePanel(row, {force = false} = {}) {
    const association = row.querySelector("[data-collection-editor-association]")
    if (!force && !association?.value) return

    const panel = row.querySelector("[data-collection-editor-panel]")
    if (panel) panel.hidden = true
    row.querySelector("[data-collection-editor-search]")?.setAttribute("aria-expanded", "false")
  }

  closeOnOutside(event) {
    this.element.querySelectorAll("[data-collection-editor-panel]").forEach((panel) => {
      if (panel.hidden) return
      const row = panel.closest("[data-collection-editor-row]")
      if (row && !row.contains(event.target)) this.closePanel(row)
    })
  }

  refreshEmpty() {
    if (!this.hasEmptyTarget) return

    const visible = this.element.querySelectorAll("[data-collection-editor-row]:not([hidden])")
    this.emptyTarget.hidden = visible.length > 0
  }

  updateCreateLabel(row, query) {
    const label = row.querySelector("[data-collection-editor-create-label]")
    if (!label) return

    const fallback = row.dataset.createLabel || "Create"
    label.textContent = query.trim() ? `Create "${query.trim()}"` : fallback
  }

  toggleNoResults(row, show) {
    const node = row.querySelector("[data-collection-editor-no-results]")
    if (node) node.hidden = !show
  }

  showCreateError(row, messages) {
    const node = row.querySelector("[data-collection-editor-create-error]")
    if (!node) return

    node.hidden = false
    node.textContent = messages.filter(Boolean).join(". ")
    const fields = row.querySelector("[data-collection-editor-create-fields]")
    if (fields) fields.hidden = false
  }

  clearCreateError(row) {
    const node = row.querySelector("[data-collection-editor-create-error]")
    if (!node) return

    node.hidden = true
    node.textContent = ""
  }

  errorMessages(payload) {
    if (Array.isArray(payload?.errors)) return payload.errors.map(String)
    if (payload?.errors && typeof payload.errors === "object") {
      return Object.entries(payload.errors).flatMap(([_key, messages]) => [].concat(messages).map(String))
    }
    if (payload?.error) return [String(payload.error)]
    return ["Could not create the record"]
  }

  localItems(row) {
    if (!row.dataset.items) return []

    try {
      return this.normalizeItems(JSON.parse(row.dataset.items))
    } catch (_error) {
      return []
    }
  }

  normalizeItems(payload) {
    const items = Array.isArray(payload) ? payload : payload?.items
    if (!Array.isArray(items)) return []

    return items.map((item) => this.normalizeItem(item)).filter(Boolean)
  }

  normalizeItem(item) {
    if (!item) return null

    const id = String(item.id ?? item.value ?? "").trim()
    const title = String(item.title ?? item.label ?? item.name ?? "").trim()
    const description = String(item.description ?? item.secondary ?? "").trim()
    if (!id || !title) return null

    return {id, title, description}
  }

  options(row) {
    return Array.from(row.querySelectorAll("[data-collection-editor-results] [role='option']"))
  }

  setActive(row, index) {
    const options = this.options(row)
    const input = row.querySelector("[data-collection-editor-search]")
    row._activeIndex = index
    options.forEach((option, optionIndex) => {
      const selected = optionIndex === index
      option.setAttribute("aria-selected", selected ? "true" : "false")
      if (selected && input && option.id) input.setAttribute("aria-activedescendant", option.id)
    })
    if ((index < 0 || !options[index]) && input) input.removeAttribute("aria-activedescendant")
    options[index]?.scrollIntoView?.({block: "nearest"})
  }

  announceReorder(event) {
    if (!this.hasStatusTarget) return

    const position = event.detail?.position
    if (!position) return

    const row = this.rowForId(event.detail?.id)
    const title = row?.querySelector("[data-collection-editor-title]")?.textContent?.trim()
    this.statusTarget.textContent = title ? `Moved ${title} to position ${position}` : `Moved row to position ${position}`
  }

  rowForId(id) {
    if (!this.hasListTarget || id == null || id === "") return null

    return Array.from(this.listTarget.querySelectorAll("[data-collection-editor-row]")).find((row) => row.dataset.id === String(id)) || null
  }

  replaceTemplateIndex(html, token, index) {
    if (!token) return html

    const pattern = /(\s(?:name|id|for|data-id|aria-controls|aria-labelledby|aria-describedby|aria-activedescendant)\s*=\s*)(["'])([\s\S]*?)\2/gi
    return html.replace(pattern, (match, prefix, quote, value) => {
      if (!value.includes(token)) return match
      return `${prefix}${quote}${value.split(token).join(index)}${quote}`
    })
  }

  searchMissed(row) {
    const node = row.querySelector("[data-collection-editor-no-results]")
    return Boolean(node && !node.hidden)
  }

  toggleSearchError(row, show) {
    const node = row.querySelector("[data-collection-editor-search-error]")
    if (node) node.hidden = !show
  }

  uniqueIndex() {
    const time = Date.now().toString()
    const salt = Math.floor(Math.random() * 1000).toString().padStart(3, "0")
    return `${time}${salt}`
  }

  rowFrom(event) {
    const target = event.target?.closest ? event.target : event.currentTarget
    return target?.closest?.("[data-collection-editor-row]") || null
  }

  get csrfToken() {
    return document.querySelector("meta[name='csrf-token']")?.content || ""
  }
}
