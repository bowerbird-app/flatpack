# frozen_string_literal: true

module FlatPack
  module Layout
    # Internal. SidebarLayout and PageLayout both render the floating top bar
    # and the page photo through here, so the markup stays one implementation.
    module Shell
      MOBILE_PAGE_ACTIONS = %i[menu floating].freeze

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

      # Desktop group for actions the view nominated.
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

      private

      def assign_mobile_actions!(value)
        name = value.is_a?(String) ? value.to_sym : value
        unless MOBILE_PAGE_ACTIONS.include?(name)
          raise ArgumentError, "mobile_actions must be :menu or :floating"
        end

        @mobile_actions = name
      end

      # Phone rows join the top nav hamburger. A shell with no top nav renders
      # one, and that bar is hidden from the md breakpoint up.
      def with_menu_page_actions(html)
        return html unless menu_page_actions?

        section = helpers.page_actions_menu_section
        return html if section.blank?

        markup = html.to_s
        if markup.include?('data-flat-pack--top-nav-target="menu"')
          insert_page_actions_section(markup, section)
        elsif markup.present?
          safe_join([markup.html_safe, shell_page_actions_nav(section)])
        else
          shell_page_actions_nav(section)
        end
      end

      def render_floating_page_action
        return unless @mobile_actions == :floating
        return unless helpers.respond_to?(:page_action_registry)

        action = helpers.page_action_registry.actions.find { |item| item.role == :primary }
        return if action.nil?

        button = render(helpers.page_action_button(action, :header, size: :md))
        content_tag(
          :div,
          button,
          class: "fp-page-actions fp-page-actions--floating",
          data: {fp_page_actions: "floating"}
        )
      end

      def menu_page_actions?
        return false unless @mobile_actions == :menu
        return false unless helpers.respond_to?(:page_actions_menu_section)

        !helpers.page_action_registry.empty?
      end

      def insert_page_actions_section(html, section)
        updated = html.sub(/(<[^>]*data-flat-pack--top-nav-target="menu")/) do
          "#{section}#{Regexp.last_match(1)}"
        end
        updated.html_safe
      end

      def shell_page_actions_nav(section)
        nav = render(FlatPack::TopNav::Component.new).to_s
        content_tag(:div, insert_page_actions_section(nav, section), class: "fp-page-actions-nav")
      end
    end
  end
end
