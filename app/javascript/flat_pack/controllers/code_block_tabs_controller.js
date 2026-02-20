// FlatPack Code Block Tabs Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]
  static values = {
    default: { type: Number, default: 0 }
  }

  connect() {
    this.selectTabByIndex(this.defaultValue)
  }

  selectTab(event) {
    const index = this.tabTargets.indexOf(event.currentTarget)
    this.selectTabByIndex(index)
  }

  selectTabByIndex(index) {
    if (index < 0 || index >= this.tabTargets.length) return

    this.tabTargets.forEach((tab, i) => {
      const isSelected = i === index
      tab.setAttribute("aria-selected", isSelected)
      tab.setAttribute("tabindex", isSelected ? "0" : "-1")
      tab.classList.remove("hover:bg-[var(--color-muted)]")

      if (isSelected) {
        tab.classList.add("bg-[var(--color-border)]")
      } else {
        tab.classList.remove("bg-[var(--color-border)]")
      }
    })

    this.panelTargets.forEach((panel, i) => {
      panel.hidden = i !== index
    })
  }

  handleKeydown(event) {
    const currentIndex = this.tabTargets.indexOf(event.currentTarget)
    let nextIndex = currentIndex

    switch (event.key) {
      case "ArrowLeft":
        event.preventDefault()
        nextIndex = currentIndex > 0 ? currentIndex - 1 : this.tabTargets.length - 1
        break
      case "ArrowRight":
        event.preventDefault()
        nextIndex = currentIndex < this.tabTargets.length - 1 ? currentIndex + 1 : 0
        break
      case "Home":
        event.preventDefault()
        nextIndex = 0
        break
      case "End":
        event.preventDefault()
        nextIndex = this.tabTargets.length - 1
        break
      case "Enter":
      case " ":
        event.preventDefault()
        this.selectTabByIndex(currentIndex)
        return
      default:
        return
    }

    this.selectTabByIndex(nextIndex)
    this.tabTargets[nextIndex].focus()
  }
}
