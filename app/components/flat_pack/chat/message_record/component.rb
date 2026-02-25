# frozen_string_literal: true

module FlatPack
  module Chat
    module MessageRecord
      class Component < FlatPack::BaseComponent
        DEFAULT_STATE = :sent

        renders_one :actions

        def initialize(
          record: nil,
          body: nil,
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
                if reveal_actions?
                  render_revealable_message
                else
                  render_message
                end
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

        def render_message(include_meta: true)
          render FlatPack::Chat::Message::Component.new(
            direction: @direction,
            timestamp: @timestamp,
            state: @state
          ) do |chat_message|
            chat_message_meta(chat_message) if include_meta
            @body
          end
        end

        def render_revealable_message
          content_tag(
            :div,
            class: "relative overflow-hidden rounded-2xl",
            data: {
              controller: "chat-message-actions",
              chat_message_actions_direction_value: @direction,
              chat_message_actions_side_value: reveal_side,
              action: "click@window->chat-message-actions#handleWindowClick keydown@window->chat-message-actions#handleWindowKeydown chat-message-actions:opened@window->chat-message-actions#handlePeerOpened"
            }
          ) do
            safe_join([
              content_tag(
                :div,
                class: tray_classes,
                data: {chat_message_actions_target: "tray"}
              ) do
                render_reveal_actions_panel
              end,
              content_tag(
                :div,
                class: "transform transition-transform duration-200 ease-out cursor-pointer",
                data: {
                  chat_message_actions_target: "surface",
                  action: "click->chat-message-actions#toggle keydown->chat-message-actions#toggleByKey"
                },
                role: "button",
                tabindex: 0,
                aria: {expanded: false}
              ) do
                render_message(include_meta: false)
              end
            ])
          end
        end

        def render_reveal_actions_panel
          content_tag(:div, class: panel_classes) do
            if @direction == :outgoing
              safe_join([
                content_tag(:span, formatted_timestamp, class: "text-xs text-[var(--chat-message-meta-color)]"),
                render_actions
              ])
            else
              content_tag(:span, formatted_timestamp, class: "text-xs text-[var(--chat-message-meta-color)]")
            end
          end
        end

        def render_actions
          return actions if actions?

          safe_join([
            render(
              FlatPack::Button::Component.new(
                text: "Edit",
                size: :sm,
                style: :secondary,
                data: {action: "click->chat-message-actions#handleEdit"}
              )
            ),
            render(
              FlatPack::Button::Component.new(
                text: "Delete",
                size: :sm,
                style: :error,
                data: {action: "click->chat-message-actions#handleDelete"}
              )
            )
          ])
        end

        def reveal_actions?
          @reveal_actions
        end

        def reveal_side
          @direction == :incoming ? "left" : "right"
        end

        def tray_classes
          classes(
            "absolute inset-y-0 flex items-center gap-2 opacity-0 pointer-events-none transition-opacity duration-150",
            (reveal_side == "left" ? "left-0 pl-2" : "right-0 pr-2")
          )
        end

        def panel_classes
          classes(
            "flex items-center gap-2 whitespace-nowrap",
            (reveal_side == "left" ? "pr-4" : "pl-4")
          )
        end

        def formatted_timestamp
          return @timestamp.to_s if @timestamp.nil? || !@timestamp.respond_to?(:strftime)

          @timestamp.strftime("%l:%M %p").strip
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
          return state if FlatPack::Chat::Message::Component::STATES.key?(state)

          DEFAULT_STATE
        end

        def read_record_attribute(name)
          return unless @record.respond_to?(name)

          @record.public_send(name)
        end

        def validate_body!
          return if @body.present?

          raise ArgumentError, "body is required"
        end

        def validate_sender_name!
          return if @sender_name.present?

          raise ArgumentError, "sender_name is required"
        end
      end
    end
  end
end