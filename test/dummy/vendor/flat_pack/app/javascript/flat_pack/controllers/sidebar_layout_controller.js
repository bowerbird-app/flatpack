import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["sidebar", "backdrop", "desktopToggle", "collapsedToggle", "mobileToggle", "headerLabel", "headerBrand", "headerRow", "footer", "scrollContainer"]
  static values = {
    side: String,
    defaultOpen: Boolean,
    storageKey: String
  }

  connect() {
    this.desktopRevealTimeout = null
    this.collapsed = false
    this.mobileOpen = false
    this.isMobile = window.innerWidth < 768
    this.transitionDuration = "300ms"
    this.transitionEasing = "cubic-bezier(0.4, 0, 0.2, 1)"
    this.lastAnchorPath = null
    this.lastAnchorOffset = null

    // Load saved desktop state from localStorage
    if (!this.isMobile && this.hasStorageKeyValue) {
      this.loadDesktopState()
    } else if (!this.isMobile) {
      this.collapsed = !this.defaultOpenValue
    }

    // Apply initial desktop state. The inline FOUC script in the component HTML
    // already set the correct data attribute before <aside> was parsed, so CSS
    // has sized the sidebar correctly. Stimulus setting the same attribute value
    // here causes no CSS change and therefore no animation.
    if (!this.isMobile) {
      this.sidebarTarget.style.pointerEvents = ""
      this.applySidebarPresentationMode()
      this.applyDesktopState()
    } else {
      this.applySidebarPresentationMode()
      this.sidebarTarget.style.pointerEvents = "none"
    }

    // Listen for window resize
    this.handleResize = this.handleResize.bind(this)
    window.addEventListener("resize", this.handleResize)

    // Persist/restore sidebar scroll position around Turbo navigations
    this.handleTurboBeforeCache = this.handleTurboBeforeCache.bind(this)
    this.handleTurboBeforeRender = this.handleTurboBeforeRender.bind(this)
    this.handleTurboLoad = this.handleTurboLoad.bind(this)
    this.handleSidebarLinkClick = this.handleSidebarLinkClick.bind(this)
    this.handlePageHide = this.handlePageHide.bind(this)
    this.handleSidebarScroll = this.handleSidebarScroll.bind(this)

    document.addEventListener("turbo:before-cache", this.handleTurboBeforeCache)
    document.addEventListener("turbo:before-render", this.handleTurboBeforeRender)
    document.addEventListener("turbo:load", this.handleTurboLoad)
    window.addEventListener("pagehide", this.handlePageHide)
    this.element.addEventListener("click", this.handleSidebarLinkClick, true)
    this.bindScrollPersistenceListener()

    // If this page was pre-restored during turbo:before-render, do not re-apply.
    const preRestored = this.currentScrollContainer()?.dataset?.flatPackScrollPreRestored === "true"
    if (!preRestored) {
      // Restore on direct page loads/non-Turbo navigations.
      const hasPersistedScrollState = !!this.readScrollState()
      if (hasPersistedScrollState) {
        this.restoreScrollPosition()
      }
    } else {
      delete this.currentScrollContainer().dataset.flatPackScrollPreRestored
    }

    this.scrollActiveItemIntoView()
  }

  disconnect() {
    this.clearDesktopRevealTimeout()
    window.removeEventListener("resize", this.handleResize)
    document.removeEventListener("turbo:before-cache", this.handleTurboBeforeCache)
    document.removeEventListener("turbo:before-render", this.handleTurboBeforeRender)
    document.removeEventListener("turbo:load", this.handleTurboLoad)
    window.removeEventListener("pagehide", this.handlePageHide)
    this.element.removeEventListener("click", this.handleSidebarLinkClick, true)
    this.unbindScrollPersistenceListener()

    // Persist as a fallback when leaving without Turbo lifecycle
    this.persistScrollState()
  }

  handleResize() {
    const wasMobile = this.isMobile
    this.isMobile = window.innerWidth < 768

    if (wasMobile !== this.isMobile) {
      if (this.isMobile) {
        // Switched to mobile - close sidebar
        this.applySidebarPresentationMode()
        this.closeMobile()
      } else {
        // Switched to desktop - apply saved state
        this.applySidebarPresentationMode()
        this.sidebarTarget.style.pointerEvents = ""
        this.applyDesktopState()
      }
    }
  }

  toggleDesktop() {
    if (this.isMobile) return

    const opening = this.collapsed
    this.collapsed = !this.collapsed
    this.applyDesktopState({ delayContentReveal: opening })
    this.saveDesktopState()
  }

  toggleMobile() {
    if (!this.isMobile) return

    this.mobileOpen = !this.mobileOpen

    if (this.mobileOpen) {
      this.openMobile()
    } else {
      this.closeMobile()
    }
  }

  openMobile() {
    // Store the element that triggered the open for focus return
    this.previouslyFocusedElement = document.activeElement

    // Enable interaction while open
    this.sidebarTarget.style.pointerEvents = "auto"

    // Ensure starting off-screen state is rendered before animating in
    if (this.sideValue === "right") {
      this.sidebarTarget.classList.add("translate-x-full")
    } else {
      this.sidebarTarget.classList.add("-translate-x-full")
    }

    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        if (!this.mobileOpen || !this.isMobile) return

        // Slide in from correct side
        if (this.sideValue === "right") {
          this.sidebarTarget.classList.remove("translate-x-full")
        } else {
          this.sidebarTarget.classList.remove("-translate-x-full")
        }
      })
    })

    // Show backdrop
    if (this.hasBackdropTarget) {
      this.backdropTarget.classList.remove("pointer-events-none")
      this.backdropTarget.classList.remove("opacity-0")
      this.backdropTarget.classList.add("opacity-100")
      this.backdropTarget.setAttribute("aria-hidden", "false")
    }

    // Prevent body scroll
    document.body.style.overflow = "hidden"

    // Focus sidebar container without scrolling to avoid layout jump
    if (!this.sidebarTarget.hasAttribute("tabindex")) {
      this.sidebarTarget.setAttribute("tabindex", "-1")
    }
    this.sidebarTarget.focus({ preventScroll: true })

    // Listen for Escape key
    this.handleEscape = this.handleEscape.bind(this)
    document.addEventListener("keydown", this.handleEscape)
  }

  closeMobile() {
      // Disable interaction while closed
      this.sidebarTarget.style.pointerEvents = "none"

    // Slide out to correct side
    if (this.sideValue === "right") {
      this.sidebarTarget.classList.add("translate-x-full")
    } else {
      this.sidebarTarget.classList.add("-translate-x-full")
    }

    // Hide backdrop
    if (this.hasBackdropTarget) {
      this.backdropTarget.classList.add("pointer-events-none")
      this.backdropTarget.classList.remove("opacity-100")
      this.backdropTarget.classList.add("opacity-0")
      this.backdropTarget.setAttribute("aria-hidden", "true")
    }

    // Restore body scroll
    document.body.style.overflow = ""

    // Remove Escape key listener
    document.removeEventListener("keydown", this.handleEscape)

    // Return focus to toggle button
    if (this.previouslyFocusedElement) {
      this.previouslyFocusedElement.focus()
      this.previouslyFocusedElement = null
    }

    this.mobileOpen = false
  }

  handleEscape(event) {
    if (event.key === "Escape" && this.mobileOpen) {
      this.closeMobile()
    }
  }

  applyDesktopState({ delayContentReveal = false } = {}) {
    if (this.isMobile) return

    // Width is driven by CSS via the data-flat-pack-sidebar-collapsed attribute
    // (set below, and pre-set by the inline FOUC script before first paint).
    // Inline styles are set as a fallback for host apps that haven't imported
    // the FlatPack CSS rules that respond to this attribute.
    const sidebarContent = this.sidebarTarget.querySelector("aside")
    if (this.collapsed) {
      this.sidebarTarget.style.width = "4rem"
      if (sidebarContent) sidebarContent.style.width = "4rem"
    } else {
      this.sidebarTarget.style.width = "16rem"
      if (sidebarContent) sidebarContent.style.width = "16rem"
    }

    // Update desktop toggle if exists
    if (this.hasDesktopToggleTarget) {
      this.desktopToggleTarget.setAttribute("aria-expanded", !this.collapsed)
      if (this.collapsed) {
        this.desktopToggleTarget.classList.add("hidden")
      } else {
        this.desktopToggleTarget.classList.remove("hidden")
      }
      
      // Update chevron rotation
      const chevron = this.desktopToggleTarget.querySelector('[data-flat-pack--sidebar-layout-target="chevron"]')
      if (chevron) {
        if (this.collapsed) {
          chevron.style.transform = "rotate(180deg)"
        } else {
          chevron.style.transform = "rotate(0deg)"
        }
      }
    }

    // Update collapsed-state toggle visibility
    if (this.hasCollapsedToggleTarget) {
      this.collapsedToggleTarget.setAttribute("aria-expanded", this.collapsed ? "false" : "true")
      if (this.collapsed) {
        this.collapsedToggleTarget.classList.remove("hidden")
        this.collapsedToggleTarget.classList.add("flex")
      } else {
        this.collapsedToggleTarget.classList.add("hidden")
        this.collapsedToggleTarget.classList.remove("flex")
      }
    }

    this.sidebarTarget.dataset.flatPackSidebarCollapsed = this.collapsed ? "true" : "false"
    if (sidebarContent) {
      sidebarContent.dataset.flatPackSidebarCollapsed = this.collapsed ? "true" : "false"
    }

    this.updateCollapsedScrollContainerState()

    this.clearDesktopRevealTimeout()

    if (this.collapsed) {
      this.setDesktopExpandedContentVisible(false)
      return
    }

    if (delayContentReveal) {
      this.setDesktopExpandedContentVisible(false)
      this.desktopRevealTimeout = setTimeout(() => {
        if (!this.isMobile && !this.collapsed) {
          this.setDesktopExpandedContentVisible(true)
        }
      }, 300)
      return
    }

    this.setDesktopExpandedContentVisible(true)
  }

  setDesktopExpandedContentVisible(visible) {
    const headerBrands = this.sidebarTarget.querySelectorAll('[data-flat-pack--sidebar-layout-target="headerBrand"]')
    headerBrands.forEach(brand => {
      if (visible) {
        brand.classList.remove("hidden")
      } else {
        brand.classList.add("hidden")
      }
    })

    // Only toggle text label spans (avoid containers like .flex-1 overflow-y-auto)
    const labels = this.sidebarTarget.querySelectorAll("a > span.flex-1, button > span.flex-1")
    labels.forEach(label => {
      if (visible) {
        label.classList.remove("sr-only")
      } else if (!label.classList.contains("sr-only")) {
        label.classList.add("sr-only")
      }
    })

    const headerLabels = this.sidebarTarget.querySelectorAll('[data-flat-pack--sidebar-layout-target="headerLabel"]')
    headerLabels.forEach(label => {
      if (visible) {
        label.classList.remove("sr-only")
      } else {
        label.classList.add("sr-only")
      }
    })

    const footers = this.sidebarTarget.querySelectorAll('[data-flat-pack--sidebar-layout-target="footer"]')
    footers.forEach(footer => {
      if (visible) {
        footer.classList.remove("hidden")
      } else {
        footer.classList.add("hidden")
      }
    })

    // Group items are rendered with indent for expanded mode.
    // Remove that indent in collapsed mode so icons align with top-level items.
    const groupPanels = this.sidebarTarget.querySelectorAll('[data-flat-pack--sidebar-group-target="panel"]')
    groupPanels.forEach(panel => {
      if (visible) {
        panel.classList.add("pl-[var(--sidebar-group-item-indent)]")
      } else {
        panel.classList.remove("pl-[var(--sidebar-group-item-indent)]")
      }
    })

    // Hide group chevrons when collapsed so only icons remain visible.
    const groupChevrons = this.sidebarTarget.querySelectorAll('[data-flat-pack--sidebar-group-target="chevron"]')
    groupChevrons.forEach(chevron => {
      if (visible) {
        chevron.classList.remove("hidden")
      } else {
        chevron.classList.add("hidden")
      }
    })

    // Adjust item link/button padding and alignment for collapsed (icon-only) mode.
    const sidebarItemLinks = this.sidebarTarget.querySelectorAll('[data-flat-pack-sidebar-item="true"]')
    sidebarItemLinks.forEach(item => {
      if (visible) {
        item.classList.remove("px-1", "justify-center")
        item.classList.add("px-4")
      } else {
        item.classList.remove("px-4")
        item.classList.add("px-1", "justify-center")
      }
    })

    // Center the header row content when collapsed (icon-only mode).
    const headerRows = this.sidebarTarget.querySelectorAll('[data-flat-pack--sidebar-layout-target="headerRow"]')
    headerRows.forEach(row => {
      if (visible) {
        row.classList.remove("justify-center")
      } else {
        row.classList.add("justify-center")
      }
    })

    // Adjust section title padding for collapsed (icon-only) mode.
    const sectionTitles = this.sidebarTarget.querySelectorAll('[data-flat-pack-sidebar-section-title="true"]')
    sectionTitles.forEach(title => {
      if (visible) {
        title.classList.remove("px-1")
        title.classList.add("px-4")
      } else {
        title.classList.remove("px-4")
        title.classList.add("px-1")
      }
    })
  }

  updateCollapsedScrollContainerState() {
    const scrollContainer = this.currentScrollContainer()
    if (!scrollContainer) return

    scrollContainer.classList.toggle("fp-scrollbar-hidden", this.collapsed)
  }

  clearDesktopRevealTimeout() {
    if (this.desktopRevealTimeout) {
      clearTimeout(this.desktopRevealTimeout)
      this.desktopRevealTimeout = null
    }
  }

  applySidebarPresentationMode() {
    const sidebarContent = this.sidebarTarget.querySelector("aside")

    this.sidebarTarget.style.transitionDuration = this.transitionDuration
    this.sidebarTarget.style.transitionTimingFunction = this.transitionEasing

    if (this.isMobile) {
      this.sidebarTarget.style.zIndex = "50"
      this.sidebarTarget.style.transitionProperty = "transform"

      if (sidebarContent) {
        sidebarContent.style.transitionProperty = ""
        sidebarContent.style.transitionDuration = ""
        sidebarContent.style.transitionTimingFunction = ""
      }
      return
    }

    this.sidebarTarget.style.zIndex = "auto"
    this.sidebarTarget.style.transitionProperty = "width, transform"

    if (sidebarContent) {
      sidebarContent.style.transitionProperty = "width"
      sidebarContent.style.transitionDuration = this.transitionDuration
      sidebarContent.style.transitionTimingFunction = this.transitionEasing
    }
  }

  saveDesktopState() {
    if (this.hasStorageKeyValue) {
      localStorage.setItem(this.storageKeyValue, this.collapsed.toString())
    }
  }

  loadDesktopState() {
    if (this.hasStorageKeyValue) {
      const saved = localStorage.getItem(this.storageKeyValue)
      if (saved !== null) {
        this.collapsed = saved === "true"
      }
    }
  }

  handleTurboBeforeCache() {
    this.persistScrollState()
  }

  handleTurboLoad() {
    // activateSidebarNav() in the layout runs on turbo:load and sets aria-current="page".
    // Calling scrollActiveItemIntoView() here (after that listener) ensures the sidebar
    // is scrolled to the active item on every navigation and direct page load.
    this.scrollActiveItemIntoView()
  }

  handleTurboBeforeRender(event) {
    this.persistScrollState()

    const newBody = event?.detail?.newBody
    if (!newBody) return

    const newScrollContainer = this.findScrollContainerInBody(newBody)
    this.restoreScrollPositionInContainer(newScrollContainer, {correctWithAnchor: true})
    if (newScrollContainer) {
      newScrollContainer.dataset.flatPackScrollPreRestored = "true"
    }
  }

  handleSidebarLinkClick(event) {
    const link = event.target.closest("a[href]")
    if (!link || !this.sidebarTarget.contains(link)) return

    const scrollContainer = this.currentScrollContainer()
    if (!scrollContainer) return

    this.lastAnchorPath = this.normalizePath(link.href)
    this.lastAnchorOffset = link.getBoundingClientRect().top - scrollContainer.getBoundingClientRect().top
    this.persistScrollState()
  }

  handleSidebarScroll() {
    this.persistScrollState()
  }

  handlePageHide() {
    this.persistScrollState()
  }

  persistScrollState() {
    const scrollContainer = this.currentScrollContainer()
    if (!scrollContainer) return

    this.writeScrollState({
      scrollTop: scrollContainer.scrollTop,
      anchorPath: this.lastAnchorPath,
      anchorOffset: this.lastAnchorOffset
    })
  }

  restoreScrollPosition(options = {}) {
    this.restoreScrollPositionInContainer(this.currentScrollContainer(), options)
  }

  restoreScrollPositionInContainer(scrollContainer, { correctWithAnchor = false } = {}) {
    if (!scrollContainer) return

    const state = this.readScrollState()
    if (!state) return

    if (typeof state.scrollTop === "number") {
      scrollContainer.scrollTop = state.scrollTop
    }

    if (!correctWithAnchor) return

    if (state.anchorPath && typeof state.anchorOffset === "number") {
      const anchorLink = this.findSidebarLinkByPath(state.anchorPath)
      if (anchorLink) {
        const currentOffset = anchorLink.getBoundingClientRect().top - scrollContainer.getBoundingClientRect().top
        scrollContainer.scrollTop += (currentOffset - state.anchorOffset)
      }
    }
  }

  findSidebarLinkByPath(path) {
    const links = this.element.querySelectorAll("a[href]")
    for (const link of links) {
      if (this.normalizePath(link.href) === path) {
        return link
      }
    }
    return null
  }

  findScrollContainerInBody(body) {
    return body.querySelector('[data-flat-pack--sidebar-layout-target="scrollContainer"]') ||
      body.querySelector('[data-flat-pack--sidebar-layout-target="sidebar"] aside > .flex-1.min-h-0.overflow-y-auto')
  }

  currentScrollContainer() {
    if (this.hasScrollContainerTarget) {
      return this.scrollContainerTarget
    }

    return this.element.querySelector('[data-flat-pack--sidebar-layout-target="scrollContainer"]') ||
      this.sidebarTarget?.querySelector('aside > .flex-1.min-h-0.overflow-y-auto')
  }

  bindScrollPersistenceListener() {
    const scrollContainer = this.currentScrollContainer()
    if (!scrollContainer) return

    this.scrollPersistenceElement = scrollContainer
    this.scrollPersistenceElement.addEventListener("scroll", this.handleSidebarScroll, {passive: true})
  }

  unbindScrollPersistenceListener() {
    if (!this.scrollPersistenceElement) return

    this.scrollPersistenceElement.removeEventListener("scroll", this.handleSidebarScroll)
    this.scrollPersistenceElement = null
  }

  normalizePath(href) {
    try {
      const url = new URL(href, window.location.origin)
      return `${url.pathname}${url.search}`
    } catch {
      return null
    }
  }

  scrollStateKey() {
    const baseKey = this.hasStorageKeyValue ? this.storageKeyValue : "flat-pack-sidebar-layout"
    const sideKey = this.hasSideValue ? this.sideValue : "left"
    return `${baseKey}:${sideKey}:scroll`
  }

  writeScrollState(payload) {
    try {
      sessionStorage.setItem(this.scrollStateKey(), JSON.stringify(payload))
    } catch {
      // Ignore storage errors (private mode / disabled storage)
    }
  }

  readScrollState() {
    try {
      const raw = sessionStorage.getItem(this.scrollStateKey())
      if (!raw) return null

      const parsed = JSON.parse(raw)
      if (!parsed || typeof parsed !== "object") return null

      return {
        scrollTop: Number.isFinite(parsed.scrollTop) ? parsed.scrollTop : null,
        anchorPath: typeof parsed.anchorPath === "string" ? parsed.anchorPath : null,
        anchorOffset: Number.isFinite(parsed.anchorOffset) ? parsed.anchorOffset : null
      }
    } catch {
      return null
    }
  }

  scrollActiveItemIntoView() {
    const scrollContainer = this.currentScrollContainer()
    if (!scrollContainer) return

    const activeItem = this.element.querySelector('a[data-flat-pack-sidebar-item="true"][aria-current="page"]')
    if (!activeItem) return

    requestAnimationFrame(() => {
      // Align active navigation item to the top edge of the scroll container.
      const containerRect = scrollContainer.getBoundingClientRect()
      const itemRect = activeItem.getBoundingClientRect()
      scrollContainer.scrollTop += itemRect.top - containerRect.top

      this.persistScrollState()
    })
  }
}
