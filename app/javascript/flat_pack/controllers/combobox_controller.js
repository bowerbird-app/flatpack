import { Controller } from "@hotwired/stimulus"
import { playOverlayEnter, playOverlayExit, cancelOverlayHide } from "controllers/flat_pack/reduced_motion"
import { onClickOutside } from "flat_pack/click_outside"
import { createRemoteQuery } from "flat_pack/remote_query"

const OPTION_CLASSES = [
  "cursor-pointer rounded-[var(--dropdown-item-radius)] px-[var(--combobox-item-padding-x)] py-[var(--combobox-item-padding-y)] text-sm",
  "text-[var(--surface-content-color)]",
  "aria-selected:bg-[var(--list-item-active-background-color)]",
  "hover:bg-[var(--list-item-hover-background-color)]"
].join(" ")

export default class extends Controller {
  static targets = ["input", "value", "list", "option", "empty", "loading", "hint", "emptyAction"]
  static values = {
    emptyText: { type: String, default: "No matches" },
    errorText: { type: String, default: "Search failed" },
    loadingText: { type: String, default: "Searching..." },
    hintText: { type: String, default: "Type at least 2 characters to search" },
    searchMode: { type: String, default: "local" },
    searchEndpoint: { type: String, default: "" },
    searchParam: { type: String, default: "q" },
    searchParams: { type: Object, default: {} },
    minSearchLength: { type: Number, default: 2 },
    debounce: { type: Number, default: 300 }
  }

  connect() {
    this.openList = false
    this.activeIndex = -1
    this.editedByUser = false
    this.remote = createRemoteQuery()
    this.outsideClick = onClickOutside(document, () => this.close(), {
      event: "mousedown",
      roots: () => this.element
    })
    this.outsideClick.add()
  }

  disconnect() {
    this.remote?.stop()
    cancelOverlayHide(this.listTarget)
    this.outsideClick?.remove()
  }

  open() {
    if (this.openList) return
    this.openList = true
    this.inputTarget.setAttribute("aria-expanded", "true")
    playOverlayEnter(this.listTarget, { placement: "bottom" })
    this.applyFilter()
  }

  close() {
    if (!this.openList) return
    this.openList = false
    this.inputTarget.setAttribute("aria-expanded", "false")
    this.inputTarget.removeAttribute("aria-busy")
    this.activeIndex = -1
    this.clearActive()
    playOverlayExit(this.listTarget, { placement: "bottom" })
  }

  clear() {
    this.inputTarget.value = ""
    this.writeHidden("")
    this.close()
    this.dispatchHiddenChange()
    this.dispatchCombobox("cleared")
  }

  // Sets the field without opening the list and without flat-pack:combobox:selected.
  // Hosts that need the choice event should listen for change, or dispatch selected themselves.
  setSelection(selection = {}) {
    const value = selection?.value == null ? "" : String(selection.value)
    const label = selection?.label == null ? "" : String(selection.label)
    this.writeHidden(value)
    this.inputTarget.value = label
    this.dispatchHiddenChange()
  }

  filter() {
    this.editedByUser = true
    if (!this.openList) {
      this.open()
    } else {
      this.applyFilter()
    }
    this.editedByUser = false
  }

  applyFilter() {
    if (this.asyncMode) {
      this.applyRemoteFilter()
      return
    }

    const query = this.inputTarget.value.trim()
    const previous = this.hiddenValue()
    const exact = this.currentOptions().find((option) => option.dataset.label.toLowerCase() === query.toLowerCase())
    if (!exact) this.writeHidden("")
    this.releaseHiddenIfEdited(previous, query)
    let visible = 0

    this.currentOptions().forEach((option) => {
      const match = option.dataset.label.toLowerCase().includes(query.toLowerCase())
      option.classList.toggle("hidden", !match)
      if (match) visible += 1
    })

    this.showEmptyState(visible === 0, this.emptyTextValue)
  }

  applyRemoteFilter() {
    this.remote.abort()
    const query = this.inputTarget.value.trim()
    const previous = this.hiddenValue()
    const selected = this.currentOptions().find((option) => option.getAttribute("aria-selected") === "true")
    const selectedLabel = selected?.dataset.label || ""
    if (query.toLowerCase() !== selectedLabel.toLowerCase()) this.writeHidden("")
    this.releaseHiddenIfEdited(previous, query)

    if (query.length < this.minSearchLengthValue) {
      this.remote.stop()
      this.showHint()
      return
    }

    this.showLoading()
    this.remote.debounce(this.debounceValue, () => this.requestRemote(query))
  }

