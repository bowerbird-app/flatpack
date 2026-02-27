# frozen_string_literal: true

module Demo
  class ChatSimulationOrchestratorWorker < ActiveJob::Base
    queue_as :default

    def perform(chat_group_id, outgoing_item_id, outgoing_item_ids = nil)
      return unless ChatGroup.exists?(chat_group_id)

      item_ids = normalize_item_ids(outgoing_item_id, outgoing_item_ids)
      return if item_ids.empty?

      anchor_item_id = item_ids.include?(outgoing_item_id.to_i) ? outgoing_item_id.to_i : item_ids.last

      item_ids.each do |item_id|
        ChatReadReceiptWorker.set(wait: 5.seconds).perform_later(item_id)
      end

      ChatTypingIndicatorWorker.set(wait: 2.seconds).perform_later(chat_group_id, anchor_item_id, true)
      ChatAutoReplyWorker.set(wait: 10.seconds).perform_later(chat_group_id, anchor_item_id)
    end

    private

    def normalize_item_ids(primary_id, candidate_ids)
      ids = Array(candidate_ids).presence || [primary_id]

      ids
        .map { |id| parse_item_id(id) }
        .compact
        .uniq
        .select { |id| ChatItem.exists?(id) }
    end

    def parse_item_id(value)
      return value if value.is_a?(Integer)

      Integer(value, 10)
    rescue ArgumentError, TypeError
      nil
    end
  end
end
