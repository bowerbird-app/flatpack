import { Controller } from "@hotwired/stimulus"

// Moves collapsible top nav content into a right-aligned chevron menu on narrow
// viewports, and frosts the bar after the page has scrolled. Nodes are relocated
// rather than duplicated so ids, event listeners and Stimulus controllers inside
// slot content keep working, and a comment placeholder records where each node
// has to return to on wider viewports.
export default class extends Controller {
  static targets = ["section", "menu", "toggle", "panel"]
  static classes = ["toggleOpen"]
  static values = {
    breakpoint: { type: Number, default: 768 }
  }

  connect() {
    this.movedNodes = []
    this.menuOpen = false
    this.boundHandleScroll = this.handleScroll.bind(this)
    this.scrollports = this.collectScrollports()

    this.scrollports.forEach((port) => {
      port.addEventListener("scroll", this.boundHandleScroll, {passive: true})
    })
    this.updateScrolled()

    if (!this.hasMenuWiring) return

    this.mediaQuery = window.matchMedia(`(max-width: ${this.breakpointValue - 1}px)`)
    this.handleMediaChange = this.handleMediaChange.bind(this)
    this.handleDocumentClick = this.handleDocumentClick.bind(this)
    this.handleKeydown = this.handleKeydown.bind(this)

    if (this.mediaQuery.addEventListener) {
      this.mediaQuery.addEventListener("change", this.handleMediaChange)
    } else {
      this.mediaQuery.addListener(this.handleMediaChange)
    }

    document.addEventListener("click", this.handleDocumentClick)
    document.addEventListener("keydown", this.handleKeydown)

    this.applyLayout()
  }

  disconnect() {
    this.scrollports?.forEach((port) => {
      port.removeEventListener("scroll", this.boundHandleScroll)
    })
    this.scrollports = []

    if (!this.hasMenuWiring) return

    if (this.mediaQuery) {
      if (this.mediaQuery.removeEventListener) {
        this.mediaQuery.removeEventListener("change", this.handleMediaChange)
      } else {
        this.mediaQuery.removeListener(this.handleMediaChange)
      }
    }

    document.removeEventListener("click", this.handleDocumentClick)
    document.removeEventListener("keydown", this.handleKeydown)

    // Leave the markup as it was rendered so a cached Turbo snapshot never
    // stores relocated nodes.
    this.closeMenu()
    this.restoreCollapsedNodes()
  }

  get hasMenuWiring() {
    return this.hasPanelTarget
  }

  get isNarrowViewport() {
    return this.mediaQuery ? this.mediaQuery.matches : false
  }

  collectScrollports() {
    const ports = new Set()
    ports.add(window)

    const sibling = this.element.nextElementSibling
    if (this.isScrollable(sibling)) ports.add(sibling)

    let node = this.element.parentElement
    while (node && node !== document.body && node !== document.documentElement) {
      if (this.isScrollable(node)) ports.add(node)
      node = node.parentElement
    }

    return Array.from(ports)
  }

  isScrollable(node) {
    if (!node || node.nodeType !== 1) return false

    const style = window.getComputedStyle(node)
    const overflowY = style.overflowY

    return overflowY === "auto" || overflowY === "scroll" || overflowY === "overlay"
  }

  handleScroll() {
    this.updateScrolled()
  }

  pageHasScrolled() {
    return this.scrollports.some((port) => {
      if (port === window) {
        return (window.scrollY || document.documentElement.scrollTop || 0) > 0
      }

      return (port.scrollTop || 0) > 0
    })
  }

  updateScrolled() {
    this.element.dataset.scrolled = this.pageHasScrolled() ? "true" : "false"
  }

  handleMediaChange() {
    this.applyLayout()
  }

  applyLayout() {
    if (this.isNarrowViewport) {
      this.collapseIntoMenu()
    } else {
      this.closeMenu()
      this.restoreCollapsedNodes()
    }
  }

  collapseIntoMenu() {
    if (!this.hasPanelTarget || this.movedNodes.length > 0) return

    this.sectionTargets.forEach((section) => {
      if (section.dataset.flatPackTopNavCollapsible !== "true") return

      Array.from(section.childNodes).forEach((node) => {
        if (this.keepsInlinePlacement(node)) return

        const placeholder = document.createComment("flat-pack-top-nav-placeholder")
        section.insertBefore(placeholder, node)
        this.panelTarget.appendChild(node)
        this.movedNodes.push({ node, placeholder })
      })

      this.updateSectionVisibility(section)
    })

    this.updateMenuVisibility()
  }

  restoreCollapsedNodes() {
    while (this.movedNodes.length > 0) {
      const { node, placeholder } = this.movedNodes.pop()

      if (placeholder.parentNode) {
        placeholder.parentNode.replaceChild(node, placeholder)
      } else if (node.parentNode) {
        node.parentNode.removeChild(node)
      }
    }

    this.sectionTargets.forEach((section) => section.classList.remove("hidden"))
    this.updateMenuVisibility()
  }

  keepsInlinePlacement(node) {
    if (node.nodeType === Node.TEXT_NODE) {
      // Whitespace between elements can move; visible text should not vanish.
      return node.textContent.trim().length > 0
    }

    if (node.nodeType !== Node.ELEMENT_NODE) return true

    return node.dataset.flatPackTopNavAlwaysDisplay === "true"
  }

  updateSectionVisibility(section) {
    const hasRemainingContent = Array.from(section.childNodes).some((node) => {
      if (node.nodeType === Node.ELEMENT_NODE) return true

      return node.nodeType === Node.TEXT_NODE && node.textContent.trim().length > 0
    })

    section.classList.toggle("hidden", !hasRemainingContent)
  }

  updateMenuVisibility() {
    if (!this.hasMenuTarget || !this.hasPanelTarget) return

    const hasMenuContent = this.panelTarget.children.length > 0
    this.menuTarget.classList.toggle("hidden", !hasMenuContent)
    this.menuTarget.classList.toggle("flex", hasMenuContent)
  }

  toggle(event) {
    if (event) event.preventDefault()

    if (this.menuOpen) {
      this.closeMenu()
    } else {
      this.openMenu()
    }
  }

  openMenu() {
    if (!this.hasPanelTarget) return

    this.panelTarget.hidden = false
    this.menuOpen = true
    this.setToggleExpanded(true)
  }

  closeMenu() {
    if (!this.hasPanelTarget) return

    this.panelTarget.hidden = true
    this.menuOpen = false
    this.setToggleExpanded(false)
  }

  setToggleExpanded(expanded) {
    if (!this.hasToggleTarget) return

    this.toggleTarget.setAttribute("aria-expanded", expanded ? "true" : "false")

    this.toggleOpenClasses.forEach((className) => {
      this.toggleTarget.classList.toggle(className, expanded)
    })
  }

  handleDocumentClick(event) {
    if (!this.menuOpen) return

    if (this.hasMenuTarget && this.menuTarget.contains(event.target)) {
      // Following a link inside the menu navigates away, so close it too.
      if (event.target.closest("a[href]")) this.closeMenu()
      return
    }

    this.closeMenu()
  }

  handleKeydown(event) {
    if (event.key !== "Escape" || !this.menuOpen) return

    this.closeMenu()
    if (this.hasToggleTarget) this.toggleTarget.focus()
  }
}
