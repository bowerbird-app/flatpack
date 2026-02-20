# frozen_string_literal: true

module FlatPack
  module Chat
    module MessageList
      class Component < FlatPack::BaseComponent
        def initialize(
          stick_to_bottom: true,
          **system_arguments
        )
          super(**system_arguments)
          @stick_to_bottom = stick_to_bottom
        end

        def call
          content_tag(:div, **container_attributes) do
            safe_join([
              render_messages_area,
              render_jump_button
            ])
          end
        end

        private

        def render_messages_area
          content_tag(:div, **messages_attributes) do
            content
          end
        end

        def render_jump_button
          content_tag(:div, **jump_button_container_attributes) do
            content_tag(:button, **jump_button_attributes) do
              safe_join([
                # Down arrow icon
                content_tag(:svg,
                  xmlns: "http://www.w3.org/2000/svg",
                  viewBox: "0 0 20 20",
                  fill: "currentColor",
                  class: "h-5 w-5") do
                  content_tag(:path,
                    nil,
                    "fill-rule": "evenodd",
                    d: "M5.293 7.293a1 1 0 011.414 0L10 10.586l3.293-3.293a1 1 0 111.414 1.414l-4 4a1 1 0 01-1.414 0l-4-4a1 1 0 010-1.414z",
                    "clip-rule": "evenodd"
                  )
                end,
                content_tag(:span, "Jump to latest")
              ])
            end
          end
        end

        def container_attributes
          merge_attributes(
            class: container_classes,
            data: {
              controller: "flat-pack--chat-scroll",
              flat_pack__chat_scroll_stick_to_bottom_value: @stick_to_bottom
            }
          )
        end

        def container_classes
          classes(
            "relative flex-1 overflow-hidden"
          )
        end

        def messages_attributes
          {
            class: messages_classes,
            data: {
              flat_pack__chat_scroll_target: "messages",
              action: "scroll->flat-pack--chat-scroll#checkScroll"
            }
          }
        end

        def messages_classes
          classes(
            "h-full overflow-y-auto overflow-x-hidden",
            "px-4 py-4 space-y-4",
            "scroll-smooth"
          )
        end

        def jump_button_container_attributes
          {
            class: jump_button_container_classes,
            data: {
              flat_pack__chat_scroll_target: "jumpButtonContainer"
            }
          }
        end

        def jump_button_container_classes
          classes(
            "absolute bottom-4 right-4",
            "hidden",
            "z-10"
          )
        end

        def jump_button_attributes
          {
            type: "button",
            class: jump_button_classes,
            data: {
              action: "click->flat-pack--chat-scroll#jump"
            },
            "aria-label": "Jump to latest message"
          }
        end

        def jump_button_classes
          classes(
            "flex items-center gap-2",
            "px-4 py-2",
            "bg-white dark:bg-zinc-800",
            "border border-[var(--color-border)]",
            "rounded-full",
            "shadow-lg",
            "text-sm font-medium",
            "text-[var(--color-foreground)]",
            "hover:bg-[var(--color-muted)]",
            "transition-colors duration-[var(--transition-base)]",
            "cursor-pointer"
          )
        end
      end
    end
  end
end
