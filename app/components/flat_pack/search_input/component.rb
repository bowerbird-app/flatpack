# frozen_string_literal: true

module FlatPack
  module SearchInput
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
        @help_text = normalize_help_text!(help_text)

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
          field.with_control { render_input_wrapper }
        end
      end

      private

      def render_input_wrapper
        content_tag(:div, class: "relative", data: {controller: "flat-pack--search-input"}) do
          safe_join([
            render_input,
            render_clear_button
          ])
        end
      end

      def render_input
        tag.input(**input_attributes)
      end

      def render_clear_button
        content_tag(:button,
          type: "button",
          class: clear_button_classes,
          data: {
            action: "flat-pack--search-input#clear",
            flat_pack__search_input_target: "clearButton"
          },
          aria: {label: "Clear search"}) do
          render_x_icon
        end
      end

      def render_x_icon
        content_tag(:svg,
          xmlns: "http://www.w3.org/2000/svg",
          width: "16",
          height: "16",
          viewBox: "0 0 24 24",
          fill: "none",
          stroke: "currentColor",
          "stroke-width": "2",
          "stroke-linecap": "round",
          "stroke-linejoin": "round",
          class: "lucide lucide-x") do
          safe_join([
            tag.path(d: "M18 6 6 18"),
            tag.path(d: "m6 6 12 12")
          ])
        end
      end

      def input_attributes
        attrs = {
          type: "search",
          name: @name,
          id: input_id,
          value: @value,
          placeholder: @placeholder,
          disabled: @disabled,
          required: @required,
          class: input_classes,
          data: {
            flat_pack__search_input_target: "input",
            action: "input->flat-pack--search-input#toggleClearButton"
          }
        }

        describedby = describedby_tokens((help_text_id if @help_text), (error_id if @error))
        attrs[:aria] = describedby.present? ? {describedby: describedby} : {}
        attrs[:aria][:invalid] = "true" if @error

        merge_attributes(**apply_default_validation(attrs.compact, error_id: error_id, has_error: @error.present?))
      end

      def wrapper_classes
        "flat-pack-input-wrapper"
      end

      def input_classes
        form_control_classes(
          error: @error,
          custom_class: @custom_class,
          extra: ["pr-10"]
        )
      end

      def clear_button_classes
        "absolute right-3 top-1/2 -translate-y-1/2 text-[var(--surface-muted-content-color)] hover:text-[var(--surface-content-color)] transition-colors hidden"
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
    end
  end
end
