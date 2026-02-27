# frozen_string_literal: true

module FlatPack
  module Chat
    module MessageRecord
      class Component < FlatPack::BaseComponent
        DEFAULT_STATE = :sent
        STATES = {
          sent: "sent",
          sending: "sending",
          failed: "failed",
          read: "read"
        }.freeze

        renders_one :actions

        def initialize(
          record: nil,
          body: nil,
          attachments: nil,
          sender_name: nil,
          timestamp: nil,
          state: nil,
          direction: nil,
          show_avatar: nil,
          show_name: nil,
          reveal_actions: false,
          **system_arguments
        )
          super(**system_arguments)
          @record = record
          @body = body.presence || read_record_attribute(:body)
          @attachments = normalize_attachments(attachments || read_record_attachments)
          @sender_name = sender_name.presence || read_record_attribute(:sender_name)
          @timestamp = timestamp || read_record_attribute(:created_at)
          @state = normalize_state(state || read_record_attribute(:state))
          @direction = normalize_direction(direction || inferred_direction)
          @show_avatar = show_avatar.nil? ? @direction == :incoming : show_avatar
          @show_name = show_name.nil? ? @direction == :incoming : show_name
          @reveal_actions = reveal_actions

          validate_body!
          validate_sender_name!
        end

        def call
          content_tag(:div, **wrapper_attributes) do
            render FlatPack::Chat::MessageGroup::Component.new(
              direction: @direction,
              show_avatar: @show_avatar,
              show_name: @show_name,
              sender_name: @sender_name
            ) do |group|
              if @show_avatar
                group.with_avatar do
                  render FlatPack::Avatar::Component.new(
                    name: @sender_name,
                    initials: sender_initials,
                    size: :sm
                  )
                end
              end

              group.with_message do
                render_message
              end
            end
          end
        end

        private

        def chat_message_meta(chat_message)
          chat_message.with_meta do
            render FlatPack::Chat::MessageMeta::Component.new(
              timestamp: @timestamp,
              state: @state
            )
          end
        end

        def render_message
          render message_component_class.new(**message_component_arguments) do |chat_message|
            chat_message_meta(chat_message) unless hide_meta_until_reveal?

            render_attachments(chat_message)

            if reveal_action_buttons_for_message? && actions?
              chat_message.with_actions do
                actions
              end
            end

            @body
          end
        end

        def render_attachments(chat_message)
          return if @attachments.blank?

          image_attachments, file_attachments = @attachments.partition { |attachment| image_attachment?(attachment) }

          if image_attachments.length > 1
            chat_message.with_media_attachment do
              render FlatPack::Chat::ImageDeck::Component.new(
                images: image_attachments,
                direction: @direction
              )
            end
          else
            image_attachments.each do |attachment|
              chat_message.with_media_attachment do
                render FlatPack::Chat::Attachment::Component.new(**attachment)
              end
            end
          end

          file_attachments.each do |attachment|
            chat_message.with_attachment do
              render FlatPack::Chat::Attachment::Component.new(**attachment)
            end
          end
        end

        def image_attachment?(attachment)
          normalize_attachment_type(attachment[:type] || attachment["type"]) == :image
        end

        def reveal_actions?
          @reveal_actions
        end

        def reveal_actions_for_message?
          reveal_actions?
        end

        def reveal_action_buttons_for_message?
          reveal_actions? && @direction == :outgoing
        end

        def hide_meta_until_reveal?
          reveal_actions? && @direction == :incoming
        end

        def message_component_class
          (@direction == :outgoing) ? FlatPack::Chat::SentMessage::Component : FlatPack::Chat::ReceivedMessage::Component
        end

        def message_component_arguments
          arguments = {
            state: @state
          }

          if reveal_actions_for_message?
            arguments[:timestamp] = @timestamp
            arguments[:reveal_actions] = true
          end

          arguments
        end

        def wrapper_attributes
          attrs = merge_attributes(
            id: dom_id_for_record,
            data: {
              pagination_cursor: read_record_attribute(:id)
            }
          )

          attrs[:id] = nil if attrs[:id].blank?
          attrs[:data]&.delete(:pagination_cursor) if attrs.dig(:data, :pagination_cursor).blank?
          attrs
        end

        def dom_id_for_record
          return unless @record.respond_to?(:to_model)

          helpers.dom_id(@record)
        end

        def sender_initials
          @sender_name.to_s.split.map { |part| part[0] }.join.first(2).upcase.presence || "?"
        end

        def inferred_direction
          outgoing = if @record.respond_to?(:outgoing?)
            @record.outgoing?
          else
            @sender_name == "You"
          end

          outgoing ? :outgoing : :incoming
        end

        def normalize_direction(value)
          value.to_sym
        rescue NoMethodError
          :incoming
        end

        def normalize_state(value)
          state = value.presence&.to_sym
          return DEFAULT_STATE if state.blank?
          return state if STATES.key?(state)

          DEFAULT_STATE
        end

        def read_record_attribute(name)
          return unless @record.respond_to?(name)

          @record.public_send(name)
        end

        def read_record_attachments
          return [] unless @record.respond_to?(:chat_item_attachments)

          @record.chat_item_attachments.to_a
        end

        def normalize_attachments(value)
          Array(value).filter_map do |attachment|
            normalize_attachment(attachment)
          end
        end

        def normalize_attachment(attachment)
          if attachment.is_a?(Hash)
            {
              type: normalize_attachment_type(attachment[:type] || attachment["type"]),
              name: attachment[:name] || attachment["name"],
              meta: attachment[:meta] || attachment["meta"],
              href: attachment[:href] || attachment["href"],
              thumbnail_url: attachment[:thumbnail_url] || attachment["thumbnail_url"]
            }.compact
          else
            {
              type: normalize_attachment_type(attachment.kind),
              name: attachment.name,
              meta: attachment.respond_to?(:meta_label) ? attachment.meta_label : nil,
              href: nil,
              thumbnail_url: record_attachment_thumbnail_url(attachment)
            }.compact
          end
        end

        def normalize_attachment_type(value)
          (value.to_s == "image") ? :image : :file
        end

        def generated_demo_thumbnail_url(name)
          seed = ERB::Util.url_encode(name.to_s)
          "https://picsum.photos/seed/#{seed}/480/280"
        end

        def record_attachment_thumbnail_url(attachment)
          return unless attachment.respond_to?(:image?) && attachment.image?

          thumbnail_url = if attachment.respond_to?(:thumbnail_url)
            attachment.thumbnail_url
          end

          thumbnail_url.presence || generated_demo_thumbnail_url(attachment.name)
        end

        def validate_body!
          return if @body.present? || @attachments.present?

          raise ArgumentError, "body or attachments are required"
        end

        def validate_sender_name!
          return if @sender_name.present?

          raise ArgumentError, "sender_name is required"
        end
      end
    end
  end
end
