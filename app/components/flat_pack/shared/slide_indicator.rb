# frozen_string_literal: true

module FlatPack
  module Shared
    # Opt-in sliding active marker for Tabs, Button::Pill, and later Segmented Buttons.
    module SlideIndicator
      CONTROLLER = "flat-pack--slide-indicator"
      LIST_CLASS = "fp-slide-indicator-list"
      ITEM_CLASS = "fp-slide-indicator__item"
      INDICATOR_CLASS = "fp-slide-indicator"
      KIND_UNDERLINE = "underline"
      KIND_PILL = "pill"

      module_function

      def normalize(indicator)
        return nil if indicator.nil? || indicator == false || indicator == ""

        name = indicator.to_sym
        return name if name == :slide

        raise ArgumentError, "Invalid indicator: #{indicator}. Must be :slide"
      end

      def list_data(kind:)
        {
          controller: CONTROLLER,
          "flat-pack--slide-indicator-kind-value": kind.to_s
        }
      end

      def item_data
        {"flat-pack--slide-indicator-target": "item"}
      end

      def indicator_classes(kind:)
        "#{INDICATOR_CLASS} #{INDICATOR_CLASS}--#{kind}"
      end
    end
  end
end
