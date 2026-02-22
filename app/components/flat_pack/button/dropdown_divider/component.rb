# frozen_string_literal: true

module FlatPack
  module Button
    module DropdownDivider
      class Component < FlatPack::BaseComponent
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
            "bg-[var(--surface-border-color)]"
          )
        end
      end
    end
  end
end
