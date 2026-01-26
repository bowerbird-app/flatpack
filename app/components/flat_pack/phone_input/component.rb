# frozen_string_literal: true

module FlatPack
  module PhoneInput
    class Component < FlatPack::BaseComponent
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
        @value = value
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
          type: 'tel',
          name: @name,
          id: input_id,
          value: @value,
          placeholder: @placeholder,
          disabled: @disabled,
          required: @required,
          class: input_classes
        }

        attrs[:aria] = { invalid: 'true', describedby: error_id } if @error

        merge_attributes(**attrs.compact)
      end

      def wrapper_classes
        'flat-pack-input-wrapper'
      end

      def label_classes
        classes(
          'block text-sm font-medium text-[var(--color-foreground)] mb-1.5'
        )
      end

      def input_classes
        base_classes = [
          'flat-pack-input',
          'w-full',
          'rounded-[var(--radius-md)]',
          'border',
          'bg-[var(--color-background)]',
          'text-[var(--color-foreground)]',
          'px-3 py-2',
          'text-sm',
          'transition-colors duration-[var(--transition-base)]',
          'placeholder:text-[var(--color-muted-foreground)]',
          'focus:outline-none focus:ring-2 focus:ring-[var(--color-ring)] focus:border-transparent',
          'disabled:opacity-50 disabled:cursor-not-allowed'
        ]

        base_classes << if @error
                          'border-[var(--color-destructive)]'
                        else
                          'border-[var(--color-border)]'
                        end

        classes(*base_classes, @custom_class)
      end

      def error_classes
        'mt-1.5 text-sm text-[var(--color-destructive)]'
      end

      def input_id
        @input_id ||= @system_arguments[:id] || "#{@name.to_s.gsub(/[^a-zA-Z0-9_-]/, '_')}_#{SecureRandom.hex(4)}"
      end

      def error_id
        "#{input_id}_error"
      end

      def validate_name!
        raise ArgumentError, 'name is required' if @name.nil? || @name.to_s.strip.empty?
      end
    end
  end
end
