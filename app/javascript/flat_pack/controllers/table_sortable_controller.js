// FlatPack Table Sortable Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["row", "handle"]
  static values = {
    reorderUrl: String,
    resource: String,
    strategy: String,
    scope: Object,
    version: String
  }

  connect() {
    this.draggedRow = null
    this.dragOverRow = null
    this.pendingSave = false
    this.lastStableOrder = this.currentOrder()
    this.setupDraggableRows()
  }

  disconnect() {
    this.removeDragListeners()
  }

  setupDraggableRows() {
    this.rowTargets.forEach((row) => {
      row.setAttribute("draggable", "true")
      
      // Add drag event listeners
      row.addEventListener("dragstart", this.handleDragStart.bind(this))
      row.addEventListener("dragend", this.handleDragEnd.bind(this))
      row.addEventListener("dragover", this.handleDragOver.bind(this))
      row.addEventListener("drop", this.handleDrop.bind(this))
      row.addEventListener("dragenter", this.handleDragEnter.bind(this))
      row.addEventListener("dragleave", this.handleDragLeave.bind(this))
    })
  }

  removeDragListeners() {
    this.rowTargets.forEach((row) => {
      row.removeAttribute("draggable")
    })
  }

  handleDragStart(event) {
    this.draggedRow = event.currentTarget
    this.draggedRow.style.opacity = "0.5"
    
    // Set drag data
    event.dataTransfer.effectAllowed = "move"
    event.dataTransfer.setData("text/html", this.draggedRow.innerHTML)
  }

  handleDragEnd(event) {
    if (this.draggedRow) {
      this.draggedRow.style.opacity = "1"
    }
    
    // Remove all drag-over indicators
    this.rowTargets.forEach((row) => {
      row.classList.remove("border-t-2", "border-[var(--color-primary)]")
    })
    
    this.draggedRow = null
    this.dragOverRow = null
  }

  handleDragOver(event) {
    if (event.preventDefault) {
      event.preventDefault()
    }
    
    event.dataTransfer.dropEffect = "move"
    return false
  }

  handleDragEnter(event) {
    const row = event.currentTarget
    
    if (row !== this.draggedRow) {
      this.dragOverRow = row
      row.classList.add("border-t-2", "border-[var(--color-primary)]")
    }
  }

  handleDragLeave(event) {
    const row = event.currentTarget
    row.classList.remove("border-t-2", "border-[var(--color-primary)]")
  }

  handleDrop(event) {
    if (event.stopPropagation) {
      event.stopPropagation()
    }
    
    if (this.draggedRow !== this.dragOverRow && this.dragOverRow) {
      // Reorder rows
      const parent = this.draggedRow.parentNode
      const draggedIndex = Array.from(parent.children).indexOf(this.draggedRow)
      const dropIndex = Array.from(parent.children).indexOf(this.dragOverRow)
      
      if (draggedIndex < dropIndex) {
        parent.insertBefore(this.draggedRow, this.dragOverRow.nextSibling)
      } else {
        parent.insertBefore(this.draggedRow, this.dragOverRow)
      }
      
      // Emit reorder event
      this.emitReorderEvent()
      this.saveOrder()
    }
    
    return false
  }

  // Keyboard fallback - move row up
  moveUp(event) {
    const row = event.currentTarget.closest("tr")
    if (!row) return
    
    const previousRow = row.previousElementSibling
    if (previousRow && previousRow.tagName === "TR") {
      row.parentNode.insertBefore(row, previousRow)
      this.emitReorderEvent()
      
      // Focus back on the button
      event.currentTarget.focus()
    }
  }

  // Keyboard fallback - move row down
  moveDown(event) {
    const row = event.currentTarget.closest("tr")
    if (!row) return
    
    const nextRow = row.nextElementSibling
    if (nextRow && nextRow.tagName === "TR") {
      row.parentNode.insertBefore(nextRow, row)
      this.emitReorderEvent()
      
      // Focus back on the button
      event.currentTarget.focus()
    }
  }

  emitReorderEvent() {
    // Collect row IDs in new order
    const orderedIds = this.currentOrder()

    if (orderedIds.length === 0) return

    this.lastStableOrder = orderedIds

    const orderedItems = orderedIds.map((id, index) => ({
      id: Number(id),
      position: index + 1
    }))

    // Dispatch custom event with ordered IDs
    const event = new CustomEvent("table:reordered", {
      detail: { orderedIds: orderedIds, items: orderedItems },
      bubbles: true
    })
    
    this.element.dispatchEvent(event)
  }

  currentOrder() {
    return this.rowTargets.map(row => {
      return row.dataset.id || row.id
    }).filter(Boolean)
  }

  async saveOrder() {
    if (!this.hasReorderUrlValue || this.pendingSave) return

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
        this.restoreOrder(this.lastStableOrder)
        this.dispatch("error", { detail: payload })
        return
      }

      this.versionValue = payload.version
      this.lastStableOrder = this.currentOrder()
      this.dispatch("saved", { detail: payload })
    } catch (_error) {
      this.restoreOrder(this.lastStableOrder)
      this.dispatch("error", { detail: { error: "Unable to save row order" } })
    } finally {
      this.pendingSave = false
    }
  }

  restoreOrder(orderedIds) {
    if (!orderedIds || orderedIds.length === 0) return

    const tbody = this.rowTargets[0]?.parentNode
    if (!tbody) return

    const rowMap = this.rowTargets.reduce((memo, row) => {
      memo[row.dataset.id || row.id] = row
      return memo
    }, {})

    orderedIds.forEach((id) => {
      const row = rowMap[id]
      if (row) tbody.appendChild(row)
    })
  }

  get csrfToken() {
    return document.querySelector("meta[name='csrf-token']")?.content || ""
  }
}
