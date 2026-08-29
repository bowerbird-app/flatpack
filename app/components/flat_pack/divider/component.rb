# frozen_string_literal: true

module FlatPack
  module Divider
    class Component < FlatPack::BaseComponent
      def initialize(
        label: nil,
        **system_arguments
      )
        super(**system_arguments)
        @label = normalize_label(label)
      end

      def call
        if labeled?
          content_tag(:div, **divider_attributes) do
            safe_join([
              line_element,
              content_tag(:span, @label, class: label_classes),
              line_element
            ])
          end
        else
          content_tag(:div, nil, **divider_attributes)
        end
      end

      private

      def normalize_label(label)
        return nil if label.nil?

        validate_text_option!(label, name: :label)
        label.presence
      end

      def labeled?
        @label.present?
      end

      def divider_attributes
        attrs = {
          class: divider_classes,
          role: "separator"
        }
        attrs[:"aria-label"] = @label if labeled?
        merge_attributes(**attrs)
      end

      def divider_classes
        if labeled?
          classes("flex w-full items-center gap-3")
        else
          classes("w-full border-t border-[var(--surface-border-color)]")
        end
      end

      def line_element
        content_tag(:div, nil, class: "min-w-0 flex-1 border-t border-[var(--surface-border-color)]")
      end

      def label_classes
        "shrink-0 text-xs font-medium text-[var(--surface-muted-content-color)] whitespace-nowrap"
      end
    end
  end
end
