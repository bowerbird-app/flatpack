import { Controller } from "@hotwired/stimulus"
import { prefersReducedMotion, motionDuration, motionTransition } from "controllers/flat_pack/reduced_motion"

const LOCK_KEY = "flatPackModalLockCount"

export default class extends Controller {
  static targets = ["dialog", "input", "item", "group", "empty"]
  static values = { shortcut: { type: Boolean, default: true } }

  connect() {
    this.previousActiveElement = null
    this.hideTimeout = null
    this.closing = false
    this.activeIndex = 0
    this.handleDocumentTriggerClick = this.handleDocumentTriggerClick.bind(this)
    this.handleShortcut = this.handleShortcut.bind(this)
    document.addEventListener("click", this.handleDocumentTriggerClick)
    document.addEventListener("keydown", this.handleShortcut)
  }

  disconnect() {
    document.removeEventListener("click", this.handleDocumentTriggerClick)
    document.removeEventListener("keydown", this.handleShortcut)
    this.clearHideTimeout()
    if (!this.element.classList.contains("hidden")) {
      this.restoreBodyScroll()
      this.restoreFocus()
    }
  }

  open() {
    const wasClosing = this.closing
    this.clearHideTimeout()
    this.closing = false
    if (!this.element.classList.contains("hidden") && !wasClosing) return

    if (!this.previousActiveElement) {
      this.previousActiveElement = document.activeElement
    }

    this.preventBodyScroll()
    this.element.classList.remove("hidden")
    this.element.setAttribute("aria-hidden", "false")
    this.element.offsetHeight
    this.applyEnterMotion()
    this.element.style.opacity = "1"

    requestAnimationFrame(() => {
      if (!this.hasDialogTarget) return
      this.dialogTarget.style.opacity = "1"
      this.dialogTarget.style.transform = prefersReducedMotion() ? "none" : "scale(1)"
    })

    this.filter()
    setTimeout(() => this.inputTarget?.focus(), 50)
  }

  close() {
    if (this.element.classList.contains("hidden") || this.closing) return

    this.closing = true
    this.clearHideTimeout()
    this.applyExitMotion()
    this.element.style.opacity = "0"
    this.restoreBodyScroll()
    if (this.hasDialogTarget) {
      this.dialogTarget.style.opacity = "0"
      if (!prefersReducedMotion()) this.dialogTarget.style.transform = "scale(0.95)"
    }

    this.hideTimeout = setTimeout(() => {
      this.hideTimeout = null
      this.closing = false
      this.element.classList.add("hidden")
      this.element.setAttribute("aria-hidden", "true")
      if (this.hasInputTarget) this.inputTarget.value = ""
      this.restoreFocus()
    }, motionDuration("base"))
  }

  handleDocumentTriggerClick(event) {
    const trigger = event.target.closest("[data-command-palette-id]")
    if (!trigger) return
    if (trigger.dataset.commandPaletteId !== this.element.id) return
    this.previousActiveElement = trigger
    this.open()
  }

  handleShortcut(event) {
    if (!this.shortcutValue) return
    const key = event.key?.toLowerCase()
    if ((event.metaKey || event.ctrlKey) && key === "k") {
      event.preventDefault()
      if (this.element.classList.contains("hidden") || this.closing) {
        this.open()
      } else {
        this.close()
      }
    }
  }

  clickBackdrop(event) {
    if (event.target === event.currentTarget) this.close()
  }

  filter() {
    const query = (this.inputTarget?.value || "").trim().toLowerCase()
    let visible = 0

    this.itemTargets.forEach((item) => {
      const match = item.dataset.search.includes(query)
      item.closest("li").classList.toggle("hidden", !match)
      if (match) visible += 1
    })

    this.groupTargets.forEach((group) => {
      const any = Array.from(group.querySelectorAll("[data-flat-pack--command-palette-target='item']"))
        .some((item) => !item.closest("li").classList.contains("hidden"))
      group.classList.toggle("hidden", !any)
    })

    if (this.hasEmptyTarget) this.emptyTarget.classList.toggle("hidden", visible > 0)
    this.activeIndex = visible > 0 ? 0 : -1
    this.syncActive()
  }

