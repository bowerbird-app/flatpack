# frozen_string_literal: true

module FlatPack
  module SegmentedButtons
    class Component < FlatPack::BaseComponent
      renders_many :buttons, ->(text:, selected: false, **args) do
        style = selected ? :primary : :secondary
        FlatPack::Button::Component.new(text: text, style: style, **args)
      end

      def initialize(**system_arguments)
        super
      end

      def call
        content_tag(:div, **group_attributes) do
          safe_join(buttons.map(&:call))
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
