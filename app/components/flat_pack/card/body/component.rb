# frozen_string_literal: true

module FlatPack
  module Card
    module Body
      class Component < ViewComponent::Base
        def initialize(**system_arguments)
          @system_arguments = system_arguments
        end

        def call
          content_tag(:div, content, **merged_system_arguments("p-[var(--card-padding-md)] flex-1 overflow-hidden"))
        end

        private

        def merged_system_arguments(default_classes)
          @system_arguments.merge(
            class: class_names(default_classes, @system_arguments[:class])
          )
        end
      end
    end
  end
end
