import { Controller } from "@hotwired/stimulus"

// Moves collapsible top nav content into one ellipsis menu on a narrow bar,
// and frosts the bar after the page has scrolled. A phone viewport also folds
// left-slot actions into that menu, keeping the sidebar toggle and a page-nav
// back or close control. Nodes are relocated rather than duplicated so ids,
// event listeners and Stimulus controllers inside slot content keep working,
// and a comment placeholder records where each node has to return to.
export default class extends Controller {
  static targets = ["section", "menu", "toggle", "panel"]
  static classes = ["toggleOpen"]
  static values = {
    breakpoint: { type: Number, default: 768 }
  }

  connect() {
    this.movedNodes = []
    this.flattenedMores = []
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

    const tight = this.isNarrowViewport || this.barIsNarrow()
    this.fitting = true
    try {
      if (tight) this.collapseIntoMenu()
      else {
        this.closeMenu()
        this.restoreCollapsedNodes()
      }
    } finally {
      this.fitting = false
    }
  }

  // A wide viewport can still leave a narrow bar, such as the main column
  // between a rail and an aside. The breakpoint is that bar's width.
  barIsNarrow() {
    const width = this.element?.clientWidth || 0
    return width > 0 && width < this.breakpointValue
  }

  collapseIntoMenu() {
    if (!this.hasPanelTarget || this.movedNodes.length > 0) return

    // A wide window keeps the desktop row, even when the bar itself is narrow
    // (a floating column between a rail and an aside). Collapsible center and
    // right slots still fold there. Left actions, page-nav unpacking, and the
    // single More menu are phone-only, so that desktop row stays put.
    if (this.isNarrowViewport) {
      this.collapsePhoneBar()
      return
    }

    this.sectionTargets.forEach((section) => {
      if (section.dataset.flatPackTopNavCollapsible !== "true") return

      Array.from(section.childNodes).forEach((node) => {
        if (this.keepsInlinePlacement(node)) return

        this.relocate(node, section)
      })

      this.updateSectionVisibility(section)
    })

    this.updateMenuVisibility()
  }

  // Phone order is source order: left, then center, then right. Page-nav
  // actions are collected from inside the nav so back can stay in the bar
  // while the rest join the menu ahead of later slots.
  collapsePhoneBar() {
    const pending = []

    this.sectionTargets.forEach((section) => {
      const collapsible = section.dataset.flatPackTopNavCollapsible === "true"

      Array.from(section.childNodes).forEach((node) => {
        if (this.keepsInlinePlacement(node)) return

        if (this.isPageNav(node)) {
          this.collectPageNavActions(node, pending)
          return
        }

        if (this.isPinned(node)) return
        if (collapsible || this.isOverflowAction(node)) pending.push({node, parent: section})
      })
    })

    pending.forEach(({node, parent}) => this.relocate(node, parent))
    this.sectionTargets.forEach((section) => this.updateSectionVisibility(section))
    this.hideEmptyPageNavs()
    this.flattenMoreMenus()
    this.orderPrimaryFirst()
    this.syncUnreadDot()
    this.updateMenuVisibility()
  }

