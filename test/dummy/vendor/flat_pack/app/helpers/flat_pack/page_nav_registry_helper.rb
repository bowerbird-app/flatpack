# frozen_string_literal: true

module FlatPack
  # Records page nav for the request, and draws one bucket as a button group.
  # This is not FlatPack::PageNavHelper (`flat_pack_page_nav`), the back and close row.
  module PageNavRegistryHelper
    REQUEST_KEY = "flat_pack.page_nav_registry"

    # Register one page nav entry. Returns nil.
    #
    # Link: `register_page_nav "Label", path, role:, icon:, data:, aria:, into:, overflow:`
    # Component: `register_page_nav component:, role:, into:, overflow:`
    # `role:` is required. `:primary`, `:secondary`, or `:destructive`.
    # `into:` is a caller-named bucket. Omit it to use `:default`.
    # `overflow: true` puts that child in the button group's overflow menu.
    def register_page_nav(
      label = nil,
      href = nil,
      role: nil,
      icon: nil,
      data: nil,
      aria: nil,
      component: nil,
      into: PageNavRegistry::DEFAULT_BUCKET,
      overflow: nil
    )
      require_role!(role)
      item = if component
        if label || href || icon || data || aria
          raise ArgumentError, "page nav component takes role: and overflow: only"
        end

        PageNavItem.new(role: role, component: component, overflow: overflow)
      else
        PageNavItem.new(label, href, role: role, icon: icon, data: data, aria: aria, overflow: overflow)
      end
      page_nav_registry.add(item, into: into)
    end

    # Registered descriptors for one bucket, in registration order.
    # A link has `role`, `label`, `href`, `icon`, `data`, and `aria`.
    # A component has `role` and `component`.
    def page_nav_items(from: PageNavRegistry::DEFAULT_BUCKET)
      page_nav_registry.items(from: from)
    end

    # One FlatPack::ButtonGroup::Component for a bucket, in registration order.
    # A link becomes a button through `styles` (a PageNavRoleStyles map).
    # A component is passed through. `variant`, `style`, `collapse`, and
    # `visible` are passed to the group.
    # `overflow` on an item is passed to that child.
    # `overflow_label` is the overflow trigger's text. Omit it for an icon.
    # `overflow_icon` replaces the default ellipsis or chevron.
    # Returns nil when the bucket is empty.
    def page_nav_button_group(styles:, from: PageNavRegistry::DEFAULT_BUCKET, variant: :joined, style: :default, collapse: false, visible: nil, overflow_label: nil, overflow_icon: nil)
      items = page_nav_items(from: from)
      return if items.empty?

      render(FlatPack::ButtonGroup::Component.new(variant: variant, style: style, collapse: collapse, visible: visible, overflow_label: overflow_label, overflow_icon: overflow_icon)) do |row|
        items.each do |item|
          child = if item.component?
            item.component
          else
            PageNavRoleStyles.button_for(item, styles: styles)
          end
          row.button(child, overflow: item.overflow)
        end
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
  end
end
