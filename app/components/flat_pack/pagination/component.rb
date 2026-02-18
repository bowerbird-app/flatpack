# frozen_string_literal: true

module FlatPack
  module Pagination
    class Component < FlatPack::BaseComponent
      SIZES = {
        compact: :compact,
        normal: :normal
      }.freeze

      def initialize(
        pagy:,
        size: :normal,
        **system_arguments
      )
        super(**system_arguments)
        @pagy = pagy
        @size = size.to_sym

        validate_pagy!
        validate_size!
      end

      def call
        return nil if @pagy.pages <= 1 && @size != :compact

        content_tag(:nav, **container_attributes) do
          content_tag(:div, class: pagination_wrapper_classes) do
            safe_join([
              render_prev_button,
              render_page_links,
              render_next_button
            ].compact)
          end
        end
      end

      private

      def container_attributes
        merge_attributes(
          class: container_classes,
          aria: {label: "Pagination"}
        )
      end

      def container_classes
        classes(
          "flex",
          "items-center",
          "justify-center",
          "py-3"
        )
      end

      def pagination_wrapper_classes
        "inline-flex items-center gap-1 rounded-[var(--radius-md)] bg-[var(--color-background)] border border-[var(--color-border)] p-1"
      end

      def render_prev_button
        disabled = @pagy.prev.nil?
        
        link_to_unless disabled, page_url(@pagy.prev), 
          class: page_button_classes(disabled: disabled),
          aria: {label: "Previous page", disabled: disabled ? "true" : nil}.compact do
          previous_icon
        end
      end

      def render_next_button
        disabled = @pagy.next.nil?
        
        link_to_unless disabled, page_url(@pagy.next),
          class: page_button_classes(disabled: disabled),
          aria: {label: "Next page", disabled: disabled ? "true" : nil}.compact do
          next_icon
        end
      end

      def render_page_links
        return nil if @size == :compact

        safe_join(series.map { |item| render_page_item(item) })
      end

      def render_page_item(item)
        case item
        when Integer
          render_page_number(item)
        when String
          render_gap
        when :gap
          render_gap
        end
      end

      def render_page_number(page)
        is_current = page == @pagy.page
        
        link_to_unless is_current, page_url(page),
          class: page_button_classes(active: is_current),
          aria: {label: "Page #{page}", current: is_current ? "page" : nil}.compact do
          page.to_s
        end
      end

      def render_gap
        content_tag(:span, "…", class: "px-3 text-[var(--color-text-muted)]")
      end

      def page_button_classes(active: false, disabled: false)
        base = "inline-flex items-center justify-center min-w-[2.25rem] h-9 px-3 text-sm font-medium rounded-[var(--radius-sm)] transition-colors"
        
        if disabled
          "#{base} text-[var(--color-text-muted)] cursor-not-allowed opacity-50"
        elsif active
          "#{base} bg-[var(--color-primary)] text-[var(--color-primary-text)]"
        else
          "#{base} text-[var(--color-text)] hover:bg-[var(--color-muted)] focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--color-ring)]"
        end
      end

      def series
        # Use pagy_series if available (from Pagy helpers)
        # Otherwise fall back to a simple range
        if defined?(pagy_series)
          pagy_series(@pagy)
        else
          # Simple series for basic pagination
          @pagy.series
        end
      end

      def page_url(page)
        return "#" unless page

        # Try to use pagy_url_for if available (from Pagy helpers)
        if defined?(pagy_url_for)
          pagy_url_for(@pagy, page)
        else
          # Fallback: just add page param
          "?page=#{page}"
        end
      end

      def previous_icon
        content_tag(:svg, class: "w-4 h-4", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor") do
          tag.path(
            "stroke-linecap": "round",
            "stroke-linejoin": "round",
            "stroke-width": "2",
            d: "M15 19l-7-7 7-7"
          )
        end
      end

      def next_icon
        content_tag(:svg, class: "w-4 h-4", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor") do
          tag.path(
            "stroke-linecap": "round",
            "stroke-linejoin": "round",
            "stroke-width": "2",
            d: "M9 5l7 7-7 7"
          )
        end
      end

      def validate_pagy!
        return if @pagy.respond_to?(:page) && @pagy.respond_to?(:pages)
        raise ArgumentError, "pagy must be a Pagy instance"
      end

      def validate_size!
        return if SIZES.key?(@size)
        raise ArgumentError, "Invalid size: #{@size}. Must be one of: #{SIZES.keys.join(", ")}"
      end
    end
  end
end
