# frozen_string_literal: true

module FlatPack
  module PageActionHelper
    REQUEST_KEY = "flat_pack.page_actions"

    # Nominate one page action. The view decides that it exists and what it means.
    # `role` is :primary, :secondary, or :destructive. Pass `data:` and `aria:`
    # through. Do not pass a CSS class or a button style.
    def page_action(label, href, role: :secondary, icon: nil, data: nil, aria: nil)
      page_action_registry.add(
        FlatPack::PageAction.new(label, href, role: role, icon: icon, data: data, aria: aria)
      )
    end

    # Render `actions` (the request list, when omitted) as a button group.
    # `context` is :header or :top_nav. `styles:` replaces role → button style
    # tokens for this call. The layout decides where the group sits.
    def page_actions(context, actions: nil, styles: nil)
      list = page_action_list(actions)
      return if list.empty?

      render(FlatPack::ButtonGroup::Component.new) do |group|
        list.each do |action|
          group.button(page_action_button(action, context, styles: styles))
        end
      end
    end

    # One button for `action`, using the style and size for `context`.
    # Pass `size:` when the placement wants a different size than the context.
    def page_action_button(action, context, size: nil, styles: nil)
      map = FlatPack::PageActions.styles(context, styles)
      arguments = {
        text: action.label,
        href: action.href,
        style: map.fetch(action.role),
        size: size || FlatPack::PageActions.size(context)
      }
      arguments[:icon] = action.icon if action.icon.present?
      arguments[:data] = action.data if action.data
      arguments[:aria] = action.aria if action.aria
      FlatPack::Button::Component.new(**arguments)
    end

    # Full-width rows for the top nav menu. Hidden in the bar. The top nav
    # controller moves the buttons into the hamburger panel.
    def page_actions_menu_section
      list = page_action_registry.actions
      return if list.empty?

      buttons = safe_join(list.map { |action| render(page_action_button(action, :top_nav)) })
      tag.div(
        buttons,
        class: "fp-page-actions-menu",
        data: {
          "flat-pack--top-nav-target": "section",
          "flat-pack-top-nav-collapsible": "true",
          fp_page_actions: "menu"
        }
      )
    end

    def page_action_registry
      request.env[REQUEST_KEY] ||= FlatPack::PageActionRegistry.new
    end

    private

    def page_action_list(actions)
      return page_action_registry.actions if actions.nil?

      Array(actions)
    end
  end
end
