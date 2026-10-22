# frozen_string_literal: true

module FlatPack
  module Card
    module Stat
      class Component < ViewComponent::Base
        # Tailwind CSS scanning requires these classes to be present as string literals.
        # DO NOT REMOVE - These duplicates ensure CSS generation:
        # "text-4xl" "font-bold" "mb-2" "text-sm" "text-[var(--surface-muted-content-color)]" "text-[var(--surface-content-color)]" "mt-2" "text-[var(--color-success-background-color)]" "text-[var(--color-danger-background-color)]" "text-center" "fp-tabular-nums" "fp-card" "rounded-[var(--card-radius)]" "p-[var(--card-padding-md)]"
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

        def initialize(value:, label:, trend:, trend_direction:, value_class: nil, background: :default, **system_arguments)
          %i[style theme tone].each do |removed|
            next unless system_arguments.key?(removed)

            raise ArgumentError, "unknown keyword: :#{removed}"
          end

          @value = value
          @label = label
          @trend = trend
          @trend_direction = trend_direction.to_sym
          @value_class = value_class
          @background = background&.to_sym
          @system_arguments = system_arguments

          validate_trend_direction!
          validate_background!
        end

        def call
          content_tag(:div, **container_attributes) do
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

        def container_attributes
          arguments = @system_arguments.dup
          extra_class = arguments.delete(:class)
          extra_data = arguments.delete(:data) || {}

          {
            class: [container_classes, extra_class].compact.join(" "),
            data: extra_data.merge(background: @background.to_s, fp_card_padding: "md")
          }.merge(arguments)
        end

        def container_classes
          [
            "fp-card",
            "rounded-[var(--card-radius)]",
            "p-[var(--card-padding-md)]",
            "text-center",
            "text-[var(--surface-content-color)]",
            Background.classes_for(@background)
          ].join(" ")
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

        def validate_background!
          return if Background::CLASSES.key?(@background)

          raise ArgumentError, "Invalid background: #{@background.inspect}. Must be one of: #{Background::NAMES.join(", ")}"
        end
      end
    end
  end
end
