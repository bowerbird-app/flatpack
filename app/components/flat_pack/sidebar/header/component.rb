# frozen_string_literal: true

module FlatPack
  module Sidebar
    module Header
      class Component < FlatPack::BaseComponent
        def call
          content_tag(:div, content.to_s, **header_attributes)
        end

        private

        def header_attributes
          merge_attributes(
            class: header_classes
          )
        end

        def header_classes
          classes(
            "shrink-0",
            "p-4",
            "border-b",
            "border-[var(--color-border)]"
          )
        end
      end
    end
  end
end
