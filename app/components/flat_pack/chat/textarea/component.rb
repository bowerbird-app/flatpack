# frozen_string_literal: true

module FlatPack
  module Chat
    module Textarea
      class Component < FlatPack::BaseComponent
        def initialize(
          name: "message[body]",
          placeholder: "Type a message...",
          autogrow: true,
          submit_on_enter: true,
          **system_arguments
        )
          super(**system_arguments)
          @name = name
          @placeholder = placeholder
          @autogrow = autogrow
          @submit_on_enter = submit_on_enter
        end

        def call
          content_tag(:div, **wrapper_attributes) do
            content_tag(:textarea, nil, **textarea_attributes)
          end
        end

        private

        def wrapper_attributes
          {
            class: wrapper_classes
          }
        end

        def wrapper_classes
          "relative"
        end

        def textarea_attributes
          merge_attributes(
            name: @name,
            placeholder: @placeholder,
            rows: 1,
            class: textarea_classes,
            data: textarea_data_attributes
          )
        end

        def textarea_classes
          classes(
            "w-full",
            "px-4 py-2.5",
            "border border-border",
            "rounded-lg",
            "bg-background",
            "text-foreground",
            "placeholder:text-muted-foreground",
            "resize-none",
            "focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-0",
            "transition-colors duration-base",
            "disabled:opacity-50 disabled:cursor-not-allowed",
            "max-h-32"
          )
        end

        def textarea_data_attributes
          {
            controller: "flat-pack--chat-textarea",
            flat_pack__chat_textarea_target: "textarea",
            flat_pack__chat_textarea_autogrow_value: @autogrow,
            flat_pack__chat_textarea_submit_on_enter_value: @submit_on_enter,
            action: textarea_actions
          }
        end

        def textarea_actions
          actions = []
          actions << "input->flat-pack--chat-textarea#autoExpand" if @autogrow
          actions << "keydown->flat-pack--chat-textarea#handleKeydown" if @submit_on_enter
          actions.join(" ")
        end
      end
    end
  end
end
