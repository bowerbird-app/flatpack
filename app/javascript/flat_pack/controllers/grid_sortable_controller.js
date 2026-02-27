// FlatPack Grid Sortable Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]
  static values = {
    reorderUrl: String,
    resource: String,
    strategy: String,
    scope: Object,
    version: String
  }

  connect() {
    this.draggedItem = null
    this.dragOverItem = null
    this.pendingSave = false
    this.needsSave = false
    this.conflictRetryPending = false
    this.lastStableOrder = this.currentOrder()
    this.setupDraggableItems()
  }

  disconnect() {
    this.removeDragListeners()
  }

  setupDraggableItems() {
    this.itemTargets.forEach((item) => {
      item.setAttribute("draggable", "true")
      item.addEventListener("dragstart", this.handleDragStart.bind(this))
      item.addEventListener("dragend", this.handleDragEnd.bind(this))
      item.addEventListener("dragover", this.handleDragOver.bind(this))
      item.addEventListener("drop", this.handleDrop.bind(this))
      item.addEventListener("dragenter", this.handleDragEnter.bind(this))
      item.addEventListener("dragleave", this.handleDragLeave.bind(this))
    })
  }

  removeDragListeners() {
    this.itemTargets.forEach((item) => {
      item.removeAttribute("draggable")
    })
  }

  handleDragStart(event) {
    this.draggedItem = event.currentTarget
    this.draggedItem.classList.add("opacity-70")

    event.dataTransfer.effectAllowed = "move"
    event.dataTransfer.setData("text/plain", this.draggedItem.dataset.id || this.draggedItem.id || "")
  }

  handleDragEnd() {
    if (this.draggedItem) {
      this.draggedItem.classList.remove("opacity-70")
    }

    this.itemTargets.forEach((item) => {
      item.classList.remove("ring-2", "ring-[var(--color-primary)]")
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
      item.classList.add("ring-2", "ring-[var(--color-primary)]")
    }
  }

  handleDragLeave(event) {
    const item = event.currentTarget
    item.classList.remove("ring-2", "ring-[var(--color-primary)]")
  }

  handleDrop(event) {
    if (event.stopPropagation) {
      event.stopPropagation()
    }

    const dropTarget = this.dragOverItem || event.currentTarget

    if (this.draggedItem && this.draggedItem !== dropTarget && dropTarget) {
      const previousOrder = this.currentOrder()

      const parent = this.draggedItem.parentNode
      const draggedIndex = Array.from(parent.children).indexOf(this.draggedItem)
      const dropIndex = Array.from(parent.children).indexOf(dropTarget)

      if (draggedIndex < dropIndex) {
        parent.insertBefore(this.draggedItem, dropTarget.nextSibling)
      } else {
        parent.insertBefore(this.draggedItem, dropTarget)
      }

      if (!this.pendingSave) {
        this.lastStableOrder = previousOrder
      }

      this.emitReorderEvent()
      this.saveOrder()
    }

    return false
  }

  emitReorderEvent() {
    const orderedIds = this.currentOrder()
    if (orderedIds.length === 0) return

    const orderedItems = orderedIds.map((id, index) => ({
      id: Number(id),
      position: index + 1
    }))

    this.element.dispatchEvent(new CustomEvent("grid:reordered", {
      detail: { orderedIds: orderedIds, items: orderedItems },
      bubbles: true
    }))
  }

  currentOrder() {
    return this.itemTargets.map((item) => item.dataset.id || item.id).filter(Boolean)
  }

  async saveOrder() {
    if (!this.hasReorderUrlValue) return

    if (this.pendingSave) {
      this.needsSave = true
      return
    }

    this.pendingSave = true

    try {
      const order = this.currentOrder()
      const items = order.map((id, index) => ({
        id: Number(id),
        position: index + 1
      }))

      const response = await fetch(this.reorderUrlValue, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": this.csrfToken,
          "Accept": "application/json"
        },
        body: JSON.stringify({
          reorder: {
            resource: this.resourceValue || "demo_table_rows",
            strategy: this.strategyValue || "dense_integer",
            scope: this.scopeValue || {},
            version: this.versionValue || "0",
            items: items
          }
        })
      })

      const payload = await response.json()

      if (!response.ok || !payload.ok) {
        const isStaleConflict = response.status === 409 || /stale/i.test(payload?.error || "")

        if (isStaleConflict && payload?.version && !this.conflictRetryPending) {
          this.versionValue = payload.version
          this.conflictRetryPending = true
          this.needsSave = true
          return
        }

        if (payload?.version) {
          this.versionValue = payload.version
        }

        this.conflictRetryPending = false
        this.dispatch("error", { detail: payload })
        return
      }

      this.versionValue = payload.version
      this.conflictRetryPending = false
      this.lastStableOrder = this.currentOrder()
      this.dispatch("saved", { detail: payload })
    } catch (_error) {
      this.conflictRetryPending = false
      this.dispatch("error", { detail: { error: "Unable to save card order" } })
    } finally {
      this.pendingSave = false

      if (this.needsSave) {
        this.needsSave = false
        this.saveOrder()
      }
    }
  }

  restoreOrder(orderedIds) {
    if (!orderedIds || orderedIds.length === 0) return

    const parent = this.itemTargets[0]?.parentNode
    if (!parent) return

    const itemMap = this.itemTargets.reduce((memo, item) => {
      memo[item.dataset.id || item.id] = item
      return memo
    }, {})

    orderedIds.forEach((id) => {
      const item = itemMap[id]
      if (item) parent.appendChild(item)
    })
  }

  get csrfToken() {
    return document.querySelector("meta[name='csrf-token']")?.content || ""
  }
}
