import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    orderablePath: String,
    orderableMethod: {type: String, default: "PATCH"},
    paramUuidName: {type: String, default: "id"},
    paramTargetPositionName: {type: String, default: "position"}
  }

  connect() {
    this.draggedItem = null
    this.dragOverItem = null
    this.pendingSave = false
    this.needsSave = false
    this.boundHandlers = new Map()
    this.setupDraggableItems()
  }

  disconnect() {
    this.removeDragListeners()
  }

  setupDraggableItems() {
    this.listItems().forEach((item) => {
      item.setAttribute("draggable", "true")
      this.bindDragListeners(item)
    })
  }

  bindDragListeners(item) {
    const handlers = {
      dragstart: this.handleDragStart.bind(this),
      dragend: this.handleDragEnd.bind(this),
      dragover: this.handleDragOver.bind(this),
      drop: this.handleDrop.bind(this),
      dragenter: this.handleDragEnter.bind(this),
      dragleave: this.handleDragLeave.bind(this)
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

      item.removeAttribute("draggable")
    })

    this.boundHandlers.clear()
  }

  handleDragStart(event) {
    this.draggedItem = event.currentTarget

    if (this.draggedItem) {
      this.draggedItem.classList.add("opacity-70")
    }

    event.dataTransfer.effectAllowed = "move"
    event.dataTransfer.setData("text/plain", this.itemIdentifier(this.draggedItem) || "")
  }

  handleDragEnd() {
    if (this.draggedItem) {
      this.draggedItem.classList.remove("opacity-70")
    }

    this.listItems().forEach((item) => {
      item.classList.remove("ring-2", "ring-inset", "ring-[var(--color-primary)]")
    })

    this.draggedItem = null
    this.dragOverItem = null
  }

  handleDragOver(event) {
    if (event.preventDefault) {
      event.preventDefault()
    }

    event.dataTransfer.dropEffect = "move"
    return false
  }

  handleDragEnter(event) {
    const item = event.currentTarget

    if (item !== this.draggedItem) {
      this.dragOverItem = item
      item.classList.add("ring-2", "ring-inset", "ring-[var(--color-primary)]")
    }
  }

  handleDragLeave(event) {
    const item = event.currentTarget
    item.classList.remove("ring-2", "ring-inset", "ring-[var(--color-primary)]")
  }

  async handleDrop(event) {
    if (event.stopPropagation) {
      event.stopPropagation()
    }

    const dropTarget = this.dragOverItem || event.currentTarget

    if (this.draggedItem && this.draggedItem !== dropTarget && dropTarget) {
      this.reorderDom(dropTarget)
      this.emitReorderEvent()
      await this.saveOrder()
    }

    return false
  }

  reorderDom(dropTarget) {
    const parent = this.draggedItem?.parentNode
    if (!parent || !this.draggedItem) return

    const draggedIndex = Array.from(parent.children).indexOf(this.draggedItem)
    const dropIndex = Array.from(parent.children).indexOf(dropTarget)

    if (draggedIndex < dropIndex) {
      parent.insertBefore(this.draggedItem, dropTarget.nextSibling)
    } else {
      parent.insertBefore(this.draggedItem, dropTarget)
    }
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
  }

  async saveOrder() {
    if (!this.hasOrderablePathValue || !this.draggedItem) return

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
      const response = await fetch(this.orderablePathValue, {
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
