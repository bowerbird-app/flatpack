# frozen_string_literal: true

require "test_helper"

class DemoChatSimulationOrchestratorWorkerTest < ActiveJob::TestCase
  setup do
    @chat_group = ChatGroup.create!(name: "Worker Test Group")
    @chat_item = @chat_group.chat_items.create!(
      sender_name: "You",
      body: "Ping",
      state: "sent"
    )
  end

  test "enqueues read receipt, typing indicator, and auto reply for integer ids" do
    clear_enqueued_jobs

    Demo::ChatSimulationOrchestratorWorker.new.perform(
      @chat_group.id,
      @chat_item.id,
      [@chat_item.id]
    )

    jobs = enqueued_jobs.map { |job| job[:job] }

    assert_includes jobs, Demo::ChatReadReceiptWorker
    assert_includes jobs, Demo::ChatTypingIndicatorWorker
    assert_includes jobs, Demo::ChatAutoReplyWorker
    assert_equal 3, jobs.size
  end
end
