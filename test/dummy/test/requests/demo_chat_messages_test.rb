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
    assert_includes payload["html"], 'data-flat-pack-chat-record-direction="outgoing"'
    assert_includes payload["html"], 'data-flat-pack-chat-record-sender="You"'
    assert_not_includes payload["html"], "flat-pack--chat-message-actions"

    persisted = @chat_group.chat_items.order(:id).last
    assert_equal "Hello from integration test", persisted.body
    assert_equal "You", persisted.sender_name
    assert_equal "tmp-123", persisted.client_temp_id
    assert_equal "sent", persisted.state
  end

  test "creates separate chat items for each attachment when body is blank" do
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

    persisted = @chat_group.chat_items.order(:id).last(2)
    assert_equal 2, persisted.size

    first_item = persisted.first
    second_item = persisted.second

    assert_nil first_item.body
    assert_nil second_item.body
    assert_equal "attachment", first_item.item_type
    assert_equal "attachment", second_item.item_type
    assert_equal 1, first_item.attachments_count
    assert_equal 1, second_item.attachments_count
    assert_equal %w[image file], persisted.map { |item| item.chat_item_attachments.first.kind }

    first_attachment = first_item.chat_item_attachments.first
    assert_equal({}, first_attachment.metadata)
    assert_nil first_attachment.storage_key
    assert_nil first_attachment.checksum
  end

  test "creates separate text and attachment chat items for mixed payloads" do
    post demo_chat_group_messages_path(@chat_group), params: {
      message: {
        body: "Please review these assets",
        attachments: [
          {
            kind: "image",
            name: "hero-1.png",
            contentType: "image/png",
            byteSize: 235_120
          }
        ]
      }
    }, as: :json

    assert_response :created

    persisted = @chat_group.chat_items.order(:id).last(2)
    text_item = persisted.find { |item| item.body.present? }
    attachment_item = persisted.find { |item| item.chat_item_attachments.any? }

    assert_equal "Please review these assets", text_item.body
    assert_equal "text", text_item.item_type
    assert_equal 0, text_item.attachments_count

    assert_nil attachment_item.body
    assert_equal "attachment", attachment_item.item_type
    assert_equal 1, attachment_item.attachments_count
    assert_equal "hero-1.png", attachment_item.chat_item_attachments.first.name
  end

  test "creates a single mixed chat item when composition mode is combined" do
    post demo_chat_group_messages_path(@chat_group), params: {
      message: {
        body: "Please review these assets",
        compositionMode: "combined",
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
    assert_equal "Please review these assets", persisted.body
    assert_equal "mixed", persisted.item_type
    assert_equal 2, persisted.attachments_count
    assert_equal %w[image file], persisted.chat_item_attachments.order(:position).pluck(:kind)
  end

  test "keeps default separate mode when composition mode is invalid" do
    post demo_chat_group_messages_path(@chat_group), params: {
      message: {
        body: "Please review",
        compositionMode: "unexpected",
        attachments: [
          {
            kind: "image",
            name: "hero-1.png",
            contentType: "image/png",
            byteSize: 235_120
          }
        ]
      }
    }, as: :json

    assert_response :created

    persisted = @chat_group.chat_items.order(:id).last(2)
    assert_equal 2, persisted.size
    assert_equal ["attachment", "text"], persisted.map(&:item_type).sort
  end

  test "persists and renders image thumbnail url from picker payload" do
    thumbnail_url = "https://images.unsplash.com/photo-1518773553398-650c184e0bb3?w=640&h=360&fit=crop"

    post demo_chat_group_messages_path(@chat_group), params: {
      message: {
        body: "",
        attachments: [
          {
            kind: "image",
            name: "checkout-mobile-a.png",
            contentType: "image/png",
            byteSize: 198_250,
            thumbnailUrl: thumbnail_url
          }
        ]
      }
    }, as: :json

    assert_response :created

    payload = JSON.parse(response.body)
    assert_includes payload["html"], "photo-1518773553398-650c184e0bb3"

    persisted = @chat_group.chat_items.order(:id).last
    attachment = persisted.chat_item_attachments.order(:position).first
    assert_equal thumbnail_url, attachment.metadata["thumbnail_url"]
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

  test "returns server-rendered optimistic preview without persisting" do
    original_count = @chat_group.chat_items.count

    post preview_demo_chat_group_messages_path(@chat_group), params: {
      message: {
        body: "Preview only",
        clientTempId: "tmp-preview"
      }
    }, as: :json

    assert_response :success

    payload = JSON.parse(response.body)
    assert_includes payload["html"], "Preview only"
    assert_includes payload["html"], "Sending"
    assert_includes payload["html"], 'data-flat-pack-chat-record-direction="outgoing"'
    assert_not_includes payload["html"], "flat-pack--chat-message-actions"
    assert_equal original_count, @chat_group.chat_items.count
  end

  test "preview returns unprocessable entity for blank payload" do
    post preview_demo_chat_group_messages_path(@chat_group), params: {
      message: {
        body: "   ",
        attachments: []
      }
    }, as: :json

    assert_response :unprocessable_entity
    payload = JSON.parse(response.body)
    assert_match(/blank/i, payload["error"])
  end

  test "falls back to in-process simulation when enqueue fails in development" do
    fallback_calls = []

    fallback_singleton = Demo::ChatSimulationFallback.singleton_class
    worker_singleton = Demo::ChatSimulationOrchestratorWorker.singleton_class
    rails_singleton = Rails.singleton_class
    original_fallback_call = Demo::ChatSimulationFallback.method(:call)
    original_perform_later = Demo::ChatSimulationOrchestratorWorker.method(:perform_later)
    original_env = Rails.method(:env)

    begin
      fallback_singleton.define_method(:call) do |*args|
        fallback_calls << args
      end

      worker_singleton.define_method(:perform_later) do |*|
        raise "queue unavailable"
      end

      rails_singleton.define_method(:env) do
        ActiveSupport::StringInquirer.new("development")
      end

      post demo_chat_group_messages_path(@chat_group), params: {
        message: {
          body: "Trigger fallback",
          clientTempId: "tmp-fallback"
        }
      }, as: :json
    ensure
      fallback_singleton.define_method(:call, original_fallback_call)
      worker_singleton.define_method(:perform_later, original_perform_later)
      rails_singleton.define_method(:env, original_env)
    end

    assert_response :created

    created_item = @chat_group.chat_items.order(:id).last
    assert_equal 1, fallback_calls.size
    assert_equal [@chat_group.id, created_item.id, [created_item.id]], fallback_calls.first
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
