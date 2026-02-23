# frozen_string_literal: true

module FlatPack
  module ChipGroup
    class Component < FlatPack::BaseComponent
      def initialize(
        wrap: true,
        size: nil,
        **system_arguments
      )
        super(**system_arguments)
        @wrap = wrap
        @size = size
      end

      def call
        content_tag(:div, **group_attributes) do
          content
        end
      end

      private

      def group_attributes
        merge_attributes(
          class: group_classes
        )
      end

      def group_classes
        classes(
          "flex items-center gap-[var(--chip-group-gap)]",
          @wrap ? "flex-wrap" : nil
        )
      end
    end
  end
end
