# frozen_string_literal: true

require "test_helper"

class DemoChatMessagesTest < ActionDispatch::IntegrationTest
  setup do
    @chat_group = ChatGroup.create!(name: "Request Test Group")

    12.times do |index|
      @chat_group.chat_items.create!(
        sender_name: "Teammate",
        body: "History message #{index + 1}",
        state: "sent",
        created_at: (12 - index).minutes.ago,
        updated_at: (12 - index).minutes.ago
      )
    end
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

    persisted = @chat_group.chat_items.order(:id).last
    assert_equal "Hello from integration test", persisted.body
    assert_equal "You", persisted.sender_name
    assert_equal "tmp-123", persisted.client_temp_id
    assert_equal "sent", persisted.state
  end

  test "creates a chat item with attachments and no body" do
    post demo_chat_group_messages_path(@chat_group), params: {
      message: {
        body: "   ",
        attachments: [
          {
            kind: "image",
            name: "hero-1.png",
            contentType: "image/png",
            byteSize: 235_120
          },
          {
            kind: "file",
            name: "release-checklist.pdf",
            contentType: "application/pdf",
            byteSize: 98_100
          }
        ]
      }
    }, as: :json

    assert_response :created

    persisted = @chat_group.chat_items.order(:id).last
    assert_nil persisted.body
    assert_equal "attachment", persisted.item_type
    assert_equal 2, persisted.chat_item_attachments.size
    assert_equal %w[image file], persisted.chat_item_attachments.order(:position).pluck(:kind)
  end

  test "returns unprocessable entity for blank body and no attachments" do
    post demo_chat_group_messages_path(@chat_group), params: {
      message: {
        body: "   "
      }
    }, as: :json

    assert_response :unprocessable_entity

    payload = JSON.parse(response.body)
    assert_match(/blank/i, payload["error"])
  end

  test "returns chat history partial for infinite scroll" do
    cursor_id = @chat_group.chat_items.order(:id).offset(9).first.id

    get demo_chat_group_messages_path(@chat_group), params: {
      before_id: cursor_id,
      limit: 4
    }

    assert_response :success
    assert_includes response.body, "data-pagination-content"
    assert_includes response.body, "flat-pack--pagination-infinite"
    assert_includes response.body, "data-flat-pack--pagination-infinite-insert-mode-value=\"prepend\""
    assert_includes response.body, "History message 6"
    assert_includes response.body, "History message 9"
  end

  test "renders start-of-chat-group system message on terminal history batch" do
    cursor_id = @chat_group.chat_items.order(:id).offset(2).first.id

    get demo_chat_group_messages_path(@chat_group), params: {
      before_id: cursor_id,
      limit: 4
    }

    assert_response :success
    assert_includes response.body, "You have reached the start of this chat group."
    refute_includes response.body, "flat-pack--pagination-infinite"
  end
end
