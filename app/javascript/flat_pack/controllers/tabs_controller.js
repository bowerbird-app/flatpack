// FlatPack Tabs Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]
  static values = {
    default: { type: Number, default: 0 }
  }

  connect() {
    // Set initial active tab
    this.selectTabByIndex(this.defaultValue)
    
    // Setup keyboard navigation
    this.setupKeyboardNavigation()
  }

  selectTab(event) {
    const clickedTab = event.currentTarget
    const index = this.tabTargets.indexOf(clickedTab)
    this.selectTabByIndex(index)
  }

  selectTabByIndex(index) {
    if (index < 0 || index >= this.tabTargets.length) return

    const selectedTab = this.tabTargets[index]
    const selectedPanel = this.panelTargets[index]

    // Update all tabs
    this.tabTargets.forEach((tab, i) => {
      const isSelected = i === index
      
      tab.setAttribute("aria-selected", isSelected)
      tab.setAttribute("tabindex", isSelected ? "0" : "-1")
      
      // Update classes for active state
      if (isSelected) {
        tab.classList.remove("text-[var(--surface-muted-content-color)]", "hover:text-[var(--surface-content-color)]", "hover:bg-[var(--surface-muted-bg-color)]")
        tab.classList.add("bg-[var(--surface-bg-color)]", "text-[var(--color-primary)]", "border-b-2", "border-[var(--color-primary)]", "-mb-px")
      } else {
        tab.classList.add("text-[var(--surface-muted-content-color)]", "hover:text-[var(--surface-content-color)]", "hover:bg-[var(--surface-muted-bg-color)]")
        tab.classList.remove("bg-[var(--surface-bg-color)]", "text-[var(--color-primary)]", "border-b-2", "border-[var(--color-primary)]", "-mb-px")
      }
    })

    // Update all panels
    this.panelTargets.forEach((panel, i) => {
      if (i === index) {
        panel.hidden = false
      } else {
        panel.hidden = true
      }
    })

    // Update URL hash if tab has an ID
    if (selectedTab.id) {
      const tabId = selectedTab.id.replace("-tab", "")
      if (history.replaceState) {
        history.replaceState(null, null, `#${tabId}`)
      }
    }
  }

  setupKeyboardNavigation() {
    this.tabTargets.forEach((tab) => {
      tab.addEventListener("keydown", (event) => this.handleKeydown(event))
    })
  }

  handleKeydown(event) {
    const currentIndex = this.tabTargets.indexOf(event.currentTarget)
    let newIndex = currentIndex

    switch (event.key) {
      case "ArrowLeft":
        event.preventDefault()
        newIndex = currentIndex > 0 ? currentIndex - 1 : this.tabTargets.length - 1
        break

      case "ArrowRight":
        event.preventDefault()
        newIndex = currentIndex < this.tabTargets.length - 1 ? currentIndex + 1 : 0
        break

      case "Home":
        event.preventDefault()
        newIndex = 0
        break

      case "End":
        event.preventDefault()
        newIndex = this.tabTargets.length - 1
        break

      case "Enter":
      case " ":
        event.preventDefault()
        this.selectTabByIndex(currentIndex)
        return

      default:
        return
    }

    // Select and focus new tab
    this.selectTabByIndex(newIndex)
    this.tabTargets[newIndex].focus()
  }
}
