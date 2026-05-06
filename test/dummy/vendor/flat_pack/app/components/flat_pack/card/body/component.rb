# frozen_string_literal: true

module FlatPack
  module Card
    module Body
      class Component < ViewComponent::Base
        PADDINGS = {
          none: "",
          sm: "p-[var(--card-padding-sm)]",
          md: "p-[var(--card-padding-md)]",
          lg: "p-[var(--card-padding-lg)]"
        }.freeze

        def initialize(padding: :md, **system_arguments)
          @padding = padding.to_sym
          @system_arguments = system_arguments

          validate_padding!
        end

        def call
          content_tag(:div, content, **merged_system_arguments(body_classes))
        end

        private

        def body_classes
          class_names(padding_classes, "flex-1 overflow-hidden")
        end

        def merged_system_arguments(default_classes)
          @system_arguments.merge(
            class: class_names(default_classes, @system_arguments[:class])
          )
        end

        def padding_classes
          PADDINGS.fetch(@padding)
        end

        def validate_padding!
          return if PADDINGS.key?(@padding)

          raise ArgumentError, "Invalid padding: #{@padding}. Must be one of: #{PADDINGS.keys.join(", ")}"
        end
      end
    end
  end
end
