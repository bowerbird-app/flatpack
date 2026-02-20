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
      this.scrollToBottom()
    }

    // Hide jump button initially
    if (this.hasJumpButtonContainerTarget) {
      this.jumpButtonContainerTarget.classList.add("hidden")
    }

    // Check scroll position on connect
    this.checkScroll()
  }

  scrollToBottom() {
    if (this.hasMessagesTarget) {
      this.messagesTarget.scrollTop = this.messagesTarget.scrollHeight
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
}
