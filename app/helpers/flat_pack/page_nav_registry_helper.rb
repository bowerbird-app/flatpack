# frozen_string_literal: true

module FlatPack
  module PageNavRegistryHelper
    REQUEST_KEY = "flat_pack.page_nav_registry"
    PLACES = %i[group menu floating].freeze

    # Register one page nav entry. Returns nil.
    #
    # Semantic: `page_nav "Label", path, role:, icon:, data:, aria:`
    # Component: `page_nav component:, role:`
    # `role:` is required. `:primary`, `:secondary`, or `:destructive`.
    def page_nav(label = nil, href = nil, role: nil, icon: nil, data: nil, aria: nil, component: nil)
      require_role!(role)
      item = if component
        if label || href || icon || data || aria
          raise ArgumentError, "page nav component takes role: only"
        end

        PageNavItem.new(role: role, component: component)
      else
        PageNavItem.new(label, href, role: role, icon: icon, data: data, aria: aria)
      end
      page_nav_registry.add(item)
    end

    # The only render path. `context` is `:header` or `:top_nav`.
    # `styles:` is a layout map (context → role → {style:, size:}), merged over
    # `FlatPack.configuration.page_nav_styles`, then the Flatpack default.
    # `place:` is `:group` (desktop and inline), `:menu`, or `:floating`.
    # A component renders on the first group call and is left out of the menu
    # and the floating button.
    def render_page_nav(context, styles: nil, place: :group)
      name = place.is_a?(String) ? place.to_sym : place
      raise ArgumentError, "place must be :group, :menu, or :floating" unless PLACES.include?(name)

      case name
      when :menu
        render_page_nav_menu(context, styles)
      when :floating
        render_page_nav_floating(context, styles)
      else
        render_page_nav_group(context, styles)
      end
    end

    def page_nav_registry
      request.env[REQUEST_KEY] ||= PageNavRegistry.new
    end

    private

    def require_role!(role)
      return if role.respond_to?(:to_sym) && PageNavItem::ROLES.include?(role.to_sym)

      raise ArgumentError, "role must be :primary, :secondary, or :destructive"
    end

    def render_page_nav_group(context, styles)
      buttons = render_page_nav_buttons(semantic_items, context, styles)
      components = render_page_nav_components
      return if buttons.blank? && components.blank?

      safe_join([
        (tag.div(buttons, class: "fp-page-nav-buttons") if buttons.present?),
        (tag.div(components, class: "fp-page-nav-components") if components.present?)
      ].compact)
    end

    def render_page_nav_menu(context, styles)
      list = semantic_items
      return if list.empty?

      buttons = safe_join(list.map { |item| render(page_nav_button(item, context, styles: styles)) })
      tag.div(
        buttons,
        class: "fp-page-nav-menu",
        data: {
          "flat-pack--top-nav-target": "section",
          "flat-pack-top-nav-collapsible": "true",
          fp_page_nav: "menu"
        }
      )
    end

    def render_page_nav_floating(context, styles)
      item = semantic_items.find { |entry| entry.role == :primary }
      return if item.nil?

      render(page_nav_button(item, context, styles: styles, size: :md))
    end

    def render_page_nav_buttons(list, context, styles)
      return if list.empty?

      render(ButtonGroup::Component.new) do |group|
        list.each { |item| group.button(page_nav_button(item, context, styles: styles)) }
      end
    end

    def render_page_nav_components
      list = page_nav_registry.claim_components
      return if list.empty?

      ordered = list.sort_by.with_index { |item, index| [PageNavItem::ROLES.index(item.role), index] }
      safe_join(ordered.map { |item| render(item.component) })
    end

    def page_nav_button(item, context, styles: nil, size: nil)
      entry = PageNav.resolve(context, styles).fetch(item.role)
      arguments = {
        text: item.label,
        href: item.href,
        style: entry.fetch(:style),
        size: size || entry.fetch(:size)
      }
      arguments[:icon] = item.icon if item.icon.present?
      arguments[:data] = item.data if item.data
      arguments[:aria] = item.aria if item.aria
      Button::Component.new(**arguments)
    end

    def semantic_items
      page_nav_registry.items.reject(&:component?)
    end
  end
end
