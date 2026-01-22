# frozen_string_literal: true

module FlatPack
  module ButtonGroup
    class Component < FlatPack::BaseComponent
      renders_many :buttons, ->(component) { component }

      def initialize(**system_arguments)
        super
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
