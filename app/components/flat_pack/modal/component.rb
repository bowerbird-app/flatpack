# frozen_string_literal: true

module FlatPack
  module Modal
    class Component < FlatPack::BaseComponent
      renders_one :header
      renders_one :body
      renders_one :footer

      undef_method :with_header, :with_header_content
      undef_method :with_body, :with_body_content
      undef_method :with_footer, :with_footer_content

      def header(*args, **kwargs, &block)
        return get_slot(:header) if args.empty? && kwargs.empty? && !block_given?

        set_slot(:header, nil, *args, **kwargs, &block)
      end

      def body(*args, **kwargs, &block)
        return get_slot(:body) if args.empty? && kwargs.empty? && !block_given?

        set_slot(:body, nil, *args, **kwargs, &block)
      end

      def footer(*args, **kwargs, &block)
        return get_slot(:footer) if args.empty? && kwargs.empty? && !block_given?

        set_slot(:footer, nil, *args, **kwargs, &block)
      end

      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "max-w-sm" "max-w-xl" "max-w-2xl" "max-w-4xl" "max-w-6xl"
      SIZES = {
        sm: "max-w-sm",
        md: "max-w-xl",
        lg: "max-w-2xl",
        xl: "max-w-4xl",
        "2xl": "max-w-6xl"
      }.freeze

      BODY_HEIGHT_MODES = %i[auto fixed min].freeze

      def initialize(
        id:,
        title: nil,
        size: :md,
        body_height_mode: :auto,
        body_height: nil,
        close_on_backdrop: true,
        close_on_escape: true,
        **system_arguments
      )
        super(**system_arguments)
        @modal_id = id
        @title = title
        @size = size.to_sym
        @body_height_mode = body_height_mode.to_sym
        @body_height = body_height
        @close_on_backdrop = close_on_backdrop
        @close_on_escape = close_on_escape

        validate_id!
        validate_size!
        validate_body_height_mode!
        validate_body_height!
      end

      def call
        content_tag(:div, **backdrop_attributes) do
          safe_join([
            render_backdrop,
            render_dialog
          ])
        end
      end

      private

      def backdrop_attributes
        merge_attributes(
          id: @modal_id,
          class: backdrop_classes,
          data: {
            controller: "flat-pack--modal",
            "flat-pack--modal-close-on-backdrop-value": @close_on_backdrop,
            "flat-pack--modal-close-on-escape-value": @close_on_escape,
            action: action_attributes
          },
          aria: {
            hidden: "true"
          }
        )
      end

      def action_attributes
        actions = []
        actions << "keydown.esc->flat-pack--modal#close" if @close_on_escape
        actions.join(" ")
      end

      def backdrop_classes
        classes(
          "fixed",
          "inset-0",
          "z-50",
          "hidden",
          "overflow-y-auto",
          "bg-[var(--modal-backdrop-color)]",
          "backdrop-blur-[var(--modal-backdrop-blur)]",
          "transition-opacity",
          "duration-300"
        )
      end

      def render_backdrop
        # Empty div that acts as clickable backdrop
        content_tag(:div,
          nil,
          class: "absolute inset-0",
          data: {action: "click->flat-pack--modal#clickBackdrop"})
      end

      def render_dialog
        content_tag(:div, class: dialog_wrapper_classes) do
          content_tag(:div, **dialog_attributes) do
            safe_join([
              render_header_section || render_close_button_row,
              render_body_content,
              render_footer_content
            ].compact)
          end
        end
      end

      def dialog_wrapper_classes
        "relative flex w-full min-h-screen items-start sm:items-center justify-center p-4 sm:p-6"
      end

      def dialog_attributes
        attributes = {
          role: "dialog",
          aria: {
            modal: "true"
          },
          class: dialog_classes,
          data: {
            "flat-pack--modal-target": "dialog"
          }
        }

        attributes[:aria][:labelledby] = header_id if header_section?
        attributes
      end

      def dialog_classes
        classes(
          "relative",
          "flex",
          "flex-col",
          "min-h-0",
          "max-h-[calc(100vh-2rem)]",
          "w-full",
          "overflow-hidden",
          size_classes,
          "p-4",
          "sm:p-6",
          "bg-[var(--modal-surface-color)]",
          "rounded-lg",
          "shadow-lg",
          "border",
          "border-[var(--modal-border-color)]",
          "transform",
          "transition-all",
          "duration-300",
          "scale-95",
          "opacity-0"
        )
      end

      def size_classes
        SIZES.fetch(@size)
      end

      def render_close_button
        content_tag(:button,
          type: "button",
          class: close_button_classes,
          aria: {label: "Close"},
          data: {action: "flat-pack--modal#close"}) do
          close_icon
        end
      end

      def close_button_classes
        "shrink-0 cursor-pointer text-[var(--modal-close-icon-color)] hover:text-[var(--modal-close-icon-hover-color)] transition-colors rounded-sm p-1 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
      end

      def render_header_section
        return nil unless header_section?

        content_tag(:div, class: header_wrapper_classes) do
          safe_join([
            render_header_content,
            render_close_button
          ])
        end
      end

      def render_close_button_row
        content_tag(:div, class: close_button_row_classes) { render_close_button }
      end

      def close_icon
        content_tag(:svg, class: "w-5 h-5", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor") do
          tag.path(
            "stroke-linecap": "round",
            "stroke-linejoin": "round",
            "stroke-width": "2",
            d: "M6 18L18 6M6 6l12 12"
          )
        end
      end

      def render_header_content
        return nil unless @title || header?

        content_tag(:div, id: header_id, class: header_classes) do
          if header?
            # SECURITY: Slot content is marked html_safe because it's expected to contain
            # Rails-generated HTML from other components. Never pass unsanitized user input
            # directly to this slot.
            header.to_s.html_safe
          else
            content_tag(:h2, @title, class: "text-lg font-semibold text-[var(--modal-title-color)]")
          end
        end
      end

      def render_body_content
        return nil unless body?

        # SECURITY: Slot content is marked html_safe because it's expected to contain
        # Rails-generated HTML from other components. Never pass unsanitized user input
        # directly to this slot.
        content_tag(:div, body.to_s.html_safe, **body_attributes)
      end

      def body_attributes
        attributes = {
          class: body_classes
        }

        height_style = body_style
        attributes[:style] = height_style if height_style.present?
        attributes
      end

      def render_footer_content
        return nil unless footer?

        # SECURITY: Slot content is marked html_safe because it's expected to contain
        # Rails-generated HTML from other components. Never pass unsanitized user input
        # directly to this slot.
        content_tag(:div, footer.to_s.html_safe, class: footer_classes)
      end

      def header_section?
        @title.present? || header?
      end

      def header_wrapper_classes
        "flat-pack-modal__header shrink-0 flex items-start justify-between gap-3"
      end

      def close_button_row_classes
        classes(
          "flat-pack-modal__close",
          "shrink-0",
          "flex",
          "justify-end",
          (header_section? ? nil : "pb-2")
        )
      end

      def header_classes
        "min-w-0"
      end

      def body_classes
        classes(
          "flat-pack-modal__body",
          "min-h-0",
          body_layout_class,
          "overflow-y-auto",
          "pt-4",
          "text-sm",
          "text-[var(--modal-body-color)]"
        )
      end

      def body_layout_class
        (@body_height_mode == :auto) ? "flex-1" : "shrink-0"
      end

      def body_style
        return nil unless @body_height_mode != :auto

        case @body_height_mode
        when :fixed
          "--flatpack-modal-body-height: #{@body_height}; height: var(--flatpack-modal-body-height);"
        when :min
          "--flatpack-modal-body-height: #{@body_height}; min-height: var(--flatpack-modal-body-height);"
        end
      end

      def footer_classes
        "flat-pack-modal__footer shrink-0 pt-4 flex justify-end gap-3"
      end

      def header_id
        "#{@modal_id}-title"
      end

      def validate_id!
        return if @modal_id.present?
        raise ArgumentError, "id is required"
      end

      def validate_size!
        return if SIZES.key?(@size)
        raise ArgumentError, "Invalid size: #{@size}. Must be one of: #{SIZES.keys.join(", ")}"
      end

      def validate_body_height_mode!
        return if BODY_HEIGHT_MODES.include?(@body_height_mode)

        raise ArgumentError, "Invalid body_height_mode: #{@body_height_mode}. Must be one of: #{BODY_HEIGHT_MODES.join(", ")}"
      end

      def validate_body_height!
        return if @body_height_mode == :auto
        return if @body_height.present? && @body_height.match?(/\A[0-9a-zA-Z\s\-+*%.,()\[\]_]+\z/)

        raise ArgumentError, "body_height is required for non-auto body_height_mode and may only contain CSS length/expression characters"
      end
    end
  end
end
