# frozen_string_literal: true

module FlatPack
  module Chip
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "bg-[var(--surface-muted-background-color)]" "text-[var(--surface-content-color)]" "border-[var(--surface-border-color)]" "bg-[var(--color-primary)]" "text-[var(--color-primary-text)]" "border-[var(--color-primary)]" "bg-[var(--color-success-background-color)]" "text-[var(--color-success-text)]" "border-[var(--color-success-border)]" "bg-[var(--color-warning-background-color)]" "text-[var(--color-warning-text)]" "border-[var(--color-warning-border)]" "bg-[var(--color-danger-background-color)]" "text-[var(--color-danger-text-color)]" "border-[var(--color-danger-border-color)]" "bg-[var(--color-secondary)]" "text-[var(--color-secondary-text)]" "border-[var(--color-info-border)]"
      STYLES = {
        default: "bg-[var(--surface-muted-background-color)] text-[var(--surface-content-color)] border-[var(--surface-border-color)]",
        primary: "bg-[var(--color-primary)] text-[var(--color-primary-text)] border-[var(--color-primary)]",
        success: "bg-[var(--color-success-background-color)] text-[var(--color-success-text)] border-[var(--color-success-border)]",
        warning: "bg-[var(--color-warning-background-color)] text-[var(--color-warning-text)] border-[var(--color-warning-border)]",
        danger: "bg-[var(--color-danger-background-color)] text-[var(--color-danger-text-color)] border-[var(--color-danger-border-color)]",
        info: "bg-[var(--color-secondary)] text-[var(--color-secondary-text)] border-[var(--color-info-border)]"
      }.freeze

      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "text-xs" "px-[var(--chip-padding-x-sm)]" "py-[var(--chip-padding-y-sm)]" "text-sm" "px-[var(--chip-padding-x-md)]" "py-[var(--chip-padding-y-md)]" "text-base" "px-[var(--chip-padding-x-lg)]" "py-[var(--chip-padding-y-lg)]"
      SIZES = {
        sm: "text-xs px-[var(--chip-padding-x-sm)] py-[var(--chip-padding-y-sm)]",
        md: "text-sm px-[var(--chip-padding-x-md)] py-[var(--chip-padding-y-md)]",
        lg: "text-base px-[var(--chip-padding-x-lg)] py-[var(--chip-padding-y-lg)]"
      }.freeze

      TYPES = %i[static button link].freeze
      REMOVE_METHODS = %i[get post].freeze

      renders_one :leading_slot
      renders_one :trailing_slot
      renders_one :remove_button_slot

      undef_method :with_leading_slot, :with_trailing_slot, :with_remove_button_slot
      undef_method :with_leading_slot_content, :with_trailing_slot_content, :with_remove_button_slot_content

      def leading(content = nil, **args, &block)
        return leading_slot if content.nil? && args.empty? && !block_given?

        set_slot(:leading_slot, content, **args, &block)
      end

      def trailing(content = nil, **args, &block)
        return trailing_slot if content.nil? && args.empty? && !block_given?

        set_slot(:trailing_slot, content, **args, &block)
      end

      def remove_button(content = nil, **args, &block)
        return remove_button_slot if content.nil? && args.empty? && !block_given?

        set_slot(:remove_button_slot, content, **args, &block)
      end

      def initialize(
        text: nil,
        style: :default,
        size: :md,
        selected: false,
        disabled: false,
        removable: false,
        href: nil,
        type: :static,
        value: nil,
        name: nil,
        remove_url: nil,
        remove_method: :post,
        remove_params: nil,
        **system_arguments
      )
        super(**system_arguments)
        @text = text
        @style = style.to_sym
        @size = size.to_sym
        @selected = selected
        @disabled = disabled
        @removable = removable && !disabled
        @href = href
        @type = type.to_sym
        @value = value
        @name = name
        @remove_url = remove_url.presence
        @remove_method = remove_method.to_sym
        @remove_params = normalize_remove_params(remove_params)

        validate_style!
        validate_size!
        validate_type!
        validate_remove_method!
        validate_remove_url!
      end

      def call
        content_tag(root_tag, **chip_attributes) do
          safe_join([
            leading,
            render_text_or_content,
            trailing,
            render_remove_button_content
          ].compact)
        end
      end

      private

      def root_tag
        return :span if @disabled && @type == :link
        return :button if @type == :button
        return :a if @type == :link
        :span
      end

      def render_text_or_content
        if @text.present?
          @text
        elsif content.present?
          content
        end
      end

      def render_remove_button_content
        return unless @removable
        return if remove_button.present?

        content_tag(:button,
          type: "button",
          class: "ml-1 inline-flex items-center justify-center rounded-full hover:bg-[var(--chip-remove-hover-background-color)]",
          "aria-label": "Remove",
          data: {action: "click->flat-pack--chip#remove"}) do
          # X icon (close)
          content_tag(:svg, xmlns: "http://www.w3.org/2000/svg", class: "h-3 w-3", viewBox: "0 0 20 20", fill: "currentColor") do
            content_tag(:path, nil, "fill-rule": "evenodd", d: "M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z", "clip-rule": "evenodd")
          end
        end
      end

      def chip_attributes
        attrs = {class: chip_classes}

        if chip_controller_enabled?
          attrs[:data] = {
            controller: "flat-pack--chip",
            flat_pack__chip_target: "chip",
            flat_pack__chip_value_value: @value
          }

          if @remove_url.present?
            attrs[:data][:"flat-pack--chip-remove-url-value"] = @remove_url
            attrs[:data][:"flat-pack--chip-remove-method-value"] = @remove_method.to_s
            attrs[:data][:"flat-pack--chip-remove-params-value"] = @remove_params.to_json if @remove_params.present?
          end
        end

        # Add button-specific attributes
        if @type == :button
          attrs[:type] = "button"
          attrs[:disabled] = true if @disabled
          attrs[:aria] = {pressed: @selected.to_s}
        end

        # Add link-specific attributes
        if @type == :link && !@disabled
          attrs[:href] = @href
        end

        merge_attributes(**attrs)
      end

      def chip_classes
        classes(
          "inline-flex items-center gap-1.5",
          "rounded-[var(--chip-border-radius)] font-medium",
          "border",
          "transition-colors duration-base",
          STYLES.fetch(@style),
          SIZES.fetch(@size),
          disabled_classes,
          selected_classes,
          focus_classes
        )
      end

      def disabled_classes
        return unless @disabled
        "opacity-50 cursor-not-allowed"
      end

      def selected_classes
        return unless @selected && @type == :button
        "ring-2 ring-[var(--color-ring)]"
      end

      def focus_classes
        nil
      end

      def chip_controller_enabled?
        @removable || @type == :button
      end

      def validate_style!
        return if STYLES.key?(@style)
        raise ArgumentError, "Invalid style: #{@style}. Must be one of: #{STYLES.keys.join(", ")}"
      end

      def validate_size!
        return if SIZES.key?(@size)
        raise ArgumentError, "Invalid size: #{@size}. Must be one of: #{SIZES.keys.join(", ")}"
      end

      def validate_type!
        return if TYPES.include?(@type)
        raise ArgumentError, "Invalid type: #{@type}. Must be one of: #{TYPES.join(", ")}"
      end

      def validate_remove_method!
        return if REMOVE_METHODS.include?(@remove_method)

        raise ArgumentError, "Invalid remove_method: #{@remove_method}. Must be one of: #{REMOVE_METHODS.join(", ")}"
      end

      def validate_remove_url!
        return if @remove_url.blank?

        sanitized_url = FlatPack::AttributeSanitizer.sanitize_url(@remove_url)
        raise ArgumentError, "Unsafe remove_url detected: #{@remove_url}" if sanitized_url.nil?

        @remove_url = sanitized_url
      end

      def normalize_remove_params(remove_params)
        return if remove_params.nil?
        return remove_params if remove_params.is_a?(Hash)

        raise ArgumentError, "remove_params must be a Hash"
      end
    end
  end
end
