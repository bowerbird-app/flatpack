# frozen_string_literal: true

module FlatPack
  module Chat
    module Message
      class Component < FlatPack::BaseComponent
        renders_many :attachments
        renders_one :meta

        # Tailwind CSS scanning requires these classes to be present as string literals.
        # DO NOT REMOVE - These duplicates ensure CSS generation:
        # "justify-start" "justify-end" "justify-center" "bg-[var(--chat-message-incoming-background-color)]" "text-[var(--chat-message-incoming-text-color)]" "bg-[var(--chat-message-outgoing-background-color)]" "text-[var(--chat-message-outgoing-text-color)]" "bg-transparent" "text-[var(--chat-message-system-text-color)]" "text-xs" "italic"
        DIRECTIONS = {
          incoming: "justify-start",
          outgoing: "justify-end"
        }.freeze

        VARIANTS = {
          default: "",
          system: "bg-transparent text-[var(--chat-message-system-text-color)] text-xs italic"
        }.freeze

        BUBBLE_DIRECTIONS = {
          incoming: "bg-[var(--chat-message-incoming-background-color)] text-[var(--chat-message-incoming-text-color)]",
          outgoing: "bg-[var(--chat-message-outgoing-background-color)] text-[var(--chat-message-outgoing-text-color)]"
        }.freeze

        STATES = {
          sent: "sent",
          sending: "sending",
          failed: "failed",
          read: "read"
        }.freeze

        def initialize(
          direction: :incoming,
          variant: :default,
          state: :sent,
          timestamp: nil,
          edited: false,
          **system_arguments
        )
          super(**system_arguments)
          @direction = direction.to_sym
          @variant = variant.to_sym
          @state = state.to_sym
          @timestamp = timestamp
          @edited = edited

          validate_direction!
          validate_variant!
          validate_state!
        end

        def call
          if @variant == :system
            render_system_message
          else
            render_default_message
          end
        end

        private

        def render_system_message
          content_tag(:div, **message_attributes) do
            safe_join([
              content_tag(:div, class: "text-center py-1") do
                content
              end
            ])
          end
        end

        def render_default_message
          content_tag(:div, **message_attributes) do
            safe_join([
              content_tag(:div, class: bubble_classes) do
                safe_join([
                  content_tag(:div, class: "break-words whitespace-pre-line") do
                    normalized_content
                  end,
                  render_attachments,
                  render_meta_section
                ].compact)
              end
            ])
          end
        end

        def normalized_content
          # ERB block indentation can introduce a leading newline with whitespace-pre-line.
          content.to_s.strip
        end

        def render_attachments
          return unless attachments?

          content_tag(:div, class: "mt-2 space-y-2") do
            safe_join(attachments)
          end
        end

        def render_meta_section
          return unless meta?

          content_tag(:div, class: "mt-1") do
            meta
          end
        end

        def message_attributes
          merge_attributes(
            class: message_classes,
            data: {
              chat_message_state: @state
            }
          )
        end

        def message_classes
          if @variant == :system
            classes(
              "flex",
              "justify-center",
              "w-full",
              VARIANTS.fetch(@variant)
            )
          else
            classes(
              "flex",
              DIRECTIONS.fetch(@direction)
            )
          end
        end

        def bubble_classes
          classes(
            "relative",
            "px-4 py-2",
            "rounded-2xl",
            "max-w-[75%] sm:max-w-[500px]",
            "shadow-sm",
            BUBBLE_DIRECTIONS.fetch(@direction),
            state_opacity_classes
          )
        end

        def state_opacity_classes
          case @state
          when :sending
            "opacity-60"
          when :failed
            "opacity-50 border-2 border-[var(--chat-message-failed-color)]"
          else
            nil
          end
        end

        def validate_direction!
          return if DIRECTIONS.key?(@direction)
          raise ArgumentError, "Invalid direction: #{@direction}. Must be one of: #{DIRECTIONS.keys.join(", ")}"
        end

        def validate_variant!
          return if VARIANTS.key?(@variant)
          raise ArgumentError, "Invalid variant: #{@variant}. Must be one of: #{VARIANTS.keys.join(", ")}"
        end

        def validate_state!
          return if STATES.key?(@state)
          raise ArgumentError, "Invalid state: #{@state}. Must be one of: #{STATES.keys.join(", ")}"
        end
      end
    end
  end
end
