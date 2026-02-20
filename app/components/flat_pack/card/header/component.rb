# frozen_string_literal: true

module FlatPack
  module Card
    module Header
      class Component < ViewComponent::Base
        # Tailwind CSS scanning requires these classes to be present as string literals.
        # DO NOT REMOVE - These duplicates ensure CSS generation:
        # "border-b" "border-[var(--color-border)]"
        def initialize(divider: true, **system_arguments)
          @divider = divider
          @system_arguments = system_arguments
        end

        def call
          content_tag(:div, content, class: header_classes, **@system_arguments)
        end

        private

        def header_classes
          classes = ["px-6 py-4"]
          classes << "border-b border-[var(--color-border)]" if @divider
          classes.join(" ")
        end
      end
    end
  end
end
