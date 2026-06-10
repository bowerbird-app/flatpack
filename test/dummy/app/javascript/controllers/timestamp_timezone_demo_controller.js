import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["localTime", "timezone"]
  static values = { iso: String }

  connect() {
    if (!this.hasIsoValue || !this.hasLocalTimeTarget) return

    const date = new Date(this.isoValue)
    if (Number.isNaN(date.getTime())) return

    this.localTimeTarget.textContent = this.formatLocalTimestamp(date)

    if (this.hasTimezoneTarget) {
      this.timezoneTarget.textContent = this.detectTimezone()
    }
  }

  detectTimezone() {
    return Intl.DateTimeFormat().resolvedOptions().timeZone || "local timezone"
  }

  formatLocalTimestamp(date) {
    const day = String(date.getDate()).padStart(2, " ")
    const month = new Intl.DateTimeFormat(undefined, { month: "short" }).format(date)
    const year = String(date.getFullYear())

    const hour24 = date.getHours()
    const hour12 = hour24 % 12 || 12
    const hour = String(hour12).padStart(2, " ")
    const minute = String(date.getMinutes()).padStart(2, "0")
    const suffix = hour24 < 12 ? "am" : "pm"

    return `${day} ${month} ${year} ${hour}:${minute}${suffix}`
  }
}
