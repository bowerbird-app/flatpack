import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "value", "list", "option", "empty"]
  static values = { emptyText: { type: String, default: "No matches" } }

  connect() {
    this.openList = false
    this.activeIndex = -1
    this.handleOutside = this.handleOutside.bind(this)
    document.addEventListener("mousedown", this.handleOutside)
  }

  disconnect() {
    document.removeEventListener("mousedown", this.handleOutside)
  }

  open() {
    if (this.openList) return
    this.openList = true
    this.listTarget.classList.remove("hidden")
    this.inputTarget.setAttribute("aria-expanded", "true")
    this.applyFilter()
  }

  close() {
    this.openList = false
    this.listTarget.classList.add("hidden")
    this.inputTarget.setAttribute("aria-expanded", "false")
    this.activeIndex = -1
    this.clearActive()
  }

  filter() {
    if (!this.openList) {
      this.open()
      return
    }
    this.applyFilter()
  }

  applyFilter() {
    const query = this.inputTarget.value.trim().toLowerCase()
    const exact = this.optionTargets.find((option) => option.dataset.label.toLowerCase() === query)
    if (!exact) this.valueTarget.value = ""
    let visible = 0

    this.optionTargets.forEach((option) => {
      const match = option.dataset.label.toLowerCase().includes(query)
      option.classList.toggle("hidden", !match)
      if (match) visible += 1
    })

    this.emptyTarget.classList.toggle("hidden", visible > 0)
    this.activeIndex = visible > 0 ? 0 : -1
    this.syncActive()
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
    this.optionTargets.forEach((item) => {
      item.setAttribute("aria-selected", item === option ? "true" : "false")
    })
    this.close()
    this.inputTarget.focus()
  }

  handleOutside(event) {
    if (!this.element.contains(event.target)) this.close()
  }

  visibleOptions() {
    return this.optionTargets.filter((option) => !option.classList.contains("hidden"))
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
    this.optionTargets.forEach((option) => {
      option.classList.remove("bg-[var(--list-item-hover-background-color)]")
    })
    this.inputTarget.removeAttribute("aria-activedescendant")
  }
}
