# frozen_string_literal: true

require "test_helper"

class DemoChatReadReceiptWorkerTest < ActiveJob::TestCase
  setup do
    @chat_group = ChatGroup.create!(name: "Read Receipt Group")
  end

  test "replaces outgoing item with reveal-actions enabled" do
    item = @chat_group.chat_items.create!(
      sender_name: "You",
      body: "Need review by EOD",
      state: "sent"
    )

    broadcast_calls = []

    Turbo::StreamsChannel.stub(:broadcast_replace_to, ->(*args, **kwargs) { broadcast_calls << [args, kwargs] }) do
      Demo::ChatReadReceiptWorker.new.perform(item.id)
    end

    item.reload

    assert_equal "read", item.state
    assert_equal 1, broadcast_calls.size

    _, kwargs = broadcast_calls.first
    assert_includes kwargs[:html], 'data-controller="chat-message-actions"'
    assert_includes kwargs[:html], "Edit"
    assert_includes kwargs[:html], "Delete"
  end

  test "does not enable reveal actions for incoming item" do
    item = @chat_group.chat_items.create!(
      sender_name: "Sam Lee",
      body: "Looks good",
      state: "sent"
    )

    broadcast_calls = []

    Turbo::StreamsChannel.stub(:broadcast_replace_to, ->(*args, **kwargs) { broadcast_calls << [args, kwargs] }) do
      Demo::ChatReadReceiptWorker.new.perform(item.id)
    end

    item.reload

    assert_equal "read", item.state
    assert_equal 1, broadcast_calls.size

    _, kwargs = broadcast_calls.first
    refute_includes kwargs[:html], 'data-controller="chat-message-actions"'
  end
end
