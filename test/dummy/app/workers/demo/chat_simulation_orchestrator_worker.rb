# frozen_string_literal: true

module Demo
  class ChatSimulationOrchestratorWorker < ActiveJob::Base
    queue_as :default

    def perform(chat_group_id, outgoing_message_id)
      return unless ChatGroup.exists?(chat_group_id)
      return unless ChatMessage.exists?(outgoing_message_id)

      ChatReadReceiptWorker.set(wait: 5.seconds).perform_later(outgoing_message_id)
      ChatTypingIndicatorWorker.set(wait: 2.seconds).perform_later(chat_group_id, outgoing_message_id, true)
      ChatAutoReplyWorker.set(wait: 10.seconds).perform_later(chat_group_id, outgoing_message_id)
    end
  end
end
