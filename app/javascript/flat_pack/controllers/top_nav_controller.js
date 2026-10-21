import { Controller } from "@hotwired/stimulus"

// On a narrow viewport, moves the top nav row into one hamburger menu. The
// open menu is a single column. A nested dropdown stays a parent row and
// discloses its items in place. A wide viewport keeps the row. Nodes are
// relocated rather than duplicated so ids, event listeners and Stimulus
// controllers inside slot content keep working. The sidebar's own mobile
// toggle stays in the bar.
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

    this.fitting = false
    if (typeof ResizeObserver !== "undefined") {
      this.resizeObserver = new ResizeObserver(() => this.applyLayout())
      this.resizeObserver.observe(this.element)
    }

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
    this.resizeObserver?.disconnect()

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
    if (this.element.closest?.("[data-flat-pack-layout-scroll]")?.dataset?.flatPackLayoutScroll === "page") {
      return [window]
    }

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
    this.placeMenu()
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
    if (this.fitting) return

    this.fitting = true
    try {
      if (this.isNarrowViewport) this.collapseIntoMenu()
      else {
        this.closeMenu()
        this.restoreCollapsedNodes()
      }
    } finally {
      this.fitting = false
    }
  }

  collapseIntoMenu() {
    if (!this.hasPanelTarget || this.movedNodes.length > 0) return

    this.sectionTargets.forEach((section) => {
      if (section.dataset.flatPackTopNavCollapsible !== "true") return

      Array.from(section.childNodes).forEach((node) => {
        if (this.keepsInlinePlacement(node) || this.isSidebarToggle(node)) return

        const placeholder = document.createComment("flat-pack-top-nav-placeholder")
        section.insertBefore(placeholder, node)
        this.panelTarget.appendChild(node)
        this.movedNodes.push({ node, placeholder })
      })

      this.updateSectionVisibility(section)
    })

    this.prepareDisclosures()
    this.updateMenuVisibility()
  }

  // A dropdown inside the phone menu is a disclosure. Its items stay in its
  // own group and are not lifted into the column.
  prepareDisclosures() {
    const panel = this.panelTarget
    if (!panel || typeof panel.querySelectorAll !== "function") return

    this.disclosures = []
    panel.querySelectorAll("[data-controller~='flat-pack--button-dropdown']").forEach((dropdown) => {
      const trigger = dropdown.querySelector("[data-flat-pack--button-dropdown-target='trigger']")
      const menu = dropdown.querySelector("[data-flat-pack--button-dropdown-target='menu']")
      if (!trigger || !menu || typeof trigger.addEventListener !== "function") return

      const record = {
        dropdown,
        trigger,
        menu,
        expanded: trigger.getAttribute("aria-expanded"),
        controls: trigger.getAttribute("aria-controls"),
        menuRole: menu.getAttribute("role"),
        menuHidden: menu.getAttribute("aria-hidden"),
        menuLabel: menu.getAttribute("aria-label"),
        menuId: menu.id || ""
      }

      if (!menu.id) {
        this.disclosureIndex = (this.disclosureIndex || 0) + 1
        menu.id = `flat-pack-top-nav-disclosure-${this.disclosureIndex}`
      }

      dropdown.dataset.flatPackTopNavDisclosure = "true"
      const label = (trigger.getAttribute("aria-label") || trigger.textContent || "").trim()
      if (label) menu.setAttribute("aria-label", label)
      menu.setAttribute("role", "group")
      trigger.setAttribute("aria-controls", menu.id)

      record.onClick = (event) => {
        event.preventDefault()
        event.stopPropagation()
        if (typeof event.stopImmediatePropagation === "function") event.stopImmediatePropagation()
        const open = dropdown.dataset.flatPackTopNavExpanded === "true"
        this.setDisclosure(record, !open)
      }
      trigger.addEventListener("click", record.onClick, true)
      this.setDisclosure(record, false)
      this.disclosures.push(record)
    })
  }

  setDisclosure(record, open, {focus = true} = {}) {
    const {dropdown, trigger, menu} = record
    dropdown.dataset.flatPackTopNavExpanded = open ? "true" : "false"
    trigger.setAttribute("aria-expanded", open ? "true" : "false")
    menu.setAttribute("aria-hidden", open ? "false" : "true")

    if (focus && !open && typeof menu.contains === "function" && menu.contains(document.activeElement) && typeof trigger.focus === "function") {
      trigger.focus()
    }
  }

  collapseDisclosures() {
    if (!this.disclosures) return

    this.disclosures.forEach((record) => this.setDisclosure(record, false, {focus: false}))
  }

  restoreDisclosures() {
    if (!this.disclosures) return

    while (this.disclosures.length > 0) {
      const record = this.disclosures.pop()
      const {dropdown, trigger, menu, onClick} = record
      trigger.removeEventListener("click", onClick, true)
      this.writeAttribute(trigger, "aria-expanded", record.expanded)
      this.writeAttribute(trigger, "aria-controls", record.controls)
      this.writeAttribute(menu, "role", record.menuRole)
      this.writeAttribute(menu, "aria-hidden", record.menuHidden)
      this.writeAttribute(menu, "aria-label", record.menuLabel)
      if (!record.menuId) menu.id = ""
      delete dropdown.dataset.flatPackTopNavDisclosure
      delete dropdown.dataset.flatPackTopNavExpanded
    }
  }

  writeAttribute(element, name, value) {
    if (value == null || value === "") element.removeAttribute(name)
    else element.setAttribute(name, value)
  }

  isSidebarToggle(node) {
    if (!node || node.nodeType !== Node.ELEMENT_NODE) return false
    if (typeof node.matches !== "function") return false

    return node.matches("[data-flat-pack--sidebar-layout-target='mobileToggle']")
  }

  restoreCollapsedNodes() {
    this.restoreDisclosures()

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
    this.placeMenu()
  }

  // The bar can sit in a short overflow-hidden column. Fix the open panel to
  // the viewport so that column does not clip it. A transformed shell ancestor
  // becomes the fixed containing block, so the offset is measured, not assumed.
  placeMenu() {
    if (!this.menuOpen || !this.hasPanelTarget || !this.hasToggleTarget) return
    if (typeof this.toggleTarget.getBoundingClientRect !== "function") return
    if (typeof this.panelTarget.getBoundingClientRect !== "function") return

    const rect = this.toggleTarget.getBoundingClientRect()
    const top = Math.round(rect.bottom + 8)
    const panel = this.panelTarget
    const margin = 8

    panel.style.position = "fixed"
    panel.style.top = `${top}px`
    panel.style.right = "auto"
    panel.style.left = "0px"
    panel.style.zIndex = "30"
    panel.style.maxHeight = `calc(100vh - ${top + 8}px)`
    panel.style.overflowY = "auto"

    const placed = panel.getBoundingClientRect()
    const viewportWidth = window.innerWidth || 0
    const width = placed.width
    let desired = rect.right - width
    const maxLeft = Math.max(margin, viewportWidth - width - margin)
    desired = Math.max(margin, Math.min(desired, maxLeft))
    panel.style.left = `${Math.round(desired - placed.left)}px`
  }

  clearMenuPlacement() {
    if (!this.hasPanelTarget || !this.panelTarget.style) return

    const panel = this.panelTarget
    panel.style.position = ""
    panel.style.top = ""
    panel.style.right = ""
    panel.style.left = ""
    panel.style.zIndex = ""
    panel.style.maxHeight = ""
    panel.style.overflowY = ""
  }

  closeMenu() {
    if (!this.hasPanelTarget) return

    this.collapseDisclosures()
    this.panelTarget.hidden = true
    this.menuOpen = false
    this.setToggleExpanded(false)
    this.clearMenuPlacement()
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
