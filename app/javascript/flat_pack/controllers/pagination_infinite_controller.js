// FlatPack Pagination Infinite Scroll Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["trigger", "loading"]
  static values = {
    url: String,
    page: { type: Number, default: 1 },
    loadingDelay: { type: Number, default: 200 },
    loadingVariant: { type: String, default: "table" }
  }

  connect() {
    this.observer = null
    this.loadingTimer = null
    this.injectedSkeletons = []
    this.setupIntersectionObserver()
  }

  disconnect() {
    this.clearLoadingTimer()

    if (this.observer) {
      this.observer.disconnect()
    }
  }

  setupIntersectionObserver() {
    // Only setup observer if IntersectionObserver is supported
    if (!("IntersectionObserver" in window)) {
      return
    }

    this.observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting && !this.isLoading) {
            this.loadMore()
          }
        })
      },
      {
        rootMargin: "100px"
      }
    )

    if (this.hasTriggerTarget) {
      this.observer.observe(this.triggerTarget)
    }
  }

  async loadMore(event) {
    if (event) {
      event.preventDefault()
    }

    if (this.isLoading) {
      return
    }

    this.isLoading = true
    this.scheduleLoading()

    try {
      const response = await fetch(this.urlValue, {
        headers: {
          "Accept": "text/html",
          "X-Requested-With": "XMLHttpRequest"
        }
      })

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`)
      }

      const html = await response.text()
      this.appendContent(html)
    } catch (error) {
      console.error("Error loading more content:", error)
      this.showError()
    } finally {
      this.hideLoading()
      this.isLoading = false
    }
  }

  appendContent(html) {
    const temp = document.createElement("div")
    temp.innerHTML = html

    const currentContent = this.element.parentElement?.querySelector("[data-pagination-content]")
    const newContent = temp.querySelector("[data-pagination-content]")
    const newPagination = temp.querySelector("[data-controller='flat-pack--pagination-infinite']")

    if (newContent && currentContent) {
      const canAppendInsideCurrent = currentContent.tagName === newContent.tagName

      if (canAppendInsideCurrent) {
        currentContent.insertAdjacentHTML("beforeend", newContent.innerHTML)
      } else {
        this.element.parentElement.insertBefore(newContent, this.element)
      }
    }

    // Replace pagination or remove if no more pages
    if (newPagination) {
      this.element.replaceWith(newPagination)
    } else {
      this.element.remove()
    }
  }

  scheduleLoading() {
    this.clearLoadingTimer()

    const delay = this.loadingDelayValue >= 0 ? this.loadingDelayValue : 200
    this.loadingTimer = window.setTimeout(() => {
      this.showLoading()
    }, delay)
  }

  showLoading() {
    if (this.loadingVariantValue === "cards") {
      this.showCardGridLoading()
      return
    }

    if (this.hasTriggerTarget) {
      this.triggerTarget.hidden = true
    }
    if (this.hasLoadingTarget) {
      this.loadingTarget.hidden = false
    }
  }

  hideLoading() {
    this.clearLoadingTimer()

    if (this.loadingVariantValue === "cards") {
      this.hideCardGridLoading()
    }

    if (this.hasTriggerTarget) {
      this.triggerTarget.hidden = false
    }
    if (this.hasLoadingTarget) {
      this.loadingTarget.hidden = true
    }
  }

  showError() {
    // Simple error handling - could be enhanced
    if (this.hasTriggerTarget) {
      this.triggerTarget.textContent = "Error loading. Try again."
    }
  }

  clearLoadingTimer() {
    if (this.loadingTimer) {
      window.clearTimeout(this.loadingTimer)
      this.loadingTimer = null
    }
  }

  showCardGridLoading() {
    if (this.hasTriggerTarget) {
      this.triggerTarget.hidden = true
    }

    const currentContent = this.element.parentElement?.querySelector("[data-pagination-content]")
    if (!currentContent) {
      if (this.hasLoadingTarget) {
        this.loadingTarget.hidden = false
      }
      return
    }

    if (this.injectedSkeletons.length > 0) {
      return
    }

    const columns = this.gridColumnCount(currentContent)
    const itemCount = currentContent.children.length
    const remainder = itemCount % columns
    const placeholdersToAdd = remainder === 0 ? columns : (columns - remainder)

    for (let i = 0; i < placeholdersToAdd; i += 1) {
      const placeholder = document.createElement("div")
      placeholder.dataset.paginationLoadingCard = "true"
      placeholder.className = "border border-[var(--color-border)] rounded-lg p-4 space-y-3"
      placeholder.innerHTML = [
        '<div class="animate-pulse bg-[var(--color-muted)] w-full rounded-lg h-[120px]" aria-busy="true" aria-label="Loading..." role="status"></div>',
        '<div class="animate-pulse bg-[var(--color-muted)] h-8 rounded w-[60%]" aria-busy="true" aria-label="Loading..." role="status"></div>',
        '<div class="animate-pulse bg-[var(--color-muted)] h-4 rounded w-[90%]" aria-busy="true" aria-label="Loading..." role="status"></div>',
        '<div class="animate-pulse bg-[var(--color-muted)] h-4 rounded w-[75%]" aria-busy="true" aria-label="Loading..." role="status"></div>'
      ].join("")

      currentContent.appendChild(placeholder)
      this.injectedSkeletons.push(placeholder)
    }
  }

  hideCardGridLoading() {
    this.injectedSkeletons.forEach((placeholder) => {
      placeholder.remove()
    })
    this.injectedSkeletons = []

    if (this.hasLoadingTarget) {
      this.loadingTarget.hidden = true
    }
  }

  gridColumnCount(gridElement) {
    const computedColumns = window.getComputedStyle(gridElement).gridTemplateColumns

    if (!computedColumns) {
      return 1
    }

    const columns = computedColumns
      .trim()
      .split(/\s+/)
      .filter((column) => column.length > 0)

    return Math.max(columns.length, 1)
  }
}
