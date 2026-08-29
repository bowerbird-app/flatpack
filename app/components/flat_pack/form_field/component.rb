# frozen_string_literal: true

module FlatPack
  module FormField
    # Internal shared field chrome: label / control / help_text / optional trailing /
    # error. Public inputs compose this so hosts keep calling TextInput, Select, etc.
    # Not a stable public host API — do not require apps to switch to FormField.
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "text-[var(--color-warning)]" "border-[var(--color-warning)]"
      # "text-[var(--surface-content-color)]" "text-[var(--surface-muted-content-color)]"

      DEFAULT_WRAPPER_CLASS = "flat-pack-input-wrapper"
      DEFAULT_LABEL_CLASS = "block text-sm font-medium text-[var(--surface-content-color)] mb-1.5"
      DEFAULT_ERROR_CLASS = "mt-1 text-sm text-[var(--color-warning)]"
      DEFAULT_HELP_TEXT_CLASS = "mt-1 text-xs text-[var(--surface-muted-content-color)]"

      renders_one :control
      renders_one :after_help

      def initialize(
        field_id:,
        label: nil,
        error: nil,
        help_text: nil,
        help_text_class: DEFAULT_HELP_TEXT_CLASS,
        **system_arguments
      )
        system_arguments[:class] = system_arguments[:class].presence || DEFAULT_WRAPPER_CLASS
        super(**system_arguments)
        @label = label
        @error = error
        @help_text = help_text
        @field_id = field_id
        @help_text_class = help_text_class
      end

      def call
        content_tag(:div, **merge_attributes) do
          safe_join([
            render_label,
            control,
            render_help_text(@help_text, id: help_text_id),
            (after_help if after_help?),
            render_error
          ].compact)
        end
      end

      private

      def render_label
        return unless @label

        label_tag(@field_id, @label, class: DEFAULT_LABEL_CLASS)
      end

      def render_error
        return unless @error

        content_tag(:p, @error, class: DEFAULT_ERROR_CLASS, id: error_id)
      end

      def help_text_classes
        @help_text_class
      end

      def help_text_id
        "#{@field_id}_help_text"
      end

      def error_id
        "#{@field_id}_error"
      end
    end
  end
end
