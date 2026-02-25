// FlatPack Chat Scroll Stimulus Controller
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["messages", "jumpButtonContainer"]
  static values = {
    stickToBottom: { type: Boolean, default: true }
  }

  connect() {
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

    if (shouldShowButton) {
      this.jumpButtonContainerTarget.classList.remove("hidden")
    } else {
      this.jumpButtonContainerTarget.classList.add("hidden")
    }
  }

  // Called when new messages are added to the list
  newMessageAdded() {
    if (this.stickToBottomValue && this.#isNearBottom()) {
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

    this.messageObserver = new MutationObserver((mutations) => {
      const hasAddedNodes = mutations.some((mutation) => mutation.addedNodes.length > 0)
      if (!hasAddedNodes) {
        return
      }

      if (this.stickToBottomValue) {
        this.scrollToBottom()
      } else {
        this.checkScroll()
      }
    })

    this.messageObserver.observe(this.messagesTarget, {
      childList: true,
      subtree: true
    })
  }

  #stopObservingMessages() {
    if (!this.messageObserver) {
      return
    }

    this.messageObserver.disconnect()
    this.messageObserver = null
  }
}