  async requestRemote(query) {
    try {
      const response = await this.remote.fetch(this.searchEndpointValue, {
        query,
        param: this.searchParamValue,
        params: this.remoteParams()
      })

      if (!this.queryIsCurrent(query)) return

      if (!response.ok) {
        this.showRemoteError(response.status)
        return
      }

      const payload = await response.json()
      if (!this.queryIsCurrent(query)) return

      const items = this.normalizeItems(payload)
      this.renderRemoteOptions(items)
      this.dispatchCombobox("results", { query, items, payload })
    } catch (error) {
      if (error?.name === "AbortError") return
      if (!this.queryIsCurrent(query)) return
      this.showRemoteError(null)
    }
  }

  normalizeItems(payload) {
    const items = Array.isArray(payload) ? payload : payload?.items
    if (!Array.isArray(items)) return []

    return items
      .map((item) => {
        const value = String(item?.value || "").trim()
        const label = String(item?.label || "").trim()
        if (!value || !label) return null

        const subtitle = String(item?.subtitle || "").trim()
        return {
          value,
          label,
          subtitle: subtitle || null,
          data: this.normalizeItemData(item?.data)
        }
      })
      .filter(Boolean)
  }

  normalizeItemData(raw) {
    if (!raw || typeof raw !== "object" || Array.isArray(raw)) return {}

    const data = {}
    Object.entries(raw).forEach(([key, value]) => {
      if (value == null) return
      const kind = typeof value
      if (kind === "string" || kind === "number" || kind === "boolean") data[key] = value
    })
    return data
  }

  renderRemoteOptions(items) {
    this.inputTarget.removeAttribute("aria-busy")
    this.currentOptions().forEach((option) => option.remove())
    const anchor = this.listAnchor()

    items.forEach((item, index) => {
      const option = this.buildOption(item, index)
      if (anchor) {
        this.listTarget.insertBefore(option, anchor)
      } else {
        this.listTarget.appendChild(option)
      }
    })

    this.showEmptyState(items.length === 0, this.emptyTextValue)
  }

  buildOption(item, index) {
    const option = document.createElement("li")
    option.id = `${this.listTarget.id || "fp-combobox"}-async-${index}`
    option.setAttribute("role", "option")
    option.setAttribute("aria-selected", "false")
    option.setAttribute("data-flat-pack--combobox-target", "option")
    option.setAttribute("data-action", "mousedown->flat-pack--combobox#choose")
    option.className = OPTION_CLASSES
    option.dataset.value = item.value
    option.dataset.label = item.label
    if (item.subtitle) option.dataset.subtitle = item.subtitle
    if (item.data && Object.keys(item.data).length > 0) {
      option.dataset.optionData = JSON.stringify(item.data)
    }

    if (item.subtitle) {
      const label = document.createElement("span")
      label.className = "block"
      label.textContent = item.label
      const subtitle = document.createElement("span")
      subtitle.className = "block text-xs text-[var(--surface-muted-content-color)]"
      subtitle.textContent = item.subtitle
      option.appendChild(label)
      option.appendChild(subtitle)
    } else {
      option.textContent = item.label
    }

    return option
  }

  showHint() {
    this.inputTarget.removeAttribute("aria-busy")
    this.currentOptions().forEach((option) => option.classList.add("hidden"))
    this.setStatus({ hint: true, loading: false, empty: false })
    this.activeIndex = -1
    this.syncActive()
  }

  showLoading() {
    this.inputTarget.setAttribute("aria-busy", "true")
    this.currentOptions().forEach((option) => option.classList.add("hidden"))
    this.setStatus({ hint: false, loading: true, empty: false })
    this.activeIndex = -1
    this.syncActive()
  }

  showRemoteError(status) {
    this.inputTarget.removeAttribute("aria-busy")
    this.currentOptions().forEach((option) => option.remove())
    this.showEmptyState(true, this.errorTextValue)
    this.dispatchCombobox("error", { status: status ?? null })
  }

  showEmptyState(empty, message) {
    if (this.hasEmptyTarget && empty) this.emptyTarget.textContent = message
    this.setStatus({ hint: false, loading: false, empty })
    const options = this.visibleOptions()
    this.activeIndex = options.length > 0 ? 0 : -1
    this.syncActive()
  }

  setStatus({ hint = false, loading = false, empty = false } = {}) {
    if (this.hasHintTarget) this.hintTarget.classList.toggle("hidden", !hint)
    if (this.hasLoadingTarget) this.loadingTarget.classList.toggle("hidden", !loading)
    this.emptyTarget?.classList.toggle("hidden", !empty)
    this.syncEmptyAction(empty && !hint && !loading)
  }

