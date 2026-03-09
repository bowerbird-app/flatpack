# frozen_string_literal: true

module Demo
  class ChatReadReceiptWorker < ActiveJob::Base
    include ActionView::RecordIdentifier

    queue_as :default

    def perform(chat_item_id)
      item = ChatItem.includes(:chat_group, :chat_item_attachments).find_by(id: chat_item_id)
      return unless item

      item.update!(state: "read") unless item.state == "read"

      item_html = ApplicationController.render(
        partial: "demo/chat_messages/message",
        locals: {
          record: item,
          reveal_actions: item.outgoing?
        },
        layout: false
      )

      Turbo::StreamsChannel.broadcast_replace_to(
        item.chat_group.demo_stream_name,
        target: dom_id(item),
        html: item_html
      )
    end
  end
end
