# frozen_string_literal: true

module FlatPack
  module FileInput
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "text-[var(--color-warning)]" "border-[var(--color-warning)]"
      # "border-[var(--color-border)]" "bg-[var(--color-background)]"
      # "text-[var(--color-foreground)]" "text-[var(--color-muted-foreground)]"

      def initialize(
        name:,
        disabled: false,
        required: false,
        label: nil,
        error: nil,
        accept: nil,
        multiple: false,
        max_size: nil,
        preview: true,
        **system_arguments
      )
        @custom_class = system_arguments[:class]
        super(**system_arguments)
        @name = name
        @disabled = disabled
        @required = required
        @label = label
        @error = error
        @accept = accept
        @multiple = multiple
        @max_size = max_size
        @preview = preview

        validate_name!
        validate_max_size!
        validate_accept!
      end

      def call
        content_tag(:div, class: wrapper_classes) do
          safe_join([
            render_label,
            render_dropzone,
            render_error
          ].compact)
        end
      end

      private

      def render_label
        return unless @label

        label_tag(input_id, @label, class: label_classes)
      end

      def render_dropzone
        content_tag(:div, **dropzone_attributes) do
          safe_join([
            render_hidden_input,
            render_dropzone_content
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
            content_tag(:div, class: "flex justify-center text-sm/6 text-[var(--color-muted-foreground)]") do
              safe_join([
                content_tag(:label, for: input_id, class: "relative cursor-pointer rounded-md bg-transparent font-semibold text-[var(--color-primary)] focus-within:outline-2 focus-within:outline-offset-2 focus-within:outline-[var(--color-primary)] hover:text-[var(--color-primary)]/80") do
                  content_tag(:span, "Upload a file")
                end,
                content_tag(:p, " or drag and drop", class: "pl-1")
              ])
            end
          ]

          if file_constraints_text
            elements << content_tag(:p, file_constraints_text, class: "text-xs/5 text-[var(--color-muted-foreground)]")
          end

          safe_join(elements)
        end
      end

      def render_file_list
        content_tag(:div, "", {
          data: {flat_pack__file_input_target: "fileList"},
          class: "mt-4 space-y-2 hidden"
        })
      end

      def render_preview_area
        return unless @preview

        content_tag(:div, "", {
          data: {flat_pack__file_input_target: "preview"},
          class: "mt-4 grid grid-cols-3 gap-4 hidden"
        })
      end

      def render_validation_error
        content_tag(:div, "", {
          data: {flat_pack__file_input_target: "validationError"},
          class: "mt-2 text-sm text-[var(--color-warning)] hidden"
        })
      end

      def render_error
        return unless @error

        content_tag(:p, @error, class: error_classes, id: error_id)
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
          class: "sr-only",
          data: {
            flat_pack__file_input_target: "input",
            action: "change->flat-pack--file-input#handleFiles"
          }
        }

        attrs[:aria] = {invalid: "true", describedby: error_id} if @error

        merge_attributes(**attrs.compact)
      end

      def dropzone_attributes
        {
          class: dropzone_classes,
          data: {
            controller: "flat-pack--file-input",
            flat_pack__file_input_max_size_value: @max_size,
            flat_pack__file_input_preview_value: @preview,
            flat_pack__file_input_multiple_value: @multiple,
            action: "dragover->flat-pack--file-input#dragOver dragenter->flat-pack--file-input#dragEnter dragleave->flat-pack--file-input#dragLeave drop->flat-pack--file-input#drop"
          }.compact
        }
      end

      def icon_attributes
        {
          class: "mx-auto size-12 text-[var(--color-muted-foreground)]/30",
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
          "block text-sm font-medium text-[var(--color-foreground)] mb-1.5"
        )
      end

      def dropzone_classes
        base_classes = [
          "flat-pack-file-input",
          "mt-2",
          "flex justify-center",
          "w-full",
          "rounded-lg",
          "border border-dashed",
          "bg-[var(--color-background)]",
          "px-6 py-10",
          "transition-colors duration-[var(--transition-base)]",
          "hover:border-[var(--color-primary)]",
          "disabled:opacity-50 disabled:cursor-not-allowed"
        ]

        base_classes << if @error
          "border-[var(--color-warning)]"
        else
          "border-[var(--color-border)]"
        end

        classes(*base_classes, @custom_class)
      end

      def dropzone_text_classes
        "mt-4"
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

      def file_constraints_text
        constraints = []
        constraints << @accept.split(",").map(&:strip).join(", ") if @accept
        constraints << "Max size: #{format_file_size(@max_size)}" if @max_size
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

      def validate_name!
        raise ArgumentError, "name is required" if @name.nil? || @name.to_s.strip.empty?
      end

      def validate_max_size!
        return if @max_size.nil?

        max_size_value = @max_size.to_i
        if max_size_value <= 0
          raise ArgumentError, "max_size must be a positive number"
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
