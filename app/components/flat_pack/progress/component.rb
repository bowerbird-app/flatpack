# frozen_string_literal: true

module FlatPack
  module Progress
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "bg-primary" "bg-success-bg" "bg-warning-bg" "bg-destructive-bg"
      VARIANTS = {
        default: "bg-primary",
        success: "bg-success-bg",
        warning: "bg-warning-bg",
        danger: "bg-destructive-bg"
      }.freeze

      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "h-1" "h-2" "h-3" "h-4"
      SIZES = {
        sm: "h-1",
        md: "h-2",
        lg: "h-3",
        xl: "h-4"
      }.freeze

      def initialize(
        value:,
        max: 100,
        variant: :default,
        size: :md,
        label: nil,
        show_label: false,
        **system_arguments
      )
        super(**system_arguments)
        @value = value.to_f
        @max = max.to_f
        @variant = variant.to_sym
        @size = size.to_sym
        @label = label
        @show_label = show_label

        validate_value!
        validate_max!
        validate_variant!
        validate_size!
      end

      def call
        content_tag(:div, **container_attributes) do
          safe_join([
            render_label,
            render_progress_bar
          ].compact)
        end
      end

      private

      def render_label
        return unless @show_label || @label

        label_text = @label || "#{percentage.to_i}%"
        content_tag(:div, label_text, class: "text-sm font-medium text-[var(--surface-content-color)] mb-1")
      end

      def render_progress_bar
        content_tag(:div, **bar_container_attributes) do
          content_tag(:div, **bar_fill_attributes) do
            content_tag(:span, "#{percentage.to_i}%", class: "sr-only")
          end
        end
      end

      def container_attributes
        merge_attributes(class: "w-full")
      end

      def bar_container_attributes
        {
          role: "progressbar",
          aria: {
            valuenow: @value,
            valuemin: 0,
            valuemax: @max,
            label: @label || "Progress"
          },
          class: bar_container_classes
        }
      end

      def bar_fill_attributes
        {
          class: bar_fill_classes,
          style: "width: #{percentage}%"
        }
      end

      def bar_container_classes
        "w-full bg-[var(--surface-muted-bg-color)] rounded-full overflow-hidden #{SIZES.fetch(@size)}"
      end

      def bar_fill_classes
        "h-full #{VARIANTS.fetch(@variant)} transition-all duration-300 ease-in-out rounded-full"
      end

      def percentage
        return 0 if @max.zero?
        [(@value / @max * 100).round(2), 100].min
      end

      def validate_value!
        return if @value >= 0
        raise ArgumentError, "value must be non-negative"
      end

      def validate_max!
        return if @max > 0
        raise ArgumentError, "max must be greater than zero"
      end

      def validate_variant!
        return if VARIANTS.key?(@variant)
        raise ArgumentError, "Invalid variant: #{@variant}. Must be one of: #{VARIANTS.keys.join(", ")}"
      end

      def validate_size!
        return if SIZES.key?(@size)
        raise ArgumentError, "Invalid size: #{@size}. Must be one of: #{SIZES.keys.join(", ")}"
      end
    end
  end
end
