# frozen_string_literal: true

module FlatPack
  module Sidebar
    module Badge
      class Component < FlatPack::BaseComponent
        VARIANTS = {
          default: "bg-primary text-white",
          muted: "bg-muted text-muted-foreground"
        }.freeze

        def initialize(
          value:,
          variant: :default,
          **system_arguments
        )
          super(**system_arguments)
          @value = value
          @variant = variant.to_sym

          validate_variant!
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
            variant_classes
          )
        end

        def variant_classes
          VARIANTS.fetch(@variant)
        end

        def validate_variant!
          return if VARIANTS.key?(@variant)
          raise ArgumentError, "Invalid variant: #{@variant}. Must be one of: #{VARIANTS.keys.join(", ")}"
        end
      end
    end
  end
end
