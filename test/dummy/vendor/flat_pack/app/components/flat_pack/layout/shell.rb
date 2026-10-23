# frozen_string_literal: true

module FlatPack
  module Layout
    # Internal. SidebarLayout and PageLayout both render the floating top bar
    # and the page photo through here, so the markup stays one implementation.
    module Shell
      def layout_top_nav(body, floating:, content_scroll:)
        return if body.nil?
        return body unless floating

        content_tag(
          :div,
          body.to_s,
          class: "fp-layout-top-nav",
          data: {"flat-pack-top-nav-floating": content_scroll.to_s}
        )
      end

      def layout_background(slot)
        backdrop = FlatPack::Backdrop::Component.new
        backdrop.with_media { slot.to_s }
        render(backdrop)
      end

      # The actions slot, in the bar. Empty content adds no markup.
      # `bar` insets the row to the content edge.
      def layout_actions(bar: false)
        return unless actions?

        html = actions.to_s
        return if html.blank?

        content_tag(:div, html, class: layout_actions_classes(bar))
      end

      def layout_actions_classes(bar)
        [
          "fp-page-nav",
          "fp-page-nav--desktop",
          ("fp-page-nav--bar" if bar)
        ].compact.join(" ")
      end
    end
  end
end
