# frozen_string_literal: true

module Demo
  class ChatReadReceiptWorker < ActiveJob::Base
    include ActionView::RecordIdentifier

    queue_as :default

    def perform(chat_message_id)
      message = ChatMessage.includes(:chat_group).find_by(id: chat_message_id)
      return unless message

      message.update!(state: "read") unless message.state == "read"

      Turbo::StreamsChannel.broadcast_replace_to(
        message.chat_group.demo_stream_name,
        target: dom_id(message),
        partial: "demo/chat_messages/message",
        locals: {message: message}
      )
    end
  end
end
