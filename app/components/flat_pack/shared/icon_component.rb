# frozen_string_literal: true

module FlatPack
  module Shared
    class IconComponent < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "w-4" "h-4" "w-5" "h-5" "w-6" "h-6" "w-8" "h-8"
      SIZES = {
        sm: "w-4 h-4",
        md: "w-5 h-5",
        lg: "w-6 h-6",
        xl: "w-8 h-8"
      }.freeze

      def initialize(name:, size: :md, **system_arguments)
        super(**system_arguments)
        @name = name
        @size = size.to_sym

        validate_size!
      end

      def call
        tag.svg(**svg_attributes) do
          tag.use "xlink:href": "#icon-#{icon_id_name}"
        end
      end

      private

      def svg_attributes
        merge_attributes(
          class: icon_classes,
          xmlns: "http://www.w3.org/2000/svg",
          fill: "none",
          viewBox: "0 0 24 24",
          stroke: "currentColor",
          aria: {hidden: true}
        )
      end

      def icon_classes
        classes(
          "inline-block",
          size_classes
        )
      end

      def size_classes
        SIZES.fetch(@size)
      end

      def validate_size!
        return if SIZES.key?(@size)
        raise ArgumentError, "Invalid size: #{@size}. Must be one of: #{SIZES.keys.join(", ")}"
      end

      def icon_id_name
        @name.to_s.tr("_", "-")
      end
    end
  end
end
