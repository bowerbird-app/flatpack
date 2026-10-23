# frozen_string_literal: true

module FlatPack
  module PageLayout
    # A single column for a public page. Arrangement only.
    # The host owns the words, the cards, and the photos.
    class Component < FlatPack::BaseComponent
      include FlatPack::Layout::Shell

      private :layout_top_nav, :layout_background

      renders_one :top_nav_slot
      renders_one :footer_slot
      renders_one :background_slot

      WIDTHS = %i[narrow default wide full].freeze
      ALIGNS = %i[top center].freeze
      CONTENT_SCROLLS = %i[behind below].freeze
      TOP_NAV_WIDTHS = %i[content full].freeze
      REMOVED_KEYWORDS = %i[floating_top_nav].freeze

      def initialize(
        width: :default,
        align: :top,
        content_scroll: :below,
        top_nav_width: :content,
        **system_arguments
      )
        reject_removed!(system_arguments)
        super(**system_arguments)
        @width = symbolize(width)
        @align = symbolize(align)
        @content_scroll = symbolize(content_scroll)
        @top_nav_width = symbolize(top_nav_width)

        validate_width!
        validate_align!
        validate_content_scroll!
        validate_top_nav_width!
      end

      def top_nav(**args, &block)
        return top_nav_slot unless block

        with_top_nav_slot(**args, &block)
      end

      def footer(**args, &block)
        return footer_slot unless block

        with_footer_slot(**args, &block)
      end

      def background(**args, &block)
        return background_slot unless block

        with_background_slot(**args, &block)
      end

      def top_nav?
        top_nav_slot?
      end

      def footer?
        footer_slot?
      end

      def background?
        background_slot?
      end

      def call
        content_tag(:div, **container_attributes) do
          safe_join([
            render_background,
            render_page_surface,
            render_frame,
            render_footer
          ].compact)
        end
      end

      private

      def render_frame
        content_tag(:div, class: frame_classes) do
          safe_join([
            render_top_nav,
            content_tag(:main, main_column, class: main_classes)
          ].compact)
        end
      end

      def render_top_nav
        return unless top_nav?

        layout_top_nav(top_nav_body, content_scroll: @content_scroll)
      end

      def top_nav_body
        html = top_nav_landmark(top_nav.to_s)
        return html if @top_nav_width == :full

        content_tag(:div, html, class: "fp-page-layout-top-nav-column")
      end

      def top_nav_landmark(html)
        return html if html.match?(/<(header|nav)\b/i)

        content_tag(:header, html)
      end

      def main_column
        content_tag(:div, content, class: "fp-layout-column")
      end

      def render_footer
        return unless footer?

        content_tag(:footer, class: "fp-page-layout-footer fp-layout-content") do
          content_tag(:div, footer.to_s, class: "fp-layout-column")
        end
      end

      def render_background
        return unless background?

        layout_background(background)
      end

      def render_page_surface
        return unless content_scroll_behind? && !background?

        content_tag(:div, "", class: "fp-layout-page-surface", aria: {hidden: true})
      end

      def container_attributes
        merge_attributes(class: container_classes, data: container_data)
      end

      def container_classes
        ["fp-page-layout", ("fp-layout-main" if background?)].compact.join(" ")
      end

      def container_data
        {
          "fp-page-layout-width": @width.to_s,
          "fp-page-layout-align": @align.to_s,
          "fp-page-layout-top-nav-width": @top_nav_width.to_s,
          "flat-pack-layout-background": ("true" if background?),
          "flat-pack-layout-scroll": ("page" if content_scroll_behind?)
        }.compact
      end

      def frame_classes
        ["fp-page-layout-frame", ("fp-layout-page" if content_scroll_behind?)].compact.join(" ")
      end

      def main_classes
        [
          "fp-page-layout-main",
          "fp-layout-content",
          ("fp-layout-scroll" if content_scroll_behind?)
        ].compact.join(" ")
      end

      def content_scroll_behind?
        @content_scroll == :behind && top_nav?
      end

      def symbolize(value)
        value.is_a?(String) ? value.to_sym : value
      end

      def validate_width!
        return if WIDTHS.include?(@width)

        raise ArgumentError, "width must be :narrow, :default, :wide, or :full"
      end

      def validate_align!
        return if ALIGNS.include?(@align)

        raise ArgumentError, "align must be :top or :center"
      end

      def reject_removed!(arguments)
        removed = arguments.keys & REMOVED_KEYWORDS
        return if removed.empty?

        raise ArgumentError, "unknown keyword: :#{removed.first}"
      end

      def validate_content_scroll!
        return if CONTENT_SCROLLS.include?(@content_scroll)

        raise ArgumentError, "content_scroll must be :behind or :below"
      end

      def validate_top_nav_width!
        return if TOP_NAV_WIDTHS.include?(@top_nav_width)

        raise ArgumentError, "top_nav_width must be :content or :full"
      end
    end
  end
end
