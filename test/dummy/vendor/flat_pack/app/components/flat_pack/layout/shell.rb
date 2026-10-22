# frozen_string_literal: true

module FlatPack
  module Layout
    # Internal. SidebarLayout and PageLayout both render the floating top bar
    # and the page photo through here, so the markup stays one implementation.
    module Shell
      MOBILE_PAGE_NAV = %i[menu floating].freeze

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

      # Desktop group for page nav the view registered.
      # `context` picks the role map. `place` picks the shell position.
      # `styles:` is merged over the host map for this render.
      def layout_page_nav(context, place:, bar: false, styles: nil)
        return unless helpers.respond_to?(:render_page_nav)

        markup = helpers.render_page_nav(context, styles: styles)
        return if markup.blank?

        content_tag(:div, markup, class: page_nav_classes(place, bar), data: {fp_page_nav: context.to_s})
      end

      def page_nav_classes(place, bar)
        [
          "fp-page-nav",
          "fp-page-nav--#{place}",
          ("fp-page-nav--bar" if bar)
        ].compact.join(" ")
      end

      private

      def assign_mobile_actions!(value)
        name = value.is_a?(String) ? value.to_sym : value
        unless MOBILE_PAGE_NAV.include?(name)
          raise ArgumentError, "mobile_actions must be :menu or :floating"
        end

        @mobile_actions = name
      end

      # Phone rows join the top nav hamburger. A shell with no top nav renders
      # one, and that bar is hidden from the md breakpoint up.
      def with_menu_page_nav(html)
        return html unless menu_page_nav?

        section = helpers.render_page_nav(:top_nav, place: :menu)
        return html if section.blank?

        markup = html.to_s
        if markup.include?('data-flat-pack--top-nav-target="menu"')
          insert_page_nav_section(markup, section)
        elsif markup.present?
          safe_join([markup.html_safe, shell_page_nav_nav(section)])
        else
          shell_page_nav_nav(section)
        end
      end

      def render_floating_page_nav
        return unless @mobile_actions == :floating
        return unless helpers.respond_to?(:render_page_nav)

        button = helpers.render_page_nav(:header, place: :floating)
        return if button.blank?

        content_tag(
          :div,
          button,
          class: "fp-page-nav fp-page-nav--floating",
          data: {fp_page_nav: "floating"}
        )
      end

      def menu_page_nav?
        return false unless @mobile_actions == :menu
        return false unless helpers.respond_to?(:page_nav_registry)

        helpers.page_nav_registry.items.any? { |item| !item.component? }
      end

      def insert_page_nav_section(html, section)
        updated = html.sub(/(<[^>]*data-flat-pack--top-nav-target="menu")/) do
          "#{section}#{Regexp.last_match(1)}"
        end
        updated.html_safe
      end

      def shell_page_nav_nav(section)
        nav = render(FlatPack::TopNav::Component.new).to_s
        content_tag(:div, insert_page_nav_section(nav, section), class: "fp-page-nav-nav")
      end
    end
  end
end
