# frozen_string_literal: true

module FlatPack
  module Chat
    module ReceivedMessage
      class Component < FlatPack::BaseComponent
        renders_many :attachments
        renders_many :media_attachments
        renders_one :meta

        STATES = {
          sent: "sent",
          sending: "sending",
          failed: "failed",
          read: "read"
        }.freeze

        def initialize(
          state: :sent,
          reveal_actions: false,
          timestamp: nil,
          **system_arguments
        )
          super(**system_arguments)
          @state = state.to_sym
          @reveal_actions = reveal_actions
          @timestamp = timestamp

          validate_state!
        end

        def call
          content_tag(:div, **message_attributes) do
            if @reveal_actions
              render_revealable_message
            else
              render_message_surface(include_meta: true)
            end
          end
        end

        private

        def render_revealable_message
          content_tag(
            :div,
            class: "relative w-full overflow-hidden rounded-2xl",
            data: {
              controller: "chat-message-actions",
              chat_message_actions_direction_value: :incoming,
              chat_message_actions_side_value: "left",
              action: "click@window->chat-message-actions#handleWindowClick keydown@window->chat-message-actions#handleWindowKeydown chat-message-actions:opened@window->chat-message-actions#handlePeerOpened"
            }
          ) do
            safe_join([
              content_tag(
                :div,
                class: "absolute inset-y-0 left-0 z-0 pl-2 flex items-center gap-2 opacity-0 pointer-events-none transition-opacity duration-150",
                data: {chat_message_actions_target: "tray"}
              ) do
                content_tag(:div, class: "flex items-center gap-2 whitespace-nowrap pr-4") do
                  render_reveal_meta
                end
              end,
              content_tag(
                :div,
                class: "relative z-10 w-full transform transition-transform duration-200 ease-out cursor-pointer",
                data: {
                  chat_message_actions_target: "surface",
                  action: "click->chat-message-actions#toggle keydown->chat-message-actions#toggleByKey"
                },
                role: "button",
                tabindex: 0,
                aria: {expanded: false}
              ) do
                render_message_surface(include_meta: false)
              end
            ])
          end
        end

        def render_reveal_meta
          return meta.to_s if meta?

          return unless @timestamp.present?

          content_tag(:span, formatted_timestamp, class: "text-xs text-[var(--chat-message-meta-color)]")
        end

        def normalized_content
          content.to_s.strip
        end

        def render_message_surface(include_meta:)
          content_tag(:div, class: "flex flex-col items-start") do
            safe_join([
              render_bubble,
              render_media_attachments,
              (include_meta ? render_meta_section : nil)
            ].compact)
          end
        end

        def render_bubble
          return unless bubble_content?

          content_tag(:div, class: bubble_classes) do
            safe_join([
              (content_tag(:div, normalized_content, class: "break-words whitespace-pre-line") if normalized_content.present?),
              render_attachments
            ].compact)
          end
        end

        def render_attachments
          return unless attachments?

          content_tag(:div, class: "mt-2 space-y-2") do
            safe_join(attachments)
          end
        end

        def render_media_attachments
          return unless media_attachments?

          content_tag(:div, class: "mt-2 space-y-2 max-w-[75%] sm:max-w-[500px]") do
            safe_join(media_attachments)
          end
        end

        def bubble_content?
          normalized_content.present? || attachments?
        end

        def render_meta_section
          return unless meta?

          content_tag(:div, class: "mt-1 [--chat-message-meta-color:var(--chat-message-incoming-meta-color)] [--chat-read-receipt-color:var(--chat-message-incoming-read-receipt-color)]") do
            meta.to_s
          end
        end

        def message_attributes
          container_classes = @reveal_actions ? "w-full" : "flex justify-start"

          merge_attributes(
            class: container_classes,
            data: {
              chat_message_state: @state
            }
          )
        end

        def bubble_classes
          classes(
            "relative",
            "px-4 py-2",
            "rounded-2xl",
            "max-w-[75%] sm:max-w-[500px]",
            "shadow-sm",
            "bg-[var(--chat-message-incoming-background-color)] text-[var(--chat-message-incoming-text-color)]",
            state_opacity_classes
          )
        end

        def state_opacity_classes
          case @state
          when :sending
            "opacity-60"
          when :failed
            "opacity-50 border-2 border-[var(--chat-message-failed-color)]"
          end
        end

        def formatted_timestamp
          return @timestamp.to_s if @timestamp.nil? || !@timestamp.respond_to?(:strftime)

          @timestamp.strftime("%l:%M %p").strip
        end

        def validate_state!
          return if STATES.key?(@state)

          raise ArgumentError, "Invalid state: #{@state}. Must be one of: #{STATES.keys.join(", ")}"
        end
      end
    end
  end
end
