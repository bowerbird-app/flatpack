# frozen_string_literal: true

module Demo
  class ChatTypingIndicatorWorker < ActiveJob::Base
    include ActionView::RecordIdentifier

    queue_as :default

    def perform(chat_group_id, outgoing_message_id, visible)
      chat_group = ChatGroup.find_by(id: chat_group_id)
      outgoing_message = ChatMessage.find_by(id: outgoing_message_id)
      return unless chat_group
      return unless outgoing_message
      return if visible && reply_already_sent?(chat_group, outgoing_message)

      Turbo::StreamsChannel.broadcast_update_to(
        chat_group.demo_stream_name,
        target: dom_id(chat_group, :typing_indicator),
        partial: "demo/chat_messages/typing_indicator",
        locals: {
          visible: visible,
          label: "Sam is typing",
          sender_name: "Sam Lee",
          initials: "SL"
        }
      )
    end

    private

    def reply_already_sent?(chat_group, outgoing_message)
      chat_group.chat_messages
        .where(sender_name: "Sam")
        .where("created_at > ?", outgoing_message.created_at)
        .exists?
    end
  end
end
