# frozen_string_literal: true

module FlatPack
  module RangeInput
    class Component < FlatPack::BaseComponent
      def initialize(
        name:,
        id: nil,
        value: nil,
        min: 0,
        max: 100,
        step: 1,
        label: nil,
        show_value: true,
        disabled: false,
        **system_arguments
      )
        super(**system_arguments)
        @name = name
        @id = id || name
        @value = value || min
        @min = min
        @max = max
        @step = step
        @label = label
        @show_value = show_value
        @disabled = disabled

        validate_name!
        validate_range!
      end

      def call
        content_tag(:div, **container_attributes) do
          safe_join([
            render_label,
            render_input_wrapper
          ].compact)
        end
      end

      private

      def render_label
        return unless @label

        content_tag(:label, **label_attributes) do
          safe_join([
            content_tag(:span, @label),
            render_value_display
          ].compact)
        end
      end

      def render_value_display
        return unless @show_value

        content_tag(:span,
          @value.to_s,
          class: "font-mono text-sm",
          data: {"flat-pack--range-input-target": "valueDisplay"})
      end

      def render_input_wrapper
        content_tag(:div, class: "relative") do
          tag.input(**input_attributes)
        end
      end

      def container_attributes
        merge_attributes(
          data: {controller: "flat-pack--range-input"},
          class: "w-full"
        )
      end

      def label_attributes
        {
          for: @id,
          class: "flex items-center justify-between mb-2 text-sm font-medium text-foreground"
        }
      end

      def input_attributes
        {
          type: "range",
          name: @name,
          id: @id,
          value: @value,
          min: @min,
          max: @max,
          step: @step,
          disabled: @disabled,
          class: input_classes,
          data: {
            "flat-pack--range-input-target": "input",
            action: "input->flat-pack--range-input#update change->flat-pack--range-input#update"
          },
          aria: {
            label: @label || "Range input",
            valuenow: @value,
            valuemin: @min,
            valuemax: @max
          }
        }
      end

      def input_classes
        "w-full h-2 bg-muted rounded-full appearance-none cursor-pointer focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed"
      end

      def validate_name!
        return if @name.present?
        raise ArgumentError, "name is required"
      end

      def validate_range!
        return if @min < @max
        raise ArgumentError, "min must be less than max"
      end
    end
  end
end
