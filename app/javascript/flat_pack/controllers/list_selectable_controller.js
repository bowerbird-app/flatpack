import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    activeClass: {type: String, default: "bg-[var(--list-item-active-background-color)]"}
  }

  activate(event) {
    const clickedLink = event.target.closest("a.flat-pack-list-item-link")
    if (!clickedLink || !this.element.contains(clickedLink)) return

    const clickedListItem = clickedLink.closest("li[role='listitem']")
    if (!clickedListItem || !this.element.contains(clickedListItem)) return

    this.setActiveListItem(clickedListItem, clickedLink)
  }

  setActiveListItem(activeListItem, activeLink) {
    const activeClasses = this.activeClassValue.split(" ").filter(Boolean)

    this.listItems.forEach((listItem) => {
      listItem.classList.remove(...activeClasses)
    })

    this.listItemLinks.forEach((link) => {
      link.removeAttribute("aria-current")
    })

    activeListItem.classList.add(...activeClasses)
    activeLink.setAttribute("aria-current", "page")
  }

  get listItems() {
    return this.element.querySelectorAll("li[role='listitem']")
  }

  get listItemLinks() {
    return this.element.querySelectorAll("a.flat-pack-list-item-link")
  }
}
