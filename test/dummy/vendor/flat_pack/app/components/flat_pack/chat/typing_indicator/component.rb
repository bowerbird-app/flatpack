# frozen_string_literal: true

module FlatPack
  module Chat
    module TypingIndicator
      class Component < FlatPack::BaseComponent
        renders_one :avatar

        alias_method :avatar_slot, :avatar

        undef_method :with_avatar, :with_avatar_content

        def avatar(content = nil, **args, &block)
          return avatar_slot if content.nil? && args.empty? && !block_given?

          set_slot(:avatar, content, **args, &block)
        end

        def initialize(
          label: "Someone is typing",
          **system_arguments
        )
          super(**system_arguments)
          @label = label
        end

        def call
          content_tag(:div, **indicator_attributes) do
            safe_join([
              render_avatar_section,
              render_bubble
            ])
          end
        end

        private

        def render_avatar_section
          return unless avatar?

          content_tag(:div, class: "flex-shrink-0 mr-3") do
            avatar.to_s
          end
        end

        def render_bubble
          content_tag(:div, class: bubble_classes) do
            content_tag(:div, class: "flex items-center gap-1") do
              safe_join([
                render_dot(0),
                render_dot(120),
                render_dot(240)
              ])
            end
          end
        end

        def render_dot(delay_ms)
          content_tag(:div, nil, class: dot_classes, style: dot_animation_style(delay_ms))
        end

        def indicator_attributes
          merge_attributes(
            class: indicator_classes,
            "aria-label": @label
          )
        end

        def indicator_classes
          classes(
            "flex items-start"
          )
        end

        def bubble_classes
          classes(
            "relative",
            "px-4 py-3",
            "rounded-2xl",
            "bg-[var(--chat-typing-background-color)]",
            "shadow-sm"
          )
        end

        def dot_classes
          classes(
            "h-2 w-2",
            "rounded-full",
            "bg-[var(--chat-typing-dot-color)]",
            "animate-bounce",
            "motion-reduce:animate-none"
          )
        end

        def dot_animation_style(delay_ms)
          "animation-duration: 650ms; animation-delay: #{delay_ms}ms"
        end
      end
    end
  end
end
