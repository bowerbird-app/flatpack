// FlatPack Select Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["trigger", "dropdown", "hiddenInput", "hiddenInputs", "searchInput", "optionsList", "chevron", "chip", "placeholder", "chipsContainer", "searchStatus", "searchHint", "loadingState", "emptyState"]
  static values = {
    searchable: Boolean,
    searchMode: { type: String, default: "local" },
    searchEndpoint: String,
    searchParam: { type: String, default: "q" },
    minSearchLength: { type: Number, default: 2 },
    multiple: Boolean,
    inputName: String
  }

  connect() {
    this.selectedValues = new Set(this.initialSelectedValues())
    this.optionLabels = this.collectOptionLabels()
    this.defaultTriggerText = this.triggerTarget.querySelector("span")?.textContent || ""
    this.debounceTimer = null
    this.abortController = null
    this.syncSelectedState()
    this.setSearchState(this.searchModeValue === "remote" ? "hint" : "idle")

    // Close dropdown when clicking outside
    this.handleOutsideClick = this.handleOutsideClick.bind(this)
    document.addEventListener("click", this.handleOutsideClick)
  }

  disconnect() {
    document.removeEventListener("click", this.handleOutsideClick)

    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer)
    }

    if (this.abortController) {
      this.abortController.abort()
    }
  }

  toggle(event) {
    event.preventDefault()
    event.stopPropagation()
    
    const isOpen = !this.dropdownTarget.classList.contains("hidden")
    
    if (isOpen) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    this.dropdownTarget.classList.remove("hidden")
    this.triggerTarget.setAttribute("aria-expanded", "true")
    this.chevronTarget.style.transform = "rotate(180deg)"
    
    // Focus search input if searchable
    if (this.searchableValue && this.hasSearchInputTarget) {
      this.searchInputTarget.focus()
    }

    if (this.searchModeValue === "remote" && this.hasSearchInputTarget && this.searchInputTarget.value.trim().length < this.minSearchLengthValue) {
      this.setSearchState("hint")
    }
  }

  close() {
    this.dropdownTarget.classList.add("hidden")
    this.triggerTarget.setAttribute("aria-expanded", "false")
    this.chevronTarget.style.transform = "rotate(0deg)"
    
    // Clear search input if exists
    if (this.hasSearchInputTarget) {
      this.searchInputTarget.value = ""
      this.showAllOptions()
    }

    if (this.searchModeValue === "remote") {
      this.setSearchState("hint")
    }
  }

  handleOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  selectOption(event) {
    const option = event.currentTarget
    const value = option.dataset.value
    const label = option.dataset.label
    const disabled = option.dataset.disabled === "true"
    
    if (disabled) {
      return
    }

    if (value && label) {
      this.optionLabels.set(value, label)
    }

    if (this.multipleValue) {
      if (this.selectedValues.has(value)) {
        this.selectedValues.delete(value)
      } else {
        this.selectedValues.add(value)
      }
      this.syncSelectedState()
      this.dispatchChange()
      return
    }

    this.selectedValues.clear()
    this.selectedValues.add(value)
    this.syncSelectedState()
    this.close()
    this.dispatchChange()
  }

  removeChip(event) {
    event.preventDefault()
    event.stopPropagation()

    const value = String(event.currentTarget?.dataset?.value || "")
    if (!value) {
      return
    }

    this.selectedValues.delete(value)
    this.syncSelectedState()
    this.dispatchChange()
  }

  removeChipKeydown(event) {
    if (event.key !== "Enter" && event.key !== " ") {
      return
    }

    this.removeChip(event)
  }

  collectOptionLabels() {
    const labels = new Map()

    if (this.hasOptionsListTarget) {
      this.optionsListTarget.querySelectorAll("[role='option']").forEach((option) => {
        const value = option.dataset.value
        const label = option.dataset.label

        if (value && label) {
          labels.set(value, label)
        }
      })
    }

    return labels
  }

  initialSelectedValues() {
    if (this.multipleValue) {
      if (!this.hasHiddenInputsTarget) {
        return []
      }

      return Array.from(this.hiddenInputsTarget.querySelectorAll("input[type='hidden']"))
        .map((input) => input.value)
        .filter((value) => value !== "")
    }

    if (!this.hasHiddenInputTarget || this.hiddenInputTarget.value === "") {
      return []
    }

    return [this.hiddenInputTarget.value]
  }

  syncSelectedState() {
    this.updateSelectedState()
    this.updateHiddenInputs()
    this.updateTriggerDisplay()
  }

  dispatchChange() {
    const changeEvent = new Event("change", { bubbles: true })

    if (this.multipleValue && this.hasHiddenInputsTarget) {
      const firstInput = this.hiddenInputsTarget.querySelector("input[type='hidden']")
      if (firstInput) {
        firstInput.dispatchEvent(changeEvent)
      } else {
        this.hiddenInputsTarget.dispatchEvent(changeEvent)
      }
      return
    }

    if (this.hasHiddenInputTarget) {
      this.hiddenInputTarget.dispatchEvent(changeEvent)
    }
  }

  updateSelectedState() {
    const allOptions = this.optionsListTarget.querySelectorAll("[role='option']")
    
    allOptions.forEach(option => {
      const isSelected = this.selectedValues.has(option.dataset.value)
      option.setAttribute("aria-selected", isSelected.toString())

      if (isSelected) {
        option.classList.add("bg-[var(--color-primary)]", "text-white")
        option.classList.remove("hover:bg-[var(--surface-muted-background-color)]", "text-[var(--surface-content-color)]")
      } else {
        option.classList.remove("bg-[var(--color-primary)]", "text-white")
        option.classList.add("hover:bg-[var(--surface-muted-background-color)]", "text-[var(--surface-content-color)]")
      }
    })
  }

  updateHiddenInputs() {
    if (this.multipleValue) {
      if (!this.hasHiddenInputsTarget) {
        return
      }

      this.hiddenInputsTarget.innerHTML = ""
      const values = Array.from(this.selectedValues)

      if (values.length === 0) {
        const input = this.buildHiddenInput("")
        this.hiddenInputsTarget.appendChild(input)
        return
      }

      values.forEach((value) => {
        const input = this.buildHiddenInput(value)
        this.hiddenInputsTarget.appendChild(input)
      })
      return
    }

    if (this.hasHiddenInputTarget) {
      const [firstValue] = Array.from(this.selectedValues)
      this.hiddenInputTarget.value = firstValue || ""
    }
  }

  buildHiddenInput(value) {
    const input = document.createElement("input")
    input.type = "hidden"
    input.name = this.inputNameValue
    input.value = value
    return input
  }

  updateTriggerDisplay() {
    if (this.multipleValue) {
      this.updateChipVisibility()
      return
    }

    const [firstValue] = Array.from(this.selectedValues)
    const selectedOption = this.optionsListTarget.querySelector(`[data-value='${CSS.escape(firstValue || "") }']`)
    const triggerSpan = this.triggerTarget.querySelector("span")

    if (!triggerSpan) {
      return
    }

    if (!firstValue) {
      triggerSpan.textContent = this.defaultTriggerText
      return
    }

    if (!selectedOption) {
      triggerSpan.textContent = this.optionLabels.get(firstValue) || this.defaultTriggerText
      return
    }

    triggerSpan.textContent = selectedOption.dataset.label
  }

  updateChipVisibility() {
    Array.from(this.selectedValues).forEach((value) => this.ensureChip(value))

    const chips = this.element.querySelectorAll("[data-flat-pack--select-target='chip']")
    chips.forEach((chip) => {
      const isSelected = this.selectedValues.has(chip.dataset.value)
      chip.classList.toggle("hidden", !isSelected)
    })

    if (this.hasPlaceholderTarget) {
      this.placeholderTarget.classList.toggle("hidden", this.selectedValues.size > 0)
    }
  }

  ensureChip(value) {
    if (!this.multipleValue || !value || !this.hasChipsContainerTarget) {
      return
    }

    const existing = this.chipsContainerTarget.querySelector(`[data-value='${CSS.escape(value)}']`)
    if (existing) {
      return
    }

    const label = this.optionLabels.get(value)
    if (!label) {
      return
    }

    const chip = document.createElement("span")
    chip.setAttribute("data-flat-pack--select-target", "chip")
    chip.dataset.value = value
    chip.innerHTML = `
      <span class="inline-flex items-center gap-1.5 rounded-(--chip-border-radius) font-medium border transition-colors duration-base bg-(--surface-muted-background-color) text-(--surface-content-color) border-(--surface-border-color) text-xs px-(--chip-padding-x-sm) py-(--button-padding-y-sm)">
        <span>${this.escapeHtml(label)}</span>
        <span class="inline-flex items-center justify-center cursor-pointer rounded-full" role="button" tabindex="0" aria-label="Remove ${this.escapeHtml(label)}" data-action="click->flat-pack--select#removeChip keydown->flat-pack--select#removeChipKeydown" data-value="${this.escapeHtml(value)}">
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="h-4 w-4">
            <path stroke-linecap="round" stroke-linejoin="round" d="M6 18 18 6M6 6l12 12" />
          </svg>
        </span>
      </span>
    `

    this.chipsContainerTarget.appendChild(chip)
  }

  search(event) {
    const query = String(event.target.value || "").trim()

    if (this.searchModeValue === "remote") {
      this.searchRemote(query)
      return
    }

    const normalizedQuery = query.toLowerCase()
    const options = this.optionsListTarget.querySelectorAll("[role='option']")
    
    options.forEach(option => {
      const label = option.dataset.label.toLowerCase()
      
      if (label.includes(normalizedQuery)) {
        option.style.display = "block"
      } else {
        option.style.display = "none"
      }
    })
  }

  searchRemote(query) {
    if (!this.hasSearchEndpointValue) {
      return
    }

    if (this.debounceTimer) {
      clearTimeout(this.debounceTimer)
    }

    if (query.length < this.minSearchLengthValue) {
      this.showAllOptions()
      this.setSearchState("hint")
      return
    }

    this.setSearchState("loading")

    this.debounceTimer = setTimeout(async () => {
      if (this.abortController) {
        this.abortController.abort()
      }

      this.abortController = new AbortController()

      const url = new URL(this.searchEndpointValue, window.location.origin)
      url.searchParams.set(this.searchParamValue, query)

      try {
        const response = await fetch(url.toString(), {
          method: "GET",
          headers: { Accept: "application/json" },
          signal: this.abortController.signal
        })

        if (!response.ok) {
          this.renderRemoteOptions([])
          this.setSearchState("empty")
          return
        }

        const payload = await response.json()
        const items = this.normalizeRemoteItems(payload)

        this.renderRemoteOptions(items)
        this.setSearchState(items.length > 0 ? "results" : "empty")
      } catch (error) {
        if (error?.name !== "AbortError") {
          this.renderRemoteOptions([])
          this.setSearchState("empty")
        }
      }
    }, 250)
  }

  normalizeRemoteItems(payload) {
    const items = Array.isArray(payload) ? payload : payload?.items
    if (!Array.isArray(items)) {
      return []
    }

    return items
      .map((item) => {
        const value = String(item?.value || "").trim()
        const label = String(item?.label || "").trim()

        if (!value || !label) {
          return null
        }

        return {
          value,
          label,
          disabled: item?.disabled === true
        }
      })
      .filter(Boolean)
  }

  renderRemoteOptions(items) {
    if (!this.hasOptionsListTarget) {
      return
    }

    this.optionsListTarget.innerHTML = items.map((item) => this.optionMarkup(item)).join("")
    this.optionsListTarget.dataset.resultsCount = String(items.length)
    items.forEach((item) => this.optionLabels.set(item.value, item.label))
    this.updateSelectedState()
    this.updateTriggerDisplay()
  }

  optionMarkup(item) {
    const value = this.escapeHtml(item.value)
    const label = this.escapeHtml(item.label)
    const selected = this.selectedValues.has(item.value)
    const disabled = item.disabled === true
    const optionClasses = disabled
      ? "px-[var(--form-control-padding)] py-[var(--form-control-padding)] text-sm rounded-sm transition-colors duration-base opacity-50 cursor-not-allowed text-[var(--surface-muted-content-color)]"
      : selected
      ? "px-[var(--form-control-padding)] py-[var(--form-control-padding)] text-sm rounded-sm transition-colors duration-base bg-[var(--color-primary)] text-white cursor-pointer"
      : "px-[var(--form-control-padding)] py-[var(--form-control-padding)] text-sm rounded-sm transition-colors duration-base hover:bg-[var(--surface-muted-background-color)] cursor-pointer text-[var(--surface-content-color)]"

    return `<div role="option" class="${optionClasses}" data-action="click->flat-pack--select#selectOption" data-value="${value}" data-label="${label}" data-disabled="${disabled}" aria-selected="${selected}">${label}</div>`
  }

  setSearchState(state) {
    if (this.searchModeValue !== "remote") {
      return
    }

    const showSearchStatus = state === "hint" || state === "loading" || state === "empty"

    if (this.hasSearchStatusTarget) {
      this.searchStatusTarget.classList.toggle("hidden", !showSearchStatus)
    }

    if (this.hasSearchHintTarget) {
      this.searchHintTarget.classList.toggle("hidden", state !== "hint")
    }

    if (this.hasLoadingStateTarget) {
      this.loadingStateTarget.classList.toggle("hidden", state !== "loading")
    }

    if (this.hasEmptyStateTarget) {
      this.emptyStateTarget.classList.toggle("hidden", state !== "empty")
    }
  }

  showAllOptions() {
    const options = this.optionsListTarget.querySelectorAll("[role='option']")
    options.forEach(option => {
      option.style.display = "block"
    })
  }

  escapeHtml(value) {
    return String(value)
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;")
      .replaceAll("'", "&#39;")
  }
}
