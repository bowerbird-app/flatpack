# frozen_string_literal: true

module FlatPack
  module Card
    module Stat
      class Component < ViewComponent::Base
        # Tailwind CSS scanning requires these classes to be present as string literals.
        # DO NOT REMOVE - These duplicates ensure CSS generation:
        # "text-4xl" "font-bold" "mb-2" "text-sm" "text-[var(--surface-muted-content-color)]" "mt-2" "text-[var(--color-success-background-color)]" "text-[var(--color-danger-background-color)]" "text-center" "fp-tabular-nums"
        TREND_DIRECTIONS = {
          up: {
            icon: "↑",
            class: "text-[var(--color-success-background-color)]"
          },
          down: {
            icon: "↓",
            class: "text-[var(--color-danger-background-color)]"
          }
        }.freeze

        def initialize(value:, label:, trend:, trend_direction:, value_class: nil, **system_arguments)
          @value = value
          @label = label
          @trend = trend
          @trend_direction = trend_direction.to_sym
          @value_class = value_class
          @system_arguments = system_arguments

          validate_trend_direction!
        end

        def call
          content_tag(:div, class: container_classes, **@system_arguments) do
            safe_join([
              content_tag(:div, @value, class: value_classes),
              content_tag(:div, @label, class: "text-sm text-[var(--surface-muted-content-color)]"),
              content_tag(:div, class: trend_classes) do
                "#{trend_icon} #{@trend}"
              end
            ])
          end
        end

        private

        def container_classes
          "text-center"
        end

        def value_classes
          ["text-4xl", "font-bold", "mb-2", "fp-tabular-nums", @value_class].compact.join(" ")
        end

        def trend_classes
          ["mt-2", "text-sm", trend_direction_class].join(" ")
        end

        def trend_icon
          TREND_DIRECTIONS.fetch(@trend_direction).fetch(:icon)
        end

        def trend_direction_class
          TREND_DIRECTIONS.fetch(@trend_direction).fetch(:class)
        end

        def validate_trend_direction!
          return if TREND_DIRECTIONS.key?(@trend_direction)

          raise ArgumentError,
            "Invalid trend_direction: #{@trend_direction}. Must be one of: #{TREND_DIRECTIONS.keys.join(", ")}"
        end
      end
    end
  end
end
