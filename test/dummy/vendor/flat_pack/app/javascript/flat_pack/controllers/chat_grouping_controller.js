import { Controller } from "@hotwired/stimulus"

const GROUP_BREAK_SELECTOR = "[data-flat-pack-chat-group-break]"
const RECORD_SELECTOR = "[data-flat-pack-chat-record]"
const AVATAR_SELECTOR = "[data-flat-pack-chat-group-avatar]"
const NAME_SELECTOR = "[data-flat-pack-chat-group-name]"

export default class extends Controller {
  connect() {
    this.refreshFrame = null
    this.mutationObserver = new MutationObserver((mutations) => {
      const hasChildListChange = mutations.some((mutation) => mutation.type === "childList")
      if (hasChildListChange) {
        this.scheduleRefresh()
      }
    })

    this.mutationObserver.observe(this.element, {
      childList: true,
      subtree: true
    })

    this.refresh()
  }

  disconnect() {
    if (this.refreshFrame) {
      window.cancelAnimationFrame(this.refreshFrame)
      this.refreshFrame = null
    }

    if (this.mutationObserver) {
      this.mutationObserver.disconnect()
      this.mutationObserver = null
    }
  }

  refresh() {
    let previousRecord = null

    this.orderedNodes.forEach((node) => {
      if (node.matches(GROUP_BREAK_SELECTOR)) {
        previousRecord = null
        return
      }

      const groupedWithPrevious = this.sameSenderGroup(previousRecord, node)
      this.applyGrouping(node, groupedWithPrevious)
      previousRecord = node
    })
  }

  scheduleRefresh() {
    if (this.refreshFrame) {
      return
    }

    this.refreshFrame = window.requestAnimationFrame(() => {
      this.refreshFrame = null
      this.refresh()
    })
  }

  get orderedNodes() {
    const walker = document.createTreeWalker(
      this.element,
      NodeFilter.SHOW_ELEMENT,
      {
        acceptNode: (node) => {
          if (!(node instanceof Element)) {
            return NodeFilter.FILTER_SKIP
          }

          if (node.matches(RECORD_SELECTOR) || node.matches(GROUP_BREAK_SELECTOR)) {
            return NodeFilter.FILTER_ACCEPT
          }

          return NodeFilter.FILTER_SKIP
        }
      }
    )

    const nodes = []
    let current = walker.nextNode()

    while (current) {
      nodes.push(current)
      current = walker.nextNode()
    }

    return nodes
  }

  sameSenderGroup(previousRecord, currentRecord) {
    if (!previousRecord || !currentRecord) {
      return false
    }

    return previousRecord.dataset.flatPackChatRecordSender === currentRecord.dataset.flatPackChatRecordSender &&
      previousRecord.dataset.flatPackChatRecordDirection === currentRecord.dataset.flatPackChatRecordDirection
  }

  applyGrouping(record, groupedWithPrevious) {
    record.dataset.flatPackChatGroupedWithPrevious = groupedWithPrevious ? "true" : "false"

    record.classList.remove("mt-0", "mt-1", "mt-4")
    record.classList.add(groupedWithPrevious ? "mt-1" : "mt-4")

    const avatar = record.querySelector(AVATAR_SELECTOR)
    if (avatar) {
      avatar.classList.toggle("invisible", groupedWithPrevious)
      if (groupedWithPrevious) {
        avatar.setAttribute("aria-hidden", "true")
      } else {
        avatar.removeAttribute("aria-hidden")
      }
    }

    const senderName = record.querySelector(NAME_SELECTOR)
    if (senderName) {
      senderName.classList.toggle("hidden", groupedWithPrevious)
    }
  }
}