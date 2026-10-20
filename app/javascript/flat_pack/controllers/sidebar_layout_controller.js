import { Controller } from "@hotwired/stimulus"

const BODY_LOCK = "flatPackModalLockCount"

export default class extends Controller {
  static targets = ["sidebar", "backdrop", "mobileToggle", "scrollContainer", "aside", "asideToggle"]
  static values = {
    side: String,
    open: Boolean,
    storageKey: String,
    asideOpen: Boolean,
    asideStorageKey: String
  }

  connect() {
    this.collapsed = false
    this.mobileOpen = false
    this.openDrawers = []
    this.holdingLock = false
    this.drawerOpeners = new Map()
    this.isMobile = window.innerWidth < 768
    this.transitionDuration = "var(--duration-slow)"
    this.transitionEasing = "var(--easing-standard)"
    this.lastAnchorPath = null
    this.lastAnchorOffset = null

    if (this.hasSidebarTarget) {
      // Load saved desktop state from localStorage
      if (!this.isMobile && this.hasStorageKeyValue) {
        this.loadDesktopState()
      } else if (!this.isMobile) {
        this.collapsed = !this.openValue
      }

      // Apply initial desktop state. The inline FOUC script in the component HTML
      // already set the correct data attribute before <aside> was parsed, so CSS
      // has sized the sidebar correctly. Stimulus setting the same attribute value
      // here causes no CSS change and therefore no animation.
      if (!this.isMobile) {
        this.sidebarTarget.style.pointerEvents = ""
        this.applySidebarPresentationMode()
        this.applyDesktopState({ immediate: true })
      } else {
        this.applySidebarPresentationMode()
        this.sidebarTarget.style.pointerEvents = "none"
      }
    }

    if (this.hasAsideTarget) {
      this.asideOpen = this.readAsideOpen()
      if (this.isMobile) this.parkAsideOffCanvas()
      else this.applyAsideOpen({ persist: false })
      this.syncAsideToggleAria()
    }

    this.boundCollapseRail = (event) => this.collapseRailFromResize(event)
    this.element.addEventListener("flat-pack:collapse-rail", this.boundCollapseRail)

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
    this.bindFloatingTopNavClearance()
    this.bindOpenWidthMemory()
    this.rememberOpenWidth()
    this.remeasureOpenWidthWhenFontsReady()

    // Groups apply open state after this parent controller connects. Wait until
    // that height is in so a long list can restore the real scrollTop.
    this.scheduleScrollRestore()
  }

  disconnect() {
    window.removeEventListener("resize", this.handleResize)
    document.removeEventListener("turbo:before-cache", this.handleTurboBeforeCache)
    document.removeEventListener("turbo:before-render", this.handleTurboBeforeRender)
    document.removeEventListener("turbo:load", this.handleTurboLoad)
    window.removeEventListener("pagehide", this.handlePageHide)
    this.element.removeEventListener("click", this.handleSidebarLinkClick, true)
    this.unbindScrollPersistenceListener()
    this.unbindFloatingTopNavClearance()
    this.unbindOpenWidthMemory()
    if (this.boundCollapseRail) {
      this.element.removeEventListener("flat-pack:collapse-rail", this.boundCollapseRail)
    }
    this.openDrawers = []
    this.syncBodyLock()
    this.unbindEscape()

    // Persist as a fallback when leaving without Turbo lifecycle
    this.persistScrollState()
  }

  handleResize() {
    const wasMobile = this.isMobile
    this.isMobile = window.innerWidth < 768

    this.syncFloatingTopNavClearance()

    if (wasMobile === this.isMobile) return

    if (this.isMobile) {
      if (this.hasSidebarTarget) this.applySidebarPresentationMode()
      this.closeMobile()
      this.parkAsideOffCanvas()
      return
    }

    this.releaseMobileDrawers()
    if (this.hasSidebarTarget) {
      this.applySidebarPresentationMode()
      this.sidebarTarget.style.pointerEvents = ""
      this.applyDesktopState({ immediate: true })
      this.rememberOpenWidth()
    }
    if (this.hasAsideTarget) {
      this.asideOpen = this.asideTarget.dataset.flatPackAsideOpen !== "false"
      this.applyAsideOpen({ persist: false })
    }
  }

