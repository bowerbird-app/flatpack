# frozen_string_literal: true

module FlatPack
  module Button
    class DropdownDividerComponent < FlatPack::BaseComponent
      def call
        content_tag(:div, nil, **divider_attributes)
      end

      private

      def divider_attributes
        merge_attributes(
          class: divider_classes,
          role: "separator"
        )
      end

      def divider_classes
        classes(
          "h-px",
          "my-1",
          "bg-[var(--color-border)]"
        )
      end
    end
  end
end
