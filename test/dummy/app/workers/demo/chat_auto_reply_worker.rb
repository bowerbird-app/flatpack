# frozen_string_literal: true

module Demo
  class ChatAutoReplyWorker < ActiveJob::Base
    include ActionView::RecordIdentifier

    queue_as :default

    def perform(chat_group_id, outgoing_item_id)
      chat_group = ChatGroup.find_by(id: chat_group_id)
      outgoing_item = ChatItem.find_by(id: outgoing_item_id)
      return unless chat_group && outgoing_item

      reply = chat_group.chat_items.create!(
        sender_name: "Sam Lee",
        body: reply_body_for(outgoing_item.body),
        state: "sent"
      )

      reply_html = ApplicationController.render(
        partial: "demo/chat_messages/message",
        locals: {
          record: reply,
          reveal_actions: true
        },
        layout: false
      )

      Turbo::StreamsChannel.broadcast_append_to(
        chat_group.demo_stream_name,
        target: dom_id(chat_group, :messages),
        html: reply_html
      )

      Turbo::StreamsChannel.broadcast_update_to(
        chat_group.demo_stream_name,
        target: dom_id(chat_group, :typing_indicator),
        partial: "demo/chat_messages/typing_indicator",
        locals: {
          visible: false,
          label: "Sam Lee is typing",
          sender_name: "Sam Lee"
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