  toggleDesktop() {
    if (this.isMobile) return

    this.collapsed = !this.collapsed
    this.applyDesktopState()
    this.saveDesktopState()
  }

  toggleMobile() {
    if (!this.isMobile || !this.hasSidebarTarget) return

    if (this.openDrawers.includes(this.sidebarTarget)) this.closeDrawer(this.sidebarTarget)
    else this.openDrawer(this.sidebarTarget)
  }

  openMobile() {
    if (!this.hasSidebarTarget) return
    this.openDrawer(this.sidebarTarget)
  }

  closeMobile() {
    if (!this.openDrawers) this.openDrawers = []
    if (this.openDrawers.length === 0) {
      if (this.hasSidebarTarget) this.slideOut(this.sidebarTarget, { restoreFocus: false })
      this.mobileOpen = false
      this.syncBackdrop()
      this.unbindEscape()
      return
    }

    ;[...this.openDrawers].forEach((panel) => this.closeDrawer(panel))
  }

  handleEscape(event) {
    if (event.key !== "Escape" || !this.openDrawers || this.openDrawers.length === 0) return
    this.closeDrawer(this.openDrawers[this.openDrawers.length - 1])
  }

  toggleAside(event) {
    if (event && typeof event.preventDefault === "function") event.preventDefault()
    if (!this.hasAsideTarget) return

    if (this.isMobile) {
      if (this.openDrawers.includes(this.asideTarget)) this.closeDrawer(this.asideTarget)
      else this.openDrawer(this.asideTarget)
      return
    }

    this.asideOpen = !this.asideOpen
    this.applyAsideOpen({ persist: true })
  }

  closeAside(event) {
    if (event && typeof event.preventDefault === "function") event.preventDefault()
    if (!this.hasAsideTarget) return

    if (this.isMobile) {
      this.closeDrawer(this.asideTarget)
      return
    }

    if (!this.asideOpen) return
    this.asideOpen = false
    this.applyAsideOpen({ persist: true })
  }

  openAside(event) {
    if (event && typeof event.preventDefault === "function") event.preventDefault()
    if (!this.hasAsideTarget) return

    if (this.isMobile) {
      this.openDrawer(this.asideTarget)
      return
    }

    if (this.asideOpen) return
    this.asideOpen = true
    this.applyAsideOpen({ persist: true })
  }

  openDrawer(panel) {
    if (!this.openDrawers) this.openDrawers = []
    if (!this.drawerOpeners) this.drawerOpeners = new Map()
    if (!panel || this.openDrawers.includes(panel)) return

    const opener = document.activeElement
    const others = this.openDrawers.filter((item) => item !== panel)
    this.openDrawers = [panel]
    others.forEach((other) => {
      this.slideOut(other, { restoreFocus: false })
      this.drawerOpeners.delete(other)
    })
    this.syncBodyLock()
    this.slideIn(panel)
    this.syncBackdrop()
    if (opener) this.drawerOpeners.set(panel, opener)
    this.focusPanel(panel)
    this.bindEscape()
    if (this.hasSidebarTarget && panel === this.sidebarTarget) this.mobileOpen = true
    this.syncAsideToggleAria()
  }

  closeDrawer(panel) {
    if (!this.openDrawers) this.openDrawers = []
    if (!this.drawerOpeners) this.drawerOpeners = new Map()
    if (!this.openDrawers.includes(panel)) return

    this.openDrawers = this.openDrawers.filter((item) => item !== panel)
    this.slideOut(panel, { restoreFocus: true })
    this.syncBackdrop()
    this.syncBodyLock()
    if (this.openDrawers.length === 0) this.unbindEscape()
    if (this.hasSidebarTarget && panel === this.sidebarTarget) this.mobileOpen = false
    this.syncAsideToggleAria()
  }

