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

      # Desktop or mobile cluster for actions the view nominated.
      # `context` picks the role → style map. `place` picks the shell position.
      def layout_page_actions(context, place:, bar: false)
        return unless helpers.respond_to?(:page_actions)

        markup = helpers.page_actions(context)
        return if markup.blank?

        content_tag(:div, markup, class: page_actions_classes(place, bar), data: {fp_page_actions: context.to_s})
      end

      def page_actions_classes(place, bar)
        [
          "fp-page-actions",
          "fp-page-actions--#{place}",
          ("fp-page-actions--bar" if bar)
        ].compact.join(" ")
      end
    end
  end
end
