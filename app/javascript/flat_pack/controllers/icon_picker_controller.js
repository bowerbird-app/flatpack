import { Controller } from "@hotwired/stimulus"
import { playOverlayEnter, playOverlayExit, cancelOverlayHide } from "controllers/flat_pack/reduced_motion"
import { onClickOutside } from "flat_pack/click_outside"
import { applyFixedPosition, place, readEdgeOffset, watchViewport } from "flat_pack/positioning"
import { iconMatches, isGridMoveKey, moveIndex } from "flat_pack/icon_picker"

const PANEL_GAP = 8
const PANEL_MIN_WIDTH = 288

export default class extends Controller {
  static targets = ["trigger", "panel", "search", "grid", "empty", "hidden", "clear", "valueIcon", "valueLabel"]

  static values = {
    catalogId: String,
    showName: { type: Boolean, default: true },
    placeholder: String
  }

  connect() {
    this.isOpen = false
    this.gridReady = false
    this.activeIndex = 0
    this.panelParent = null
    this.panelNext = null
    // Stimulus targets only resolve inside the controller. The panel moves to
    // document.body while open, so keep the nodes themselves.
    this.panel = this.panelTarget
    this.search = this.searchTarget
    this.grid = this.gridTarget
    this.empty = this.emptyTarget
    this.clear = this.hasClearTarget ? this.clearTarget : null
    this.onPanelClick = this.onPanelClick.bind(this)
    this.onPanelKey = this.onPanelKey.bind(this)
    this.onSearch = this.onSearch.bind(this)
    this.onSearchKey = this.onSearchKey.bind(this)
    this.onDocumentKey = this.onDocumentKey.bind(this)
    this.outsideClick = onClickOutside(document, () => this.close(), {
      capture: true,
      roots: () => [this.element, this.panel],
      onlyWhen: () => this.isOpen
    })
    this.viewportWatch = watchViewport(() => {
      if (this.isOpen) this.position()
    })
    this.panel.addEventListener("click", this.onPanelClick)
    this.panel.addEventListener("keydown", this.onPanelKey)
    this.search.addEventListener("input", this.onSearch)
    this.search.addEventListener("keydown", this.onSearchKey)
  }

  disconnect() {
    cancelOverlayHide(this.panel)
    this.isOpen = false
    this.panel.removeEventListener("click", this.onPanelClick)
    this.panel.removeEventListener("keydown", this.onPanelKey)
    this.search.removeEventListener("input", this.onSearch)
    this.search.removeEventListener("keydown", this.onSearchKey)
    this.removeGlobalListeners()
    this.restorePanel()
  }

  toggle(event) {
    event.preventDefault()
    if (this.triggerTarget.disabled) return

    if (this.isOpen) this.close()
    else this.open()
  }

  triggerKey(event) {
    if (event.key !== "ArrowDown" || this.triggerTarget.disabled) return

    event.preventDefault()
    this.open()
  }

  open() {
    if (this.isOpen || this.triggerTarget.disabled) return

    this.ensureGrid()
    this.mountPanel()
    this.isOpen = true
    this.triggerTarget.setAttribute("aria-expanded", "true")
    this.panel.inert = false
    this.panel.setAttribute("aria-hidden", "false")
    this.filter()
    this.syncPressed()
    this.addGlobalListeners()
    playOverlayEnter(this.panel, {
      placement: "bottom",
      beforeAnimate: () => this.position()
    })
    this.search.focus()
  }

  close() {
    if (!this.isOpen) return

    const returnFocus = this.panel.contains(document.activeElement)
    this.isOpen = false
    this.triggerTarget.setAttribute("aria-expanded", "false")
    this.removeGlobalListeners()
    if (returnFocus) this.triggerTarget.focus()

    playOverlayExit(this.panel, {
      placement: "bottom",
      onHidden: () => {
        this.panel.setAttribute("aria-hidden", "true")
        this.panel.inert = true
        this.restorePanel()
      }
    })
  }

  onSearch() {
    if (!this.isOpen) return

    this.filter()
  }

  onSearchKey(event) {
    if (event.key !== "ArrowDown") return

    const buttons = this.visibleOptions()
    if (!buttons.length) return

    event.preventDefault()
    this.activeIndex = Math.min(this.activeIndex, buttons.length - 1)
    this.focusActive()
  }

  onPanelKey(event) {
    if (event.target === this.search) return
    if (!isGridMoveKey(event.key)) return

    const buttons = this.visibleOptions()
    if (!buttons.length) return

    event.preventDefault()
    this.activeIndex = moveIndex(this.activeIndex, buttons.length, this.columnCount(buttons), event.key)
    this.focusActive()
  }

  onPanelClick(event) {
    if (this.clear?.contains(event.target)) {
      event.preventDefault()
      this.choose("")
      return
    }

    const button = event.target.closest("[data-icon-name]")
    if (!button || !this.grid.contains(button)) return

    event.preventDefault()
    this.choose(button.dataset.iconName)
  }

