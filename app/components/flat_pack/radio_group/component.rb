# frozen_string_literal: true

module FlatPack
  module RadioGroup
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "text-[var(--color-warning)]"

      def initialize(
        name:,
        options:,
        value: nil,
        label: nil,
        disabled: false,
        required: false,
        error: nil,
        **system_arguments
      )
        @custom_class = system_arguments[:class]
        super(**system_arguments)
        @name = name
        @raw_options = options
        @options = normalize_options(options)
        @value = value
        @label = label
        @disabled = disabled
        @required = required
        @error = error

        validate_name!
        validate_options!
      end

      def call
        content_tag(:div, class: wrapper_classes) do
          safe_join([
            render_label,
            render_radio_group,
            render_error
          ].compact)
        end
      end

      private

      def render_label
        return unless @label

        content_tag(:legend, @label, class: label_classes)
      end

      def render_radio_group
        content_tag(:fieldset, class: "space-y-2") do
          safe_join(@options.map { |option| render_radio_option(option) })
        end
      end

      def render_radio_option(option)
        option_value = option[:value]
        option_label = option[:label]
        option_disabled = option[:disabled] || @disabled
        checked = @value.to_s == option_value.to_s

        content_tag(:div, class: "flex items-center") do
          safe_join([
            tag.input(**radio_attributes(option_value, checked, option_disabled)),
            label_tag(radio_id(option_value), option_label, class: radio_label_classes(option_disabled))
          ])
        end
      end

      def render_error
        return unless @error

        content_tag(:p, @error, class: error_classes, id: error_id)
      end

      def radio_attributes(option_value, checked, option_disabled)
        attrs = {
          type: "radio",
          name: @name,
          id: radio_id(option_value),
          value: option_value,
          checked: checked,
          disabled: option_disabled,
          required: @required,
          class: radio_classes
        }

        attrs[:aria] = {invalid: "true", describedby: error_id} if @error

        attrs.compact
      end

      def wrapper_classes
        "flat-pack-radio-group-wrapper"
      end

      def label_classes
        classes(
          "block text-sm font-medium text-[var(--color-foreground)] mb-2"
        )
      end

      def radio_label_classes(disabled)
        classes(
          "ml-2 text-sm font-medium text-[var(--color-foreground)]",
          disabled ? "opacity-50 cursor-not-allowed" : "cursor-pointer"
        )
      end

      def radio_classes
        base_classes = [
          "flat-pack-radio",
          "h-4 w-4",
          "rounded-full",
          "border",
          "bg-[var(--color-background)]",
          "text-[var(--color-primary)]",
          "transition-colors duration-[var(--transition-base)]",
          "focus:outline-none focus:ring-2 focus:ring-[var(--color-ring)] focus:ring-offset-2",
          "disabled:opacity-50 disabled:cursor-not-allowed"
        ]

        base_classes << if @error
          "border-[var(--color-warning)]"
        else
          "border-[var(--color-border)]"
        end

        classes(*base_classes, @custom_class)
      end

      def error_classes
        "mt-2 text-sm text-[var(--color-warning)]"
      end

      def radio_id(option_value)
        "#{@name.to_s.gsub(/[^a-zA-Z0-9_-]/, "_")}_#{option_value.to_s.gsub(/[^a-zA-Z0-9_-]/, "_")}"
      end

      def error_id
        "#{@name.to_s.gsub(/[^a-zA-Z0-9_-]/, "_")}_error"
      end

      def normalize_options(options)
        return [] if options.nil?

        options.map do |option|
          case option
          when String
            {label: option, value: option, disabled: false}
          when Array
            {label: option[0], value: option[1], disabled: false}
          when Hash
            {
              label: option[:label] || option["label"],
              value: option[:value] || option["value"],
              disabled: option[:disabled] || option["disabled"] || false
            }
          else
            raise ArgumentError, "Invalid option format: #{option.inspect}"
          end
        end
      end

      def validate_name!
        raise ArgumentError, "name is required" if @name.nil? || @name.to_s.strip.empty?
      end

      def validate_options!
        raise ArgumentError, "options is required" if @raw_options.nil?
        raise ArgumentError, "options must be an array" unless @raw_options.is_a?(Array)
        raise ArgumentError, "options cannot be empty" if @raw_options.empty?
      end
    end
  end
end
