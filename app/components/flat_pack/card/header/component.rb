# frozen_string_literal: true

module FlatPack
  module Card
    module Header
      class Component < ViewComponent::Base
        # Tailwind CSS scanning requires these classes to be present as string literals.
        # DO NOT REMOVE - These duplicates ensure CSS generation:
        # "border-b" "border-[var(--card-border-color)]" "p-[var(--card-padding-sm)]" "p-[var(--card-padding-md)]" "p-[var(--card-padding-lg)]"
        def initialize(divider: true, padding: :md, **system_arguments)
          @divider = divider
          @padding = padding.to_sym
          @system_arguments = system_arguments
          validate_padding!
        end

        def call
          content_tag(:div, content, **merged_system_arguments(header_classes))
        end

        private

        def merged_system_arguments(default_classes)
          @system_arguments.merge(
            class: class_names(default_classes, @system_arguments[:class])
          )
        end

        def header_classes
          classes = [FlatPack::Card::Component::PADDINGS.fetch(@padding)]
          classes << "border-b border-[var(--card-border-color)]" if @divider
          classes.join(" ")
        end

        def validate_padding!
          return if FlatPack::Card::Component::PADDINGS.key?(@padding)

          raise ArgumentError, "Invalid padding: #{@padding}. Must be one of: #{FlatPack::Card::Component::PADDINGS.keys.join(", ")}"
        end
      end
    end
  end
end
