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
  static targets = ["input", "value", "list", "option", "empty", "loading", "hint"]
  static values = {
    emptyText: { type: String, default: "No matches" },
    loadingText: { type: String, default: "Searching..." },
    hintText: { type: String, default: "Type at least 2 characters to search" },
    searchMode: { type: String, default: "local" },
    searchEndpoint: { type: String, default: "" },
    searchParam: { type: String, default: "q" },
    minSearchLength: { type: Number, default: 2 },
    debounce: { type: Number, default: 300 }
  }

  connect() {
    this.openList = false
    this.activeIndex = -1
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

  filter() {
    if (!this.openList) {
      this.open()
      return
    }
    this.applyFilter()
  }

  applyFilter() {
    if (this.asyncMode) {
      this.applyRemoteFilter()
      return
    }

    const query = this.inputTarget.value.trim().toLowerCase()
    const exact = this.currentOptions().find((option) => option.dataset.label.toLowerCase() === query)
    if (!exact) this.valueTarget.value = ""
    let visible = 0

    this.currentOptions().forEach((option) => {
      const match = option.dataset.label.toLowerCase().includes(query)
      option.classList.toggle("hidden", !match)
      if (match) visible += 1
    })

    this.setStatus({ empty: visible === 0 })
    this.activeIndex = visible > 0 ? 0 : -1
    this.syncActive()
  }

  applyRemoteFilter() {
    const query = this.inputTarget.value.trim()
    const selected = this.currentOptions().find((option) => option.getAttribute("aria-selected") === "true")
    const selectedLabel = selected?.dataset.label || ""
    if (query.toLowerCase() !== selectedLabel.toLowerCase()) this.valueTarget.value = ""

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
        param: this.searchParamValue
      })

      if (!response.ok) {
        this.renderRemoteOptions([])
        return
      }

      this.renderRemoteOptions(this.normalizeItems(await response.json()))
    } catch (error) {
      if (error?.name === "AbortError") return
      this.renderRemoteOptions([])
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
          subtitle: subtitle || null
        }
      })
      .filter(Boolean)
  }

  renderRemoteOptions(items) {
    this.inputTarget.removeAttribute("aria-busy")
    this.currentOptions().forEach((option) => option.remove())

    items.forEach((item, index) => {
      this.listTarget.appendChild(this.buildOption(item, index))
    })

    this.setStatus({ empty: items.length === 0, hint: false, loading: false })
    this.activeIndex = items.length > 0 ? 0 : -1
    this.syncActive()
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

  setStatus({ hint = false, loading = false, empty = false } = {}) {
    if (this.hasHintTarget) this.hintTarget.classList.toggle("hidden", !hint)
    if (this.hasLoadingTarget) this.loadingTarget.classList.toggle("hidden", !loading)
    this.emptyTarget?.classList.toggle("hidden", !empty)
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
    this.valueTarget.value = option.dataset.value
    this.inputTarget.value = option.dataset.label
    this.currentOptions().forEach((item) => {
      item.setAttribute("aria-selected", item === option ? "true" : "false")
    })
    this.valueTarget.dispatchEvent(new Event("change", { bubbles: true }))
    this.element.dispatchEvent(new CustomEvent("flat-pack:combobox:selected", {
      bubbles: true,
      detail: {
        value: option.dataset.value,
        label: option.dataset.label,
        subtitle: option.dataset.subtitle || null
      }
    }))
    this.close()
    this.inputTarget.focus()
  }

  currentOptions() {
    return Array.from(this.listTarget.querySelectorAll('[role="option"]'))
  }

  visibleOptions() {
    return this.currentOptions().filter((option) => !option.classList.contains("hidden"))
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
    this.currentOptions().forEach((option) => {
      option.classList.remove("bg-[var(--list-item-hover-background-color)]")
    })
    this.inputTarget.removeAttribute("aria-activedescendant")
  }

  get asyncMode() {
    return this.searchModeValue === "remote"
  }
}
