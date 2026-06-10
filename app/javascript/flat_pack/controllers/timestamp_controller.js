import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    iso: String,
    fallback: String,
    format: { type: String, default: "%e %b %Y %l:%M%P" }
  }

  connect() {
    const tooltipElement = this.findTooltipElement()
    if (!tooltipElement) return

    tooltipElement.textContent = this.formattedTimestamp()
  }

  formattedTimestamp() {
    if (!this.hasIsoValue) return this.fallbackValue || ""

    const date = new Date(this.isoValue)
    if (Number.isNaN(date.getTime())) return this.fallbackValue || ""

    return this.formatTimestamp(date)
  }

  formatTimestamp(date) {
    const dayOfMonth = String(date.getDate()).padStart(2, " ")
    const month = new Intl.DateTimeFormat(undefined, { month: "short" }).format(date)
    const year = String(date.getFullYear())

    const hour24 = date.getHours()
    const hour12 = hour24 % 12 || 12
    const hour = String(hour12).padStart(2, " ")
    const minutes = String(date.getMinutes()).padStart(2, "0")
    const meridiem = hour24 < 12 ? "am" : "pm"

    return `${dayOfMonth} ${month} ${year} ${hour}:${minutes}${meridiem}`
  }

  findTooltipElement() {
    const wrapper = this.element.closest("[data-controller~='flat-pack--tooltip']")
    if (!wrapper) return null

    return wrapper.querySelector("[data-flat-pack--tooltip-target='tooltip']")
  }
}
