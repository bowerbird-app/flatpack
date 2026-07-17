# frozen_string_literal: true

module FlatPack
  module Chat
    module Composer
      class Component < FlatPack::BaseComponent
        renders_one :left_slot
        renders_one :center_slot
        renders_one :right_slot
        renders_one :attachments

        undef_method :with_left_slot, :with_left_slot_content,
          :with_center_slot, :with_center_slot_content,
          :with_right_slot, :with_right_slot_content,
          :with_attachments, :with_attachments_content

        def initialize(**system_arguments)
          super
        end

        def call
          content_tag(:div, **composer_attributes) do
            safe_join([
              render_attachments_section,
              content_tag(:div, class: composer_controls_classes) do
                safe_join([
                  render_left_section,
                  render_center_section,
                  render_right_section
                ])
              end
            ].compact)
          end
        end

        def left_slot(*args, **kwargs, &block)
          return get_slot(:left_slot) if args.empty? && kwargs.empty? && !block

          set_slot(:left_slot, nil, *args, **kwargs, &block)
        end

        def center_slot(*args, **kwargs, &block)
          return get_slot(:center_slot) if args.empty? && kwargs.empty? && !block

          set_slot(:center_slot, nil, *args, **kwargs, &block)
        end

        def right_slot(*args, **kwargs, &block)
          return get_slot(:right_slot) if args.empty? && kwargs.empty? && !block

          set_slot(:right_slot, nil, *args, **kwargs, &block)
        end

        def attachments(*args, **kwargs, &block)
          return get_slot(:attachments) if args.empty? && kwargs.empty? && !block

          set_slot(:attachments, nil, *args, **kwargs, &block)
        end

        def left(*args, **kwargs, &block)
          left_slot(*args, **kwargs, &block)
        end

        def center(*args, **kwargs, &block)
          center_slot(*args, **kwargs, &block)
        end

        def right(*args, **kwargs, &block)
          right_slot(*args, **kwargs, &block)
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

        private

        def render_left_section
          return unless left?

          content_tag(:div, class: "flex items-center gap-2") do
            left.to_s
          end
        end

        def render_center_section
          content_tag(:div, class: "flex-1 min-w-0 self-stretch") do
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
            class: "min-h-[var(--chat-composer-control-height)] rounded-lg border-[var(--chat-input-border-color)] bg-[var(--chat-input-background-color)] px-4 py-[var(--chat-composer-control-padding-y)] text-sm leading-5 text-[var(--chat-input-text-color)] placeholder:text-[var(--chat-input-placeholder-color)] focus:ring-inset focus:ring-[var(--chat-input-focus-ring-color)] max-h-32"
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
            style: :primary,
            size: :md,
            type: "submit",
            aria: {label: "Send message"},
            class: "min-h-[var(--chat-composer-control-height)] min-w-[var(--chat-composer-control-height)] shrink-0 border-transparent bg-[var(--chat-send-button-background-color)] text-[var(--chat-send-button-text-color)] hover:bg-[var(--chat-send-button-hover-background-color)] focus-visible:ring-inset focus-visible:ring-[var(--chat-send-button-focus-ring-color)]"
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

        def composer_controls_classes
          classes(
            "flex items-center gap-2",
            "[--button-icon-only-padding-md:var(--chat-composer-control-padding-y)]",
            "[--button-padding-y-md:var(--chat-composer-control-padding-y)]",
            "[&_.flat-pack-input-wrapper]:flex",
            "[&_.flat-pack-input-wrapper]:items-stretch",
            "[&_.flat-pack-input-wrapper]:h-full",
            "[&_.flat-pack-input]:h-full",
            "[&_button]:min-h-[var(--chat-composer-control-height)]",
            "[&_button]:min-w-[var(--chat-composer-control-height)]"
          )
        end
      end
    end
  end
end
