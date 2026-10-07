import { Controller } from "@hotwired/stimulus"
import { prefersReducedMotion } from "controllers/flat_pack/reduced_motion"

const DRAG_THRESHOLD_PX = 4
const SETTLE_MS = 300
const SIBLING_FLIP_MS = 280
const PLACEHOLDER_CLASS = "flat-pack-list-reorder-placeholder"
const PLACEHOLDER_VISIBLE_CLASS = "is-visible"
const DRAGGING_CLASS = "is-dragging"
const PRESS_CLASS = "is-pressing"
const LIFT_CLASS = "is-lifted"
const REORDERING_CLASS = "is-reordering"
const DRAG_TRANSITION = "box-shadow var(--duration-fast) var(--easing-standard), scale var(--duration-fast) var(--easing-standard)"
const SETTLE_TRANSITION = "transform var(--duration-slow) var(--easing-spring-snappy), box-shadow var(--duration-slow) var(--easing-standard), scale var(--duration-slow) var(--easing-spring-snappy)"

export default class extends Controller {
  static values = {
    orderableUrl: String,
    orderableMethod: {type: String, default: "PATCH"},
    paramUuidName: {type: String, default: "id"},
    paramTargetPositionName: {type: String, default: "position"},
    handleSelector: {type: String, default: ""}
  }

  connect() {
    this.draggedItem = null
    this.placeholder = null
    this.pendingSave = false
    this.needsSave = false
    this.pointerId = null
    this.startX = 0
    this.startY = 0
    this.originX = 0
    this.originY = 0
    this.itemWidth = 0
    this.itemHeight = 0
    this.layoutLeft = 0
    this.layoutTop = 0
    this.layoutWidth = 0
    this.layoutHeight = 0
    this.dragging = false
    this.dragActivated = false
    this.settleTimer = null
    this.boundHandlers = new Map()
    this.boundWindowPointerMove = this.handleWindowPointerMove.bind(this)
    this.boundWindowPointerUp = this.handleWindowPointerUp.bind(this)
    this.boundWindowPointerCancel = this.handleWindowPointerUp.bind(this)
    this.setupDraggableItems()
    this.observeItems()
  }

  disconnect() {
    this.itemObserver?.disconnect()
    this.cancelActiveDrag()
    this.removeDragListeners()
  }

  setupDraggableItems() {
    this.listItems().forEach((item) => {
      this.bindDragListeners(item)
    })
  }

  bindDragListeners(item) {
    const handlers = {
      pointerdown: this.handlePointerDown.bind(this),
      keydown: this.handleKeyDown.bind(this)
    }

    this.boundHandlers.set(item, handlers)

    Object.entries(handlers).forEach(([eventName, handler]) => {
      item.addEventListener(eventName, handler)
    })
  }

  removeDragListeners() {
    this.listItems().forEach((item) => {
      const handlers = this.boundHandlers.get(item)

      if (handlers) {
        Object.entries(handlers).forEach(([eventName, handler]) => {
          item.removeEventListener(eventName, handler)
        })
      }
    })

    this.boundHandlers.clear()
    this.teardownWindowListeners()
  }

  handlePointerDown(event) {
    if (event.button != null && event.button !== 0) return
    if (this.dragging) return
    if (this.handleSelectorValue) {
      if (!(event.target instanceof Element) || !event.target.closest(this.handleSelectorValue)) return
    } else if (this.isInteractiveTarget(event.target)) {
      return
    }

    const item = event.currentTarget
    if (!item || !this.listItems().includes(item)) return

    const rect = item.getBoundingClientRect()
    this.layoutLeft = rect.left
    this.layoutTop = rect.top
    this.layoutWidth = rect.width
    this.layoutHeight = rect.height

    this.draggedItem = item
    this.pointerId = event.pointerId
    this.startX = event.clientX
    this.startY = event.clientY
    this.dragActivated = false
    this.dragging = true

    if (!prefersReducedMotion()) item.classList.add(PRESS_CLASS)

    window.addEventListener("pointermove", this.boundWindowPointerMove)
    window.addEventListener("pointerup", this.boundWindowPointerUp)
    window.addEventListener("pointercancel", this.boundWindowPointerCancel)
  }

  handleWindowPointerMove(event) {
    if (!this.dragging || event.pointerId !== this.pointerId) return

    if (!this.dragActivated) {
      const dx = event.clientX - this.startX
      const dy = event.clientY - this.startY
      if (Math.hypot(dx, dy) < DRAG_THRESHOLD_PX) return

      this.activateDrag(event)
    }

    event.preventDefault()
    this.updateDragPosition(event.clientX, event.clientY)
    this.updatePlaceholderForPointer(event.clientY)
  }

