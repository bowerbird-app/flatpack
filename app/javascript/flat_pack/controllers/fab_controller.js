// FlatPack FAB Stimulus Controller
// Speed-dial open/close, keyboard, backdrop, and optional hide-on-scroll.
// Layout is a value so :arc can land later without rewriting the open/close loop.
import { Controller } from "@hotwired/stimulus"
import { prefersReducedMotion, motionDuration, motionTransition } from "controllers/flat_pack/reduced_motion"

const STAGGER_MS = 30
const SCROLL_DELTA = 8

export default class extends Controller {
  static targets = ["trigger", "menu", "action", "backdrop"]
  static values = {
    layout: { type: String, default: "stack" },
    hideOnScroll: { type: Boolean, default: false }
  }

  connect() {
    this.openState = false
    this.hideTimeout = null
    this.lastScrollY = window.scrollY
    this.hiddenOnScroll = false

    this.handleDocumentPointer = this.handleDocumentPointer.bind(this)
    this.handleMenuKeydown = this.handleMenuKeydown.bind(this)

    this.syncBottomNavOffset()
    if (this.hasMenuTarget) this.collapseActions(true)
  }

  disconnect() {
    this.clearHideTimeout()
    document.removeEventListener("pointerdown", this.handleDocumentPointer, true)
    if (this.hasMenuTarget) this.menuTarget.removeEventListener("keydown", this.handleMenuKeydown)
  }

  toggle(event) {
    event?.preventDefault()
    if (this.openState) {
      this.close()
    } else {
      this.open()
    }
  }

  open() {
    if (!this.hasMenuTarget || this.openState) return

    this.clearHideTimeout()
    this.openState = true
    this.showFromScroll()
    this.element.dataset.fpOpen = "true"
    this.triggerTarget.setAttribute("aria-expanded", "true")
    this.menuTarget.hidden = false
    this.menuTarget.removeAttribute("inert")

    this.revealActions()
    this.showBackdrop()

    document.addEventListener("pointerdown", this.handleDocumentPointer, true)
    this.menuTarget.addEventListener("keydown", this.handleMenuKeydown)

    const focusDelay = prefersReducedMotion() ? 0 : motionDuration("fast")
    this.hideTimeout = window.setTimeout(() => {
      this.hideTimeout = null
      this.focusAction(0)
    }, focusDelay)
  }

  close(eventOrOptions = {}) {
    const restoreFocus = eventOrOptions?.restoreFocus !== false
    if (!this.hasMenuTarget || !this.openState) return

    this.clearHideTimeout()
    this.openState = false
    this.element.dataset.fpOpen = "false"
    this.triggerTarget.setAttribute("aria-expanded", "false")
    this.menuTarget.setAttribute("inert", "")

    this.concealActions()
    this.hideBackdrop()

    document.removeEventListener("pointerdown", this.handleDocumentPointer, true)
    this.menuTarget.removeEventListener("keydown", this.handleMenuKeydown)

    const closeDelay = this.closeDuration()
    this.hideTimeout = window.setTimeout(() => {
      this.hideTimeout = null
      if (!this.openState) {
        this.menuTarget.hidden = true
        this.collapseActions(true)
      }
      if (restoreFocus) this.triggerTarget.focus()
    }, closeDelay)
  }

  escape(event) {
    if (!this.openState) return

    event.preventDefault()
    this.close()
  }

  choose() {
    if (!this.openState) return

    this.close({ restoreFocus: false })
  }

  onScroll() {
    if (!this.hideOnScrollValue || this.openState) return

    const y = window.scrollY
    const delta = y - this.lastScrollY
    this.lastScrollY = y

    if (y <= 0) {
      this.showFromScroll()
      return
    }

    if (delta > SCROLL_DELTA) {
      this.hideFromScroll()
    } else if (delta < -SCROLL_DELTA) {
      this.showFromScroll()
    }
  }

  onResize() {
    this.syncBottomNavOffset()
  }

  handleDocumentPointer(event) {
    if (!this.openState) return
    if (this.element.contains(event.target)) return

    this.close()
  }

  handleMenuKeydown(event) {
    if (!this.openState) return

    switch (event.key) {
      case "ArrowDown":
      case "ArrowRight":
        event.preventDefault()
        this.moveAction(1)
        break
      case "ArrowUp":
      case "ArrowLeft":
        event.preventDefault()
        this.moveAction(-1)
        break
      case "Home":
        event.preventDefault()
        this.focusAction(0)
        break
      case "End":
        event.preventDefault()
        this.focusAction(this.actionTargets.length - 1)
        break
      case "Tab":
        this.handleTab(event)
        break
      default:
        break
    }
  }

