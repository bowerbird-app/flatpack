# frozen_string_literal: true

module Demo
  class ChatSimulationFallback
    def self.call(chat_group_id, outgoing_item_id, outgoing_item_ids = nil)
      Thread.new(chat_group_id, outgoing_item_id, outgoing_item_ids) do |group_id, item_id, item_ids|
        Rails.logger.info("[chat-demo] fallback simulation started group=#{group_id} item=#{item_id}")

        ActiveRecord::Base.connection_pool.with_connection do
          normalized_ids = Array(item_ids).presence || [item_id]

          sleep 5
          normalized_ids.each do |normalized_id|
            Demo::ChatReadReceiptWorker.new.perform(normalized_id)
          end
          Demo::ChatTypingIndicatorWorker.new.perform(group_id, item_id, true)

          sleep 5
          Demo::ChatAutoReplyWorker.new.perform(group_id, item_id)
        end

        Rails.logger.info("[chat-demo] fallback simulation completed group=#{group_id} item=#{item_id}")
      rescue => error
        Rails.logger.warn("[chat-demo] fallback simulation failed: #{error.class}: #{error.message}")
      end
    end
  end
end
