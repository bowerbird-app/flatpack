# frozen_string_literal: true

module FlatPack
  module Toasts
    module Region
      class Component < FlatPack::BaseComponent
        def initialize(**system_arguments)
          super
        end

        def call
          content_tag(:div, content, **container_attributes)
        end

        private

        def container_attributes
          merge_attributes(
            aria: {live: "polite", atomic: "false"},
            class: container_classes,
            style: "top: calc(var(--spacing-xl) * 2); right: var(--spacing-md);"
          )
        end

        def container_classes
          classes(
            "fixed",
            "z-[60]",
            "flex",
            "flex-col",
            "gap-3",
            "pointer-events-none"
          )
        end
      end
    end
  end
end
