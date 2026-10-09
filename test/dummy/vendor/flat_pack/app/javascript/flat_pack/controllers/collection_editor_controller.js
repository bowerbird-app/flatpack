import { Controller } from "@hotwired/stimulus"
import { flatPackCopy } from "flat_pack/copy"

export default class extends Controller {
  static targets = ["list", "template", "empty", "addButton", "status"]
  static values = {
    templateIndex: {type: String, default: "NEW_RECORD"}
  }

  connect() {
    this.onDocumentClick = this.closeOnOutside.bind(this)
    this.onCreateClick = this.submitCreate.bind(this)
    this.onReordered = this.announceReorder.bind(this)
    this.onPosition = () => this.repositionOpenResults()
    document.addEventListener("click", this.onDocumentClick)
    document.addEventListener("click", this.onCreateClick)
    document.addEventListener("scroll", this.onPosition, true)
    window.addEventListener("resize", this.onPosition)
    this.element.addEventListener("list:reordered", this.onReordered)
    this.refreshEmpty()
  }

  disconnect() {
    document.removeEventListener("click", this.onDocumentClick)
    document.removeEventListener("click", this.onCreateClick)
    document.removeEventListener("scroll", this.onPosition, true)
    window.removeEventListener("resize", this.onPosition)
    this.element.removeEventListener("list:reordered", this.onReordered)
    this.element.querySelectorAll("[data-collection-editor-row]").forEach((row) => {
      this.restoreResults(row)
      this.restoreModal(this.createModal(row))
      this.restoreModal(this.libraryModal(row))
    })
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
    if (row.querySelector("[data-collection-editor-image]")) {
      this.openLibrary({preventDefault() {}, target: row})
      return
    }
    this.showPanel(row)
    row.querySelector("[data-collection-editor-search]")?.focus()
  }

  remove(event) {
    event.preventDefault()
    const row = this.rowFrom(event)
    if (!row) return

    this.discardCreateModal(row)
    this.discardLibraryModal(row)

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
        this.chooseOption(row, active, event)
        return
      }
      if (options.length === 1) {
        this.chooseOption(row, options[0], event)
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

    const fields = this.createScope(row).querySelector("[data-collection-editor-create-fields]")
    const query = row.querySelector("[data-collection-editor-search]")?.value
      || this.libraryModal(row)?.querySelector("[data-collection-editor-library-search]")?.value
      || ""
    if (!fields || !fields.querySelector("[data-create-field]")) {
      this.create(event)
      return
    }

    const prompt = row.querySelector("[data-collection-editor-create-button]")
    if (prompt) prompt.hidden = true
    this.hideResults(row)
    this.invalidateEdit(row)
    this.clearCreateError(row)
    this.clearFields(row)
    this.prepareDialog(row, "create")
    row.dataset.editorState = "ready"
    fields.querySelectorAll("[data-fill-from-query]").forEach((input) => {
      if (!input.value) input.value = query
    })

    if (this.openCreateModal(row)) {
      window.setTimeout(() => {
        this.createScope(row).querySelector("[data-create-field]")?.focus()
      }, 150)
      return
    }

    fields.hidden = false
    fields.querySelector("[data-create-field]")?.focus()
  }

  submitCreate(event) {
    const button = event.target?.closest?.("[data-collection-editor-create-submit]")
    if (!button) return

    const row = this.rowFrom(event)
    if (!row || !this.element.contains(row)) return

    if (row.dataset.editorMode === "edit") return this.update(event)
    return this.create(event)
  }