  async handleWindowPointerUp(event) {
    if (!this.dragging || (event.pointerId != null && event.pointerId !== this.pointerId)) return

    this.teardownWindowListeners()

    if (!this.dragActivated) {
      this.draggedItem?.classList.remove(PRESS_CLASS)
      this.resetDragState()
      return
    }

    event.preventDefault()
    await this.finishDrag()
  }

  activateDrag(event) {
    const item = this.draggedItem
    if (!item) return

    this.dragActivated = true
    this.originX = this.layoutLeft
    this.originY = this.layoutTop
    this.itemWidth = this.layoutWidth
    this.itemHeight = this.layoutHeight
    this.startX = event.clientX
    this.startY = event.clientY

    this.placeholder = this.createPlaceholder(item)
    item.parentNode.insertBefore(this.placeholder, item)
    this.revealPlaceholder()

    this.element.classList.add(REORDERING_CLASS)
    item.classList.remove(PRESS_CLASS)
    item.classList.add(DRAGGING_CLASS)
    item.classList.add(LIFT_CLASS)
    if (!prefersReducedMotion()) item.style.transition = DRAG_TRANSITION
    item.style.touchAction = "none"
    item.style.width = `${this.itemWidth}px`
    item.style.height = `${this.itemHeight}px`
    item.style.position = "fixed"
    item.style.left = `${this.originX}px`
    item.style.top = `${this.originY}px`
    item.style.zIndex = "40"
    item.style.margin = "0"
    item.style.pointerEvents = "none"
    item.style.userSelect = "none"
    item.style.willChange = "transform, box-shadow, scale"

    try {
      item.setPointerCapture?.(this.pointerId)
    } catch (_error) {
      // Pointer may already be released on some browsers.
    }

    this.updateDragPosition(event.clientX, event.clientY)
  }

  updateDragPosition(clientX, clientY) {
    const item = this.draggedItem
    if (!item) return

    const dx = clientX - this.startX
    const dy = clientY - this.startY
    item.style.transform = `translate3d(${dx}px, ${dy}px, 0)`
  }

  updatePlaceholderForPointer(clientY) {
    if (!this.placeholder || !this.placeholder.parentNode) return

    const items = this.listItems().filter((item) => item !== this.draggedItem)
    let insertBeforeNode = null

    for (const item of items) {
      const rect = item.getBoundingClientRect()
      const midpoint = rect.top + rect.height / 2
      if (clientY < midpoint) {
        insertBeforeNode = item
        break
      }
    }

    const target = insertBeforeNode || null
    const currentNext = this.placeholder.nextElementSibling === this.draggedItem
      ? this.placeholder.nextElementSibling?.nextElementSibling
      : this.placeholder.nextElementSibling

    if (target === currentNext) return
    if (target == null && this.placeholder.parentNode.lastElementChild === this.placeholder) return
    if (target && target.previousElementSibling === this.placeholder) return

    this.movePlaceholder(target)
  }

  movePlaceholder(beforeNode) {
    const parent = this.placeholder?.parentNode
    if (!parent) return

    const siblings = this.listItems().filter((item) => item !== this.draggedItem)
    const firstRects = prefersReducedMotion()
      ? null
      : new Map(siblings.map((item) => [item, item.getBoundingClientRect()]))

    if (beforeNode) {
      parent.insertBefore(this.placeholder, beforeNode)
    } else {
      parent.appendChild(this.placeholder)
    }

    if (!firstRects) return

    this.playSiblingFlip(siblings, firstRects)
  }

  playSiblingFlip(siblings, firstRects) {
    siblings.forEach((item) => {
      const first = firstRects.get(item)
      if (!first) return

      const last = item.getBoundingClientRect()
      const dx = first.left - last.left
      const dy = first.top - last.top
      if (dx === 0 && dy === 0) return

      item.style.transition = "none"
      item.style.transform = `translate3d(${dx}px, ${dy}px, 0)`
      void item.offsetHeight
      item.style.transition = "transform var(--duration-slow) var(--easing-spring), color var(--duration-fast) var(--easing-standard)"
      item.style.transform = "translate3d(0, 0, 0)"

      window.setTimeout(() => {
        if (item.classList.contains(DRAGGING_CLASS)) return
        item.style.transition = ""
        item.style.transform = ""
      }, SIBLING_FLIP_MS)
    })
  }

  async finishDrag() {
    const item = this.draggedItem
    if (!item || !this.placeholder) {
      this.resetDragState()
      return
    }

    const originIndex = this.originIndexAmongItems(item)
    const targetIndex = this.placeholderIndex()
    await this.settleDraggedItem()
    this.commitPlaceholder(item)
    this.clearDragStyles(item)

    if (originIndex !== targetIndex) {
      this.emitReorderEvent()
      await this.saveOrder()
    }

    this.resetDragState()
  }