  slideIn(panel) {
    panel.style.pointerEvents = "auto"
    if (this.isAsidePanel(panel)) panel.removeAttribute("inert")

    const side = this.drawerSide(panel)
    if (side === "right") panel.classList.add("translate-x-full")
    else panel.classList.add("-translate-x-full")

    requestAnimationFrame(() => {
      requestAnimationFrame(() => {
        if (!this.openDrawers.includes(panel) || !this.isMobile) return
        if (side === "right") panel.classList.remove("translate-x-full")
        else panel.classList.remove("-translate-x-full")
      })
    })
  }

  slideOut(panel, { restoreFocus = false } = {}) {
    if (!panel) return
    panel.style.pointerEvents = "none"
    if (this.isAsidePanel(panel)) panel.setAttribute("inert", "")

    const side = this.drawerSide(panel)
    if (side === "right") panel.classList.add("translate-x-full")
    else panel.classList.add("-translate-x-full")

    if (!restoreFocus) return
    const opener = this.drawerOpeners.get(panel)
    this.drawerOpeners.delete(panel)
    if (opener && opener !== panel && typeof opener.focus === "function") opener.focus()
  }

  drawerSide(panel) {
    if (panel?.dataset?.mobileDrawerSide) return panel.dataset.mobileDrawerSide
    if (this.hasSidebarTarget && panel === this.sidebarTarget && this.hasSideValue) return this.sideValue
    return "left"
  }

  isAsidePanel(panel) {
    return this.hasAsideTarget && panel === this.asideTarget
  }

  focusPanel(panel) {
    if (!panel) return
    if (typeof panel.hasAttribute === "function" && !panel.hasAttribute("tabindex") && typeof panel.setAttribute === "function") {
      panel.setAttribute("tabindex", "-1")
    }
    if (typeof panel.focus === "function") panel.focus({ preventScroll: true })
  }

  syncBackdrop() {
    if (!this.hasBackdropTarget) return
    const open = this.openDrawers.length > 0
    this.backdropTarget.classList.toggle("pointer-events-none", !open)
    this.backdropTarget.classList.toggle("opacity-0", !open)
    this.backdropTarget.classList.toggle("opacity-100", open)
    this.backdropTarget.setAttribute("aria-hidden", open ? "false" : "true")
  }

  syncBodyLock() {
    const body = document.body
    if (!body) return
    if (!this.openDrawers) this.openDrawers = []

    const want = this.openDrawers.length > 0
    if (want && !this.holdingLock) {
      const count = Number(body.dataset[BODY_LOCK] || "0")
      if (count === 0) {
        this.savedOverflow = body.style.overflow
        body.style.overflow = "hidden"
      }
      body.dataset[BODY_LOCK] = String(count + 1)
      this.holdingLock = true
      return
    }

    if (!want && this.holdingLock) {
      const count = Number(body.dataset[BODY_LOCK] || "0")
      if (count > 1) {
        body.dataset[BODY_LOCK] = String(count - 1)
      } else {
        delete body.dataset[BODY_LOCK]
        body.style.overflow = this.savedOverflow || ""
      }
      this.holdingLock = false
    }
  }

  bindEscape() {
    if (this.escapeBound) return
    this.handleEscape = this.handleEscape.bind(this)
    document.addEventListener("keydown", this.handleEscape)
    this.escapeBound = true
  }

  unbindEscape() {
    if (!this.escapeBound) return
    document.removeEventListener("keydown", this.handleEscape)
    this.escapeBound = false
  }

  releaseMobileDrawers() {
    this.openDrawers = []
    this.mobileOpen = false
    this.syncBackdrop()
    this.syncBodyLock()
    this.unbindEscape()
  }

  parkAsideOffCanvas() {
    if (!this.hasAsideTarget) return
    this.asideTarget.setAttribute("inert", "")
    this.asideTarget.style.pointerEvents = "none"
    const side = this.drawerSide(this.asideTarget)
    if (side === "right") this.asideTarget.classList.add("translate-x-full")
    else this.asideTarget.classList.add("-translate-x-full")
  }

  readAsideOpen() {
    if (!this.isMobile && this.hasAsideStorageKeyValue) {
      try {
        const saved = localStorage.getItem(this.asideStorageKeyValue)
        if (saved !== null) return saved === "true"
      } catch {
        // Ignore storage errors (private mode / disabled storage)
      }
    }

    return this.hasAsideOpenValue ? this.asideOpenValue : true
  }

