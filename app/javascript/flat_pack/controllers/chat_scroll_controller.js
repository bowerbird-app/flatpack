// FlatPack Chat Scroll Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["messages", "jumpButtonContainer"]
  static values = {
    stickToBottom: { type: Boolean, default: true }
  }

  connect() {
    this.wasNearBottom = false
    this.ignoreNextMutation = false
    this.isPrependingHistory = false
    this.prependResetTimer = null
    this.handlePaginationContentInserted = (event) => this.#onPaginationContentInserted(event)
    this.handleTurboStreamAppend = (event) => this.#onTurboStreamAppend(event)
    this.element.addEventListener("flat-pack:pagination:content-inserted", this.handlePaginationContentInserted)
    document.addEventListener("turbo:before-stream-render", this.handleTurboStreamAppend)

    // Initial scroll to bottom if stick_to_bottom is enabled
    if (this.stickToBottomValue) {
      this.scrollToBottom({ instant: true })
    }

    // Hide jump button initially
    if (this.hasJumpButtonContainerTarget) {
      this.jumpButtonContainerTarget.classList.add("hidden")
    }

    // Check scroll position on connect
    this.checkScroll()

    this.#startObservingMessages()
  }

  disconnect() {
    if (this.prependResetTimer) {
      window.clearTimeout(this.prependResetTimer)
      this.prependResetTimer = null
    }

    if (this.handlePaginationContentInserted) {
      this.element.removeEventListener("flat-pack:pagination:content-inserted", this.handlePaginationContentInserted)
      this.handlePaginationContentInserted = null
    }

    if (this.handleTurboStreamAppend) {
      document.removeEventListener("turbo:before-stream-render", this.handleTurboStreamAppend)
      this.handleTurboStreamAppend = null
    }

    this.#stopObservingMessages()
  }

  scrollToBottom({ instant = false } = {}) {
    if (this.hasMessagesTarget) {
      const messages = this.messagesTarget
      const hadSmoothScrolling = messages.classList.contains("scroll-smooth")

      if (instant && hadSmoothScrolling) {
        messages.classList.remove("scroll-smooth")
      }

      messages.scrollTop = messages.scrollHeight

      if (instant && hadSmoothScrolling) {
        requestAnimationFrame(() => {
          messages.classList.add("scroll-smooth")
        })
      }
    }
  }

  jump() {
    this.scrollToBottom()
    // Hide button after jumping
    if (this.hasJumpButtonContainerTarget) {
      this.jumpButtonContainerTarget.classList.add("hidden")
    }
  }

  checkScroll() {
    if (!this.hasMessagesTarget || !this.hasJumpButtonContainerTarget) {
      return
    }

    const messages = this.messagesTarget
    const scrollTop = messages.scrollTop
    const scrollHeight = messages.scrollHeight
    const clientHeight = messages.clientHeight

    // Show jump button if user has scrolled up more than 100px from bottom
    const distanceFromBottom = scrollHeight - scrollTop - clientHeight
    const shouldShowButton = distanceFromBottom > 100
    this.wasNearBottom = !shouldShowButton

    if (shouldShowButton) {
      this.jumpButtonContainerTarget.classList.remove("hidden")
    } else {
      this.jumpButtonContainerTarget.classList.add("hidden")
    }
  }

  // Called when new messages are added to the list
  newMessageAdded() {
    if (this.isPrependingHistory) {
      this.checkScroll()
      return
    }

    if (this.stickToBottomValue && this.wasNearBottom) {
      // Auto-scroll to bottom if we're already near the bottom
      this.scrollToBottom()
    } else {
      // Otherwise, show the jump button
      this.checkScroll()
    }
  }

  #isNearBottom() {
    if (!this.hasMessagesTarget) {
      return false
    }

    const messages = this.messagesTarget
    const scrollTop = messages.scrollTop
    const scrollHeight = messages.scrollHeight
    const clientHeight = messages.clientHeight
    const distanceFromBottom = scrollHeight - scrollTop - clientHeight

    return distanceFromBottom < 100
  }

  #startObservingMessages() {
    if (!this.hasMessagesTarget) {
      return
    }

    this.wasNearBottom = this.#isNearBottom()

    this.messageObserver = new MutationObserver((mutations) => {
      if (this.ignoreNextMutation) {
        this.ignoreNextMutation = false
        this.checkScroll()
        return
      }

      const hasAddedNodes = mutations.some((mutation) => mutation.addedNodes.length > 0)
      if (!hasAddedNodes) {
        return
      }

      this.checkScroll()
    })

    this.messageObserver.observe(this.messagesTarget, {
      childList: true,
      subtree: true
    })
  }

  #onPaginationContentInserted(event) {
    if (event?.detail?.insertMode !== "prepend") {
      return
    }

    this.isPrependingHistory = true
    this.ignoreNextMutation = true

    if (this.prependResetTimer) {
      window.clearTimeout(this.prependResetTimer)
    }

    this.prependResetTimer = window.setTimeout(() => {
      this.isPrependingHistory = false
      this.prependResetTimer = null
    }, 100)
  }

  #onTurboStreamAppend(event) {
    if (!this.hasMessagesTarget) {
      return
    }

    const streamElement = event.target
    if (!(streamElement instanceof Element)) {
      return
    }

    if (streamElement.getAttribute("action") !== "append") {
      return
    }

    const targetId = this.messagesTarget.getAttribute("id")
    if (!targetId) {
      return
    }

    if (streamElement.getAttribute("target") !== targetId) {
      return
    }

    this.newMessageAdded()
  }

  #stopObservingMessages() {
    if (!this.messageObserver) {
      return
    }

    this.messageObserver.disconnect()
    this.messageObserver = null
  }
}