  originIndexAmongItems(item) {
    return this.listItems().indexOf(item)
  }

  placeholderIndex() {
    if (!this.placeholder?.parentNode) return 0

    return Array.from(this.placeholder.parentNode.children)
      .filter((node) => node === this.placeholder || (node.matches?.("li[role='listitem']") && node !== this.draggedItem))
      .indexOf(this.placeholder)
  }

  settleDraggedItem() {
    const item = this.draggedItem
    const placeholder = this.placeholder
    if (!item || !placeholder) return Promise.resolve()

    if (prefersReducedMotion()) {
      return Promise.resolve()
    }

    const target = placeholder.getBoundingClientRect()
    const existing = item.style.transform || "translate3d(0px, 0px, 0)"
    const match = existing.match(/translate3d\(([-\d.]+)px,\s*([-\d.]+)px/)
    const fromX = match ? Number.parseFloat(match[1]) : 0
    const fromY = match ? Number.parseFloat(match[2]) : 0
    const dx = target.left - (this.originX + fromX)
    const dy = target.top - (this.originY + fromY)
    const transformChanges = dx !== 0 || dy !== 0

    item.style.transition = SETTLE_TRANSITION
    item.style.transform = `translate3d(${fromX + dx}px, ${fromY + dy}px, 0)`
    item.style.scale = "1"
    item.classList.remove(LIFT_CLASS)

    return new Promise((resolve) => {
      let settled = false
      const finish = () => {
        if (settled) return
        settled = true
        item.removeEventListener("transitionend", onEnd)
        if (this.settleTimer) {
          window.clearTimeout(this.settleTimer)
          this.settleTimer = null
        }
        resolve()
      }
      const onEnd = (event) => {
        if (event.target !== item) return
        const watched = transformChanges ? "transform" : "scale"
        if (event.propertyName !== watched) return
        finish()
      }

      item.addEventListener("transitionend", onEnd)
      this.settleTimer = window.setTimeout(finish, SETTLE_MS + 80)
    })
  }

  commitPlaceholder(item) {
    if (!this.placeholder?.parentNode || !item) return

    this.placeholder.parentNode.insertBefore(item, this.placeholder)
    this.placeholder.remove()
    this.placeholder = null
  }

  clearDragStyles(item) {
    if (!item) return

    item.classList.remove(DRAGGING_CLASS)
    item.classList.remove(PRESS_CLASS)
    item.classList.remove(LIFT_CLASS)
    item.style.touchAction = ""
    item.style.width = ""
    item.style.height = ""
    item.style.position = ""
    item.style.left = ""
    item.style.top = ""
    item.style.zIndex = ""
    item.style.margin = ""
    item.style.pointerEvents = ""
    item.style.userSelect = ""
    item.style.willChange = ""
    item.style.transform = ""
    item.style.transition = ""
    item.style.scale = ""
  }

  cancelActiveDrag() {
    if (this.settleTimer) {
      window.clearTimeout(this.settleTimer)
      this.settleTimer = null
    }

    this.teardownWindowListeners()

    if (this.placeholder) {
      if (this.draggedItem && this.placeholder.parentNode) {
        this.placeholder.parentNode.insertBefore(this.draggedItem, this.placeholder)
      }
      this.placeholder.remove()
      this.placeholder = null
    }

    if (this.draggedItem) {
      this.clearDragStyles(this.draggedItem)
    }

    this.resetDragState()
  }

  resetDragState() {
    this.element.classList.remove(REORDERING_CLASS)
    this.listItems().forEach((item) => {
      if (!item.classList.contains(DRAGGING_CLASS)) {
        item.style.transition = ""
        item.style.transform = ""
      }
    })

    this.draggedItem = null
    this.placeholder = null
    this.pointerId = null
    this.dragging = false
    this.dragActivated = false
  }

  teardownWindowListeners() {
    window.removeEventListener("pointermove", this.boundWindowPointerMove)
    window.removeEventListener("pointerup", this.boundWindowPointerUp)
    window.removeEventListener("pointercancel", this.boundWindowPointerCancel)
  }

  revealPlaceholder() {
    const placeholder = this.placeholder
    if (!placeholder) return

    const show = () => placeholder.classList?.add(PLACEHOLDER_VISIBLE_CLASS)
    if (typeof window.requestAnimationFrame === "function") {
      window.requestAnimationFrame(show)
    } else {
      show()
    }
  }

  createPlaceholder(item) {
    const placeholder = document.createElement("li")
    placeholder.className = PLACEHOLDER_CLASS
    placeholder.setAttribute("aria-hidden", "true")
    const height = this.layoutHeight || item.offsetHeight || item.getBoundingClientRect().height
    placeholder.style.height = `${height}px`
    return placeholder
  }

  // Testable DOM reorder used by unit tests and as a reduced-motion hard path helper.
  reorderDom(dropTarget) {
    const parent = this.draggedItem?.parentNode
    if (!parent || !this.draggedItem || !dropTarget) return

    const draggedIndex = Array.from(parent.children).indexOf(this.draggedItem)
    const dropIndex = Array.from(parent.children).indexOf(dropTarget)

    if (draggedIndex < 0 || dropIndex < 0) return

    if (draggedIndex < dropIndex) {
      parent.insertBefore(this.draggedItem, dropTarget.nextSibling)
    } else {
      parent.insertBefore(this.draggedItem, dropTarget)
    }
  }

  async commitReorderTo(dropTarget) {
    if (!this.draggedItem || !dropTarget || this.draggedItem === dropTarget) return

    this.reorderDom(dropTarget)
    this.emitReorderEvent()
    await this.saveOrder()
  }

  emitReorderEvent() {
    const movedItem = this.draggedItem
    if (!movedItem) return

    const detail = {
      id: this.itemIdentifier(movedItem),
      position: this.currentPosition(movedItem)
    }

    this.element.dispatchEvent(new CustomEvent("list:reordered", {
      detail,
      bubbles: true
    }))
  }

  currentPosition(item) {
    if (!item) return null

    return this.listItems().indexOf(item) + 1
  }

  itemIdentifier(item) {
    return item?.dataset?.id || item?.id || null
  }

  listItems() {
    return Array.from(this.element.querySelectorAll("li[role='listitem']"))
      .filter((item) => item?.dataset?.collectionEditorDestroyed !== "true")
  }

  observeItems() {
    if (typeof MutationObserver !== "function") return

    this.itemObserver = new MutationObserver(() => {
      this.listItems().forEach((item) => {
        if (!this.boundHandlers.has(item)) this.bindDragListeners(item)
      })
    })
    this.itemObserver.observe(this.element, {childList: true})
  }

  handleKeyDown(event) {
    if (!this.handleSelectorValue) return
    if (!(event.target instanceof Element) || !event.target.closest(this.handleSelectorValue)) return
    if (event.key !== "ArrowUp" && event.key !== "ArrowDown") return

    event.preventDefault()
    this.nudge(event.currentTarget, event.key === "ArrowUp" ? -1 : 1)
  }

  async nudge(item, delta) {
    const items = this.listItems()
    const index = items.indexOf(item)
    const target = index + delta
    if (index < 0 || target < 0 || target >= items.length) return

    const sibling = items[target]
    if (delta < 0) {
      item.parentNode.insertBefore(item, sibling)
    } else {
      item.parentNode.insertBefore(item, sibling.nextSibling)
    }

    this.draggedItem = item
    this.emitReorderEvent()
    await this.saveOrder()
    if (!this.dragging) this.draggedItem = null
  }

  isInteractiveTarget(target) {
    if (!(target instanceof Element)) return false

    return Boolean(
      target.closest("a, button, input, select, textarea, label, [contenteditable='true'], [data-no-reorder]")
    )
  }

  async saveOrder() {
    if (!this.hasOrderableUrlValue || !this.draggedItem) return
    if (this.draggedItem.dataset?.orderableUnsaved === "true") return

    if (this.pendingSave) {
      this.needsSave = true
      return
    }

    this.pendingSave = true

    const item = this.draggedItem
    const payload = new URLSearchParams()
    payload.set(this.paramUuidNameValue || "id", this.itemIdentifier(item) || "")
    payload.set(this.paramTargetPositionNameValue || "position", this.currentPosition(item)?.toString() || "")

    try {
      const response = await fetch(this.orderableUrlValue, {
        method: this.orderableMethodValue || "PATCH",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
          "X-CSRF-Token": this.csrfToken,
          "Accept": "application/json"
        },
        body: payload.toString()
      })

      const payloadBody = await response.json()

      if (!response.ok || !payloadBody.ok) {
        this.element.dispatchEvent(new CustomEvent("list:error", {
          detail: payloadBody,
          bubbles: true
        }))
        return
      }

      this.element.dispatchEvent(new CustomEvent("list:saved", {
        detail: payloadBody,
        bubbles: true
      }))
    } catch (_error) {
      this.element.dispatchEvent(new CustomEvent("list:error", {
        detail: {error: "Unable to save list order"},
        bubbles: true
      }))
    } finally {
      this.pendingSave = false

      if (this.needsSave) {
        this.needsSave = false
        this.saveOrder()
      }
    }
  }

  get csrfToken() {
    return document.querySelector("meta[name='csrf-token']")?.content || ""
  }
}