  onDocumentKey(event) {
    if (!this.isOpen || event.key !== "Escape") return

    event.preventDefault()
    event.stopPropagation()
    this.close()
  }

  choose(name) {
    this.hiddenTarget.value = name
    this.hiddenTarget.dispatchEvent(new Event("change", { bubbles: true }))
    this.syncPressed()
    this.syncTrigger()
    this.close()
  }

  ensureGrid() {
    if (this.gridReady) return

    const template = document.getElementById(this.catalogIdValue)
    if (!template?.content) return

    this.grid.append(template.content.cloneNode(true))
    this.gridReady = true
  }

  filter() {
    let visible = 0
    this.options().forEach((button) => {
      const match = iconMatches(button.dataset.iconName, this.search.value)
      button.hidden = !match
      if (match) visible += 1
    })
    this.empty.hidden = visible > 0

    const buttons = this.visibleOptions()
    const selected = buttons.findIndex((button) => button.dataset.iconName === this.hiddenTarget.value)
    this.activeIndex = selected >= 0 ? selected : 0
    this.syncTabindex()
  }

  syncPressed() {
    const name = this.hiddenTarget.value
    this.options().forEach((button) => {
      button.setAttribute("aria-pressed", button.dataset.iconName === name ? "true" : "false")
    })
    if (this.clear) {
      this.clear.setAttribute("aria-pressed", name ? "false" : "true")
    }
  }

  syncTrigger() {
    const name = this.hiddenTarget.value
    const button = name ? this.optionByName(name) : null
    this.valueIconTarget.replaceChildren()

    const svg = button?.querySelector("svg")
    if (svg) {
      this.valueIconTarget.append(svg.cloneNode(true))
      this.valueIconTarget.hidden = false
    } else {
      this.valueIconTarget.hidden = true
    }

    const label = name ? (button?.getAttribute("aria-label") || name) : this.placeholderValue
    const showLabel = !name || this.showNameValue
    this.valueLabelTarget.hidden = !showLabel
    this.valueLabelTarget.textContent = showLabel ? label : ""
    this.triggerTarget.dataset.empty = name ? "false" : "true"
    this.triggerTarget.setAttribute("aria-label", label)
  }

  syncTabindex() {
    const buttons = this.visibleOptions()
    if (this.activeIndex >= buttons.length) this.activeIndex = Math.max(buttons.length - 1, 0)

    this.options().forEach((button) => {
      button.tabIndex = -1
    })
    const active = buttons[this.activeIndex]
    if (active) active.tabIndex = 0
  }

  focusActive() {
    this.syncTabindex()
    this.visibleOptions()[this.activeIndex]?.focus()
  }

  options() {
    return Array.from(this.grid.querySelectorAll("[data-icon-name]"))
  }

  visibleOptions() {
    return this.options().filter((button) => !button.hidden)
  }

  optionByName(name) {
    return this.options().find((button) => button.dataset.iconName === name) || null
  }

  columnCount(buttons) {
    if (buttons.length < 2) return 1

    const top = buttons[0].offsetTop
    let count = 1
    for (let index = 1; index < buttons.length; index += 1) {
      if (buttons[index].offsetTop !== top) break
      count += 1
    }
    return count
  }

  mountPanel() {
    if (this.panel.parentElement === document.body) return

    this.panelParent = this.panel.parentNode
    this.panelNext = this.panel.nextSibling
    document.body.append(this.panel)
  }

  restorePanel() {
    if (!this.panelParent || this.panel.parentNode === this.panelParent) return

    if (this.panelNext && this.panelNext.parentNode === this.panelParent) {
      this.panelParent.insertBefore(this.panel, this.panelNext)
    } else {
      this.panelParent.append(this.panel)
    }
    this.panelParent = null
    this.panelNext = null
  }

  position() {
    const edge = readEdgeOffset(this.panel)
    const measured = this.panel.getBoundingClientRect()
    const maxWidth = Math.max(window.innerWidth - (edge * 2), 0)
    const width = Math.min(Math.max(measured.width, PANEL_MIN_WIDTH), maxWidth)
    const placed = place(
      this.triggerTarget.getBoundingClientRect(),
      { width, height: measured.height },
      { width: window.innerWidth, height: window.innerHeight },
      { placement: "bottom_left", gap: PANEL_GAP, edge, flip: true, stickToEdge: true }
    )

    applyFixedPosition(this.panel, placed)
    this.panel.style.width = `${width}px`
    this.panel.style.maxWidth = `${maxWidth}px`
  }

  addGlobalListeners() {
    this.outsideClick.add()
    this.viewportWatch.add()
    document.addEventListener("keydown", this.onDocumentKey, true)
  }

  removeGlobalListeners() {
    this.outsideClick?.remove()
    this.viewportWatch?.remove()
    document.removeEventListener("keydown", this.onDocumentKey, true)
  }
}
