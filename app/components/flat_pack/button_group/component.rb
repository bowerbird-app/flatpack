# frozen_string_literal: true

module FlatPack
  module ButtonGroup
    class Component < FlatPack::BaseComponent
      def initialize(**system_arguments)
        super
        @buttons = []
      end

      def with_button(component)
        # Collects a button component to be rendered within the group.
        # Supports method chaining to allow fluent API style.
        @buttons << component
        self
      end

      def call
        content_tag(:div, **group_attributes) do
          safe_join(@buttons.map(&:call))
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
          "inline-flex",
          "rounded-[var(--radius-md)]",
          "shadow-[var(--shadow-sm)]",
          "[&>*]:rounded-none",
          "[&>*:first-child]:rounded-l-[var(--radius-md)]",
          "[&>*:last-child]:rounded-r-[var(--radius-md)]",
          "[&>*]:border-r-0",
          "[&>*:last-child]:border-r",
          "[&>*]:shadow-none"
        )
      end
    end
  end
end
