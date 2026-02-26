# frozen_string_literal: true

module Demo
  class ChatMessagesController < ApplicationController
    DEFAULT_HISTORY_LIMIT = 10
    MAX_HISTORY_LIMIT = 50

    before_action :set_chat_group

    def index
      items = history_items
      oldest_item_id = items.first&.id
      has_more = oldest_item_id.present? && @chat_group.chat_items.where("id < ?", oldest_item_id).exists?

      render partial: "demo/chat_messages/history_results",
        formats: [:html],
        locals: {
          items: items,
          has_more: has_more,
          history_url: demo_chat_group_messages_path(@chat_group),
          history_limit: history_limit
        }
    end

    def create
      item = @chat_group.chat_items.build(
        body: payload[:body],
        client_temp_id: payload[:client_temp_id],
        submitted_at: payload[:submitted_at],
        sender_name: "You",
        state: "sent"
      )

      payload[:attachments].each_with_index do |attachment, index|
        item.chat_item_attachments.build(
          kind: attachment[:kind],
          name: attachment[:name],
          content_type: attachment[:content_type],
          byte_size: attachment[:byte_size],
          position: index
        )
      end

      if item.save
        enqueue_chat_simulation(item)

        render json: {
          html: render_to_string(
            renderable: FlatPack::Chat::MessageRecord::Component.new(record: item, reveal_actions: true)
          ),
          state: item.state,
          timestamp: timestamp_label(item.created_at)
        }, status: :created
      else
        render json: {error: item.errors.full_messages.to_sentence}, status: :unprocessable_entity
      end
    end

    private

    def set_chat_group
      @chat_group = ChatGroup.find(params[:chat_group_id])
    end

    def payload
      raw = params.fetch(:message, {}).permit(:body, :clientTempId, :submittedAt, attachments: [:kind, :name, :contentType, :byteSize])

      {
        body: raw[:body],
        client_temp_id: raw[:clientTempId],
        submitted_at: parse_submitted_at(raw[:submittedAt]),
        attachments: normalize_attachments(raw[:attachments])
      }
    end

    def normalize_attachments(value)
      Array(value).map do |attachment|
        {
          kind: attachment[:kind].to_s == "image" ? "image" : "file",
          name: attachment[:name].to_s,
          content_type: attachment[:contentType].presence,
          byte_size: normalize_byte_size(attachment[:byteSize])
        }
      end.select { |attachment| attachment[:name].present? }
    end

    def normalize_byte_size(value)
      return nil if value.blank?

      Integer(value, 10)
    rescue ArgumentError, TypeError
      nil
    end

    def parse_submitted_at(value)
      return if value.blank?

      Time.zone.parse(value)
    rescue ArgumentError, TypeError
      nil
    end

    def timestamp_label(value)
      value.strftime("%l:%M %p").strip
    end

    def enqueue_chat_simulation(item)
      return if Rails.env.test?

      Demo::ChatSimulationOrchestratorWorker.perform_later(@chat_group.id, item.id)
    rescue StandardError => error
      Rails.logger.warn("[chat-demo] simulation enqueue skipped: #{error.class}: #{error.message}")
      nil
    end

    def history_items
      scope = @chat_group.chat_items.includes(:chat_item_attachments)
      scope = scope.where("id < ?", before_id) if before_id

      scope
        .order(created_at: :desc, id: :desc)
        .limit(history_limit)
        .to_a
        .reverse
    end

    def before_id
      value = params[:before_id].to_s
      return if value.blank?

      Integer(value, 10)
    rescue ArgumentError, TypeError
      nil
    end

    def history_limit
      requested = params[:limit].to_i
      return DEFAULT_HISTORY_LIMIT if requested <= 0

      [requested, MAX_HISTORY_LIMIT].min
    end
  end
end