  applyAsideOpen({ persist = false } = {}) {
    if (!this.hasAsideTarget) return

    const open = !!this.asideOpen
    this.asideTarget.dataset.flatPackAsideOpen = open ? "true" : "false"
    if (!this.isMobile) {
      if (open) this.asideTarget.removeAttribute("inert")
      else this.asideTarget.setAttribute("inert", "")
      this.asideTarget.style.pointerEvents = ""
    }
    this.syncAsideToggleAria()
    if (!persist || this.isMobile || !this.hasAsideStorageKeyValue) return

    try {
      localStorage.setItem(this.asideStorageKeyValue, open ? "true" : "false")
    } catch {
      // Ignore storage errors (private mode / disabled storage)
    }
  }

  syncAsideToggleAria() {
    if (!this.hasAsideToggleTarget) return
    const expanded = this.isMobile
      ? this.hasAsideTarget && this.openDrawers.includes(this.asideTarget)
      : !!this.asideOpen
    this.asideToggleTargets.forEach((node) => {
      node.setAttribute("aria-expanded", expanded ? "true" : "false")
    })
  }

  collapseRailFromResize() {
    if (this.isMobile || this.collapsed || !this.hasSidebarTarget) return
    this.collapsed = true
    this.applyDesktopState()
    this.saveDesktopState()
  }

  applyDesktopState() {
    if (this.isMobile) return

    this.paintFallbackWidth(this.sidebarTarget)
    this.sidebarTarget.dataset.flatPackSidebarCollapsed = this.collapsed ? "true" : "false"
    this.dispatch("collapse", { detail: { collapsed: this.collapsed }, target: this.sidebarTarget })
  }

  usesContentWidth() {
    return this.hasSidebarTarget && this.sidebarTarget.dataset.flatPackSidebarWidth === "content"
  }

  paintFallbackWidth(element) {
    if (!element) return

    const collapsedWidth = "var(--sidebar-collapsed-width, 4rem)"
    if (!this.usesContentWidth()) {
      element.style.width = this.collapsed ? collapsedWidth : "var(--sidebar-width, 16rem)"
      element.style.minWidth = ""
      element.style.maxWidth = ""
      return
    }

    if (this.collapsed) {
      element.style.width = collapsedWidth
      element.style.minWidth = collapsedWidth
      element.style.maxWidth = collapsedWidth
      return
    }

    element.style.width = "var(--sidebar-measured-width, max-content)"
    element.style.minWidth = "var(--sidebar-measured-width, var(--sidebar-content-min-width, 12rem))"
    element.style.maxWidth = "var(--sidebar-measured-width, var(--sidebar-content-max-width, 20rem))"
  }

  bindOpenWidthMemory() {
    if (!this.hasSidebarTarget || this.handleWidthTransitionEnd) return

    this.handleWidthTransitionEnd = (event) => {
      if (event.propertyName !== "width") return
      if (event.target !== this.sidebarTarget) return
      this.rememberOpenWidth()
    }
    this.sidebarTarget.addEventListener("transitionend", this.handleWidthTransitionEnd)
  }

  unbindOpenWidthMemory() {
    if (!this.handleWidthTransitionEnd || !this.hasSidebarTarget) return

    this.sidebarTarget.removeEventListener("transitionend", this.handleWidthTransitionEnd)
    this.handleWidthTransitionEnd = null
  }

  remeasureOpenWidthWhenFontsReady() {
    if (!document.fonts?.ready) return

    document.fonts.ready.then(() => {
      if (!this.hasSidebarTarget || !this.sidebarTarget.isConnected) return
      if (this.isMobile || !this.usesContentWidth()) return
      if (this.collapsed) {
        this.sidebarTarget.style.removeProperty("--sidebar-measured-width")
        return
      }

      this.rememberOpenWidth()
    })
  }

