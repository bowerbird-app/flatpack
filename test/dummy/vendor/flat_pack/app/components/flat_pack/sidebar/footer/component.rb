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
            "fp-sidebar-footer",
            "shrink-0",
            "p-[var(--sidebar-padding)]",
            "border-t",
            "border-[var(--sidebar-border-color)]",
            "text-[var(--sidebar-footer-text-color)]"
          )
        end
      end
    end
  end
end
