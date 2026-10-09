// Overlay-agnostic multi-screen navigation. Pair with Modal now; Drawer in a later PR.
// History is in-memory only — this controller never writes the browser history stack.
import { Controller } from "@hotwired/stimulus"

const NAV_PUSH = "push"
const NAV_REPLACE = "replace"
const NAV_RESET = "reset"
const NAV_BACK = "back"
const NAV_CLOSE = "close"
const NAV_RETRY = "retry"
const VISIT_ACTIONS = new Set([NAV_PUSH, NAV_REPLACE, NAV_RESET])

export default class extends Controller {
  static targets = ["frame", "title", "backButton", "headerActions", "footer", "loading", "error", "liveRegion"]
  static values = {
    src: String
  }

  connect() {
    this.stack = []
    this.currentUrl = this.srcValue
    this.pendingAction = null
    this.restoreSelector = null
    this.clickedSelector = null
    this.wasOpen = this.isOpen()
    this.handleMutation = this.handleMutation.bind(this)

    if (typeof MutationObserver === "function") {
      this.observer = new MutationObserver(this.handleMutation)
      this.observer.observe(this.element, {attributes: true, attributeFilter: ["aria-hidden", "class"]})
    }

    this.updateBackButton()
  }

  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
      this.observer = null
    }
  }

  onClick(event) {
    const control = event.target.closest("[data-fp-nav]")
    if (!control || !this.element.contains(control)) return

    const nav = control.dataset.fpNav
    if (nav === NAV_BACK) {
      event.preventDefault()
      this.back()
      return
    }
    if (nav === NAV_CLOSE) {
      event.preventDefault()
      this.close()
      return
    }
    if (nav === NAV_RETRY) {
      event.preventDefault()
      this.retry()
      return
    }
    if (!VISIT_ACTIONS.has(nav)) return
    if (this.isForm(control)) return

    const url = control.getAttribute("href") || control.dataset.href
    if (!url) return

    event.preventDefault()
    this.clickedSelector = this.selectorFor(control)
    this.navigate(url, nav)
  }

  onSubmit(event) {
    const form = event.target
    if (!form || !form.getAttribute) return
    if (!this.element.contains(form)) return

    const nav = (event.submitter && event.submitter.dataset.fpNav) || form.dataset.fpNav
    if (!nav) return

    if (nav === NAV_BACK) {
      event.preventDefault()
      this.back()
      return
    }
    if (nav === NAV_CLOSE) {
      event.preventDefault()
      this.close()
      return
    }
    if (!VISIT_ACTIONS.has(nav)) return

    this.pendingAction = nav
    this.clickedSelector = this.selectorFor(event.submitter || form)
    if (this.hasFrameTarget) {
      form.setAttribute("data-turbo-frame", this.frameTarget.id)
    }
  }

  onBeforeFetchRequest(event) {
    if (!this.isOurRequest(event)) return

    this.showLoading()
    this.hideError()

    const url = this.urlFromEvent(event)
    if (url && this.pendingAction && this.pendingAction !== NAV_BACK) {
      this.applyHistory(url, this.pendingAction)
    }
  }

  onBeforeFetchResponse(event) {
    if (!this.isOurRequest(event)) return

    const response = event.detail && event.detail.fetchResponse && event.detail.fetchResponse.response
    if (!response || response.ok) return

    event.preventDefault()
    this.showError()
  }

  onFrameLoad(event) {
    if (!this.isOurFrame(event.target)) return

    this.hideLoading()
    this.hideError()
    this.currentUrl = (this.hasFrameTarget && this.frameTarget.getAttribute("src")) || this.currentUrl
    this.applyScreenChrome()
    this.focusAfterLoad()
    this.pendingAction = null
    this.clickedSelector = null
  }

  onFrameMissing(event) {
    if (!this.isOurFrame(event.target)) return

    event.preventDefault()
    this.showError()
  }

  onFetchError(event) {
    if (!this.isOurRequest(event)) return

    this.showError()
  }

  back() {
    if (this.stack.length === 0) return
    if (this.pendingAction === NAV_BACK) return
    if (!this.dispatch("before-visit", {url: this.peekUrl(), action: NAV_BACK})) return

    this.pendingAction = NAV_BACK
    const entry = this.stack.pop()
    this.restoreSelector = entry.focus
    this.currentUrl = entry.url
    this.updateBackButton()
    this.visit(entry.url)
  }

  close() {
    this.clearHistory()
    this.resetFrame()
    this.closeOverlay()
  }

  retry() {
    this.hideError()
    this.visit(this.currentUrl || this.srcValue)
  }

  navigate(url, action) {
    if (!VISIT_ACTIONS.has(action)) return
    if (!this.dispatch("before-visit", {url, action})) return

    this.pendingAction = action
    this.visit(url)
  }

  visit(url) {
    if (!this.hasFrameTarget) return

    this.showLoading()
    this.hideError()
    this.frameTarget.setAttribute("src", url)
    this.frameTarget.src = url
  }

  handleMutation() {
    const open = this.isOpen()
    if (open && !this.wasOpen) this.onOpened()
    if (!open && this.wasOpen) this.onClosed()
    this.wasOpen = open
  }

  onOpened() {
    if (!this.hasFrameTarget) return

    this.currentUrl = this.currentUrl || this.srcValue
    if (!this.frameTarget.getAttribute("src") && this.srcValue) {
      this.visit(this.srcValue)
      return
    }
    if (!this.frameTarget.hasAttribute("complete")) this.showLoading()
  }

  onClosed() {
    this.clearHistory()
    this.resetFrame()
  }

  applyHistory(url, action) {
    const normalized = this.normalizeUrl(url)

    if (action === NAV_RESET) {
      this.stack = []
      this.currentUrl = normalized
      this.updateBackButton()
      return
    }

    if (action === NAV_REPLACE) {
      this.currentUrl = normalized
      return
    }

    if (this.sameUrl(normalized, this.currentUrl)) return

    if (this.currentUrl) {
      this.stack.push({url: this.currentUrl, focus: this.clickedSelector})
    }
    this.currentUrl = normalized
    this.updateBackButton()
  }

  clearHistory() {
    this.stack = []
    this.currentUrl = this.srcValue
    this.pendingAction = null
    this.restoreSelector = null
    this.clickedSelector = null
    this.updateBackButton()
  }

  resetFrame() {
    if (!this.hasFrameTarget) return

    const frame = this.frameTarget
    frame.removeAttribute("complete")
    frame.removeAttribute("src")
    if (typeof frame.replaceChildren === "function") {
      frame.replaceChildren()
    } else {
      frame.innerHTML = ""
    }
    frame.setAttribute("loading", "lazy")
    if (this.srcValue) frame.setAttribute("src", this.srcValue)

    this.hideLoading()
    this.hideError()
    this.clearChrome()
  }

  applyScreenChrome() {
    if (!this.hasFrameTarget) return

    const screen = this.frameTarget.querySelector("[data-fp-screen]")
    const title = screen ? screen.getAttribute("data-title") : null
    if (title != null && this.hasTitleTarget) {
      this.titleTarget.textContent = title
      if (this.hasLiveRegionTarget) this.liveRegionTarget.textContent = title
    }

    this.moveSlot(screen, "[data-fp-screen-header-actions]", this.hasHeaderActionsTarget ? this.headerActionsTarget : null)
    this.moveSlot(screen, "[data-fp-screen-footer]", this.hasFooterTarget ? this.footerTarget : null)

    if (this.hasFooterTarget) {
      this.toggleHidden(this.footerTarget, this.footerTarget.childNodes.length === 0)
    }
  }

  clearChrome() {
    if (this.hasHeaderActionsTarget && typeof this.headerActionsTarget.replaceChildren === "function") {
      this.headerActionsTarget.replaceChildren()
    }
    if (this.hasFooterTarget) {
      if (typeof this.footerTarget.replaceChildren === "function") this.footerTarget.replaceChildren()
      this.toggleHidden(this.footerTarget, true)
    }
  }

  moveSlot(screen, selector, destination) {
    if (!destination) return
    if (typeof destination.replaceChildren === "function") destination.replaceChildren()
    if (!screen) return

    const source = screen.querySelector(selector)
    if (!source) return

    const nodes = Array.from(source.childNodes)
    nodes.forEach((node) => destination.appendChild(node))
  }

  updateBackButton() {
    if (!this.hasBackButtonTarget) return

    const show = this.stack.length > 0
    this.toggleHidden(this.backButtonTarget, !show)
    this.backButtonTarget.disabled = !show
    this.backButtonTarget.setAttribute("aria-hidden", show ? "false" : "true")
  }

  focusAfterLoad() {
    const restore = this.restoreSelector
    this.restoreSelector = null
    if (restore) {
      const remembered = this.element.querySelector(restore)
      if (remembered && typeof remembered.focus === "function") {
        remembered.focus()
        return
      }
    }

    if (this.hasTitleTarget && typeof this.titleTarget.focus === "function") {
      this.titleTarget.focus()
      return
    }

    if (!this.hasFrameTarget) return
    const first = this.frameTarget.querySelector(
      'a[href], button:not([disabled]):not([hidden]), input:not([disabled]):not([type="hidden"]), select:not([disabled]), textarea:not([disabled])'
    )
    if (first && typeof first.focus === "function") first.focus()
  }

  showLoading() {
    this.hideError()
    this.setBusy(true)
    if (this.hasLoadingTarget) this.toggleHidden(this.loadingTarget, false)
    if (this.hasFrameTarget) {
      this.frameTarget.setAttribute("aria-busy", "true")
      this.frameTarget.style.visibility = "hidden"
    }
  }

  hideLoading() {
    if (this.hasLoadingTarget) this.toggleHidden(this.loadingTarget, true)
    if (this.hasFrameTarget) {
      this.frameTarget.removeAttribute("aria-busy")
      if (!this.hasErrorTarget || this.errorTarget.hidden) {
        this.frameTarget.style.visibility = ""
        this.setBusy(false)
      }
    } else {
      this.setBusy(false)
    }
  }

  showError() {
    if (this.hasLoadingTarget) this.toggleHidden(this.loadingTarget, true)
    this.setBusy(true)
    if (this.hasErrorTarget) this.toggleHidden(this.errorTarget, false)
    if (this.hasFrameTarget) {
      this.frameTarget.setAttribute("aria-busy", "false")
      this.frameTarget.style.visibility = "hidden"
    }
    this.pendingAction = null
    if (this.hasErrorTarget) {
      const retry = this.errorTarget.querySelector("button, [data-fp-nav='retry']")
      if (retry && typeof retry.focus === "function") retry.focus()
    }
  }

  hideError() {
    if (this.hasErrorTarget) this.toggleHidden(this.errorTarget, true)
    if (this.hasFrameTarget && (!this.hasLoadingTarget || this.loadingTarget.hidden)) {
      this.frameTarget.style.visibility = ""
      this.setBusy(false)
    }
  }

  setBusy(busy) {
    if (busy) this.element.setAttribute("data-fp-navigable-busy", "true")
    else this.element.removeAttribute("data-fp-navigable-busy")
  }

  closeOverlay() {
    const application = this.application
    if (application && typeof application.getControllerForElementAndIdentifier === "function") {
      const identifiers = ["flat-pack--modal", "flat-pack--drawer"]
      for (const identifier of identifiers) {
        const overlay = application.getControllerForElementAndIdentifier(this.element, identifier)
        if (overlay && typeof overlay.close === "function") {
          overlay.close()
          return
        }
      }
    }

    const closeControl = this.element.querySelector('[data-action*="#close"]')
    if (closeControl && typeof closeControl.click === "function") closeControl.click()
  }

  isOpen() {
    return this.element.getAttribute("aria-hidden") === "false"
  }

  isOurFrame(target) {
    return this.hasFrameTarget && target === this.frameTarget
  }

  isOurRequest(event) {
    if (this.isOurFrame(event.target)) return true

    const headers = (event.detail && event.detail.fetchOptions && event.detail.fetchOptions.headers) || {}
    const frameId = headers["Turbo-Frame"] || headers["turbo-frame"]
    return Boolean(this.hasFrameTarget && frameId && frameId === this.frameTarget.id)
  }

  urlFromEvent(event) {
    const url = event.detail && event.detail.url
    if (!url) return null
    if (typeof url === "string") return url
    if (typeof url.href === "string") return url.href
    return url.toString ? url.toString() : null
  }

  peekUrl() {
    if (this.stack.length === 0) return this.srcValue
    return this.stack[this.stack.length - 1].url
  }

  normalizeUrl(url) {
    if (!url) return ""
    try {
      const parsed = new URL(url, (typeof window !== "undefined" && window.location && window.location.origin) || "http://example.test")
      return `${parsed.pathname}${parsed.search}`
    } catch {
      return String(url)
    }
  }

  sameUrl(left, right) {
    return this.normalizeUrl(left) === this.normalizeUrl(right)
  }

  selectorFor(element) {
    if (!element || !element.getAttribute) return null
    const href = element.getAttribute("href")
    const nav = element.dataset && element.dataset.fpNav
    if (href && nav) return `[data-fp-nav="${nav}"][href="${href}"]`
    if (href) return `[href="${href}"]`
    return null
  }

  isForm(element) {
    return element && element.tagName === "FORM"
  }

  toggleHidden(element, hidden) {
    if (!element) return
    element.hidden = hidden
    if (hidden) {
      element.setAttribute("hidden", "hidden")
    } else {
      element.removeAttribute("hidden")
    }
  }

  dispatch(name, detail) {
    const EventCtor = typeof CustomEvent === "function" ? CustomEvent : Event
    const event = new EventCtor(`flat-pack:navigable:${name}`, {
      bubbles: true,
      cancelable: true,
      detail: Object.assign({stack: this.stack.slice()}, detail)
    })
    this.element.dispatchEvent(event)
    return !event.defaultPrevented
  }
}
