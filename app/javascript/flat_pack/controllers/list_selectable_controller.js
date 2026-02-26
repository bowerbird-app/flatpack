import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    activeClass: {type: String, default: "bg-[var(--list-item-active-background-color)]"}
  }

  activate(event) {
    const clickedLink = event.target.closest("a.flat-pack-list-item-link")
    if (!clickedLink || !this.element.contains(clickedLink)) return

    this.setActiveLink(clickedLink)
  }

  setActiveLink(activeLink) {
    const activeClasses = this.activeClassValue.split(" ").filter(Boolean)

    this.listItemLinks.forEach((link) => {
      link.classList.remove(...activeClasses)
      link.removeAttribute("aria-current")
    })

    activeLink.classList.add(...activeClasses)
    activeLink.setAttribute("aria-current", "page")
  }

  get listItemLinks() {
    return this.element.querySelectorAll("a.flat-pack-list-item-link")
  }
}
