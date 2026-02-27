# frozen_string_literal: true

module FlatPack
  module Checkbox
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "text-warning" "h-[var(--checkbox-size)]" "w-[var(--checkbox-size)]" "rounded-[var(--checkbox-radius)]" "focus:rounded-[var(--checkbox-radius)]" "ml-[var(--checkbox-label-gap)]"

      def initialize(
        name:,
        value: "1",
        checked: false,
        label: nil,
        disabled: false,
        required: false,
        error: nil,
        **system_arguments
      )
        @custom_class = system_arguments[:class]
        super(**system_arguments)
        @name = name
        @value = value
        @checked = checked
        @label = label
        @disabled = disabled
        @required = required
        @error = error

        validate_name!
      end

      def call
        content_tag(:div, class: wrapper_classes) do
          safe_join([
            render_checkbox_wrapper,
            render_error
          ].compact)
        end
      end

      private

      def render_checkbox_wrapper
        content_tag(:div, class: "flex items-center") do
          safe_join([
            render_input,
            render_label
          ].compact)
        end
      end

      def render_input
        tag.input(**input_attributes)
      end

      def render_label
        return unless @label

        label_tag(input_id, @label, class: label_classes)
      end

      def render_error
        return unless @error

        content_tag(:p, @error, class: error_classes, id: error_id)
      end

      def input_attributes
        attrs = {
          type: "checkbox",
          name: @name,
          id: input_id,
          value: @value,
          checked: @checked,
          disabled: @disabled,
          required: @required,
          class: input_classes
        }

        attrs[:aria] = {invalid: "true", describedby: error_id} if @error

        merge_attributes(**apply_default_validation(attrs.compact, error_id: error_id, has_error: @error.present?))
      end

      def wrapper_classes
        "flat-pack-checkbox-wrapper"
      end

      def label_classes
        # Ensure 'ml-[var(--checkbox-label-gap)]' is present as a string literal for Tailwind CSS
        classes(
          "ml-[var(--checkbox-label-gap)] text-sm font-medium text-[var(--surface-content-color)]",
          @disabled ? "opacity-50 cursor-not-allowed" : "cursor-pointer"
        )
      end

      def input_classes
        base_classes = [
          "flat-pack-checkbox",
          "h-[var(--checkbox-size)] w-[var(--checkbox-size)]",
          "rounded-[var(--checkbox-radius)]",
          "border",
          "bg-[var(--surface-background-color)]",
          "accent-primary",
          "text-primary",
          "checked:bg-primary checked:border-primary",
          "transition-colors duration-base",
          "focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 focus:rounded-[var(--checkbox-radius)]",
          "cursor-pointer",
          "disabled:opacity-50 disabled:cursor-not-allowed"
        ]

        base_classes << if @error
          "border-warning"
        else
          "border-[var(--surface-border-color)]"
        end

        classes(*base_classes, @custom_class)
      end

      def error_classes
        "mt-1 text-sm text-warning"
      end

      def input_id
        @input_id ||= @system_arguments[:id] || "#{@name.to_s.gsub(/[^a-zA-Z0-9_-]/, "_")}_#{SecureRandom.hex(4)}"
      end

      def error_id
        "#{input_id}_error"
      end

      def validate_name!
        raise ArgumentError, "name is required" if @name.nil? || @name.to_s.strip.empty?
      end
    end
  end
end
