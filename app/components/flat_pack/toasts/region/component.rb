# frozen_string_literal: true

module FlatPack
  module Toasts
    module Region
      class Component < FlatPack::BaseComponent
        def initialize(**system_arguments)
          super(**system_arguments)
        end

        def call
          content_tag(:div, content, **container_attributes)
        end

        private

        def container_attributes
          merge_attributes(
            aria: {live: "polite", atomic: "false"},
            class: container_classes
          )
        end

        def container_classes
          classes(
            "fixed",
            "top-4",
            "right-4",
            "z-50",
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
