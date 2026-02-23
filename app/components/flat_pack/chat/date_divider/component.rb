# frozen_string_literal: true

module FlatPack
  module Chat
    module DateDivider
      class Component < FlatPack::BaseComponent
        def initialize(
          label:,
          **system_arguments
        )
          super(**system_arguments)
          @label = label

          validate_label!
        end

        def call
          content_tag(:div, **divider_attributes) do
            safe_join([
              content_tag(:div, nil, class: "flex-1 border-t border-[var(--chat-date-divider-line-color)]"),
              content_tag(:span, @label, class: label_classes),
              content_tag(:div, nil, class: "flex-1 border-t border-[var(--chat-date-divider-line-color)]")
            ])
          end
        end

        private

        def divider_attributes
          merge_attributes(
            class: divider_classes,
            role: "separator",
            "aria-label": @label
          )
        end

        def divider_classes
          classes(
            "flex items-center gap-3",
            "py-4 px-4"
          )
        end

        def label_classes
          "text-xs font-medium text-[var(--chat-date-divider-text-color)] whitespace-nowrap"
        end

        def validate_label!
          return if @label.present?
          raise ArgumentError, "label is required"
        end
      end
    end
  end
end