  restoreCollapsedNodes() {
    this.unflattenMoreMenus()
    this.clearUnreadDot()
    this.showPageNavs()

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

  relocate(node, parent) {
    if (!parent || node.parentNode === this.panelTarget) return

    const placeholder = document.createComment("flat-pack-top-nav-placeholder")
    parent.insertBefore(placeholder, node)
    this.panelTarget.appendChild(node)
    this.movedNodes.push({ node, placeholder })
  }

  isPageNav(node) {
    return node?.nodeType === Node.ELEMENT_NODE && typeof node.matches === "function" && node.matches(".flat-pack-page-nav")
  }

  collectPageNavActions(nav, pending) {
    const row = (typeof nav.querySelector === "function" && nav.querySelector(":scope > div")) || nav

    Array.from(row.children || []).forEach((child) => {
      if (this.keepsInlinePlacement(child) || this.isPinned(child)) return

      pending.push({node: child, parent: row})
    })
  }

  hideEmptyPageNavs() {
    if (typeof this.element.querySelectorAll !== "function") return

    this.element.querySelectorAll(".flat-pack-page-nav").forEach((nav) => {
      const row = nav.querySelector(":scope > div") || nav
      const occupied = Array.from(row.children || []).some((child) => child.nodeType === Node.ELEMENT_NODE)
      if (!occupied) nav.hidden = true
    })
  }

  showPageNavs() {
    if (typeof this.element.querySelectorAll !== "function") return

    this.element.querySelectorAll(".flat-pack-page-nav").forEach((nav) => {
      nav.hidden = false
    })
  }

  // Page nav's own More menu becomes rows in this menu. No nested More.
  flattenMoreMenus() {
    if (typeof this.panelTarget.querySelectorAll !== "function") return

    this.flattenedMores = this.flattenedMores || []

    this.panelTarget.querySelectorAll("[data-controller~='flat-pack--button-dropdown']").forEach((dropdown) => {
      const trigger = dropdown.querySelector("[data-flat-pack--button-dropdown-target='trigger']")
      const label = (trigger?.innerText || trigger?.textContent || "").replace(/\s+/g, " ").trim()
      if (label !== "More") return

      const menu = dropdown.querySelector("[role='menu']")
      if (!menu) return

      const items = Array.from(menu.children).filter((node) => node.nodeType === Node.ELEMENT_NODE)
      if (items.length === 0) return

      const marker = document.createComment("flat-pack-top-nav-more")
      dropdown.parentNode.insertBefore(marker, dropdown)
      items.forEach((item) => dropdown.parentNode.insertBefore(item, dropdown))
      dropdown.hidden = true
      this.flattenedMores.push({ dropdown, marker, items, menu })
    })
  }

  unflattenMoreMenus() {
    if (!this.flattenedMores) return

    while (this.flattenedMores.length > 0) {
      const { dropdown, marker, items, menu } = this.flattenedMores.pop()
      items.forEach((item) => menu.appendChild(item))
      dropdown.hidden = false
      if (marker.parentNode) marker.parentNode.insertBefore(dropdown, marker)
      marker.remove?.()
    }
  }

  orderPrimaryFirst() {
    const kids = Array.from(this.panelTarget.children || [])
    if (kids.length < 2) return

    const ordered = [
      ...kids.filter((el) => this.isPrimary(el)),
      ...kids.filter((el) => !this.isPrimary(el))
    ]
    if (ordered.every((el, index) => el === kids[index])) return

    ordered.forEach((el) => this.panelTarget.appendChild(el))
  }

  isPrimary(node) {
    if (!node || node.nodeType !== Node.ELEMENT_NODE) return false
    if (node.dataset?.fpStyle === "primary") return true
    if (typeof node.querySelector !== "function") return false

    return !!node.querySelector("[data-fp-style='primary']")
  }

  syncUnreadDot() {
    if (!this.hasToggleTarget || typeof this.panelTarget.querySelector !== "function") return

    const unread = this.panelTarget.querySelector(".fp-red-dot, [data-flat-pack-unread='true']")
    if (unread) this.toggleTarget.setAttribute("data-flat-pack-unread", "true")
    else this.toggleTarget.removeAttribute("data-flat-pack-unread")
  }

  clearUnreadDot() {
    if (!this.hasToggleTarget) return

    this.toggleTarget.removeAttribute?.("data-flat-pack-unread")
  }

  isOverflowAction(node) {
    if (!node || node.nodeType !== Node.ELEMENT_NODE || this.isPinned(node)) return false
    if (typeof node.matches !== "function") return false
    if (node.matches(".flat-pack-page-nav")) return false

    return node.matches("button, a, [data-controller~='flat-pack--button-dropdown']")
  }

  isPinned(node) {
    if (!node || node.nodeType !== Node.ELEMENT_NODE) return false
    if (node.dataset?.flatPackTopNavAlwaysDisplay === "true") return true
    if (typeof node.matches !== "function") return false

    const selector = [
      "[data-flat-pack--sidebar-layout-target='mobileToggle']",
      "[data-flat-pack--sidebar-layout-target='asideToggle']",
      "[data-action*='page-nav#back']",
      "[data-action*='page-nav#close']",
      "[data-flat-pack-page-nav='back']",
      "[data-flat-pack-page-nav='close']"
    ].join(", ")

    if (node.matches(selector)) return true
    if (typeof node.querySelector !== "function") return false

    return !!node.querySelector(selector)
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

  // The bar can sit in a short overflow-hidden column. An absolute menu is
  // clipped there, so the open panel is fixed to the viewport under the toggle.
  placeMenu() {
    if (!this.menuOpen || !this.hasPanelTarget || !this.hasToggleTarget) return
    if (typeof this.toggleTarget.getBoundingClientRect !== "function") return

    const rect = this.toggleTarget.getBoundingClientRect()
    const panel = this.panelTarget
    const top = Math.round(rect.bottom + 8)

    panel.style.position = "fixed"
    panel.style.top = `${top}px`
    panel.style.right = `${Math.max(8, Math.round(window.innerWidth - rect.right))}px`
    panel.style.left = "auto"
    panel.style.zIndex = "30"
    panel.style.maxHeight = `calc(100vh - ${top + 8}px)`
    panel.style.overflowY = "auto"
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
