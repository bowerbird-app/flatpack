# frozen_string_literal: true

module FlatPack
  module ChartButtons
    class CheckboxComponent < FlatPack::BaseComponent
      def initialize(
        name:,
        label:,
        url:,
        checked: false,
        checked_value: "1",
        unchecked_value: "0",
        auto_submit: true,
        form_data: {},
        checkbox_data: {},
        submit_label: "Apply",
        turbo_frame: nil,
        size: :sm,
        **system_arguments
      )
        super(**system_arguments)
        @name = name
        @label = label
        @url = url
        @checked = checked
        @checked_value = checked_value
        @unchecked_value = unchecked_value
        @auto_submit = auto_submit
        @turbo_frame = turbo_frame
        @form_data = merge_form_data(form_data)
        @checkbox_data = merge_checkbox_data(checkbox_data)
        @submit_label = submit_label
        @size = size
      end

      def call
        form_with(url: @url, method: :get, class: "inline-flex items-center gap-2", data: @form_data) do
          safe_join([
            hidden_field_tag(@name, @unchecked_value),
            render(
              FlatPack::Checkbox::Component.new(
                name: @name,
                label: @label,
                value: @checked_value,
                checked: @checked,
                data: @checkbox_data,
                **@system_arguments
              )
            ),
            submit_button_component
          ].compact)
        end
      end

      private

      def submit_button_component
        return nil if @auto_submit

        render FlatPack::Button::Component.new(text: @submit_label, size: @size, type: "submit")
      end

      def merge_form_data(data)
        merged = (data || {}).dup
        frame_override = merged.delete(:turbo_frame) || merged.delete("turbo_frame")
        frame_value = frame_override.nil? ? @turbo_frame : frame_override
        merged[:turbo_frame] = frame_value if frame_value.present?

        return merged unless @auto_submit

        controller = merged[:controller] || merged["controller"]
        merged[:controller] = append_token(controller, "flat-pack--chart-buttons")
        merged
      end

      def merge_checkbox_data(data)
        merged = (data || {}).dup
        return merged unless @auto_submit

        action = merged[:action] || merged["action"]
        merged[:action] = append_token(action, "change->flat-pack--chart-buttons#submitForm")
        merged
      end

      def append_token(existing_value, token)
        tokens = [existing_value, token].compact.flat_map { |value| value.to_s.split }
        tokens.uniq.join(" ")
      end
    end
  end
end
