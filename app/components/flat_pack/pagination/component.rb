# frozen_string_literal: true

module FlatPack
  module Pagination
    class Component < FlatPack::BaseComponent
      SIZES = {
        compact: :compact,
        normal: :normal
      }.freeze
      MODES = {
        standard: :standard,
        infinite: :infinite
      }.freeze

      def initialize(
        pagy: nil,
        size: :normal,
        mode: :standard,
        anchor: nil,
        turbo_frame: nil,
        infinite_url: nil,
        has_more: true,
        loading_text: "Loading more...",
        loading_variant: :table,
        **system_arguments
      )
        super(**system_arguments)
        @pagy = pagy
        @size = size.to_sym
        @mode = mode.to_sym
        @anchor = anchor.to_s.delete_prefix("#").presence
        @turbo_frame = turbo_frame.to_s.presence
        @infinite_url = infinite_url
        @has_more = has_more
        @loading_text = loading_text
        @loading_variant = loading_variant.to_sym

        validate_mode!
        validate_pagy!
        validate_size!
      end

      def call
        if @mode == :infinite
          has_more = @pagy ? (@has_more && @pagy.next.present?) : @has_more

          return render FlatPack::PaginationInfinite::Component.new(
            url: @infinite_url || page_url(@pagy&.next),
            page: @pagy&.next || ((@pagy&.page || 1) + 1),
            has_more: has_more,
            loading_text: @loading_text,
            loading_variant: @loading_variant,
            **@system_arguments
          )
        end

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
          "py-4"
        )
      end

      def pagination_wrapper_classes
        "inline-flex items-center gap-1.5 rounded-md bg-background border border-border p-1.5"
      end

      def render_prev_button
        disabled = @pagy.prev.nil?

        if disabled
          content_tag(
            :span,
            previous_icon,
            class: page_button_classes(disabled: true),
            aria: {label: "Previous page", disabled: "true"}
          )
        else
          link_to(
            page_url(@pagy.prev),
            class: page_button_classes,
            aria: {label: "Previous page"},
            data: link_data_attributes
          ) do
            previous_icon
          end
        end
      end

      def render_next_button
        disabled = @pagy.next.nil?

        if disabled
          content_tag(
            :span,
            next_icon,
            class: page_button_classes(disabled: true),
            aria: {label: "Next page", disabled: "true"}
          )
        else
          link_to(
            page_url(@pagy.next),
            class: page_button_classes,
            aria: {label: "Next page"},
            data: link_data_attributes
          ) do
            next_icon
          end
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

        if is_current
          content_tag(
            :span,
            page.to_s,
            class: page_button_classes(active: true),
            aria: {label: "Page #{page}", current: "page"}
          )
        else
          link_to(
            page.to_s,
            page_url(page),
            class: page_button_classes,
            aria: {label: "Page #{page}"},
            data: link_data_attributes
          )
        end
      end

      def render_gap
        content_tag(:span, "…", class: "#{gap_padding_classes} text-muted-foreground")
      end

      def page_button_classes(active: false, disabled: false)
        base = "inline-flex items-center justify-center #{button_size_classes} text-sm font-medium rounded-sm transition-colors"

        if disabled
          "#{base} text-muted-foreground cursor-not-allowed opacity-50"
        elsif active
          "#{base} bg-primary text-primary-text"
        else
          "#{base} text-foreground hover:bg-muted focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring"
        end
      end

      def button_size_classes
        if @size == :compact
          "min-w-[2.5rem] h-10 px-3.5"
        else
          "min-w-[2.75rem] h-10 px-4"
        end
      end

      def gap_padding_classes
        (@size == :compact) ? "px-3" : "px-4"
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

        url =
          # Try to use pagy_url_for if available (from Pagy helpers)
          if helpers.respond_to?(:pagy_url_for)
            helpers.pagy_url_for(@pagy, page)
          else
            # Fallback: just add page param
            "?page=#{page}"
          end

        append_anchor(url)
      end

      def append_anchor(url)
        return url unless @anchor
        return url if url.include?("#")

        "#{url}##{@anchor}"
      end

      def link_data_attributes
        return nil unless @turbo_frame

        {
          turbo_frame: @turbo_frame
        }
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
        return if @mode == :infinite
        return if @pagy.respond_to?(:page) && @pagy.respond_to?(:pages)
        raise ArgumentError, "pagy must be a Pagy instance"
      end

      def validate_size!
        return if SIZES.key?(@size)
        raise ArgumentError, "Invalid size: #{@size}. Must be one of: #{SIZES.keys.join(", ")}"
      end

      def validate_mode!
        return if MODES.key?(@mode)
        raise ArgumentError, "Invalid mode: #{@mode}. Must be one of: #{MODES.keys.join(", ")}"
      end
    end
  end
end
