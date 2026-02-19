# frozen_string_literal: true

module FlatPack
  module Chat
    module TypingIndicator
      class Component < FlatPack::BaseComponent
        renders_one :avatar

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
            avatar
          end
        end

        def render_bubble
          content_tag(:div, class: bubble_classes) do
            content_tag(:div, class: "flex items-center gap-1") do
              safe_join([
                render_dot,
                render_dot,
                render_dot
              ])
            end
          end
        end

        def render_dot
          content_tag(:div, nil, class: dot_classes)
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
            "bg-[var(--color-muted)]",
            "shadow-sm"
          )
        end

        def dot_classes
          classes(
            "h-2 w-2",
            "rounded-full",
            "bg-[var(--color-muted-foreground)]",
            "animate-bounce"
          )
        end
      end
    end
  end
end
