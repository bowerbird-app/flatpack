# frozen_string_literal: true

module FlatPack
  module Sidebar
    module Badge
      class Component < FlatPack::BaseComponent
        STYLES = {
          default: "border border-[var(--badge-primary-border-color)] bg-[var(--badge-primary-background-color)] text-[var(--badge-primary-text-color)]",
          muted: "border border-[var(--badge-default-border-color)] bg-[var(--badge-default-background-color)] text-[var(--badge-default-text-color)]"
        }.freeze

        def initialize(
          value:,
          style: :default,
          **system_arguments
        )
          super(**system_arguments)
          @value = value
          @style = style.to_sym

          validate_style!
        end

        def call
          content_tag(:span, @value, **badge_attributes)
        end

        private

        def badge_attributes
          merge_attributes(
            class: badge_classes
          )
        end

        def badge_classes
          classes(
            "inline-flex",
            "items-center",
            "justify-center",
            "px-2",
            "py-0.5",
            "text-xs",
            "font-medium",
            "rounded-full",
            style_classes
          )
        end

        def style_classes
          STYLES.fetch(@style)
        end

        def validate_style!
          return if STYLES.key?(@style)
          raise ArgumentError, "Invalid style: #{@style}. Must be one of: #{STYLES.keys.join(", ")}"
        end
      end
    end
  end
end
