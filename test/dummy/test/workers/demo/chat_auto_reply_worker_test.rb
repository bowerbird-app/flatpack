# frozen_string_literal: true

require "test_helper"

class DemoChatAutoReplyWorkerTest < ActiveJob::TestCase
  setup do
    @chat_group = ChatGroup.create!(name: "Auto Reply Group")
  end

  test "appends incoming reply without action buttons" do
    outgoing_item = @chat_group.chat_items.create!(
      sender_name: "You",
      body: "Please check this",
      state: "sent"
    )

    append_calls = []
    update_calls = []
    channel_singleton = Turbo::StreamsChannel.singleton_class
    original_broadcast_append_to = Turbo::StreamsChannel.method(:broadcast_append_to)
    original_broadcast_update_to = Turbo::StreamsChannel.method(:broadcast_update_to)

    begin
      channel_singleton.define_method(:broadcast_append_to) do |*args, **kwargs|
        append_calls << [args, kwargs]
      end

      channel_singleton.define_method(:broadcast_update_to) do |*args, **kwargs|
        update_calls << [args, kwargs]
      end

      Demo::ChatAutoReplyWorker.new.perform(@chat_group.id, outgoing_item.id)
    ensure
      channel_singleton.define_method(:broadcast_append_to, original_broadcast_append_to)
      channel_singleton.define_method(:broadcast_update_to, original_broadcast_update_to)
    end

    assert_equal 1, append_calls.size
    assert_equal 1, update_calls.size

    _, kwargs = append_calls.first
    assert_includes kwargs[:html], "Sam Lee"
    assert_includes kwargs[:html], "Got it: Please check this. I am on it now."
    assert_includes kwargs[:html], 'data-flat-pack-chat-record-direction="incoming"'
    assert_includes kwargs[:html], 'data-controller="flat-pack--chat-message-actions"'
    refute_includes kwargs[:html], "Edit"
    refute_includes kwargs[:html], "Delete"
  end
end