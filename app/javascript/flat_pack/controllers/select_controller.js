// FlatPack Select Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["trigger", "dropdown", "hiddenInput", "searchInput", "optionsList", "chevron"]
  static values = {
    searchable: Boolean
  }

  connect() {
    // Close dropdown when clicking outside
    this.handleOutsideClick = this.handleOutsideClick.bind(this)
    document.addEventListener("click", this.handleOutsideClick)
  }

  disconnect() {
    document.removeEventListener("click", this.handleOutsideClick)
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
    
    // Update hidden input
    this.hiddenInputTarget.value = value
    
    // Update trigger text
    const triggerSpan = this.triggerTarget.querySelector("span")
    if (triggerSpan) {
      triggerSpan.textContent = label
    }
    
    // Update selected state in dropdown
    this.updateSelectedState(option)
    
    // Close dropdown
    this.close()
    
    // Dispatch change event
    this.hiddenInputTarget.dispatchEvent(new Event("change", { bubbles: true }))
  }

  updateSelectedState(selectedOption) {
    // Remove selected state from all options
    const allOptions = this.optionsListTarget.querySelectorAll("[role='option']")
    allOptions.forEach(option => {
      option.setAttribute("aria-selected", "false")
      option.classList.remove("bg-[var(--color-primary)]", "text-white")
      option.classList.add("hover:bg-[var(--surface-muted-bg-color)]", "text-[var(--surface-content-color)]")
    })
    
    // Add selected state to clicked option
    selectedOption.setAttribute("aria-selected", "true")
    selectedOption.classList.add("bg-[var(--color-primary)]", "text-white")
    selectedOption.classList.remove("hover:bg-[var(--surface-muted-bg-color)]", "text-[var(--surface-content-color)]")
  }

  search(event) {
    const query = event.target.value.toLowerCase()
    const options = this.optionsListTarget.querySelectorAll("[role='option']")
    
    options.forEach(option => {
      const label = option.dataset.label.toLowerCase()
      
      if (label.includes(query)) {
        option.style.display = "block"
      } else {
        option.style.display = "none"
      }
    })
  }

  showAllOptions() {
    const options = this.optionsListTarget.querySelectorAll("[role='option']")
    options.forEach(option => {
      option.style.display = "block"
    })
  }
}
