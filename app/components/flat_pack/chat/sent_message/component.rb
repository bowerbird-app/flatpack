# frozen_string_literal: true

module FlatPack
  module Chat
    module SentMessage
      class Component < FlatPack::BaseComponent
        renders_many :attachments
        renders_many :media_attachments
        renders_one :meta
        renders_one :actions

        alias_method :meta_slot, :meta
        alias_method :actions_slot, :actions

        undef_method :with_attachment, :with_attachment_content,
          :with_media_attachment, :with_media_attachment_content,
          :with_meta, :with_meta_content,
          :with_actions, :with_actions_content

        def attachment(*args, **kwargs, &block)
          set_slot(:attachments, nil, *args, **kwargs, &block)
        end

        def media_attachment(*args, **kwargs, &block)
          set_slot(:media_attachments, nil, *args, **kwargs, &block)
        end

        def meta(*args, **kwargs, &block)
          return meta_slot if args.empty? && kwargs.empty? && !block_given?

          set_slot(:meta, nil, *args, **kwargs, &block)
        end

        def actions(*args, **kwargs, &block)
          return actions_slot if args.empty? && kwargs.empty? && !block_given?

          set_slot(:actions, nil, *args, **kwargs, &block)
        end

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
              controller: "flat-pack--chat-message-actions",
              flat_pack__chat_message_actions_direction_value: :outgoing,
              flat_pack__chat_message_actions_side_value: "right",
              action: "click@window->flat-pack--chat-message-actions#handleWindowClick keydown@window->flat-pack--chat-message-actions#handleWindowKeydown chat-message-actions:opened@window->flat-pack--chat-message-actions#handlePeerOpened"
            }
          ) do
            safe_join([
              content_tag(
                :div,
                class: "absolute inset-y-0 right-0 z-0 pr-2 flex items-center gap-2 opacity-0 pointer-events-none transition-opacity duration-150",
                data: {flat_pack__chat_message_actions_target: "tray"}
              ) do
                content_tag(:div, class: "flex items-center gap-2 whitespace-nowrap pl-4") do
                  safe_join([
                    render_reveal_meta,
                    render_actions
                  ].compact)
                end
              end,
              content_tag(
                :div,
                class: "relative z-10 w-full transform transition-transform duration-200 ease-out cursor-pointer",
                data: {
                  flat_pack__chat_message_actions_target: "surface",
                  action: "click->flat-pack--chat-message-actions#toggle keydown->flat-pack--chat-message-actions#toggleByKey"
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

        def render_actions
          return actions if actions?

          safe_join([
            render(
              FlatPack::Button::Component.new(
                text: "Edit",
                size: :sm,
                style: :secondary,
                data: {action: "click->flat-pack--chat-message-actions#handleEdit"}
              )
            ),
            render(
              FlatPack::Button::Component.new(
                text: "Delete",
                size: :sm,
                style: :error,
                data: {action: "click->flat-pack--chat-message-actions#handleDelete"}
              )
            )
          ])
        end

        def render_message_surface(include_meta:)
          content_tag(:div, class: "flex flex-col items-end") do
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

        def normalized_content
          content.to_s.strip
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

          content_tag(:div, class: "mt-1 w-full flex justify-end [--chat-message-meta-color:var(--chat-message-outgoing-meta-color)] [--chat-read-receipt-color:var(--chat-message-outgoing-read-receipt-color)]") do
            meta.to_s
          end
        end

        def message_attributes
          container_classes = @reveal_actions ? "w-full" : "flex justify-end"

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
            "bg-[var(--chat-message-outgoing-background-color)] text-[var(--chat-message-outgoing-text-color)]",
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
