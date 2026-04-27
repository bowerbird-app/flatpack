import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["link"]

  show() {
    if (!this.hasLinkTarget) return
    this.linkTarget.style.opacity = "1"
  }

  hide() {
    if (!this.hasLinkTarget) return
    this.linkTarget.style.opacity = "0"
  }

  async copy(event) {
    event.preventDefault()

    const link = event.currentTarget
    const href = link.getAttribute("href")
    if (!href || !href.startsWith("#")) return

    const url = new URL(window.location.href)
    url.hash = href.slice(1)

    await this.writeText(url.toString())
    window.history.replaceState({}, "", url)
  }

  async writeText(text) {
    if (navigator.clipboard?.writeText) {
      try {
        await navigator.clipboard.writeText(text)
        return
      } catch {
      }
    }

    const input = document.createElement("input")
    input.value = text
    input.style.position = "fixed"
    input.style.opacity = "0"

    document.body.appendChild(input)
    input.select()
    document.execCommand("copy")
    input.remove()
  }
}
