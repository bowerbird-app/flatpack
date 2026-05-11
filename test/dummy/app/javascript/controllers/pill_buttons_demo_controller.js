import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["pill"]
  static values = {
    activeClasses: String,
    inactiveClasses: String
  }

  connect() {
    this.handleHashChange = this.syncFromHash.bind(this)
    window.addEventListener("hashchange", this.handleHashChange)
    this.syncFromHash()
  }

  disconnect() {
    window.removeEventListener("hashchange", this.handleHashChange)
  }

  activate(event) {
    const pill = event.currentTarget
    if (!this.isSamePageHashLink(pill)) return

    event.preventDefault()
    this.setActivePill(pill)
    this.updateLocationAndScroll(pill)
  }

  syncFromHash() {
    const activePill = this.findPillForHash(window.location.hash) || this.pillTargets[0]
    if (!activePill) return

    this.setActivePill(activePill)
  }

  setActivePill(activePill) {
    const activeClasses = this.parseClasses(this.activeClassesValue)
    const inactiveClasses = this.parseClasses(this.inactiveClassesValue)

    this.pillTargets.forEach((pill) => {
      const isActive = pill === activePill

      pill.classList.remove(...activeClasses)
      pill.classList.remove(...inactiveClasses)
      pill.classList.add(...(isActive ? activeClasses : inactiveClasses))

      if (isActive) {
        pill.setAttribute("aria-current", "page")
      } else {
        pill.removeAttribute("aria-current")
      }
    })
  }

  findPillForHash(hash) {
    if (!hash) return null

    return this.pillTargets.find((pill) => this.hashFor(pill) === hash)
  }

  isSamePageHashLink(pill) {
    return this.hashFor(pill).length > 0
  }

  hashFor(pill) {
    const url = new URL(pill.href, window.location.href)

    if (url.pathname !== window.location.pathname || url.search !== window.location.search) {
      return ""
    }

    return url.hash
  }

  updateLocationAndScroll(pill) {
    const hash = this.hashFor(pill)
    const target = this.targetForHash(hash)

    if (hash && window.location.hash !== hash && window.history?.pushState) {
      window.history.pushState(null, "", hash)
    }

    if (target) {
      target.scrollIntoView({ block: "start", behavior: "smooth" })
    }
  }

  targetForHash(hash) {
    if (!hash) return null

    return document.getElementById(decodeURIComponent(hash.slice(1)))
  }

  parseClasses(classString) {
    return (classString || "").split(/\s+/).filter(Boolean)
  }
}