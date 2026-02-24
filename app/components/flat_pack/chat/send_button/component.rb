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
          render FlatPack::Button::Component.new(
            icon: "send",
            icon_only: true,
            size: :md,
            style: :primary,
            type: "submit",
            loading: @loading,
            disabled: @disabled || @loading,
            aria: {label: @loading ? "Sending..." : "Send message"},
            class: "border-transparent bg-[var(--chat-send-button-background-color)] text-[var(--chat-send-button-text-color)] hover:bg-[var(--chat-send-button-hover-background-color)] focus-visible:ring-[var(--chat-send-button-focus-ring-color)] shrink-0",
            **@system_arguments
          )
        end
      end
    end
  end
end
