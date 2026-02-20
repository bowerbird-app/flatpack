// FlatPack Pagination Infinite Scroll Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["trigger", "loading"]
  static values = {
    url: String,
    page: { type: Number, default: 1 }
  }

  connect() {
    this.observer = null
    this.setupIntersectionObserver()
  }

  disconnect() {
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
    this.showLoading()

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
      this.hideLoading()
      this.showError()
    } finally {
      this.isLoading = false
    }
  }

  appendContent(html) {
    // Insert new content before the pagination container
    const temp = document.createElement("div")
    temp.innerHTML = html
    
    const newContent = temp.querySelector("[data-pagination-content]")
    const newPagination = temp.querySelector("[data-controller='flat-pack--pagination-infinite']")

    if (newContent) {
      this.element.parentElement.insertBefore(newContent, this.element)
    }

    // Replace pagination or remove if no more pages
    if (newPagination) {
      this.element.replaceWith(newPagination)
    } else {
      this.element.remove()
    }
  }

  showLoading() {
    if (this.hasTriggerTarget) {
      this.triggerTarget.hidden = true
    }
    if (this.hasLoadingTarget) {
      this.loadingTarget.hidden = false
    }
  }

  hideLoading() {
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
}
