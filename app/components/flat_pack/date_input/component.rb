# frozen_string_literal: true

module FlatPack
  module DateInput
    class Component < FlatPack::BaseComponent
      include FlatPack::FormField::ControlStyles
      include FlatPack::DatePicker::Field

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
        picker: :native,
        chrome: :field,
        **system_arguments
      )
        assign_control_chrome!(chrome)
        @custom_class = system_arguments[:class]
        super(**system_arguments)
        @name = name
        @picker = normalize_picker(picker)
        @value = format_date_value(value)
        @placeholder = placeholder
        @disabled = disabled
        @required = required
        @label = label
        @error = error
        @help_text = normalize_help_text!(help_text)
        @min = format_date_value(min)
        @max = format_date_value(max)

        validate_name!
        validate_picker!
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
        return render_custom_picker if custom_picker_mode?

        tag.input(**native_input_attributes)
      end

      def native_input_attributes
        attrs = {
          type: "date",
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

      def render_custom_picker
        content_tag(:div, **picker_root_attributes) do
          safe_join([
            render_picker_trigger,
            render_picker_hidden_fields,
            render_picker_panel
          ])
        end
      end

      def render_picker_hidden_fields
        tag.input(type: "hidden", name: @name, value: @value, data: {"flat-pack--flatpack-date-picker-target": "singleField"})
      end

      def picker_data_attributes
        existing_controller = data_attributes[:controller]
        controllers = [existing_controller, "flat-pack--flatpack-date-picker"].compact.join(" ")

        data_attributes.merge(
          controller: controllers,
          "flat-pack--flatpack-date-picker-range-value": false,
          "flat-pack--flatpack-date-picker-min-value": @min,
          "flat-pack--flatpack-date-picker-max-value": @max,
          "flat-pack--flatpack-date-picker-value-value": @value,
          "flat-pack--flatpack-date-picker-panel-id-value": panel_id
        ).compact
      end

      def merged_data_attributes
        existing_controller = data_attributes[:controller]
        controllers = [existing_controller, "flat-pack--date-input"].compact.join(" ")

        data_attributes.merge(controller: controllers)
      end

      def input_classes
        form_control_classes(error: @error, custom_class: @custom_class)
      end

      def input_id
        @input_id ||= @system_arguments[:id] || "#{@name.to_s.gsub(/[^a-zA-Z0-9_-]/, "_")}_#{SecureRandom.hex(4)}"
      end

      def validate_name!
        raise ArgumentError, "name is required" if @name.nil? || @name.to_s.strip.empty?
      end

      def validate_picker!
        unless %i[native flatpack_date_picker].include?(@picker)
          raise ArgumentError, "picker must be one of: native, flatpack_date_picker"
        end
      end

      def normalize_picker(picker)
        (picker || :native).to_sym
      end

      def custom_picker_mode?
        @picker == :flatpack_date_picker
      end

      def picker_placeholder
        fp_t("date.select")
      end

      def range_picker?
        false
      end

      def initial_display_value
        @value
      end
    end
  end
end
