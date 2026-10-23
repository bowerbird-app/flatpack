# frozen_string_literal: true

module FlatPack
  # Records page nav for the request, and draws one bucket as a button group.
  # This is not FlatPack::PageNavHelper (`flat_pack_page_nav`), the back and close row.
  module PageNavRegistryHelper
    REQUEST_KEY = "flat_pack.page_nav_registry"

    # Register one page nav entry. Returns nil.
    #
    # Link: `register_page_nav "Label", path, role:, icon:, data:, aria:, into:`
    # Component: `register_page_nav component:, role:, into:`
    # `role:` is required. `:primary`, `:secondary`, or `:destructive`.
    # `into:` is a caller-named bucket. Omit it to use `:default`.
    def register_page_nav(
      label = nil,
      href = nil,
      role: nil,
      icon: nil,
      data: nil,
      aria: nil,
      component: nil,
      into: PageNavRegistry::DEFAULT_BUCKET
    )
      require_role!(role)
      item = if component
        if label || href || icon || data || aria
          raise ArgumentError, "page nav component takes role: only"
        end

        PageNavItem.new(role: role, component: component)
      else
        PageNavItem.new(label, href, role: role, icon: icon, data: data, aria: aria)
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
    # A component is passed through. `collapse` is passed to the group.
    # Returns nil when the bucket is empty.
    def page_nav_button_group(styles:, from: PageNavRegistry::DEFAULT_BUCKET, collapse: false)
      items = page_nav_items(from: from)
      return if items.empty?

      render(FlatPack::ButtonGroup::Component.new(collapse: collapse)) do |row|
        items.each do |item|
          child = if item.component?
            item.component
          else
            PageNavRoleStyles.button_for(item, styles: styles)
          end
          row.button(child)
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
