# frozen_string_literal: true

module FlatPack
  module Sidebar
    module Footer
      class Component < FlatPack::BaseComponent
        def call
          content_tag(:div, content, **footer_attributes)
        end

        private

        def footer_attributes
          merge_attributes(
            class: footer_classes
          )
        end

        def footer_classes
          classes(
            "shrink-0",
            "p-4",
            "border-t",
            "border-[var(--color-border)]"
          )
        end
      end
    end
  end
end