  rememberOpenWidth() {
    if (this.isMobile || this.collapsed || !this.usesContentWidth()) return

    const rail = this.sidebarTarget

    // The width transition is !important. Reading mid-transition stores the
    // old 16rem length and the next paint never reaches max-content.
    rail.style.setProperty("transition-property", "none", "important")
    rail.style.removeProperty("--sidebar-measured-width")

    const width = rail.getBoundingClientRect().width
    if (width > 0) {
      rail.style.setProperty("--sidebar-measured-width", `${Math.round(width)}px`)
    }

    rail.style.removeProperty("transition-property")
  }

  navItemNodes() {
    return this.sidebarTarget.querySelectorAll('a[data-flat-pack-sidebar-item="true"]')
  }

  applySidebarPresentationMode() {
    this.sidebarTarget.style.transitionDuration = this.transitionDuration
    this.sidebarTarget.style.transitionTimingFunction = this.transitionEasing

    if (this.isMobile) {
      this.sidebarTarget.style.zIndex = "50"
      this.sidebarTarget.style.transitionProperty = "transform"
      return
    }

    this.sidebarTarget.style.zIndex = "auto"
    this.sidebarTarget.style.transitionProperty = "width, transform"
  }

  saveDesktopState() {
    if (this.hasStorageKeyValue) {
      localStorage.setItem(this.storageKeyValue, this.collapsed.toString())
    }
  }

  loadDesktopState() {
    if (!this.hasStorageKeyValue) return

    const saved = localStorage.getItem(this.storageKeyValue)
    if (saved !== null) {
      this.collapsed = saved === "true"
      return
    }

    if (this.hasOpenValue) this.collapsed = !this.openValue
  }

  handleTurboBeforeCache() {
    this.persistScrollState()
  }

  handleTurboLoad() {
    const scrollContainer = this.currentScrollContainer()
    if (scrollContainer?.dataset?.flatPackScrollPreRestored === "true") {
      delete scrollContainer.dataset.flatPackScrollPreRestored
    }

    this.scheduleScrollRestore()
  }

  scheduleScrollRestore() {
    const restore = () => {
      this.restoreScrollPosition({correctWithAnchor: true})
      this.scrollActiveItemIntoView()
    }

    if (typeof requestAnimationFrame !== "function") {
      restore()
      return
    }

    requestAnimationFrame(() => {
      requestAnimationFrame(restore)
    })
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
    if (!this.hasSidebarTarget) return
    const link = event.target.closest("a[href]")
    if (!link || !this.sidebarTarget.contains(link)) return

    if (this.isPrimarySidebarNavClick(event, link)) {
      this.markItemCurrent(link)
    }

    const scrollContainer = this.currentScrollContainer()
    if (!scrollContainer) return

    this.lastAnchorPath = this.normalizePath(link.href)
    this.lastAnchorOffset = link.getBoundingClientRect().top - scrollContainer.getBoundingClientRect().top
    this.persistScrollState()
  }

