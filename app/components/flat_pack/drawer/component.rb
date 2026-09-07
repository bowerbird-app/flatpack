# frozen_string_literal: true

module FlatPack
  module Drawer
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
      # "max-w-sm" "max-w-md" "max-w-lg" "max-h-[70vh]" "max-h-[85vh]" "h-[90vh]"
      SIDES = %i[left right bottom].freeze
      SIZES = %i[sm md lg].freeze

      def initialize(
        id:,
        title: nil,
        side: :right,
        size: :md,
        close_on_backdrop: true,
        close_on_escape: true,
        **system_arguments
      )
        super(**system_arguments)
        @drawer_id = id
        @title = title
        @side = side.to_sym
        @size = size.to_sym
        @close_on_backdrop = close_on_backdrop
        @close_on_escape = close_on_escape

        validate_id!
        validate_side!
        validate_size!
      end

      def call
        content_tag(:div, **root_attributes) do
          safe_join([
            render_backdrop,
            render_panel
          ])
        end
      end

      private

      def root_attributes
        merge_attributes(
          id: @drawer_id,
          class: root_classes,
          data: {
            controller: "flat-pack--drawer",
            "flat-pack--drawer-side-value": @side.to_s,
            "flat-pack--drawer-close-on-backdrop-value": @close_on_backdrop,
            "flat-pack--drawer-close-on-escape-value": @close_on_escape,
            action: action_attributes
          },
          aria: {hidden: "true"}
        )
      end

      def action_attributes
        actions = []
        actions << "keydown.esc->flat-pack--drawer#close" if @close_on_escape
        actions << "keydown->flat-pack--drawer#trapTab"
        actions.join(" ")
      end

      def root_classes
        classes(
          "fixed inset-0 z-50 hidden",
          "fp-drawer-backdrop",
          "bg-[var(--drawer-backdrop-color)]",
          "backdrop-blur-[var(--drawer-backdrop-blur)]",
          "transition-opacity duration-[var(--duration-slow)] ease-[var(--easing-enter)]"
        )
      end

      def render_backdrop
        content_tag(:div, nil, class: "absolute inset-0", data: {action: "click->flat-pack--drawer#clickBackdrop"})
      end

      def render_panel
        content_tag(:div, **panel_attributes) do
          safe_join([
            render_header_section || render_close_button_row,
            render_body_content,
            render_footer_content
          ].compact)
        end
      end

      def panel_attributes
        attributes = {
          role: "dialog",
          aria: {modal: "true"},
          class: panel_classes,
          data: {"flat-pack--drawer-target": "panel"}
        }
        attributes[:aria][:labelledby] = header_id if header_section?
        attributes
      end

      def panel_classes
        classes(
          "fp-drawer-panel fp-overlay-pad",
          "absolute flex flex-col overflow-hidden",
          "bg-[var(--drawer-surface-color)]",
          "border-[var(--drawer-border-color)]",
          "shadow-lg",
          "transition-[opacity,translate] duration-[var(--duration-slow)] ease-[var(--easing-enter)]",
          "opacity-0",
          side_classes,
          size_classes
        )
      end

      def side_classes
        case @side
        when :left
          "inset-y-0 left-0 w-full border-r rounded-r-[var(--radius-lg)] -translate-x-full motion-reduce:translate-x-0"
        when :right
          "inset-y-0 right-0 w-full border-l rounded-l-[var(--radius-lg)] translate-x-full motion-reduce:translate-x-0"
        else
          "inset-x-0 bottom-0 w-full border-t rounded-t-[var(--radius-lg)] translate-y-full motion-reduce:translate-y-0"
        end
      end

      def size_classes
        if @side == :bottom
          {
            sm: "max-h-[70vh]",
            md: "max-h-[85vh]",
            lg: "h-[90vh]"
          }.fetch(@size)
        else
          {
            sm: "max-w-sm",
            md: "max-w-md",
            lg: "max-w-lg"
          }.fetch(@size)
        end
      end

      def render_header_section
        return nil unless header_section?

        content_tag(:div, class: "shrink-0 flex items-start justify-between gap-3 p-4 sm:p-6") do
          safe_join([render_header_content, render_close_button])
        end
      end

      def render_close_button_row
        content_tag(:div, class: "shrink-0 flex justify-end p-4 pb-0") { render_close_button }
      end

      def render_header_content
        return nil unless @title || header?

        content_tag(:div, id: header_id, class: "min-w-0") do
          if header?
            header.to_s.html_safe
          else
            content_tag(:h2, @title, class: "text-lg font-semibold text-[var(--drawer-title-color)] fp-text-balance")
          end
        end
      end

      def render_close_button
        content_tag(:button,
          type: "button",
          class: "shrink-0 cursor-pointer text-[var(--drawer-close-icon-color)] hover:text-[var(--drawer-close-icon-hover-color)] transition-colors rounded-[var(--radius-sm)] p-1 fp-hit-target focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-ring",
          aria: {label: "Close"},
          data: {action: "flat-pack--drawer#close"}) do
          render FlatPack::Shared::IconComponent.new(name: "x-mark", size: :md)
        end
      end

      def render_body_content
        return nil unless body?

        content_tag(:div, body.to_s.html_safe, class: "fp-drawer-body min-h-0 flex-1 overflow-y-auto px-4 sm:px-6 pb-4 text-sm text-[var(--drawer-body-color)]")
      end

      def render_footer_content
        return nil unless footer?

        content_tag(:div, footer.to_s.html_safe, class: "shrink-0 p-4 sm:p-6 pt-0 flex justify-end gap-3")
      end

      def header_section?
        @title.present? || header?
      end

      def header_id
        "#{@drawer_id}-title"
      end

      def validate_id!
        return if @drawer_id.present?

        raise ArgumentError, "id is required"
      end

      def validate_side!
        return if SIDES.include?(@side)

        raise ArgumentError, "Invalid side: #{@side}. Must be one of: #{SIDES.join(", ")}"
      end

      def validate_size!
        return if SIZES.include?(@size)

        raise ArgumentError, "Invalid size: #{@size}. Must be one of: #{SIZES.join(", ")}"
      end
    end
  end
end
