# frozen_string_literal: true

module FlatPack
  module CopyButton
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation. They match Button.
      # "inline-flex" "items-center" "justify-center" "gap-2" "font-medium" "cursor-pointer"
      # "border" "fp-button" "fp-button-raised" "fp-button-flat" "fp-touch-manipulation" "fp-hit-target"
      # "rounded-[var(--button-border-radius)]"
      # "px-[var(--button-padding-x-sm)]" "py-[var(--button-padding-y-sm)]" "text-xs"
      # "px-[var(--button-padding-x-md)]" "py-[var(--button-padding-y-md)]" "text-sm"
      # "px-[var(--button-padding-x-lg)]" "py-[var(--button-padding-y-lg)]" "text-base"
      # "p-[var(--button-icon-only-padding-sm)]" "p-[var(--button-icon-only-padding-md)]" "p-[var(--button-icon-only-padding-lg)]"
      # "transition-[color,background-color,border-color,box-shadow,transform]"
      # "duration-[var(--duration-fast)]" "ease-[var(--easing-standard)]"
      # "focus-visible:outline-none" "focus-visible:ring-2" "focus-visible:ring-inset"
      # "focus-visible:ring-[var(--button-focus-ring-color)]" "focus-visible:ring-offset-2"
      # "focus-visible:ring-offset-[var(--button-focus-ring-offset-color)]"
      # "disabled:pointer-events-none" "disabled:opacity-[var(--button-disabled-opacity)]"

      def initialize(
        text: nil,
        target: nil,
        label: FlatPack::Copy::OMITTED,
        icon: "clipboard-document",
        icon_only: false,
        style: :default,
        size: :md,
        timeout: 2000,
        type: "button",
        **system_arguments
      )
        super(**system_arguments)
        @text = text
        @target = target.to_s.strip.presence
        @label = label.equal?(FlatPack::Copy::OMITTED) ? nil : label
        @icon = icon.presence || "clipboard-document"
        @icon_only = icon_only == true
        @style = style.to_sym
        @size = size.to_sym
        @timeout = normalize_timeout(timeout)
        @type = type.to_s
        @disabled = extract_disabled!

        validate_source!
        validate_style!
        validate_size!
      end

      def call
        content_tag(:span, **host_attributes) do
          safe_join([render_button, render_live_region])
        end
      end

      private

      def render_button
        content_tag(:button, **button_attributes) do
          safe_join([render_icons, render_label].compact)
        end
      end

      def render_icons
        content_tag(:span, class: "fp-copy-button__icons", aria: {hidden: "true"}) do
          safe_join([
            render_state_icon("idle", @icon),
            render_state_icon("copied", "check"),
            render_state_icon("error", "exclamation-circle")
          ])
        end
      end

      def render_state_icon(state, name)
        content_tag(:span, data: {icon: state}) do
          render FlatPack::Shared::IconComponent.new(name: name, size: @size)
        end
      end

      def render_label
        return if @icon_only

        content_tag(
          :span,
          idle_name,
          aria: {hidden: "true"},
          data: {flat_pack__clipboard_target: "label"}
        )
      end

      def render_live_region
        content_tag(
          :span,
          "",
          class: "sr-only",
          aria: {live: "polite", atomic: "true"},
          data: {flat_pack__clipboard_target: "live"}
        )
      end

      def host_attributes
        merge_attributes(
          class: "inline-flex",
          data: clipboard_data
        )
      end

      def button_attributes
        {
          type: @type,
          class: button_classes,
          disabled: @disabled,
          data: {
            action: "click->flat-pack--clipboard#copy",
            flat_pack__clipboard_target: "button",
            fp_style: @style.to_s,
            fp_clipboard_state: "idle"
          },
          aria: {label: idle_name}
        }.compact
      end

      def clipboard_data
        {
          controller: "flat-pack--clipboard",
          flat_pack__clipboard_source_value: source_name,
          flat_pack__clipboard_text_value: (@text unless @text.nil?),
          flat_pack__clipboard_target_value: (@target if source_name == "target"),
          flat_pack__clipboard_feedback_value: "button",
          flat_pack__clipboard_timeout_value: @timeout,
          flat_pack__clipboard_icon_value: @icon,
          flat_pack__clipboard_copied_label_value: fp_t("clipboard.copied_label"),
          flat_pack__clipboard_error_label_value: fp_t("clipboard.error_label"),
          flat_pack__clipboard_empty_label_value: fp_t("clipboard.nothing"),
          flat_pack__clipboard_copied_announcement_value: fp_t("clipboard.copied"),
          flat_pack__clipboard_error_announcement_value: fp_t("clipboard.unable"),
          flat_pack__clipboard_empty_announcement_value: fp_t("clipboard.nothing")
        }.compact
      end

      def button_classes
        TailwindMerge::Merger.new.merge(
          [
            "inline-flex items-center justify-center gap-2",
            "rounded-[var(--button-border-radius)]",
            "font-medium",
            "cursor-pointer",
            "fp-button",
            "fp-copy-button",
            FlatPack::Button::StyleRegistry.press_class(@style),
            "border",
            "transition-[color,background-color,border-color,box-shadow,transform] duration-[var(--duration-fast)] ease-[var(--easing-standard)]",
            "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-[var(--button-focus-ring-color)] focus-visible:ring-offset-2 focus-visible:ring-offset-[var(--button-focus-ring-offset-color)]",
            "disabled:pointer-events-none disabled:opacity-[var(--button-disabled-opacity)]",
            "fp-touch-manipulation",
            (@icon_only ? nil : FlatPack::Button::Component::SIZES.fetch(@size)),
            (@icon_only ? "#{FlatPack::Button::Component::ICON_ONLY_SIZES.fetch(@size)} fp-hit-target" : nil)
          ].compact.join(" ")
        )
      end

      def source_name
        @text.nil? ? "target" : "text"
      end

      def idle_name
        @label.presence || fp_t("clipboard.copy")
      end

      def extract_disabled!
        value = @system_arguments.delete(:disabled)
        value = @system_arguments.delete("disabled") if value.nil?
        value == true || value.to_s == "disabled"
      end

      def normalize_timeout(timeout)
        value = Integer(timeout)
        raise ArgumentError, "timeout must be a non-negative integer" if value.negative?

        value
      rescue ArgumentError, TypeError
        raise ArgumentError, "timeout must be a non-negative integer"
      end

      def validate_source!
        return if !@text.nil? || @target.present?

        raise ArgumentError, "Pass text: or target: so the button has something to copy."
      end

      def validate_style!
        return if FlatPack::Button::StyleRegistry.known?(@style)

        raise ArgumentError, FlatPack::Button::StyleRegistry.invalid_style_message(@style)
      end

      def validate_size!
        return if FlatPack::Button::Component::SIZES.key?(@size)

        raise ArgumentError, "Invalid size: #{@size}. Must be one of: #{FlatPack::Button::Component::SIZES.keys.join(", ")}"
      end
    end
  end
end