  async edit(event) {
    event.preventDefault()
    const row = this.rowFrom(event)
    if (!row?.dataset.updateUrl || row.dataset.editorState === "loading") return

    const id = row.querySelector("[data-collection-editor-association]")?.value
    if (!id) return

    const request = this.invalidateEdit(row)
    this.prepareDialog(row, "edit")
    this.clearFields(row)
    this.clearCreateError(row)
    row.dataset.editorState = "loading"
    if (!this.openCreateModal(row)) {
      delete row.dataset.editorState
      return
    }

    try {
      const response = await fetch(this.recordUrl(row, id), {
        method: "GET",
        headers: {Accept: "application/json"},
        credentials: "same-origin"
      })
      const payload = await response.json()
      if (!this.editStillCurrent(row, request)) return

      const fields = payload?.fields
      if (!response.ok || !fields || typeof fields !== "object" || Array.isArray(fields)) {
        this.showCreateError(row, this.errorMessages(payload, flatPackCopy("collection_editor.load_failed")))
        row.dataset.editorState = "error"
        return
      }

      this.fillFields(row, fields)
      row.dataset.editorState = "ready"
      this.setSubmitEnabled(row, true)
      window.setTimeout(() => {
        this.createScope(row).querySelector("[data-create-field]")?.focus()
      }, 150)
    } catch (_error) {
      if (!this.editStillCurrent(row, request)) return
      this.showCreateError(row, [flatPackCopy("collection_editor.load_failed")])
      row.dataset.editorState = "error"
    }
  }

