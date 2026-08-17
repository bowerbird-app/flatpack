# frozen_string_literal: true

module FlatPack
  module ChartButtons
    class Component < FlatPack::BaseComponent
      renders_many :controls, ->(component) { component }

      undef_method :with_control, :with_control_content

      def initialize(
        turbo_frame: nil,
        turbo_prefetch: false,
        size: :sm,
        margin_bottom: "mb-3",
        **system_arguments
      )
        super(**system_arguments)
        @turbo_frame = turbo_frame
        @turbo_prefetch = turbo_prefetch
        @size = size
        @margin_bottom = margin_bottom
      end

      def control(component = nil, &block)
        component = capture(&block) if block_given?
        raise ArgumentError, "control requires a component instance or block" if component.blank?

        set_slot(:controls, nil, component)
      end

      def button(
        text:,
        href:,
        selected: false,
        style: nil,
        size: nil,
        data: {},
        aria: {},
        **system_arguments
      )
        control(
          FlatPack::ChartButtons::ButtonComponent.new(
            text: text,
            href: href,
            style: style,
            size: size || @size,
            selected: selected,
            turbo_frame: @turbo_frame,
            turbo_prefetch: @turbo_prefetch,
            data: data,
            aria: aria,
            **system_arguments
          )
        )
      end

      def dropdown(
        text:,
        options:,
        style: :secondary,
        size: nil,
        placement: :bottom_right,
        trigger_attributes: {},
        **system_arguments
      )
        control(
          FlatPack::ChartButtons::DropdownComponent.new(
            text: text,
            options: options,
            style: style,
            size: size || @size,
            placement: placement,
            trigger_attributes: trigger_attributes,
            turbo_frame: @turbo_frame,
            turbo_prefetch: @turbo_prefetch,
            **system_arguments
          )
        )
      end

      def checkbox(
        name:,
        label:,
        href:,
        checked: false,
        checked_value: "1",
        unchecked_value: "0",
        auto_submit: true,
        form_data: {},
        checkbox_data: {},
        submit_label: "Apply",
        **system_arguments
      )
        control(
          FlatPack::ChartButtons::CheckboxComponent.new(
            name: name,
            label: label,
            href: href,
            checked: checked,
            checked_value: checked_value,
            unchecked_value: unchecked_value,
            auto_submit: auto_submit,
            form_data: form_data,
            checkbox_data: checkbox_data,
            submit_label: submit_label,
            turbo_frame: @turbo_frame,
            size: @size,
            **system_arguments
          )
        )
      end

      def call
        content_tag(:div, **container_attributes) do
          safe_join(controls.map { |entry| render_control(entry) })
        end
      end

      private

      def container_attributes
        merge_attributes(
          class: container_classes
        )
      end

      def container_classes
        classes("flex flex-wrap items-center gap-2", @margin_bottom)
      end

      def render_control(entry)
        return render(entry) if entry.respond_to?(:render_in)

        entry.to_s
      end
    end
  end
end
