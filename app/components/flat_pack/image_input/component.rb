# frozen_string_literal: true

module FlatPack
  module ImageInput
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "h-12 w-12" "h-16 w-16" "h-20 w-20" "h-24 w-24" "h-20 w-36"
      SIZES = {
        md: "h-12 w-12",
        lg: "h-16 w-16",
        xl: "h-20 w-20",
        "2xl": "h-24 w-24",
        wide: "h-20 w-36"
      }.freeze

      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "rounded-[var(--avatar-radius-circle)]" "rounded-[var(--avatar-radius-rounded)]" "rounded-[var(--avatar-radius-square)]"
      SHAPES = {
        circle: "rounded-[var(--avatar-radius-circle)]",
        rounded: "rounded-[var(--avatar-radius-rounded)]",
        square: "rounded-[var(--avatar-radius-square)]"
      }.freeze

      DANGEROUS_EXTENSIONS = %w[.exe .bat .cmd .sh .scr .com .pif .vbs .js .jar .msi .app .deb .rpm .apk .ps1 .psm1 .hta].freeze

      def initialize(
        name:,
        src: nil,
        alt: nil,
        shape: :circle,
        size: :xl,
        icon: "camera",
        edit_icon: "pencil",
        accept: "image/*",
        disabled: false,
        required: false,
        label: nil,
        help_text: nil,
        error: nil,
        clearable: true,
        remove_name: nil,
        input_attributes: {},
        clear_attributes: {},
        **system_arguments
      )
        super(**system_arguments)
        @name = name
        @src = sanitize_src!(src)
        @alt = alt
        @shape = shape.to_sym
        @size = size.to_sym
        @icon = icon
        @edit_icon = edit_icon
        @accept = accept
        @disabled = disabled
        @required = required
        @label = label
        @help_text = normalize_help_text!(help_text)
        @error = error
        @clearable = clearable
        @remove_name = remove_name
        @input_attributes = input_attributes
        @clear_attributes = clear_attributes

        validate_name!
        validate_size!
        validate_shape!
        validate_accept!
        validate_remove_name!
      end

      def call
        render FlatPack::FormField::Component.new(
          label: @label,
          error: @error,
          help_text: @help_text,
          field_id: input_id,
          **form_field_arguments
        ) do |field|
          field.with_control { render_stage }
        end
      end

      private

      def render_stage
        content_tag(:div, **stage_attributes) do
          safe_join([
            render_surface,
            render_clear_button,
            render_remove_input,
            content
          ].compact)
        end
      end

      def render_surface
        content_tag(:label, for: input_id, class: surface_classes) do
          safe_join([
            render_file_input,
            render_empty_layer,
            render_preview,
            render_overlay
          ])
        end
      end

      def render_file_input
        tag.input(**file_input_attributes)
      end

      def render_empty_layer
        content_tag(:span, **empty_layer_attributes) do
          render FlatPack::Shared::IconComponent.new(
            name: @icon,
            size: :lg,
            class: "text-[var(--surface-muted-content-color)]"
          )
        end
      end

      def render_preview
        options = {
          alt: @alt.presence || "",
          class: "absolute inset-0 h-full w-full object-cover",
          data: {flat_pack__image_input_target: "preview"}
        }
        options[:src] = @src if @src.present?
        options[:hidden] = true if @src.blank?
        tag.img(**options)
      end

      def render_overlay
        content_tag(:span, **overlay_attributes) do
          render FlatPack::Shared::IconComponent.new(name: @edit_icon, size: :md)
        end
      end

      def render_clear_button
        return unless @clearable

        tag.button(**clear_button_attributes) do
          render FlatPack::Shared::IconComponent.new(name: "x-mark", size: :sm)
        end
      end

      def render_remove_input
        return if @remove_name.blank?

        tag.input(
          type: "hidden",
          name: @remove_name,
          value: "0",
          autocomplete: "off",
          data: {flat_pack__image_input_target: "remove"}
        )
      end

      def stage_attributes
        attributes = {
          class: ["relative inline-block overflow-visible", ("pointer-events-none" if @disabled)].compact.join(" "),
          data: {
            controller: "flat-pack--image-input",
            flat_pack__image_input_initial_src_value: @src.to_s,
            flat_pack__image_input_clearable_value: @clearable,
            action: stage_actions
          }
        }
        attributes[:aria] = {disabled: "true"} if @disabled
        attributes
      end

      def surface_classes
        [
          "group relative inline-block overflow-hidden",
          SIZES.fetch(@size),
          SHAPES.fetch(@shape),
          "focus-within:outline-2 focus-within:outline-offset-2 focus-within:outline-primary",
          (@error.present? ? "ring-2 ring-[var(--color-error)]" : nil)
        ].compact.join(" ")
      end

      def empty_layer_attributes
        attributes = {
          class: empty_classes,
          data: {flat_pack__image_input_target: "empty"}
        }
        attributes[:hidden] = true if @src.present?
        attributes
      end

      def overlay_attributes
        attributes = {
          class: overlay_classes,
          data: {flat_pack__image_input_target: "overlay"}
        }
        attributes[:hidden] = true if @src.blank?
        attributes
      end

      def stage_actions
        [
          "dragover->flat-pack--image-input#dragOver",
          "dragenter->flat-pack--image-input#dragEnter",
          "dragleave->flat-pack--image-input#dragLeave",
          "drop->flat-pack--image-input#drop"
        ].join(" ")
      end

      def empty_classes
        border = @error.present? ? "border-[var(--color-error)]" : "border-[var(--surface-border-color)]"
        [
          "absolute inset-0 flex items-center justify-center",
          "border-2 border-dashed",
          border,
          "bg-[var(--surface-muted-background-color)]/40",
          "hover:border-primary group-focus-within:border-primary",
          "motion-safe:transition-colors",
          "motion-safe:duration-[var(--duration-fast)]",
          "motion-safe:ease-[var(--easing-standard)]"
        ].join(" ")
      end

      def overlay_classes
        [
          "pointer-events-none absolute inset-0 flex items-center justify-center",
          "bg-black/45 text-white opacity-0",
          "group-hover:opacity-100 group-focus-within:opacity-100",
          "motion-safe:transition-opacity",
          "motion-safe:duration-[var(--duration-base)]",
          "motion-safe:ease-[var(--easing-standard)]"
        ].join(" ")
      end

      def file_input_attributes
        aria = {}
        aria[:label] = accessible_name if @label.blank?
        describedby = describedby_tokens((help_text_id if @help_text), (error_id if @error))
        aria[:describedby] = describedby if describedby.present?
        aria[:invalid] = "true" if @error

        base = {
          id: input_id,
          class: "sr-only",
          accept: @accept,
          data: {
            flat_pack__image_input_target: "input",
            action: "change->flat-pack--image-input#choose"
          },
          aria: aria
        }

        merged = merge_host_attributes(base, @input_attributes, locked: [:type, :name])
        merged[:type] = "file"
        merged[:name] = @name
        merged[:disabled] = true if @disabled
        merged[:required] = true if @required
        apply_default_validation(merged, error_id: error_id, has_error: @error.present?)
      end

      def clear_button_attributes
        base = {
          class: [
            "fp-hit-slop absolute -top-1 -right-1 z-10 size-6 rounded-full shadow-sm",
            "inline-flex items-center justify-center",
            "border border-[var(--surface-border-color)]",
            "bg-[var(--surface-background-color)] text-[var(--surface-content-color)]"
          ].join(" "),
          aria: {label: fp_t("image_input.clear")},
          data: {
            flat_pack__image_input_target: "clear",
            action: "click->flat-pack--image-input#clear"
          }
        }
        merged = merge_host_attributes(base, @clear_attributes, locked: [:type])
        merged[:type] = "button"
        merged[:disabled] = true if @disabled
        merged[:hidden] = true if @src.blank?
        merged
      end

      def merge_host_attributes(base, host, locked:)
        extra = host.to_h.symbolize_keys
        locked.each { |key| extra.delete(key) }
        extra_data = (extra.delete(:data) || {}).symbolize_keys
        extra_aria = (extra.delete(:aria) || {}).symbolize_keys
        extra_class = extra.delete(:class)

        merged = base.merge(extra)
        merged[:class] = [base[:class], extra_class].compact_blank.join(" ")
        merged[:data] = merge_data_attributes(base[:data], extra_data)
        merged[:aria] = (base[:aria] || {}).merge(extra_aria)
        merged.delete(:aria) if merged[:aria].blank?
        merged.compact
      end

      def form_field_arguments
        arguments = @system_arguments.except(:id)
        custom_class = arguments.delete(:class)
        arguments[:class] = ["flat-pack-input-wrapper", custom_class].compact_blank.join(" ")
        arguments
      end

      def accessible_name
        @alt.presence || fp_t("image_input.choose")
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

      def sanitize_src!(src)
        return nil if src.nil? || src.to_s.strip.empty?

        sanitized = FlatPack::AttributeSanitizer.sanitize_url(src)
        raise ArgumentError, "src is not a safe URL" if sanitized.nil?

        sanitized
      end

      def validate_name!
        raise ArgumentError, "name is required" if @name.nil? || @name.to_s.strip.empty?
      end

      def validate_size!
        return if SIZES.key?(@size)

        raise ArgumentError, "Invalid size: #{@size}. Must be one of: #{SIZES.keys.join(", ")}"
      end

      def validate_shape!
        return if SHAPES.key?(@shape)

        raise ArgumentError, "Invalid shape: #{@shape}. Must be one of: #{SHAPES.keys.join(", ")}"
      end

      def validate_accept!
        return if @accept.nil?

        accept_lower = @accept.downcase
        DANGEROUS_EXTENSIONS.each do |ext|
          next unless accept_lower.include?(ext)

          raise ArgumentError, "File type #{ext} is not allowed for security reasons"
        end
      end

      def validate_remove_name!
        return if @remove_name.nil?

        blank = !@remove_name.is_a?(String) || @remove_name.strip.empty?
        raise ArgumentError, "remove_name must be a non-blank string" if blank
        raise ArgumentError, "remove_name must not equal name" if @remove_name == @name.to_s
      end
    end
  end
end
