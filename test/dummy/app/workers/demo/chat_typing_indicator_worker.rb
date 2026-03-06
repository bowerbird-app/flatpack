# frozen_string_literal: true

module Demo
  class ChatTypingIndicatorWorker < ActiveJob::Base
    include ActionView::RecordIdentifier

    queue_as :default

    def perform(chat_group_id, outgoing_item_id, visible)
      chat_group = ChatGroup.find_by(id: chat_group_id)
      outgoing_item = ChatItem.find_by(id: outgoing_item_id)
      return unless chat_group
      return unless outgoing_item
      return if visible && reply_already_sent?(chat_group, outgoing_item)

      Turbo::StreamsChannel.broadcast_update_to(
        chat_group.demo_stream_name,
        target: dom_id(chat_group, :typing_indicator),
        partial: "demo/chat_messages/typing_indicator",
        locals: {
          visible: visible,
          label: "Sam is typing",
          sender_name: "Sam Lee"
        }
      )
    end

    private

    def reply_already_sent?(chat_group, outgoing_item)
      chat_group.chat_items
        .where(sender_name: "Sam")
        .where("created_at > ?", outgoing_item.created_at)
        .exists?
    end
  end
end
