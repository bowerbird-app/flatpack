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
    end
  end
end