  syncEmptyAction(show) {
    if (!this.hasEmptyActionTarget) return
    this.emptyActionTarget.classList.toggle("hidden", !show)
  }

  keydown(event) {
    if (event.key === "Escape") {
      this.close()
      return
    }
    if (event.key === "ArrowDown") {
      event.preventDefault()
      this.open()
      this.move(1)
    } else if (event.key === "ArrowUp") {
      event.preventDefault()
      this.open()
      this.move(-1)
    } else if (event.key === "Enter") {
      const active = this.visibleOptions()[this.activeIndex]
      if (active) {
        event.preventDefault()
        this.select(active)
      }
    }
  }

  choose(event) {
    event.preventDefault()
    this.select(event.currentTarget)
  }

  select(option) {
    if (this.isEmptyAction(option)) {
      this.dispatchCombobox("empty-action", {
        query: this.inputTarget.value.trim(),
        value: option.dataset.value
      })
      this.close()
      this.inputTarget.focus()
      return
    }

    this.writeHidden(option.dataset.value)
    this.inputTarget.value = option.dataset.label
    this.currentOptions().forEach((item) => {
      item.setAttribute("aria-selected", item === option ? "true" : "false")
    })
    this.dispatchHiddenChange()
    this.dispatchCombobox("selected", {
      value: option.dataset.value,
      label: option.dataset.label,
      subtitle: option.dataset.subtitle || null,
      data: this.readOptionData(option)
    })
    this.close()
    this.inputTarget.focus()
  }

  currentOptions() {
    return this.optionElements().filter((option) => !this.isEmptyAction(option))
  }

  visibleOptions() {
    return this.optionElements().filter((option) => !option.classList.contains("hidden"))
  }

  optionElements() {
    return Array.from(this.listTarget.querySelectorAll('[role="option"]'))
  }

  isEmptyAction(option) {
    return option?.dataset?.emptyAction === "true"
  }

  listAnchor() {
    if (this.hasHintTarget) return this.hintTarget
    if (this.hasLoadingTarget) return this.loadingTarget
    if (this.hasEmptyTarget) return this.emptyTarget
    if (this.hasEmptyActionTarget) return this.emptyActionTarget
    return null
  }

  move(delta) {
    const options = this.visibleOptions()
    if (options.length === 0) return
    this.activeIndex = (this.activeIndex + delta + options.length) % options.length
    this.syncActive()
    options[this.activeIndex].scrollIntoView({ block: "nearest" })
  }

  syncActive() {
    const options = this.visibleOptions()
    options.forEach((option, index) => {
      const active = index === this.activeIndex
      option.classList.toggle("bg-[var(--list-item-hover-background-color)]", active)
      if (active && option.id) {
        this.inputTarget.setAttribute("aria-activedescendant", option.id)
      }
    })
    if (this.activeIndex < 0) this.inputTarget.removeAttribute("aria-activedescendant")
  }

  clearActive() {
    this.optionElements().forEach((option) => {
      option.classList.remove("bg-[var(--list-item-hover-background-color)]")
    })
    this.inputTarget.removeAttribute("aria-activedescendant")
  }

  queryIsCurrent(query) {
    return this.inputTarget.value.trim() === query
  }

  remoteParams() {
    const params = this.searchParamsValue
    if (!params || typeof params !== "object" || Array.isArray(params)) return {}
    return params
  }

  hiddenValue() {
    return this.hasValueTarget ? this.valueTarget.value : ""
  }

  writeHidden(next) {
    if (!this.hasValueTarget) return
    this.valueTarget.value = next ?? ""
  }

  dispatchHiddenChange() {
    if (!this.hasValueTarget) return
    this.valueTarget.dispatchEvent(new Event("change", { bubbles: true }))
  }

  releaseHiddenIfEdited(previous, query) {
    if (!this.editedByUser || query !== "" || previous === "") return
    if (this.hiddenValue() !== "") return
    this.dispatchHiddenChange()
    this.dispatchCombobox("cleared")
  }

  readOptionData(option) {
    const raw = option?.dataset?.optionData
    if (!raw) return {}

    try {
      const parsed = JSON.parse(raw)
      if (!parsed || typeof parsed !== "object" || Array.isArray(parsed)) return {}
      return parsed
    } catch {
      return {}
    }
  }

  dispatchCombobox(name, detail) {
    this.element.dispatchEvent(new CustomEvent(`flat-pack:combobox:${name}`, {
      bubbles: true,
      detail
    }))
  }

  get asyncMode() {
    return this.searchModeValue === "remote"
  }
}
