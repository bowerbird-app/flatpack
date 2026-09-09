# frozen_string_literal: true

module FlatPack
  module Spinner
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "w-4" "h-4" "w-5" "h-5" "w-6" "h-6" "w-8" "h-8"
      SIZES = FlatPack::Shared::IconComponent::SIZES

      def initialize(size: :md, label: "Loading", **system_arguments)
        super(**system_arguments)
        @size = size.to_sym
        @label = label
        validate_size!
      end

      def call
        content_tag(:svg, **spinner_attributes) do
          safe_join([
            content_tag(:circle, nil, class: "opacity-25", cx: "12", cy: "12", r: "10", stroke: "currentColor", "stroke-width": "4"),
            content_tag(:path, nil, class: "opacity-75", fill: "currentColor", d: "M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z")
          ])
        end
      end

      private

      def spinner_attributes
        attrs = {
          class: spinner_classes,
          xmlns: "http://www.w3.org/2000/svg",
          fill: "none",
          viewBox: "0 0 24 24"
        }
        if @label.present?
          attrs[:role] = "status"
          attrs[:aria] = {label: @label}
        else
          attrs[:aria] = {hidden: "true"}
        end
        merge_attributes(**attrs)
      end

      def spinner_classes
        classes(
          "fp-spinner",
          SIZES.fetch(@size)
        )
      end

      def validate_size!
        return if SIZES.key?(@size)

        raise ArgumentError, "Invalid size: #{@size}. Must be one of: #{SIZES.keys.join(", ")}"
      end
    end
  end
end
