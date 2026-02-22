# frozen_string_literal: true

module FlatPack
  module Chat
    module SendButton
      class Component < FlatPack::BaseComponent
        def initialize(
          loading: false,
          disabled: false,
          **system_arguments
        )
          super(**system_arguments)
          @loading = loading
          @disabled = disabled
        end

        def call
          content_tag(:button, **button_attributes) do
            if @loading
              render_loading_content
            else
              render_send_icon
            end
          end
        end

        private

        def render_send_icon
          # Send/paper plane icon
          content_tag(:svg,
            xmlns: "http://www.w3.org/2000/svg",
            viewBox: "0 0 20 20",
            fill: "currentColor",
            class: "h-5 w-5") do
            content_tag(:path,
              nil,
              d: "M10.894 2.553a1 1 0 00-1.788 0l-7 14a1 1 0 001.169 1.409l5-1.429A1 1 0 009 15.571V11a1 1 0 112 0v4.571a1 1 0 00.725.962l5 1.428a1 1 0 001.17-1.408l-7-14z"
            )
          end
        end

        def render_loading_content
          # Simple CSS spinner
          content_tag(:svg,
            class: "animate-spin h-5 w-5",
            xmlns: "http://www.w3.org/2000/svg",
            fill: "none",
            viewBox: "0 0 24 24") do
            safe_join([
              content_tag(:circle,
                nil,
                class: "opacity-25",
                cx: "12",
                cy: "12",
                r: "10",
                stroke: "currentColor",
                "stroke-width": "4"),
              content_tag(:path,
                nil,
                class: "opacity-75",
                fill: "currentColor",
                d: "M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z")
            ])
          end
        end

        def button_attributes
          merge_attributes(
            type: "submit",
            class: button_classes,
            disabled: @disabled || @loading,
            "aria-label": @loading ? "Sending..." : "Send message"
          )
        end

        def button_classes
          classes(
            "flex items-center justify-center",
            "h-10 w-10",
            "rounded-lg",
            "bg-[var(--chat-send-button-background-color)]",
            "text-[var(--chat-send-button-text-color)]",
            "hover:bg-[var(--chat-send-button-hover-background-color)]",
            "disabled:opacity-50 disabled:cursor-not-allowed",
            "transition-colors duration-base",
            "focus:outline-none focus:ring-2 focus:ring-[var(--chat-send-button-focus-ring-color)] focus:ring-offset-2",
            "shrink-0"
          )
        end
      end
    end
  end
end
