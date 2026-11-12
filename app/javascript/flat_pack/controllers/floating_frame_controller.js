// Mounts the framed page on the first open and moves focus with the panel.
// Popover still positions the panel, toggles aria-expanded, and handles Escape
// while focus is in the parent page. This controller listens inside a
// same-origin iframe, traps Tab on a narrow viewport, and returns focus only
// when the close control asks.
import { Controller } from "@hotwired/stimulus"

// Matches the panel rule in application.css: @media (max-width: 639px).
const SMALL_SCREEN = "(max-width: 639px)"
const TAB_SELECTOR = "a[href], button, input, select, textarea, iframe, [tabindex]:not([tabindex='-1'])"

export default class extends Controller {
  connect() {
    this.placeOnBody()
    if (this.observer) return

    this.trigger = this.element.querySelector("[data-flat-pack--floating-frame-target='trigger']")
    this.open = this.trigger?.getAttribute("aria-expanded") === "true"
    this.returnFocus = false
    this.onExpanded = this.onExpanded.bind(this)
    this.onTab = this.onTab.bind(this)
    this.onFrameKey = this.onFrameKey.bind(this)
    this.onViewport = this.onViewport.bind(this)
    this.attachFrameKey = this.attachFrameKey.bind(this)
    this.observer = new MutationObserver(this.onExpanded)

    if (!this.trigger) return

    this.observer.observe(this.trigger, {
      attributes: true,
      attributeFilter: ["aria-expanded"]
    })
    this.watchViewport()
    this.syncModal()
  }

  disconnect() {
    this.observer?.disconnect()
    this.observer = null
    this.releaseFrameKey()
    this.releaseTrap()
    this.unwatchViewport()
  }

  // Page shells often clip with overflow. Fixed positioning inside that box
  // cannot paint over a sidebar, so the whole frame moves to the body.
  // The move makes Stimulus disconnect and connect again. Connect bails out
  // once the observer exists, and a later disconnect does not move the node back.
  placeOnBody() {
    if (typeof document === "undefined" || !document.body) return
    if (this.element.parentElement === document.body) return

    document.body.append(this.element)
  }

  // The close button runs this before Popover closes. Escape in the parent
  // page is Popover's own path, which already focuses the launcher. A click
  // outside closes with this flag still false, so focus stays where it is.
  prepareRestore() {
    this.returnFocus = true
  }

  onExpanded() {
    const open = this.trigger.getAttribute("aria-expanded") === "true"
    if (open === this.open) return

    this.open = open
    if (open) {
      this.mountFrame()
      this.bindFrameKey()
      this.focusPanel()
    } else if (this.returnFocus) {
      this.returnFocus = false
      this.focusTrigger()
    }
    this.syncModal()
  }

  mountFrame() {
    const template = this.element.querySelector("[data-flat-pack--floating-frame-target='source']")
    const mount = this.element.querySelector("[data-flat-pack--floating-frame-target='mount']")
    if (!template || !mount || mount.childElementCount > 0) return

    mount.append(template.content)
  }

  focusPanel() {
    const close = this.element.querySelector("[data-flat-pack--floating-frame-target='close']")
    this.afterFrame(() => close?.focus())
  }

  focusTrigger() {
    this.trigger?.focus()
  }

  afterFrame(callback) {
    if (typeof requestAnimationFrame === "function") {
      requestAnimationFrame(callback)
    } else {
      callback()
    }
  }

  syncModal() {
    const panel = this.panel()
    if (!panel || typeof panel.setAttribute !== "function") return

    const modal = this.open && this.smallScreen()
    if (modal) {
      panel.setAttribute("aria-modal", "true")
      this.ensureTrap()
      return
    }

    if (typeof panel.removeAttribute === "function") panel.removeAttribute("aria-modal")
    this.releaseTrap()
  }

  smallScreen() {
    if (typeof window === "undefined" || typeof window.matchMedia !== "function") return false

    return window.matchMedia(SMALL_SCREEN).matches
  }

  watchViewport() {
    if (this.watchingViewport || typeof window === "undefined" || typeof window.matchMedia !== "function") return

    this.viewportQuery = window.matchMedia(SMALL_SCREEN)
    if (typeof this.viewportQuery.addEventListener !== "function") return

    this.watchingViewport = true
    this.viewportQuery.addEventListener("change", this.onViewport)
  }

  unwatchViewport() {
    if (!this.watchingViewport) return

    this.viewportQuery?.removeEventListener("change", this.onViewport)
    this.viewportQuery = null
    this.watchingViewport = false
  }

  onViewport() {
    this.syncModal()
  }

  ensureTrap() {
    if (this.trapping || typeof document === "undefined") return

    this.trapping = true
    document.addEventListener("keydown", this.onTab, true)
  }

  releaseTrap() {
    if (!this.trapping || typeof document === "undefined") return

    this.trapping = false
    document.removeEventListener("keydown", this.onTab, true)
  }