  async update(event) {
    event.preventDefault()
    const row = this.rowFrom(event)
    const id = row?.querySelector("[data-collection-editor-association]")?.value
    if (!row || !row.dataset.updateUrl || !id || row.dataset.editorState !== "ready" || row.dataset.creating === "true") return

    row.dataset.creating = "true"
    this.clearCreateError(row)

    try {
      const response = await fetch(this.recordUrl(row, id), {
        method: "PATCH",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
          "X-CSRF-Token": this.csrfToken,
          Accept: "application/json"
        },
        body: this.fieldBody(row).toString(),
        credentials: "same-origin"
      })
      const payload = await response.json()
      const item = this.normalizeItem(payload?.item)

      if (!response.ok || payload?.ok === false || !item) {
        this.showCreateError(row, this.errorMessages(payload, flatPackCopy("collection_editor.save_failed")))
        return
      }

      this.applyUpdate(row, item)
    } catch (_error) {
      this.showCreateError(row, [flatPackCopy("collection_editor.save_failed")])
    } finally {
      delete row.dataset.creating
    }
  }

  async create(event) {
    event.preventDefault()
    const row = this.rowFrom(event)
    if (!row || !row.dataset.createUrl || row.dataset.creating === "true") return

    row.dataset.creating = "true"
    const body = this.fieldBody(row, {query: true})

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
      this.showCreateError(row, [flatPackCopy("collection_editor.create_failed")])
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
      this.renderResults(row, matches, {query})
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
      this.renderResults(row, items, {query})
      this.toggleNoResults(row, items.length === 0)
      this.toggleSearchError(row, false)
    } catch (error) {
      if (error?.name === "AbortError") return
      this.renderResults(row, [])
      this.toggleNoResults(row, false)
      this.toggleSearchError(row, true)
    }
  }

  renderResults(row, items, {query} = {}) {
    const list = this.resultsList(row)
    if (!list) return

    list.replaceChildren()
    row._activeIndex = -1
    row.querySelector("[data-collection-editor-search]")?.removeAttribute("aria-activedescendant")
    items.forEach((item) => list.append(this.optionElement(row, item)))
    if (items.length === 0 && this.queryReady(row, query)) {
      const empty = document.createElement("p")
      empty.className = "flat-pack-collection-editor-menu-empty"
      empty.textContent = row.dataset.emptyText || "No matches"
      list.append(empty)
      if (row.dataset.createUrl) list.append(this.createOption(row))
    }
    this.placeResults(row)
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
      event.stopPropagation()
      this.applySelection(row, option.dataset)
    })

    return option
  }

  createOption(row) {
    const option = document.createElement("button")
    option.type = "button"
    option.className = "flat-pack-collection-editor-create-option"
    option.setAttribute("role", "option")
    option.dataset.createOption = "true"
    option.textContent = "+ New"
    const list = this.resultsList(row)
    row._optionSerial = (row._optionSerial || 0) + 1
    option.id = `${list?.id || "collection-editor-option"}-${row._optionSerial}`
    option.addEventListener("click", (event) => {
      event.preventDefault()
      event.stopPropagation()
      this.promptCreate(event)
    })
    return option
  }

  chooseOption(row, option, event) {
    if (option.dataset.createOption === "true") {
      this.promptCreate(event)
      return
    }
    this.applySelection(row, option.dataset)
  }

  openImage(event) {
    event.preventDefault()
    const row = this.rowFrom(event)
    if (!row) return

    const id = row.querySelector("[data-collection-editor-association]")?.value
    if (id && row.dataset.updateUrl) return this.edit(event)

    return this.openLibrary(event)
  }

  openLibrary(event) {
    event?.preventDefault?.()
    const row = this.rowFrom(event)
    if (!row) return

    const modal = this.libraryModal(row)
    if (!modal) return

    const search = modal.querySelector("[data-collection-editor-library-search]")
    if (search) search.value = ""
    const portaled = this.placeModal(modal)
    const open = () => {
      this.showCreateModal(modal)
      this.loadLibrary(row, "")
      window.setTimeout(() => search?.focus(), 150)
    }
    if (portaled) window.setTimeout(open, 0)
    else open()
  }

  searchLibrary(event) {
    const row = this.rowFrom(event)
    if (!row) return

    const query = event.currentTarget?.value || ""
    window.clearTimeout(row._libraryTimer)
    row._libraryTimer = window.setTimeout(() => this.loadLibrary(row, query), 250)
  }

  searchLibraryKeydown(event) {
    if (event.key !== "Enter" && event.key !== "Escape") return
    event.preventDefault()
    if (event.key !== "Escape") return

    const row = this.rowFrom(event)
    if (row) this.closeLibrary(row)
  }

  createFromLibrary(event) {
    event.preventDefault()
    const row = this.rowFrom(event)
    if (!row) return

    this.closeLibrary(row)
    this.promptCreate(event)
  }

  async loadLibrary(row, query = "") {
    const grid = this.libraryGrid(row)
    if (!grid) return

    this.toggleLibraryMessage(row, "empty", false)
    this.toggleLibraryMessage(row, "error", false)

    if (!row.dataset.searchUrl) {
      const needle = query.trim().toLowerCase()
      const matches = this.localItems(row).filter((item) => {
        if (!needle) return true
        return `${item.title} ${item.description}`.toLowerCase().includes(needle)
      })
      this.renderLibrary(row, matches)
      this.toggleLibraryMessage(row, "empty", matches.length === 0)
      return
    }

    if (row._libraryAbort) row._libraryAbort.abort()
    const controller = new AbortController()
    row._libraryAbort = controller
    const url = new URL(row.dataset.searchUrl, window.location.origin)
    const typed = query.trim()
    if (typed) url.searchParams.set(row.dataset.searchParam || "q", typed)

    try {
      const response = await fetch(url.toString(), {
        method: "GET",
        headers: {Accept: "application/json"},
        signal: controller.signal,
        credentials: "same-origin"
      })
      const payload = await response.json()
      const items = this.normalizeItems(payload)
      this.renderLibrary(row, items)
      this.toggleLibraryMessage(row, "empty", items.length === 0)
    } catch (error) {
      if (error?.name === "AbortError") return
      this.renderLibrary(row, [])
      this.toggleLibraryMessage(row, "error", true)
    }
  }

  renderLibrary(row, items) {
    const grid = this.libraryGrid(row)
    if (!grid) return

    grid.replaceChildren()
    items.forEach((item) => grid.append(this.libraryItem(row, item)))
  }

  libraryItem(row, item) {
    const button = document.createElement("button")
    button.type = "button"
    button.className = "flat-pack-collection-editor-library-item"
    button.dataset.id = item.id
    button.dataset.title = item.title
    button.dataset.description = item.description || ""
    if (item.thumbnailUrl) button.dataset.thumbnailUrl = item.thumbnailUrl

    if (item.thumbnailUrl) {
      const image = document.createElement("img")
      image.src = item.thumbnailUrl
      image.alt = ""
      button.append(image)
    }

    const label = document.createElement("span")
    label.textContent = item.title
    button.append(label)
    button.addEventListener("click", (event) => {
      event.preventDefault()
      event.stopPropagation()
      this.applySelection(row, {
        id: item.id,
        title: item.title,
        description: item.description,
        thumbnailUrl: item.thumbnailUrl
      })
    })
    return button
  }

  applySelection(row, item) {
    const id = item.id || item.value || ""
    const title = item.title || item.label || ""
    const description = item.description || ""
    const thumbnailUrl = item.thumbnailUrl || item.thumbnail_url || ""
    if (this.duplicateImage(row, id)) {
      this.focusJoinedImage(row, id)
      return
    }

    const association = row.querySelector("[data-collection-editor-association]")
    if (association) association.value = id

    this.writeSummary(row, {title, description, thumbnailUrl})
    this.clearCreateError(row)
    this.closeLibrary(row)
    this.closeCreateModal(row)
    this.closePanel(row, {force: true})
    this.focusSelection(row)

    row.dispatchEvent(new CustomEvent("collection-editor:selected", {
      bubbles: true,
      detail: {id, title, description, thumbnailUrl}
    }))
  }

  applyUpdate(row, item) {
    const id = row.querySelector("[data-collection-editor-association]")?.value || item.id
    const title = item.title || ""
    const description = item.description || ""
    const thumbnailUrl = item.thumbnailUrl || ""

    this.element.querySelectorAll("[data-collection-editor-row]").forEach((match) => {
      const association = match.querySelector("[data-collection-editor-association]")
      if (!association || association.value !== String(id)) return
      this.writeSummary(match, {title, description, thumbnailUrl})
    })

    this.clearCreateError(row)
    this.closeLibrary(row)
    this.closeCreateModal(row)
    this.focusSelection(row)
    row.dispatchEvent(new CustomEvent("collection-editor:updated", {
      bubbles: true,
      detail: {id: String(id), title, description, thumbnailUrl}
    }))
  }

  writeSummary(row, item) {
    const title = item.title || ""
    const description = item.description || ""
    const summary = row.querySelector("[data-collection-editor-summary]")
    if (summary) summary.hidden = false

    const titleNode = row.querySelector("[data-collection-editor-title]")
    if (titleNode) titleNode.textContent = title

    const descriptionNode = row.querySelector("[data-collection-editor-description]")
    if (descriptionNode) {
      descriptionNode.textContent = description
      descriptionNode.hidden = true
    }

    const remove = row.querySelector("[data-collection-editor-remove]")
    if (remove && title) remove.setAttribute("aria-label", `Remove ${title}`)

    const chipRemove = row.querySelector("[data-collection-editor-chip-remove]")
    if (chipRemove && title) chipRemove.setAttribute("aria-label", `Remove ${title}`)

    const edit = row.querySelector("[data-collection-editor-edit]")
    if (edit && title) edit.setAttribute("aria-label", `${row.dataset.editLabel || "Edit"} ${title}`)

    const choose = row.querySelector("[data-collection-editor-image-choose]")
    if (choose && title) {
      const prefix = row.dataset.editLabel
      choose.setAttribute("aria-label", prefix ? `${prefix} ${title}` : title)
    }

    const preview = row.querySelector("[data-collection-editor-image-preview]")
    if (preview && item.thumbnailUrl) {
      preview.src = item.thumbnailUrl
      preview.hidden = false
      const placeholder = row.querySelector("[data-collection-editor-image-placeholder]")
      if (placeholder) placeholder.hidden = true
    }

    const handle = row.querySelector("[data-collection-editor-handle]")
    if (handle && title) handle.setAttribute("aria-label", `Reorder ${title}`)
  }

  showPanel(row) {
    const panel = row.querySelector("[data-collection-editor-panel]")
    if (panel) panel.hidden = false
    this.placeResults(row)
  }

  closePanel(row, {force = false} = {}) {
    const association = row.querySelector("[data-collection-editor-association]")
    if (!force && !association?.value) return

    const panel = row.querySelector("[data-collection-editor-panel]")
    if (panel) panel.hidden = true
    this.hideResults(row)
  }

  closeOnOutside(event) {
    this.element.querySelectorAll("[data-collection-editor-panel]").forEach((panel) => {
      if (panel.hidden) return
      const row = panel.closest("[data-collection-editor-row]")
      const list = row ? this.resultsList(row) : null
      if (row?.contains(event.target) || list?.contains(event.target)) return
      if (row) this.closePanel(row)
    })
  }

  refreshEmpty() {
    if (!this.hasEmptyTarget) return

    const visible = this.element.querySelectorAll("[data-collection-editor-row]:not([hidden])")
    this.emptyTarget.hidden = visible.length > 0
  }

  toggleNoResults(row, show) {
    const node = row.querySelector("[data-collection-editor-no-results]")
    if (node) node.hidden = !show
  }

  showCreateError(row, messages) {
    this.openCreateModal(row)
    const node = this.createScope(row).querySelector("[data-collection-editor-create-error]")
    if (!node) return

    node.hidden = false
    node.textContent = messages.filter(Boolean).join(". ")
    const fields = this.createScope(row).querySelector("[data-collection-editor-create-fields]")
    if (fields && !this.createModal(row)) fields.hidden = false
  }

  clearCreateError(row) {
    const node = this.createScope(row).querySelector("[data-collection-editor-create-error]")
    if (!node) return

    node.hidden = true
    node.textContent = ""
  }

  errorMessages(payload, fallback = flatPackCopy("collection_editor.create_failed")) {
    if (Array.isArray(payload?.errors)) return payload.errors.map(String)
    if (payload?.errors && typeof payload.errors === "object") {
      return Object.entries(payload.errors).flatMap(([_key, messages]) => [].concat(messages).map(String))
    }
    if (payload?.error) return [String(payload.error)]
    return [fallback]
  }

  fieldBody(row, {query = false} = {}) {
    const body = new URLSearchParams()
    if (query) {
      const typed = row.querySelector("[data-collection-editor-search]")?.value || ""
      body.set(row.dataset.searchParam || "q", typed)
    }
    this.createScope(row).querySelectorAll("[data-create-field]").forEach((input) => {
      const key = input.dataset.createField
      if (key) body.set(key, input.value)
    })
    return body
  }

  clearFields(row) {
    this.createScope(row).querySelectorAll("[data-create-field]").forEach((input) => {
      input.value = ""
    })
  }

  fillFields(row, fields) {
    this.createScope(row).querySelectorAll("[data-create-field]").forEach((input) => {
      const key = input.dataset.createField
      if (!key || !Object.prototype.hasOwnProperty.call(fields, key)) return
      input.value = fields[key] == null ? "" : String(fields[key])
    })
  }

  recordUrl(row, id) {
    return String(row.dataset.updateUrl || "").replace(":id", encodeURIComponent(id))
  }

  prepareDialog(row, mode) {
    row.dataset.editorMode = mode
    const modal = this.createModal(row)
    if (!modal) return

    const title = modal.querySelector("[data-collection-editor-modal-title]")
    const submit = modal.querySelector("[data-collection-editor-create-submit]")
    const label = submit?.querySelector("span")
    if (mode === "edit") {
      if (title) title.textContent = row.dataset.editTitle || "Edit"
      if (label) label.textContent = row.dataset.updateLabel || "Save"
      if (submit) submit.disabled = true
      return
    }

    if (title) title.textContent = row.dataset.createTitle || "New"
    if (label) label.textContent = row.dataset.createLabel || "Create"
    if (submit) submit.disabled = false
  }

  invalidateEdit(row) {
    row._editRequest = (row._editRequest || 0) + 1
    return row._editRequest
  }

  editStillCurrent(row, request) {
    return row._editRequest === request && row.dataset.editorMode === "edit"
  }

  setSubmitEnabled(row, enabled) {
    const submit = this.createModal(row)?.querySelector("[data-collection-editor-create-submit]")
    if (submit) submit.disabled = !enabled
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
    const thumbnailUrl = String(item.thumbnailUrl ?? item.thumbnail_url ?? "").trim()
    if (!id || !title) return null

    return {id, title, description, thumbnailUrl}
  }

  options(row) {
    const list = this.resultsList(row)
    if (!list) return []

    return Array.from(list.querySelectorAll("[role='option']"))
  }

  resultsList(row) {
    if (row._resultsList) return row._resultsList

    row._resultsList = row.querySelector("[data-collection-editor-results]")
    return row._resultsList
  }

  queryReady(row, query) {
    const typed = query ?? row.querySelector("[data-collection-editor-search]")?.value ?? ""
    const minimum = Number(row.dataset.minSearchLength || "1")
    return typed.trim().length >= minimum
  }

  placeResults(row) {
    const list = this.resultsList(row)
    const input = row.querySelector("[data-collection-editor-search]")
    const panel = row.querySelector("[data-collection-editor-panel]")
    if (!list || !input) return

    const count = list.childElementCount ?? list.children?.length ?? 0
    if (count === 0 || panel?.hidden) {
      list.classList?.remove("is-open")
      this.restoreResults(row)
      if (panel?.hidden) input.setAttribute("aria-expanded", "false")
      return
    }

    if (document.body && list.parentElement !== document.body) {
      row._resultsHome = list.parentElement
      document.body.appendChild(list)
    }

    const rect = input.getBoundingClientRect()
    const width = Math.max(rect.width, 192)
    list.classList.add("is-open")
    list.style.width = `${width}px`
    list.style.left = `${rect.left}px`
    list.style.top = `${rect.bottom + 4}px`
    const menuRect = list.getBoundingClientRect()
    if (menuRect.bottom > window.innerHeight - 8) {
      list.style.top = `${Math.max(8, rect.top - menuRect.height - 4)}px`
    }
    input.setAttribute("aria-expanded", "true")
  }

  hideResults(row) {
    const list = this.resultsList(row)
    if (list) {
      list.replaceChildren()
      list.classList?.remove("is-open")
      if (list.style) {
        list.style.top = ""
        list.style.left = ""
        list.style.width = ""
      }
    }
    this.restoreResults(row)
    row.querySelector("[data-collection-editor-search]")?.setAttribute("aria-expanded", "false")
  }

  restoreResults(row) {
    const list = row._resultsList
    if (!list || !row._resultsHome || list.parentElement === row._resultsHome) return

    row._resultsHome.appendChild(list)
  }

  repositionOpenResults() {
    this.element.querySelectorAll("[data-collection-editor-row]").forEach((row) => {
      const list = row._resultsList
      if (!list?.classList.contains("is-open")) return
      this.placeResults(row)
    })
  }

  rowFrom(event) {
    const target = event.target?.closest ? event.target : event.currentTarget
    const row = target?.closest?.("[data-collection-editor-row]")
    if (row) return row

    const library = target?.closest?.("[data-collection-editor-library-modal]")
    if (library?.id && this.element) {
      const image = this.element.querySelector(`[data-library-modal-id="${library.id}"]`)
      const owner = image?.closest?.("[data-collection-editor-row]")
      if (owner) return owner
    }

    const modal = target?.closest?.("[data-collection-editor-create-modal]")
    if (modal?.id && this.element) {
      const entity = this.element.querySelector(`[data-create-modal-id="${modal.id}"]`)
      const owner = entity?.closest?.("[data-collection-editor-row]")
      if (owner) return owner
    }

    const list = target?.closest?.("[data-collection-editor-results]")
    if (!list?.id || !this.element) return null

    const entity = this.element.querySelector(`[data-results-id="${list.id}"]`)
    return entity?.closest?.("[data-collection-editor-row]") || null
  }

  createScope(row) {
    return this.createModal(row) || row
  }

  createModal(row) {
    if (!row) return null

    const nested = row.querySelector("[data-collection-editor-create-modal]")
    if (nested) return nested

    const marker = row.querySelector("[data-create-modal-id]")
    const id = marker?.getAttribute?.("data-create-modal-id")
    if (!id || typeof document.getElementById !== "function") return null

    return document.getElementById(id)
  }

  openCreateModal(row) {
    const modal = this.createModal(row)
    if (!modal) return false

    const portaled = this.placeModal(modal)
    const open = () => this.showCreateModal(modal)
    if (portaled) window.setTimeout(open, 0)
    else open()
    return true
  }

  showCreateModal(modal) {
    const controller = this.application?.getControllerForElementAndIdentifier?.(modal, "flat-pack--modal")
    if (controller?.open) {
      controller.open()
      return
    }

    modal.classList?.remove("hidden")
    modal.classList?.add("flex")
    modal.setAttribute?.("aria-hidden", "false")
  }

  closeCreateModal(row) {
    const modal = this.createModal(row)
    if (!modal) return

    const controller = this.application?.getControllerForElementAndIdentifier?.(modal, "flat-pack--modal")
    if (controller?.close) controller.close()
    else {
      modal.classList?.remove("flex")
      modal.classList?.add("hidden")
      modal.setAttribute?.("aria-hidden", "true")
    }

    window.setTimeout(() => this.restoreModal(modal), 250)
  }

  placeModal(modal) {
    if (!document.body || modal.parentElement === document.body) return false

    modal._modalHome = modal.parentElement
    document.body.appendChild(modal)
    return true
  }

  restoreModal(modal) {
    if (!modal?._modalHome || !document.body || modal.parentElement !== document.body) return

    modal._modalHome.appendChild(modal)
  }

  discardCreateModal(row) {
    this.createModal(row)?.remove()
  }

  libraryModal(row) {
    if (!row) return null

    const nested = row.querySelector("[data-collection-editor-library-modal]")
    if (nested) return nested

    const marker = row.querySelector("[data-library-modal-id]")
    const id = marker?.getAttribute?.("data-library-modal-id")
    if (!id || typeof document.getElementById !== "function") return null

    return document.getElementById(id)
  }

  libraryGrid(row) {
    return this.libraryModal(row)?.querySelector("[data-collection-editor-library]")
  }

  closeLibrary(row) {
    const modal = this.libraryModal(row)
    if (!modal) return

    const controller = this.application?.getControllerForElementAndIdentifier?.(modal, "flat-pack--modal")
    if (controller?.close) controller.close()
    else {
      modal.classList?.remove("flex")
      modal.classList?.add("hidden")
      modal.setAttribute?.("aria-hidden", "true")
    }

    window.setTimeout(() => this.restoreModal(modal), 250)
  }

  discardLibraryModal(row) {
    this.libraryModal(row)?.remove()
  }

  toggleLibraryMessage(row, kind, show) {
    const name = kind === "error" ? "data-collection-editor-library-error" : "data-collection-editor-library-empty"
    const node = this.libraryModal(row)?.querySelector(`[${name}]`)
    if (node) node.hidden = !show
  }

  duplicateImage(row, id) {
    if (!id || !row.querySelector("[data-collection-editor-image]")) return false

    return this.visibleRows().some((other) => {
      if (other === row) return false
      return other.querySelector("[data-collection-editor-association]")?.value === String(id)
    })
  }

  focusJoinedImage(row, id) {
    this.closeLibrary(row)
    this.closeCreateModal(row)
    const match = this.visibleRows().find((other) => {
      return other !== row && other.querySelector("[data-collection-editor-association]")?.value === String(id)
    })
    const choose = match?.querySelector("[data-collection-editor-image-choose]")
    window.setTimeout(() => choose?.focus(), 260)
    if (this.hasStatusTarget) this.statusTarget.textContent = flatPackCopy("collection_editor.already_joined")
  }

  visibleRows() {
    return Array.from(this.element.querySelectorAll("[data-collection-editor-row]:not([hidden])"))
  }

  focusSelection(row) {
    const target = row.querySelector("[data-collection-editor-chip-remove]") || row.querySelector("[data-collection-editor-image-choose]")
    target?.focus()
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

    const pattern = /(\s(?:name|id|for|data-id|data-results-id|data-create-modal-id|data-library-modal-id|aria-controls|aria-labelledby|aria-describedby|aria-activedescendant)\s*=\s*)(["'])([\s\S]*?)\2/gi
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

  get csrfToken() {
    return document.querySelector("meta[name='csrf-token']")?.content || ""
  }
}
