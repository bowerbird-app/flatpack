# frozen_string_literal: true

module FlatPack
  module Modal
    class Component < FlatPack::BaseComponent
      renders_one :header
      renders_one :body
      renders_one :footer

      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "max-w-sm" "max-w-md" "max-w-lg" "max-w-xl" "max-w-2xl"
      SIZES = {
        sm: "max-w-sm",
        md: "max-w-md",
        lg: "max-w-lg",
        xl: "max-w-xl",
        "2xl": "max-w-2xl"
      }.freeze

      def initialize(
        id:,
        title: nil,
        size: :md,
        close_on_backdrop: true,
        close_on_escape: true,
        **system_arguments
      )
        super(**system_arguments)
        @modal_id = id
        @title = title
        @size = size.to_sym
        @close_on_backdrop = close_on_backdrop
        @close_on_escape = close_on_escape

        validate_id!
        validate_size!
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
          "bg-black/50",
          "backdrop-blur-sm",
          "transition-opacity",
          "duration-300"
        )
      end

      def render_backdrop
        # Empty div that acts as clickable backdrop
        content_tag(:div,
          nil,
          class: "absolute inset-0",
          data: {action: "click->flat-pack--modal#clickBackdrop"}
        )
      end

      def render_dialog
        content_tag(:div, class: dialog_wrapper_classes) do
          content_tag(:div, **dialog_attributes) do
            safe_join([
              render_close_button,
              render_header_content,
              render_body_content,
              render_footer_content
            ].compact)
          end
        end
      end

      def dialog_wrapper_classes
        "relative flex min-h-screen items-center justify-center p-4"
      end

      def dialog_attributes
        {
          role: "dialog",
          aria: {
            modal: "true",
            labelledby: header_id
          },
          class: dialog_classes,
          data: {
            "flat-pack--modal-target": "dialog"
          }
        }
      end

      def dialog_classes
        classes(
          "relative",
          "w-full",
          size_classes,
          "bg-[var(--color-background)]",
          "rounded-[var(--radius-lg)]",
          "shadow-lg",
          "border",
          "border-[var(--color-border)]",
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
          data: {action: "flat-pack--modal#close"}
        ) do
          close_icon
        end
      end

      def close_button_classes
        "absolute top-4 right-4 text-[var(--color-text-muted)] hover:text-[var(--color-text)] transition-colors rounded-[var(--radius-sm)] p-1 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--color-ring)]"
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
            content_tag(:h2, @title, class: "text-lg font-semibold text-[var(--color-text)]")
          end
        end
      end

      def render_body_content
        return nil unless body?

        # SECURITY: Slot content is marked html_safe because it's expected to contain
        # Rails-generated HTML from other components. Never pass unsanitized user input
        # directly to this slot.
        content_tag(:div, body.to_s.html_safe, class: body_classes)
      end

      def render_footer_content
        return nil unless footer?

        # SECURITY: Slot content is marked html_safe because it's expected to contain
        # Rails-generated HTML from other components. Never pass unsanitized user input
        # directly to this slot.
        content_tag(:div, footer.to_s.html_safe, class: footer_classes)
      end

      def header_classes
        "px-6 pt-6 pb-4"
      end

      def body_classes
        "px-6 py-4 text-sm text-[var(--color-text)]"
      end

      def footer_classes
        "px-6 pb-6 pt-4 flex justify-end gap-3 border-t border-[var(--color-border)]"
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
    end
  end
end
