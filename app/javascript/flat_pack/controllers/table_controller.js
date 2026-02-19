// FlatPack Table Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["row", "selectAll", "checkbox"]

  // Select all rows
  toggleAll(event) {
    const checked = event.target.checked
    this.checkboxTargets.forEach(checkbox => {
      checkbox.checked = checked
    })
    this.updateSelectAllState()
  }

  // Update select all checkbox state
  updateSelectAllState() {
    if (!this.hasSelectAllTarget) return

    const checkedCount = this.checkboxTargets.filter(cb => cb.checked).length
    const totalCount = this.checkboxTargets.length

    if (checkedCount === 0) {
      this.selectAllTarget.checked = false
      this.selectAllTarget.indeterminate = false
    } else if (checkedCount === totalCount) {
      this.selectAllTarget.checked = true
      this.selectAllTarget.indeterminate = false
    } else {
      this.selectAllTarget.checked = false
      this.selectAllTarget.indeterminate = true
    }
  }

  // Toggle individual row selection
  toggle(event) {
    this.updateSelectAllState()
  }

  // Get selected row IDs
  getSelectedIds() {
    return this.checkboxTargets
      .filter(cb => cb.checked)
      .map(cb => cb.value)
  }

  // Highlight row on hover (optional enhancement)
  highlightRow(event) {
    event.currentTarget.classList.add("bg-[var(--color-muted)]")
  }

  unhighlightRow(event) {
    event.currentTarget.classList.remove("bg-[var(--color-muted)]")
  }

  // Clear row with animation
  clearRow(event) {
    const row = event.currentTarget.closest("tr")
    if (!row) return

    // Check for prefers-reduced-motion
    const prefersReducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches

    if (prefersReducedMotion) {
      // Skip animation
      row.style.display = "none"
    } else {
      // Get current height
      const height = row.offsetHeight
      
      // Set explicit height for animation
      row.style.height = `${height}px`
      row.style.overflow = "hidden"
      row.style.transition = "height 0.3s ease-out, opacity 0.3s ease-out"
      
      // Trigger reflow
      row.offsetHeight
      
      // Animate out
      requestAnimationFrame(() => {
        row.style.height = "0"
        row.style.opacity = "0"
      })
      
      // Hide after animation
      setTimeout(() => {
        row.style.display = "none"
      }, 300)
    }
  }
}
