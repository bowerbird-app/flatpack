# frozen_string_literal: true

module Demo
  class ChatSimulationOrchestratorWorker < ActiveJob::Base
    queue_as :default

    def perform(chat_group_id, outgoing_item_id)
      return unless ChatGroup.exists?(chat_group_id)
      return unless ChatItem.exists?(outgoing_item_id)

      ChatReadReceiptWorker.set(wait: 5.seconds).perform_later(outgoing_item_id)
      ChatTypingIndicatorWorker.set(wait: 2.seconds).perform_later(chat_group_id, outgoing_item_id, true)
      ChatAutoReplyWorker.set(wait: 10.seconds).perform_later(chat_group_id, outgoing_item_id)
    end
  end
end
