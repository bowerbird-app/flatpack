# frozen_string_literal: true

module Demo
  class ChatAutoReplyWorker < ActiveJob::Base
    include ActionView::RecordIdentifier

    queue_as :default

    def perform(chat_group_id, outgoing_message_id)
      chat_group = ChatGroup.find_by(id: chat_group_id)
      outgoing_message = ChatMessage.find_by(id: outgoing_message_id)
      return unless chat_group && outgoing_message

      reply = chat_group.chat_messages.create!(
        sender_name: "Sam",
        body: reply_body_for(outgoing_message.body),
        state: "sent"
      )

      Turbo::StreamsChannel.broadcast_append_to(
        chat_group.demo_stream_name,
        target: dom_id(chat_group, :messages),
        renderable: FlatPack::Chat::MessageRecord::Component.new(record: reply, reveal_actions: true)
      )

      Turbo::StreamsChannel.broadcast_update_to(
        chat_group.demo_stream_name,
        target: dom_id(chat_group, :typing_indicator),
        partial: "demo/chat_messages/typing_indicator",
        locals: {
          visible: false,
          label: "Sam is typing",
          sender_name: "Sam Lee",
          initials: "SL"
        }
      )
    end

    private

    def reply_body_for(outgoing_body)
      return "Nice—got it. I will take a look and share an update shortly." if outgoing_body.blank?

      if outgoing_body.length < 60
        "Got it: #{outgoing_body}. I am on it now."
      else
        "Got it. I reviewed your message and will follow up with the next update shortly."
      end
    end
  end
end
