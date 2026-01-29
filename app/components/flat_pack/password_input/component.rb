# frozen_string_literal: true

module FlatPack
  module PasswordInput
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "text-[var(--color-warning)]" "border-[var(--color-warning)]"

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
            render_input_wrapper,
            render_error
          ].compact)
        end
      end

      private

      def render_label
        return unless @label

        label_tag(input_id, @label, class: label_classes)
      end

      def render_input_wrapper
        content_tag(:div, class: "relative", data: {controller: "flat-pack--password-input"}) do
          safe_join([
            render_input,
            render_toggle_button
          ])
        end
      end

      def render_input
        tag.input(**input_attributes)
      end

      def render_toggle_button
        content_tag(:button,
          type: "button",
          class: toggle_button_classes,
          data: {
            action: "flat-pack--password-input#toggle",
            flat_pack__password_input_target: "toggle"
          },
          aria: {label: "Toggle password visibility"}) do
          safe_join([
            render_eye_icon,
            render_eye_off_icon
          ])
        end
      end

      def render_eye_icon
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
          class: "lucide lucide-eye",
          data: {flat_pack__password_input_target: "eyeIcon"}) do
          safe_join([
            tag.path(d: "M2.062 12.348a1 1 0 0 1 0-.696 10.75 10.75 0 0 1 19.876 0 1 1 0 0 1 0 .696 10.75 10.75 0 0 1-19.876 0"),
            tag.circle(cx: "12", cy: "12", r: "3")
          ])
        end
      end

      def render_eye_off_icon
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
          class: "lucide lucide-eye-off hidden",
          data: {flat_pack__password_input_target: "eyeOffIcon"}) do
          safe_join([
            tag.path(d: "M10.733 5.076a10.744 10.744 0 0 1 11.205 6.575 1 1 0 0 1 0 .696 10.747 10.747 0 0 1-1.444 2.49"),
            tag.path(d: "M14.084 14.158a3 3 0 0 1-4.242-4.242"),
            tag.path(d: "M17.479 17.499a10.75 10.75 0 0 1-15.417-5.151 1 1 0 0 1 0-.696 10.75 10.75 0 0 1 4.446-5.143"),
            tag.path(d: "m2 2 20 20")
          ])
        end
      end

      def render_error
        return unless @error

        content_tag(:p, @error, class: error_classes, id: error_id)
      end

      def input_attributes
        attrs = {
          type: "password",
          name: @name,
          id: input_id,
          value: @value,
          placeholder: @placeholder,
          disabled: @disabled,
          required: @required,
          class: input_classes,
          data: {
            flat_pack__password_input_target: "input"
          }
        }

        attrs[:aria] = {invalid: "true", describedby: error_id} if @error

        merge_attributes(**attrs.compact)
      end

      def wrapper_classes
        "flat-pack-input-wrapper"
      end

      def label_classes
        classes(
          "block text-sm font-medium text-[var(--color-foreground)] mb-1.5"
        )
      end

      def input_classes
        base_classes = [
          "flat-pack-input",
          "w-full",
          "rounded-[var(--radius-md)]",
          "border",
          "bg-[var(--color-background)]",
          "text-[var(--color-foreground)]",
          "px-3 py-2",
          "pr-10",
          "text-sm",
          "transition-colors duration-[var(--transition-base)]",
          "placeholder:text-[var(--color-muted-foreground)]",
          "focus:outline-none focus:ring-2 focus:ring-[var(--color-ring)] focus:border-transparent",
          "disabled:opacity-50 disabled:cursor-not-allowed"
        ]

        base_classes << if @error
          "border-[var(--color-warning)]"
        else
          "border-[var(--color-border)]"
        end

        classes(*base_classes, @custom_class)
      end

      def toggle_button_classes
        "absolute right-3 top-1/2 -translate-y-1/2 text-[var(--color-muted-foreground)] hover:text-[var(--color-foreground)] transition-colors"
      end

      def error_classes
        "mt-1 text-sm text-[var(--color-warning)]"
      end

      def input_id
        @input_id ||= @system_arguments[:id] || "#{@name.to_s.gsub(/[^a-zA-Z0-9_-]/, "_")}_#{SecureRandom.hex(4)}"
      end

      def error_id
        "#{input_id}_error"
      end

      def validate_name!
        raise ArgumentError, "name is required" if @name.nil? || @name.to_s.strip.empty?
      end
    end
  end
end
