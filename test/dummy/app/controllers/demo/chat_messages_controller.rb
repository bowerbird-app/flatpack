# frozen_string_literal: true

module Demo
  class ChatMessagesController < ApplicationController
    COMPOSITION_MODES = %w[combined separate].freeze
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
      items = build_outgoing_items

      if items.blank?
        render json: {error: "Message or attachments can't be blank"}, status: :unprocessable_entity
        return
      end

      ChatItem.transaction do
        items.each(&:save!)
      end

      simulation_anchor = simulation_anchor_item(items)
      enqueue_chat_simulation(simulation_anchor, items)

      render json: {
        html: rendered_items_html(items),
        state: simulation_anchor.state,
        timestamp: timestamp_label(simulation_anchor.created_at)
      }, status: :created
    rescue ActiveRecord::RecordInvalid => error
      render json: {error: error.record.errors.full_messages.to_sentence}, status: :unprocessable_entity
    end

    def preview
      preview_item = build_preview_item

      render json: {
        html: render_to_string(
          renderable: FlatPack::Chat::MessageRecord::Component.new(record: preview_item, reveal_actions: true)
        )
      }, status: :ok
    rescue ArgumentError => error
      render json: {error: error.message}, status: :unprocessable_entity
    end

    private

    def set_chat_group
      @chat_group = ChatGroup.find(params[:chat_group_id])
    end

    def payload
      raw = params.fetch(:message, {}).permit(:body, :clientTempId, :submittedAt, :compositionMode, attachments: [:kind, :name, :contentType, :byteSize, :thumbnailUrl])

      {
        body: raw[:body],
        client_temp_id: raw[:clientTempId],
        submitted_at: parse_submitted_at(raw[:submittedAt]),
        composition_mode: normalize_composition_mode(raw[:compositionMode]),
        attachments: normalize_attachments(raw[:attachments])
      }
    end

    def normalize_attachments(value)
      Array(value).map do |attachment|
        {
          kind: (attachment[:kind].to_s == "image") ? "image" : "file",
          name: attachment[:name].to_s,
          content_type: attachment[:contentType].presence,
          byte_size: normalize_byte_size(attachment[:byteSize]),
          thumbnail_url: attachment[:thumbnailUrl].presence
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

    def build_outgoing_items
      mode = payload[:composition_mode]
      return build_combined_outgoing_item if mode == "combined"

      build_separate_outgoing_items
    end

    def build_combined_outgoing_item
      has_body = payload[:body].present?
      has_attachments = payload[:attachments].present?
      return [] unless has_body || has_attachments

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
          metadata: attachment[:thumbnail_url].present? ? {thumbnail_url: attachment[:thumbnail_url]} : {},
          position: index
        )
      end

      [item]
    end

    def build_separate_outgoing_items
      items = []

      if payload[:body].present?
        items << @chat_group.chat_items.build(
          body: payload[:body],
          client_temp_id: payload[:client_temp_id],
          submitted_at: payload[:submitted_at],
          sender_name: "You",
          state: "sent"
        )
      end

      payload[:attachments].each do |attachment|
        item = @chat_group.chat_items.build(
          body: nil,
          client_temp_id: nil,
          submitted_at: payload[:submitted_at],
          sender_name: "You",
          state: "sent"
        )

        item.chat_item_attachments.build(
          kind: attachment[:kind],
          name: attachment[:name],
          content_type: attachment[:content_type],
          byte_size: attachment[:byte_size],
          metadata: attachment[:thumbnail_url].present? ? {thumbnail_url: attachment[:thumbnail_url]} : {},
          position: 0
        )

        items << item
      end

      items
    end

    def normalize_composition_mode(value)
      requested = value.to_s
      return requested if COMPOSITION_MODES.include?(requested)

      "separate"
    end

    def simulation_anchor_item(items)
      items.find { |item| item.body.present? } || items.last
    end

    def rendered_items_html(items)
      items.map do |item|
        render_to_string(
          renderable: FlatPack::Chat::MessageRecord::Component.new(record: item, reveal_actions: true)
        )
      end.join
    end

    def enqueue_chat_simulation(anchor_item, items)
      return if Rails.env.test?

      Demo::ChatSimulationOrchestratorWorker.perform_later(@chat_group.id, anchor_item.id, items.map(&:id))
    rescue => error
      Rails.logger.warn("[chat-demo] simulation enqueue skipped: #{error.class}: #{error.message}")
      Demo::ChatSimulationFallback.call(@chat_group.id, anchor_item.id, items.map(&:id)) if Rails.env.development?
      nil
    end

    def build_preview_item
      has_body = payload[:body].present?
      has_attachments = payload[:attachments].present?
      raise ArgumentError, "Message or attachments can't be blank" unless has_body || has_attachments

      preview_item = @chat_group.chat_items.build(
        body: payload[:body],
        client_temp_id: payload[:client_temp_id],
        submitted_at: payload[:submitted_at],
        sender_name: "You",
        state: "sending"
      )

      payload[:attachments].each_with_index do |attachment, index|
        preview_item.chat_item_attachments.build(
          kind: attachment[:kind],
          name: attachment[:name],
          content_type: attachment[:content_type],
          byte_size: attachment[:byte_size],
          metadata: attachment[:thumbnail_url].present? ? {thumbnail_url: attachment[:thumbnail_url]} : {},
          position: index
        )
      end

      preview_item.created_at = payload[:submitted_at] || Time.zone.now
      preview_item
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
