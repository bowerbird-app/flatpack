# frozen_string_literal: true

module Demo
  class ChatSimulationFallback
    def self.call(chat_group_id, outgoing_item_id)
      Thread.new(chat_group_id, outgoing_item_id) do |group_id, item_id|
        begin
          Rails.logger.info("[chat-demo] fallback simulation started group=#{group_id} item=#{item_id}")

          ActiveRecord::Base.connection_pool.with_connection do
            sleep 5
            Demo::ChatReadReceiptWorker.new.perform(item_id)
            Demo::ChatTypingIndicatorWorker.new.perform(group_id, item_id, true)

            sleep 5
            Demo::ChatAutoReplyWorker.new.perform(group_id, item_id)
          end

          Rails.logger.info("[chat-demo] fallback simulation completed group=#{group_id} item=#{item_id}")
        rescue StandardError => error
          Rails.logger.warn("[chat-demo] fallback simulation failed: #{error.class}: #{error.message}")
        end
      end
    end
  end
end
