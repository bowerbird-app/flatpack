# frozen_string_literal: true

module FlatPack
  module Chat
    module Composer
      class Component < FlatPack::BaseComponent
        renders_one :left_slot
        renders_one :center_slot
        renders_one :right_slot
        renders_one :attachments

        def initialize(**system_arguments)
          super
        end

        def call
          content_tag(:div, **composer_attributes) do
            safe_join([
              render_attachments_section,
              content_tag(:div, class: "flex items-center gap-2") do
                safe_join([
                  render_left_section,
                  render_center_section,
                  render_right_section
                ])
              end
            ].compact)
          end
        end

        def left(*args, &block)
          return with_left_slot(*args, &block) if block_given? || args.any?

          left_slot
        end

        def center(*args, &block)
          return with_center_slot(*args, &block) if block_given? || args.any?

          center_slot
        end

        def right(*args, &block)
          return with_right_slot(*args, &block) if block_given? || args.any?

          right_slot
        end

        def left?
          left_slot?
        end

        def center?
          center_slot?
        end

        def right?
          right_slot?
        end

        def textarea
          center
        end

        def textarea?
          center?
        end

        def actions
          right
        end

        def actions?
          right?
        end

        def attachment(...)
          with_attachments(...)
        end

        private

        def render_left_section
          return unless left?

          content_tag(:div, class: "flex items-center gap-2") do
            left.to_s
          end
        end

        def render_center_section
          content_tag(:div, class: "flex-1 min-w-0") do
            if center?
              center.to_s
            else
              render_default_center
            end
          end
        end

        def render_default_center
          render FlatPack::TextArea::Component.new(
            name: "message[body]",
            placeholder: "Type a message...",
            rows: 1,
            autogrow: true,
            submit_on_enter: true,
            class: "min-h-[var(--chat-composer-control-height)] rounded-lg border-[var(--chat-input-border-color)] bg-[var(--chat-input-background-color)] px-4 py-2 text-sm leading-5 text-[var(--chat-input-text-color)] placeholder:text-[var(--chat-input-placeholder-color)] focus:ring-[var(--chat-input-focus-ring-color)] max-h-32"
          )
        end

        def render_right_section
          if right?
            right.to_s
          else
            render_default_right
          end
        end

        def render_default_right
          render FlatPack::Button::Component.new(
            icon: "send",
            icon_only: true,
            size: :md,
            style: :primary,
            type: "submit",
            aria: {label: "Send message"},
            class: "border-transparent bg-[var(--chat-send-button-background-color)] text-[var(--chat-send-button-text-color)] hover:bg-[var(--chat-send-button-hover-background-color)] focus-visible:ring-[var(--chat-send-button-focus-ring-color)] shrink-0"
          )
        end

        def render_attachments_section
          return unless attachments?

          content_tag(:div, class: "mb-2") do
            attachments.to_s
          end
        end

        def composer_attributes
          merge_attributes(
            class: composer_classes
          )
        end

        def composer_classes
          classes(
            "rounded-[var(--chat-composer-radius)]",
            "bg-[var(--chat-composer-background-color)]",
            "p-4"
          )
        end
      end
    end
  end
end
