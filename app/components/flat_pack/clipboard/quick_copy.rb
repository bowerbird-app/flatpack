# frozen_string_literal: true

module FlatPack
  module Clipboard
    # Shared trailing control for TextInput and TextArea quick_copy.
    # The field click and the icon button both hit flat-pack--clipboard.
    module QuickCopy
      private

      def render_quick_copy_field(target_id:, button_label:, disabled:, button_position: :middle)
        content_tag(:div, class: "fp-quick-copy relative", data: quick_copy_controller_data(target_id)) do
          safe_join([
            yield,
            quick_copy_button(button_label, disabled, button_position)
          ])
        end
      end

      def quick_copy_controller_data(target_id)
        {
          controller: "flat-pack--clipboard",
          flat_pack__clipboard_source_value: "target",
          flat_pack__clipboard_target_value: target_id,
          flat_pack__clipboard_feedback_value: "toast",
          flat_pack__clipboard_icon_value: "clipboard-document",
          action: "click->flat-pack--clipboard#copy"
        }
      end

      def quick_copy_button(button_label, disabled, button_position)
        content_tag(
          :button,
          type: "button",
          class: quick_copy_button_classes(button_position),
          disabled: disabled,
          data: {flat_pack__clipboard_target: "button"},
          aria: {label: button_label}
        ) do
          render FlatPack::Shared::IconComponent.new(name: "clipboard-document", size: :sm)
        end
      end

      # Middle matches a single-line field. Top matches a multi-line textarea.
      # These literals already exist on the previous trailing icon buttons.
      def quick_copy_button_classes(button_position)
        position_class = case button_position
        when :middle
          "absolute right-2 top-1/2 -translate-y-1/2"
        when :top
          "absolute right-2 top-2"
        else
          raise ArgumentError, "button_position must be :middle or :top"
        end

        [
          position_class,
          "inline-flex items-center justify-center",
          "h-6 w-6 rounded",
          "text-[var(--surface-muted-content-color)]",
          "hover:text-[var(--surface-content-color)]",
          "hover:bg-[var(--surface-muted-background-color)]",
          "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-ring",
          "disabled:opacity-50 disabled:cursor-not-allowed"
        ].join(" ")
      end
    end
  end
end