  isPrimarySidebarNavClick(event, link) {
    if (event.defaultPrevented) return false
    if (event.button && event.button !== 0) return false
    if (event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return false
    if (link.target && link.target !== "_self") return false

    return link.matches('a[data-flat-pack-sidebar-item="true"]')
  }

  markItemCurrent(link) {
    this.navItemNodes().forEach((item) => {
      if (item === link) {
        this.applyItemCurrent(item)
      } else {
        this.clearItemCurrent(item)
      }
    })
  }

  applyItemCurrent(item) {
    item.classList.remove(...this.inactiveItemClasses())
    item.classList.add(...this.activeItemClasses())
    item.setAttribute("aria-current", "page")

    const iconEl = item.querySelector('[data-flat-pack-sidebar-item-icon="true"]')
    if (!iconEl) return

    iconEl.classList.remove(this.inactiveIconClass())
    iconEl.classList.add(this.activeIconClass())
  }

  clearItemCurrent(item) {
    item.classList.remove(...this.activeItemClasses())
    item.classList.add(...this.inactiveItemClasses())
    item.removeAttribute("aria-current")

    const iconEl = item.querySelector('[data-flat-pack-sidebar-item-icon="true"]')
    if (!iconEl) return

    iconEl.classList.remove(this.activeIconClass())
    iconEl.classList.add(this.inactiveIconClass())
  }

  activeItemClasses() {
    return [
      "bg-[var(--sidebar-item-active-background-color)]",
      "text-[var(--sidebar-item-active-text-color)]"
    ]
  }

  inactiveItemClasses() {
    return [
      "text-[var(--sidebar-item-text-color)]",
      "hover:bg-[var(--sidebar-item-hover-background-color)]",
      "hover:text-[var(--sidebar-item-hover-text-color)]"
    ]
  }

  activeIconClass() {
    return "text-[var(--sidebar-item-active-icon-color)]"
  }

  inactiveIconClass() {
    return "text-[var(--sidebar-item-icon-color)]"
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
    return body.querySelector('[data-flat-pack--sidebar-layout-target="scrollContainer"]')
  }

  currentScrollContainer() {
    if (this.hasScrollContainerTarget) return this.scrollContainerTarget

    return this.element.querySelector('[data-flat-pack--sidebar-layout-target="scrollContainer"]')
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
      const containerRect = scrollContainer.getBoundingClientRect()
      const itemRect = activeItem.getBoundingClientRect()

      if (itemRect.top >= containerRect.top && itemRect.bottom <= containerRect.bottom) return

      if (itemRect.top < containerRect.top) {
        scrollContainer.scrollTop += itemRect.top - containerRect.top
      } else if (itemRect.bottom > containerRect.bottom) {
        scrollContainer.scrollTop += itemRect.bottom - containerRect.bottom
      }

      this.persistScrollState()
    })
  }

  bindFloatingTopNavClearance() {
    this.syncFloatingTopNavClearance()
    const nav = this.floatingTopNavElement()
    if (!nav || typeof ResizeObserver === "undefined") return

    this.topNavResizeObserver = new ResizeObserver(() => this.syncFloatingTopNavClearance())
    this.topNavResizeObserver.observe(nav)
  }

  unbindFloatingTopNavClearance() {
    if (!this.topNavResizeObserver) return

    this.topNavResizeObserver.disconnect()
    this.topNavResizeObserver = null
  }

  floatingTopNavElement() {
    return this.element.querySelector('[data-flat-pack-top-nav-floating="behind"]')
  }

  // One toolbar is a few pixels off the token. A wrapped row is not.
  // Raise the token only when the cards actually need more room.
  syncFloatingTopNavClearance() {
    const nav = this.floatingTopNavElement()
    const column = nav && nav.parentElement
    if (!column) return

    const floor = this.floatingTopNavClearanceFloor(column)
    const band = this.pageScrolls()
      ? (parseFloat(getComputedStyle(nav).top) || 0) + nav.offsetHeight
      : nav.offsetTop + nav.offsetHeight
    this.applyFloatingTopNavClearance(column, band, floor)
  }

  pageScrolls() {
    return this.element?.dataset?.flatPackLayoutScroll === "page"
  }

  clearanceElement(column) {
    return this.pageScrolls() ? document.documentElement : column
  }

  floatingTopNavClearanceFloor(column) {
    if (Number.isFinite(this.topNavClearanceFloor)) return this.topNavClearanceFloor

    const scroll = column.querySelector(".fp-layout-scroll")
    const host = this.clearanceElement(column)
    const inline = host.style.getPropertyValue("--top-nav-float-clearance")
    if (inline) host.style.removeProperty("--top-nav-float-clearance")
    // Custom properties keep their calc() text. The used padding is pixels.
    const parsed = scroll ? parseFloat(getComputedStyle(scroll).paddingTop) : NaN
    if (inline) host.style.setProperty("--top-nav-float-clearance", inline)

    this.topNavClearanceFloor = Number.isFinite(parsed) ? parsed : 0
    return this.topNavClearanceFloor
  }

  applyFloatingTopNavClearance(column, band, floor) {
    const host = this.clearanceElement(column)
    if (band > floor + 8) {
      host.style.setProperty("--top-nav-float-clearance", `${Math.ceil(band)}px`)
    } else {
      host.style.removeProperty("--top-nav-float-clearance")
    }
  }
}
