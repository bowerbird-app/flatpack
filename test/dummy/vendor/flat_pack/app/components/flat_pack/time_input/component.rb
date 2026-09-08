# frozen_string_literal: true

module FlatPack
  module TimeInput
    class Component < FlatPack::BaseComponent
      include FlatPack::FormField::ControlStyles

      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "text-[var(--color-error)]" "border-[var(--color-error)]"

      def initialize(
        name:,
        value: nil,
        placeholder: nil,
        disabled: false,
        required: false,
        label: nil,
        error: nil,
        help_text: nil,
        min: nil,
        max: nil,
        **system_arguments
      )
        @custom_class = system_arguments[:class]
        super(**system_arguments)
        @name = name
        @value = format_time_value(value)
        @placeholder = placeholder
        @disabled = disabled
        @required = required
        @label = label
        @error = error
        @help_text = normalize_help_text!(help_text)
        @min = format_time_value(min)
        @max = format_time_value(max)

        validate_name!
      end

      def call
        render FlatPack::FormField::Component.new(
          label: @label,
          error: @error,
          help_text: @help_text,
          field_id: input_id,
          class: wrapper_classes
        ) do |field|
          field.with_control { render_input }
        end
      end

      private

      def render_input
        tag.input(**input_attributes)
      end

      def input_attributes
        attrs = {
          type: "time",
          name: @name,
          id: input_id,
          value: @value,
          placeholder: @placeholder,
          disabled: @disabled,
          required: @required,
          min: @min,
          max: @max,
          class: input_classes,
          data: merged_data_attributes
        }

        describedby = describedby_tokens((help_text_id if @help_text), (error_id if @error))
        attrs[:aria] = describedby.present? ? {describedby: describedby} : {}
        attrs[:aria][:invalid] = "true" if @error

        merge_attributes(**apply_default_validation(attrs.compact, error_id: error_id, has_error: @error.present?))
      end

      def merged_data_attributes
        existing_controller = data_attributes[:controller]
        controllers = [existing_controller, "flat-pack--date-input"].compact.join(" ")

        data_attributes.merge(controller: controllers)
      end

      def wrapper_classes
        "flat-pack-input-wrapper"
      end

      def input_classes
        form_control_classes(error: @error, custom_class: @custom_class)
      end

      def input_id
        @input_id ||= @system_arguments[:id] || "#{@name.to_s.gsub(/[^a-zA-Z0-9_-]/, "_")}_#{SecureRandom.hex(4)}"
      end

      def error_id
        "#{input_id}_error"
      end

      def help_text_id
        "#{input_id}_help_text"
      end

      def validate_name!
        raise ArgumentError, "name is required" if @name.nil? || @name.to_s.strip.empty?
      end

      # Convert Time objects to HH:MM format string.
      # Accepts Date, Time, DateTime objects or strings.
      def format_time_value(value)
        return nil if value.nil?
        return value if value.is_a?(String)

        if value.respond_to?(:strftime)
          value.strftime("%H:%M")
        else
          value.to_s
        end
      end
    end
  end
end
