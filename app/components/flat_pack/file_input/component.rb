# frozen_string_literal: true

module FlatPack
  module FileInput
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "text-[var(--color-error)]" "border-[var(--color-error)]"
      # "border-[var(--surface-border-color)]" "bg-[var(--surface-background-color)]"
      # "text-[var(--surface-content-color)]" "text-[var(--surface-muted-content-color)]"
      # "flex" "flex-col" "items-center" "items-start" "gap-2" "gap-4"
      # "sm:flex-row" "sm:items-start" "min-w-0" "flex-1" "w-full" "max-w-xs" "shrink-0"
      # "sr-only" "text-center" "text-left"

      VARIANTS = %i[dropzone button].freeze

      DRAG_ACTIONS = "dragover->flat-pack--file-input#dragOver dragenter->flat-pack--file-input#dragEnter dragleave->flat-pack--file-input#dragLeave drop->flat-pack--file-input#drop"

      renders_one :actions

      undef_method :with_actions, :with_actions_content

      def initialize(
        name:,
        variant: :dropzone,
        text: nil,
        style: nil,
        size: nil,
        round: nil,
        icon: nil,
        icon_variant: nil,
        icon_style: nil,
        disabled: false,
        required: false,
        label: nil,
        error: nil,
        help_text: nil,
        accept: nil,
        multiple: false,
        max_size: nil,
        max_files: nil,
        preview: true,
        show_file_list: true,
        **system_arguments
      )
        @custom_class = system_arguments.delete(:class)
        super(**system_arguments)
        @name = name
        @variant = variant
        @text = text
        @style = style
        @size = size
        @round = round
        @icon = icon
        @icon_variant = icon_variant
        @icon_style = icon_style
        @disabled = disabled
        @required = required
        @label = label
        @error = error
        @help_text = normalize_help_text!(help_text)
        @accept = accept
        @multiple = multiple
        @max_size = max_size
        @max_files = max_files
        @preview = preview
        @show_file_list = show_file_list

        validate_name!
        validate_variant!
        validate_button_only_options!
        validate_max_size!
        validate_max_files!
        validate_accept!
      end

      def call
        content_tag(:div, class: wrapper_classes) do
          safe_join([
            render_label,
            render_field,
            render_help_text,
            render_error
          ].compact)
        end
      end

      def actions(*args, **kwargs, &block)
        return get_slot(:actions) if args.empty? && kwargs.empty? && !block

        set_slot(:actions, nil, *args, **kwargs, &block)
      end

      private

      def render_label
        return unless @label

        label_tag(input_id, @label, class: label_classes)
      end

      def render_field
        control = button_variant? ? render_button_stack : render_dropzone
        return content_tag(:div, control, class: "mt-2") unless actions?

        content_tag(:div, class: "mt-2 flex flex-col gap-4 sm:flex-row sm:items-start") do
          safe_join([
            content_tag(:div, control, class: "min-w-0 flex-1"),
            content_tag(:div, actions, **actions_attributes)
          ])
        end
      end

      def render_button_stack
        content_tag(:div, class: "flex flex-col items-start gap-2", data: controller_data) do
          safe_join([
            render_button,
            render_hidden_input,
            render_limit_message
          ])
        end
      end

      def render_button
        render(FlatPack::Button::Component.new(**button_arguments))
      end

      def render_dropzone
        content_tag(:div, **dropzone_attributes) do
          safe_join([
            render_hidden_input,
            render_dropzone_content,
            render_limit_message
          ])
        end
      end

      def render_hidden_input
        tag.input(**input_attributes)
      end

      def render_dropzone_content
        content_tag(:div, class: "text-center") do
          safe_join([
            render_upload_icon,
            render_dropzone_text,
            render_validation_error,
            render_file_list,
            render_preview_area
          ].compact)
        end
      end

      def render_upload_icon
        content_tag(:svg, **icon_attributes) do
          tag.path(d: "M1.5 6a2.25 2.25 0 0 1 2.25-2.25h16.5A2.25 2.25 0 0 1 22.5 6v12a2.25 2.25 0 0 1-2.25 2.25H3.75A2.25 2.25 0 0 1 1.5 18V6ZM3 16.06V18c0 .414.336.75.75.75h16.5A.75.75 0 0 0 21 18v-1.94l-2.69-2.689a1.5 1.5 0 0 0-2.12 0l-.88.879.97.97a.75.75 0 1 1-1.06 1.06l-5.16-5.159a1.5 1.5 0 0 0-2.12 0L3 16.061Zm10.125-7.81a1.125 1.125 0 1 1 2.25 0 1.125 1.125 0 0 1-2.25 0Z", clip_rule: "evenodd", fill_rule: "evenodd")
        end
      end

      def render_dropzone_text
        content_tag(:div, class: dropzone_text_classes) do
          elements = [
            content_tag(:div, class: "flex justify-center text-sm/6 text-[var(--surface-muted-content-color)]") do
              safe_join([
                content_tag(:button, type: "button", class: "relative cursor-pointer rounded-[var(--radius-md)] bg-transparent font-semibold text-primary focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-primary hover:text-primary/80", data: {action: "flat-pack--file-input#clickInput"}) do
                  content_tag(:span, fp_t("file_input.upload"))
                end,
                content_tag(:p, fp_t("file_input.or_drag"), class: "pl-1")
              ])
            end
          ]

          if file_constraints_text
            elements << content_tag(:p, file_constraints_text, class: "text-xs/5 text-[var(--surface-muted-content-color)]")
          end

          safe_join(elements)
        end
      end

      def render_file_list
        return unless show_built_in_list?

        content_tag(:div, "", {
          data: {flat_pack__file_input_target: "fileList"},
          class: "mt-4 space-y-2 hidden"
        })
      end

      def render_preview_area
        return unless @preview && show_built_in_list?

        content_tag(:div, "", {
          data: {flat_pack__file_input_target: "preview"},
          class: "mt-4 grid grid-cols-3 gap-4 hidden"
        })
      end

      def render_validation_error
        content_tag(:div, "", {
          data: {flat_pack__file_input_target: "validationError"},
          class: "mt-2 text-sm text-[var(--color-error)] hidden"
        })
      end

      def render_limit_message
        content_tag(
          :p,
          "",
          id: limit_message_id,
          role: "status",
          aria: {live: "polite"},
          data: {flat_pack__file_input_target: "limitMessage"},
          class: limit_message_classes
        )
      end

      def render_error
        return unless @error

        content_tag(:p, @error, class: error_classes, id: error_id)
      end

      def button_arguments
        args = {
          text: button_text,
          style: button_style,
          size: button_size,
          type: "button",
          disabled: @disabled,
          data: {
            action: "flat-pack--file-input#clickInput",
            flat_pack__file_input_target: "button"
          }
        }
        args[:round] = @round unless @round.nil?
        args[:icon] = @icon if @icon.present?
        args[:icon_variant] = @icon_variant unless @icon_variant.nil?
        args[:icon_style] = @icon_style unless @icon_style.nil?
        args[:class] = @custom_class if @custom_class.present?
        describedby = field_describedby
        args[:aria] = {describedby: describedby} if describedby.present?
        args
      end

      def button_text
        @text.presence || fp_t("file_input.choose")
      end

      def button_style
        (@style || :primary).to_sym
      end

      def button_size
        (@size || :md).to_sym
      end

      def input_attributes
        attrs = {
          type: "file",
          name: @name,
          id: input_id,
          disabled: @disabled,
          required: @required,
          accept: @accept,
          multiple: @multiple,
          class: button_variant? ? "sr-only" : "hidden",
          data: {
            flat_pack__file_input_target: "input",
            action: "change->flat-pack--file-input#handleFiles"
          }
        }
        attrs[:tabindex] = -1 if button_variant?

        describedby = field_describedby
        attrs[:aria] = describedby.present? ? {describedby: describedby} : {}
        attrs[:aria][:invalid] = "true" if @error
        attrs[:aria][:label] = button_text if button_variant? && @label.blank?

        merge_attributes(**apply_default_validation(attrs.compact, error_id: error_id, has_error: @error.present?))
      end

      def dropzone_attributes
        {
          class: dropzone_classes,
          data: controller_data
        }
      end

      def controller_data
        {
          controller: "flat-pack--file-input",
          action: DRAG_ACTIONS,
          flat_pack__file_input_max_size_value: @max_size,
          flat_pack__file_input_preview_value: show_built_in_list? ? @preview : false,
          flat_pack__file_input_multiple_value: @multiple,
          flat_pack__file_input_max_files_value: @max_files,
          flat_pack__file_input_limit_message_value: limit_message_text,
          flat_pack__file_input_show_list_value: show_built_in_list?
        }.compact
      end

      def actions_attributes
        {
          class: "w-full max-w-xs shrink-0",
          data: {flat_pack_file_input_actions: true}
        }
      end

      def icon_attributes
        {
          class: "mx-auto size-12 text-[var(--surface-muted-content-color)]/30",
          fill: "currentColor",
          viewBox: "0 0 24 24",
          "aria-hidden": "true"
        }
      end

      def wrapper_classes
        "flat-pack-input-wrapper"
      end

      def label_classes
        classes(
          "block text-sm font-medium text-[var(--surface-content-color)] mb-1.5"
        )
      end

      def dropzone_classes
        base_classes = [
          "flat-pack-file-input",
          "flex flex-col items-center",
          "w-full",
          "rounded-[var(--radius-lg)]",
          "border border-dashed",
          "bg-[var(--surface-background-color)]",
          "px-6 py-10",
          "transition-colors duration-base",
          "hover:border-primary",
          "disabled:opacity-50 disabled:cursor-not-allowed"
        ]

        base_classes << if @error
          "border-[var(--color-error)]"
        else
          "border-[var(--surface-border-color)]"
        end

        classes(*base_classes, @custom_class)
      end

      def dropzone_text_classes
        "mt-4"
      end

      def limit_message_classes
        alignment = button_variant? ? "text-left" : "text-center"
        "mt-2 w-full #{alignment} text-sm text-[var(--surface-content-color)] hidden"
      end

      def error_classes
        "mt-1 text-sm text-[var(--color-error)]"
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

      def limit_message_id
        "#{input_id}_limit"
      end

      def field_describedby
        describedby_tokens(
          (help_text_id if @help_text),
          (error_id if @error),
          (limit_message_id if @max_files)
        )
      end

      def limit_message_text
        return if @max_files.nil?

        if @max_files == 1
          fp_t("file_input.too_many_one")
        else
          fp_t("file_input.too_many", count: @max_files)
        end
      end

      def file_constraints_text
        constraints = []
        constraints << @accept.split(",").map(&:strip).join(", ") if @accept
        constraints << fp_t("file_input.max_size", size: format_file_size(@max_size)) if @max_size
        constraints.join(" • ") if constraints.any?
      end

      def format_file_size(bytes)
        return "" unless bytes

        if bytes < 1024
          "#{bytes}B"
        elsif bytes < 1024 * 1024
          "#{(bytes / 1024.0).round(1)}KB"
        else
          "#{(bytes / (1024.0 * 1024.0)).round(1)}MB"
        end
      end

      def button_variant?
        @variant == :button
      end

      def show_built_in_list?
        !button_variant? && @show_file_list
      end

      def validate_name!
        raise ArgumentError, "name is required" if @name.nil? || @name.to_s.strip.empty?
      end

      def validate_variant!
        if @variant.nil? || !VARIANTS.include?(@variant.to_sym)
          raise ArgumentError, "variant must be one of: #{VARIANTS.join(", ")}"
        end

        @variant = @variant.to_sym
      end

      def validate_button_only_options!
        return if button_variant?

        extras = []
        extras << "text" if @text.present?
        extras << "style" unless @style.nil?
        extras << "size" unless @size.nil?
        extras << "round" unless @round.nil?
        extras << "icon" if @icon.present?
        extras << "icon_variant" unless @icon_variant.nil?
        extras << "icon_style" unless @icon_style.nil?
        return if extras.empty?

        verb = extras.one? ? "is" : "are"
        raise ArgumentError, "#{extras.join(", ")} #{verb} only for variant: :button"
      end

      def validate_max_size!
        return if @max_size.nil?

        max_size_value = @max_size.to_i
        if max_size_value <= 0
          raise ArgumentError, "max_size must be a positive number"
        end
      end

      def validate_max_files!
        return if @max_files.nil?

        unless @max_files.is_a?(Integer) && @max_files.positive?
          raise ArgumentError, "max_files must be a positive integer"
        end
      end

      def validate_accept!
        return if @accept.nil?

        # Block dangerous file types
        dangerous_extensions = %w[.exe .bat .cmd .sh .scr .com .pif .vbs .js .jar .msi .app .deb .rpm .apk .ps1 .psm1 .hta]
        accept_lower = @accept.downcase

        dangerous_extensions.each do |ext|
          if accept_lower.include?(ext)
            raise ArgumentError, "File type #{ext} is not allowed for security reasons"
          end
        end
      end
    end
  end
end