  handleTab(event) {
    const items = this.actionTargets
    if (items.length === 0) return

    const first = items[0]
    const last = items[items.length - 1]

    if (event.shiftKey && document.activeElement === first) {
      event.preventDefault()
      this.triggerTarget.focus()
      return
    }

    if (!event.shiftKey && document.activeElement === last) {
      this.close({ restoreFocus: false })
    }
  }

  revealActions() {
    this.applyLayoutOpen()
  }

  concealActions() {
    this.applyLayoutClose()
  }

  applyLayoutOpen() {
    switch (this.layoutValue) {
      case "stack":
      default:
        this.openStack()
    }
  }

  applyLayoutClose() {
    switch (this.layoutValue) {
      case "stack":
      default:
        this.closeStack()
    }
  }

  openStack() {
    const reduced = prefersReducedMotion()
    const transition = motionTransition(["opacity", "transform"], { duration: "base", easing: "enter" })

    this.actionTargets.forEach((action, index) => {
      action.tabIndex = 0
      action.style.transition = transition
      action.style.transitionDelay = reduced ? "0ms" : `${index * STAGGER_MS}ms`
      action.style.opacity = "1"
      action.style.transform = "none"
    })
  }

  closeStack() {
    const reduced = prefersReducedMotion()
    const transition = motionTransition(["opacity", "transform"], { duration: "fast", easing: "exit" })
    const last = this.actionTargets.length - 1

    this.actionTargets.forEach((action, index) => {
      action.tabIndex = -1
      action.style.transition = transition
      action.style.transitionDelay = reduced ? "0ms" : `${(last - index) * STAGGER_MS}ms`
      action.style.opacity = "0"
      action.style.transform = this.hiddenActionTransform()
    })
  }

  collapseActions(instant) {
    this.actionTargets.forEach((action) => {
      action.tabIndex = -1
      if (instant) {
        action.style.transition = "none"
        action.style.transitionDelay = "0ms"
      }
      action.style.opacity = "0"
      action.style.transform = this.hiddenActionTransform()
    })
  }

  hiddenActionTransform() {
    if (prefersReducedMotion()) return "none"

    const fromTop = (this.element.dataset.fpPosition || "").startsWith("top")
    return fromTop ? "translateY(-12px) scale(0.8)" : "translateY(12px) scale(0.8)"
  }

  showBackdrop() {
    if (!this.hasBackdropTarget) return

    this.backdropTarget.style.transition = motionTransition("opacity", { duration: "base", easing: "enter" })
    this.backdropTarget.dataset.fpVisible = "true"
    this.backdropTarget.style.opacity = "1"
    this.backdropTarget.style.pointerEvents = "auto"
  }

  hideBackdrop() {
    if (!this.hasBackdropTarget) return

    this.backdropTarget.style.transition = motionTransition("opacity", { duration: "fast", easing: "exit" })
    this.backdropTarget.dataset.fpVisible = "false"
    this.backdropTarget.style.opacity = "0"
    this.backdropTarget.style.pointerEvents = "none"
  }

  hideFromScroll() {
    if (this.hiddenOnScroll) return

    this.hiddenOnScroll = true
    this.element.dataset.fpScrollHidden = "true"
  }

  showFromScroll() {
    if (!this.hiddenOnScroll) return

    this.hiddenOnScroll = false
    delete this.element.dataset.fpScrollHidden
  }

  syncBottomNavOffset() {
    const position = this.element.dataset.fpPosition || ""
    if (!position.startsWith("bottom")) {
      this.element.style.removeProperty("--fp-fab-nav-offset")
      return
    }

    const scope = this.element.classList.contains("fp-fab--contained")
      ? (this.element.offsetParent || this.element.parentElement || document)
      : document
    const nav = scope.querySelector(".fp-bottom-nav")
    const height = nav ? Math.ceil(nav.getBoundingClientRect().height) : 0
    this.element.style.setProperty("--fp-fab-nav-offset", `${height}px`)
  }

  focusAction(index) {
    const items = this.actionTargets
    if (items.length === 0) return

    const next = items[Math.max(0, Math.min(index, items.length - 1))]
    next?.focus()
  }

  moveAction(step) {
    const items = this.actionTargets
    if (items.length === 0) return

    const current = items.indexOf(document.activeElement)
    const start = current === -1 ? 0 : current
    const next = (start + step + items.length) % items.length
    this.focusAction(next)
  }

  closeDuration() {
    if (prefersReducedMotion()) return 0

    const count = Math.max(this.actionTargets.length, 1)
    return motionDuration("fast") + ((count - 1) * STAGGER_MS)
  }

  clearHideTimeout() {
    if (this.hideTimeout == null) return

    window.clearTimeout(this.hideTimeout)
    this.hideTimeout = null
  }
}
