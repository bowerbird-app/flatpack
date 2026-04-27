# frozen_string_literal: true

module FlatPack
  module Sidebar
    module Divider
      class Component < FlatPack::BaseComponent
        def call
          content_tag(:div, "", **divider_attributes)
        end

        private

        def divider_attributes
          merge_attributes(
            class: divider_classes
          )
        end

        def divider_classes
          classes(
            "h-px",
            "bg-[var(--sidebar-divider-color)]",
            "mx-4",
            "my-2"
          )
        end
      end
    end
  end
end