  onTab(event) {
    if (event.key !== "Tab" || !this.open || !this.smallScreen()) return

    const panel = this.panel()
    if (!panel) return

    const stops = this.tabStops(panel)
    if (stops.length === 0) {
      event.preventDefault()
      if (typeof panel.focus === "function") panel.focus()
      return
    }

    const active = this.deepActive()
    const index = stops.indexOf(active)
    if (!this.focusInside(panel, active)) {
      event.preventDefault()
      const edge = event.shiftKey ? stops[stops.length - 1] : stops[0]
      edge.focus()
      return
    }

    if (index === -1) return

    if (event.shiftKey) {
      if (index !== 0) return
      event.preventDefault()
      stops[stops.length - 1].focus()
      return
    }

    if (index !== stops.length - 1) return

    event.preventDefault()
    stops[0].focus()
  }

  tabStops(panel) {
    const stops = []
    this.collectStops(panel, stops, true)
    return stops
  }

  collectStops(root, stops, descend) {
    if (!root || typeof root.querySelectorAll !== "function") return

    root.querySelectorAll(TAB_SELECTOR).forEach((element) => {
      if (!this.canTab(element)) return
      if (descend && String(element.tagName).toUpperCase() === "IFRAME") {
        const inner = this.frameStops(element)
        if (inner.length > 0) {
          stops.push(...inner)
          return
        }
      }
      stops.push(element)
    })
  }

  frameStops(frame) {
    try {
      const body = frame.contentDocument?.body
      if (!body) return []

      const stops = []
      this.collectStops(body, stops, false)
      return stops
    } catch (_error) {
      return []
    }
  }

  canTab(element) {
    if (!element || element.disabled) return false
    if (element.getAttribute("aria-hidden") === "true") return false
    if (typeof element.tabIndex === "number" && element.tabIndex < 0) return false
    if (typeof element.matches === "function" && element.matches("input[type='hidden']")) return false

    return true
  }

  focusInside(panel, active) {
    if (!active) return false
    if (typeof panel.contains === "function" && panel.contains(active)) return true

    const frame = this.frameElement()
    if (!frame || (typeof panel.contains === "function" && !panel.contains(frame))) return false

    try {
      return Boolean(frame.contentDocument?.body?.contains(active))
    } catch (_error) {
      return active === frame
    }
  }

  deepActive() {
    const active = typeof document === "undefined" ? null : document.activeElement
    if (!active || String(active.tagName).toUpperCase() !== "IFRAME") return active

    try {
      const inner = active.contentDocument?.activeElement
      const body = active.contentDocument?.body
      if (inner && inner !== body && inner !== active.contentDocument.documentElement) return inner
    } catch (_error) {
      return active
    }

    return active
  }

  // Key events inside an iframe do not reach the parent document. Same-origin
  // frames expose contentWindow. Cross-origin access throws, and Escape stays
  // inside that page.
  bindFrameKey() {
    const frame = this.frameElement()
    if (!frame || this.boundFrame === frame) return

    this.boundFrame = frame
    if (typeof frame.addEventListener === "function") {
      frame.addEventListener("load", this.attachFrameKey)
    }
    this.attachFrameKey()
  }

  attachFrameKey() {
    const frame = this.boundFrame
    if (!frame) return

    this.releaseFrameWindow()
    let win
    try {
      win = frame.contentWindow
    } catch (_error) {
      return
    }
    if (!win || typeof win.addEventListener !== "function") return

    win.addEventListener("keydown", this.onFrameKey, true)
    win.addEventListener("keydown", this.onTab, true)
    this.boundWindow = win
  }

  onFrameKey(event) {
    if (event.key !== "Escape" || !this.open) return

    event.preventDefault()
    event.stopPropagation()
    this.element.querySelector("[data-flat-pack--floating-frame-target='close']")?.click()
  }

  releaseFrameKey() {
    const frame = this.boundFrame
    if (frame && typeof frame.removeEventListener === "function") {
      frame.removeEventListener("load", this.attachFrameKey)
    }
    this.releaseFrameWindow()
    this.boundFrame = null
  }

  releaseFrameWindow() {
    const win = this.boundWindow
    this.boundWindow = null
    if (!win || typeof win.removeEventListener !== "function") return

    try {
      win.removeEventListener("keydown", this.onFrameKey, true)
      win.removeEventListener("keydown", this.onTab, true)
    } catch (_error) {
      // The frame navigated cross-origin. The window is already gone.
    }
  }

  panel() {
    return this.element.querySelector("[data-flat-pack--floating-frame-target='panel']")
  }

  frameElement() {
    const mount = this.element.querySelector("[data-flat-pack--floating-frame-target='mount']")
    if (!mount) return null

    const walk = (node) => {
      if (String(node.nodeName).toUpperCase() === "IFRAME") return node

      for (const child of node.children || []) {
        const found = walk(child)
        if (found) return found
      }
      return null
    }

    return walk(mount)
  }
}
