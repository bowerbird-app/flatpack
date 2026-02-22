# frozen_string_literal: true

module FlatPack
  module UrlInput
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "text-warning" "border-warning"

      def initialize(
        name:,
        value: nil,
        placeholder: nil,
        disabled: false,
        required: false,
        label: nil,
        error: nil,
        **system_arguments
      )
        @custom_class = system_arguments[:class]
        super(**system_arguments)
        @name = name
        @value = sanitize_value(value)
        @placeholder = placeholder
        @disabled = disabled
        @required = required
        @label = label
        @error = error

        validate_name!
      end

      def call
        content_tag(:div, class: wrapper_classes) do
          safe_join([
            render_label,
            render_input,
            render_error
          ].compact)
        end
      end

      private

      def render_label
        return unless @label

        label_tag(input_id, @label, class: label_classes)
      end

      def render_input
        tag.input(**input_attributes)
      end

      def render_error
        return unless @error

        content_tag(:p, @error, class: error_classes, id: error_id)
      end

      def input_attributes
        attrs = {
          type: "url",
          name: @name,
          id: input_id,
          value: @value,
          placeholder: @placeholder,
          disabled: @disabled,
          required: @required,
          class: input_classes
        }

        attrs[:aria] = {invalid: "true", describedby: error_id} if @error

        merge_attributes(**attrs.compact)
      end

      def wrapper_classes
        "flat-pack-input-wrapper"
      end

      def label_classes
        classes(
          "block text-sm font-medium text-foreground mb-1.5"
        )
      end

      def input_classes
        base_classes = [
          "flat-pack-input",
          "w-full",
          "rounded-md",
          "border",
          "bg-background",
          "text-foreground",
          "px-[var(--form-control-padding)] py-[var(--form-control-padding)]",
          "text-sm",
          "transition-colors duration-base",
          "placeholder:text-muted-foreground",
          "focus:outline-none focus:ring-2 focus:ring-ring focus:border-transparent",
          "disabled:opacity-50 disabled:cursor-not-allowed"
        ]

        base_classes << if @error
          "border-warning"
        else
          "border-border"
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

      def sanitize_value(value)
        return nil if value.nil?

        FlatPack::AttributeSanitizer.sanitize_url(value)
      end

      def validate_name!
        raise ArgumentError, "name is required" if @name.nil? || @name.to_s.strip.empty?
      end
    end
  end
end
