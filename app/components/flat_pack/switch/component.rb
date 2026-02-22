# frozen_string_literal: true

module FlatPack
  module Switch
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "h-5" "w-9" "h-6" "w-11" "h-7" "w-12"
      SIZES = {
        sm: "h-5 w-9",
        md: "h-6 w-11",
        lg: "h-7 w-12"
      }.freeze

      def initialize(
        name:,
        checked: false,
        label: nil,
        error: nil,
        disabled: false,
        required: false,
        size: :md,
        **system_arguments
      )
        super(**system_arguments)
        @name = name
        @checked = checked
        @label = label
        @error = error
        @disabled = disabled
        @required = required
        @size = size.to_sym

        validate_name!
        validate_size!
      end

      def call
        content_tag(:div, class: wrapper_classes) do
          safe_join([
            render_switch_and_label,
            render_error
          ].compact)
        end
      end

      private

      def render_switch_and_label
        content_tag(:div, class: "flex items-center") do
          safe_join([
            render_switch_container,
            render_label
          ].compact)
        end
      end

      def render_switch_container
        content_tag(:label, class: "relative inline-flex items-center cursor-pointer #{"opacity-50 cursor-not-allowed" if @disabled}") do
          safe_join([
            render_input,
            render_track,
            render_thumb
          ])
        end
      end

      def render_input
        tag.input(**input_attributes)
      end

      def render_track
        content_tag(:div, nil, class: track_classes, role: "switch", "aria-checked": @checked.to_s)
      end

      def render_thumb
        content_tag(:div, nil, class: thumb_classes)
      end

      def render_label
        return unless @label

        content_tag(:span, @label, class: "ml-3 text-sm font-medium text-foreground")
      end

      def render_error
        return unless @error

        content_tag(:span, @error, class: "mt-1 text-sm text-warning")
      end

      def input_attributes
        merge_attributes(type: "checkbox",
          name: @name,
          value: "1",
          checked: @checked,
          disabled: @disabled,
          required: @required,
          class: "sr-only peer")
      end

      def track_classes
        classes(
          "pointer-events-none",
          "rounded-full transition-colors duration-200",
          SIZES.fetch(@size),
          "peer-checked:bg-primary",
          "peer-focus-visible:ring-2 peer-focus-visible:ring-ring peer-focus-visible:ring-offset-2",
          @checked ? "bg-primary" : "bg-muted"
        )
      end

      def thumb_classes
        size_map = {
          sm: {width: "w-4", height: "h-4", translate: "peer-checked:translate-x-4"},
          md: {width: "w-5", height: "h-5", translate: "peer-checked:translate-x-5"},
          lg: {width: "w-6", height: "h-6", translate: "peer-checked:translate-x-5"}
        }

        size_config = size_map.fetch(@size)

        classes(
          "pointer-events-none",
          "absolute left-0.5 top-0",
          "rounded-full bg-white shadow-sm",
          "transition-transform duration-200",
          "translate-y-0.5",
          size_config[:width],
          size_config[:height],
          size_config[:translate]
        )
      end

      def wrapper_classes
        classes("flex flex-col")
      end

      def validate_name!
        return if @name.present?
        raise ArgumentError, "name is required"
      end

      def validate_size!
        return if SIZES.key?(@size)
        raise ArgumentError, "Invalid size: #{@size}. Must be one of: #{SIZES.keys.join(", ")}"
      end
    end
  end
end
