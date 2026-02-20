# frozen_string_literal: true

module FlatPack
  module Chat
    module MessageMeta
      class Component < FlatPack::BaseComponent
        STATES = {
          sent: "sent",
          sending: "sending",
          failed: "failed",
          read: "read"
        }.freeze

        def initialize(
          timestamp: nil,
          state: :sent,
          edited: false,
          **system_arguments
        )
          super(**system_arguments)
          @timestamp = timestamp
          @state = state.to_sym
          @edited = edited

          validate_state!
        end

        def call
          content_tag(:div, **meta_attributes) do
            safe_join([
              render_timestamp,
              render_edited_indicator,
              render_state_indicator
            ].compact, " ")
          end
        end

        private

        def render_timestamp
          return unless @timestamp

          content_tag(:span, formatted_timestamp, class: "text-xs text-[var(--color-muted-foreground)]")
        end

        def render_edited_indicator
          return unless @edited

          content_tag(:span, "(edited)", class: "text-xs text-[var(--color-muted-foreground)] italic")
        end

        def render_state_indicator
          case @state
          when :sending
            render_sending_indicator
          when :failed
            render_failed_indicator
          when :read
            render_read_indicator
          else
            nil
          end
        end

        def render_sending_indicator
          content_tag(:span, class: "text-xs text-[var(--color-muted-foreground)]") do
            "Sending..."
          end
        end

        def render_failed_indicator
          content_tag(:span, class: "text-xs text-red-500 flex items-center gap-1") do
            safe_join([
              # Alert icon
              content_tag(:svg,
                xmlns: "http://www.w3.org/2000/svg",
                viewBox: "0 0 20 20",
                fill: "currentColor",
                class: "h-3 w-3") do
                content_tag(:path,
                  nil,
                  "fill-rule": "evenodd",
                  d: "M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z",
                  "clip-rule": "evenodd"
                )
              end,
              "Failed"
            ])
          end
        end

        def render_read_indicator
          content_tag(:span, class: "text-xs text-[var(--color-primary)]") do
            safe_join([
              # Double check icon
              content_tag(:svg,
                xmlns: "http://www.w3.org/2000/svg",
                viewBox: "0 0 20 20",
                fill: "currentColor",
                class: "h-3 w-3 inline") do
                safe_join([
                  content_tag(:path, nil, d: "M0 11l2-2 5 5L18 3l2 2L7 18z")
                ])
              end
            ])
          end
        end

        def meta_attributes
          merge_attributes(
            class: meta_classes
          )
        end

        def meta_classes
          classes(
            "flex items-center gap-1.5 text-xs"
          )
        end

        def formatted_timestamp
          return @timestamp unless @timestamp.respond_to?(:strftime)

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