  keydown(event) {
    if (event.key === "ArrowDown") {
      event.preventDefault()
      this.move(1)
    } else if (event.key === "ArrowUp") {
      event.preventDefault()
      this.move(-1)
    } else if (event.key === "Enter") {
      const active = this.visibleItems()[this.activeIndex]
      if (active) {
        event.preventDefault()
        active.click()
      }
    }
  }

  choose() {
    this.close()
  }

  trapTab(event) {
    if (event.key !== "Tab" || !this.hasDialogTarget) return
    const focusable = Array.from(
      this.dialogTarget.querySelectorAll('button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])')
    )
    if (focusable.length === 0) return
    const first = focusable[0]
    const last = focusable[focusable.length - 1]
    if (event.shiftKey && document.activeElement === first) {
      event.preventDefault()
      last.focus()
    } else if (!event.shiftKey && document.activeElement === last) {
      event.preventDefault()
      first.focus()
    }
  }

  visibleItems() {
    return this.itemTargets.filter((item) => !item.closest("li").classList.contains("hidden"))
  }

  move(delta) {
    const items = this.visibleItems()
    if (items.length === 0) return
    this.activeIndex = (this.activeIndex + delta + items.length) % items.length
    this.syncActive()
    items[this.activeIndex].scrollIntoView({ block: "nearest" })
  }

  syncActive() {
    const items = this.visibleItems()
    items.forEach((item, index) => {
      const selected = index === this.activeIndex
      item.setAttribute("aria-selected", selected ? "true" : "false")
    })
  }

  preventBodyScroll() {
    this.originalOverflow = document.body.style.overflow
    this.originalPaddingRight = document.body.style.paddingRight
    this.originalOverscrollBehavior = document.body.style.overscrollBehavior
    const lockCount = Number(document.body.dataset[LOCK_KEY] || "0")
    if (lockCount === 0) {
      const scrollbarWidth = window.innerWidth - document.documentElement.clientWidth
      if (scrollbarWidth > 0) document.body.style.paddingRight = `${scrollbarWidth}px`
      document.body.style.overflow = "hidden"
      document.body.style.overscrollBehavior = "none"
    }
    document.body.dataset[LOCK_KEY] = String(lockCount + 1)
  }

  restoreBodyScroll() {
    const lockCount = Number(document.body.dataset[LOCK_KEY] || "0")
    if (lockCount > 1) {
      document.body.dataset[LOCK_KEY] = String(lockCount - 1)
      return
    }
    delete document.body.dataset[LOCK_KEY]
    document.body.style.overflow = this.originalOverflow || ""
    document.body.style.paddingRight = this.originalPaddingRight || ""
    document.body.style.overscrollBehavior = this.originalOverscrollBehavior || ""
  }

  restoreFocus() {
    if (this.previousActiveElement?.focus) {
      this.previousActiveElement.focus()
      this.previousActiveElement = null
    }
  }

  applyEnterMotion() {
    this.element.style.transition = motionTransition("opacity", { duration: "slow", easing: "enter" })
    if (!this.hasDialogTarget) return
    this.dialogTarget.style.transition = motionTransition(["opacity", "transform"], { duration: "slow", easing: "enter" })
  }

  applyExitMotion() {
    this.element.style.transition = motionTransition("opacity", { duration: "base", easing: "exit" })
    if (!this.hasDialogTarget) return
    this.dialogTarget.style.transition = motionTransition(["opacity", "transform"], { duration: "base", easing: "exit" })
  }

  clearHideTimeout() {
    if (!this.hideTimeout) return
    clearTimeout(this.hideTimeout)
    this.hideTimeout = null
  }
}
