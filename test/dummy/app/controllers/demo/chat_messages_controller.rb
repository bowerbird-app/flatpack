# frozen_string_literal: true

module Demo
  class ChatMessagesController < ApplicationController
    DEFAULT_HISTORY_LIMIT = 10
    MAX_HISTORY_LIMIT = 50

    before_action :set_chat_group

    def index
      messages = history_messages
      oldest_message_id = messages.first&.id
      has_more = oldest_message_id.present? && @chat_group.chat_messages.where("id < ?", oldest_message_id).exists?

      render partial: "demo/chat_messages/history_results",
        formats: [:html],
        locals: {
          messages: messages,
          has_more: has_more,
          history_url: demo_chat_group_messages_path(@chat_group),
          history_limit: history_limit
        }
    end

    def create
      message = @chat_group.chat_messages.build(
        body: payload[:body],
        client_temp_id: payload[:client_temp_id],
        submitted_at: payload[:submitted_at],
        sender_name: "You",
        state: "sent"
      )

      if message.save
        enqueue_chat_simulation(message)

        render json: {
          html: render_to_string(
            renderable: FlatPack::Chat::MessageRecord::Component.new(record: message, reveal_actions: true)
          ),
          state: message.state,
          timestamp: timestamp_label(message.created_at)
        }, status: :created
      else
        render json: {error: message.errors.full_messages.to_sentence}, status: :unprocessable_entity
      end
    end

    private

    def set_chat_group
      @chat_group = ChatGroup.find(params[:chat_group_id])
    end

    def payload
      raw = params.fetch(:message, {}).permit(:body, :clientTempId, :submittedAt)

      {
        body: raw[:body],
        client_temp_id: raw[:clientTempId],
        submitted_at: parse_submitted_at(raw[:submittedAt])
      }
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

    def enqueue_chat_simulation(message)
      return if Rails.env.test?

      Demo::ChatSimulationOrchestratorWorker.perform_later(@chat_group.id, message.id)
    rescue StandardError => error
      Rails.logger.warn("[chat-demo] simulation enqueue skipped: #{error.class}: #{error.message}")
      nil
    end

    def history_messages
      scope = @chat_group.chat_messages
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
