# frozen_string_literal: true

module Demo
  class ChatMessagesController < ApplicationController
    before_action :set_chat_group

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
            partial: "demo/chat_messages/message",
            formats: [:html],
            locals: {message: message}
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
  end
end
