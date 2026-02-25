# frozen_string_literal: true

require "test_helper"

class DemoChatMessagesTest < ActionDispatch::IntegrationTest
  setup do
    @chat_group = ChatGroup.create!(name: "Request Test Group")
  end

  test "creates a chat message and returns confirmation payload" do
    post demo_chat_group_messages_path(@chat_group), params: {
      message: {
        body: "Hello from integration test",
        clientTempId: "tmp-123",
        submittedAt: Time.current.iso8601
      }
    }, as: :json

    assert_response :created

    payload = JSON.parse(response.body)
    assert_equal "sent", payload["state"]
    assert_includes payload["html"], "Hello from integration test"

    persisted = @chat_group.chat_messages.order(:id).last
    assert_equal "Hello from integration test", persisted.body
    assert_equal "You", persisted.sender_name
    assert_equal "tmp-123", persisted.client_temp_id
    assert_equal "sent", persisted.state
  end

  test "returns unprocessable entity for blank body" do
    post demo_chat_group_messages_path(@chat_group), params: {
      message: {
        body: "   "
      }
    }, as: :json

    assert_response :unprocessable_entity

    payload = JSON.parse(response.body)
    assert_match(/Body can't be blank/i, payload["error"])
  end
end
