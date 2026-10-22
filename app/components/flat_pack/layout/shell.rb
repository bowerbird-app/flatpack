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

      # The default page-nav bucket, drawn by this shell.
      # `styles` is a role map from `PageNavRoleStyles`. `bar` insets the row.
      # `:menu` folds the links in a button group. `:floating` keeps a row and
      # pins the primary link. A component renders once, beside the links.
      def layout_page_nav(styles:, bar: false)
        return unless helpers.respond_to?(:page_nav_items)

        items = helpers.page_nav_items
        return if items.empty?

        content_tag(:div, page_nav_body(items, styles), class: page_nav_classes(bar), data: page_nav_data)
      end

      def page_nav_classes(bar)
        [
          "fp-page-nav",
          "fp-page-nav--desktop",
          ("fp-page-nav--bar" if bar),
          ("fp-page-nav--pin-row" if pin_page_nav?)
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

      def render_floating_page_nav
        return unless pin_page_nav?
        return unless helpers.respond_to?(:page_nav_items)

        item = helpers.page_nav_items.find { |entry| entry.role == :primary && !entry.component? }
        return if item.nil?

        button = render(PageNavRoleStyles.button_for(item, styles: PageNavRoleStyles::PIN))
        content_tag(:div, button, class: "fp-page-nav fp-page-nav--floating", data: {fp_page_nav: "floating"})
      end

      def page_nav_body(items, styles)
        safe_join([
          page_nav_links(items.reject(&:component?), styles),
          page_nav_components(items.select(&:component?))
        ].compact)
      end

      def page_nav_links(links, styles)
        return if links.empty?

        group = render(FlatPack::ButtonGroup::Component.new(**page_nav_group_arguments)) do |row|
          links.each { |item| row.button(PageNavRoleStyles.button_for(item, styles: styles)) }
        end
        return group unless pin_page_nav?

        content_tag(:div, group, class: "fp-page-nav-buttons")
      end

      def page_nav_group_arguments
        return {collapse: :menu} if menu_page_nav?

        {}
      end

      def page_nav_components(components)
        return if components.empty?

        rendered = safe_join(components.map { |item| render(item.component) })
        content_tag(:div, rendered, class: "fp-page-nav-components")
      end

      def page_nav_data
        {fp_page_nav: PageNavRegistry::DEFAULT_BUCKET.to_s}
      end

      def menu_page_nav?
        @mobile_actions == :menu
      end

      def pin_page_nav?
        @mobile_actions == :floating
      end
    end
  end
end
