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

    # Render `actions` (the request list, when omitted) for `context`.
    # `context` is :header, :top_nav, or :mobile.
    # `styles:` replaces role → button style tokens for this call.
    def page_actions(context, actions: nil, styles: nil)
      list = actions.nil? ? page_action_registry.actions : actions
      FlatPack::PageActions.render(self, list, context, styles: styles)
    end

    def page_action_registry
      request.env[REQUEST_KEY] ||= FlatPack::PageActionRegistry.new
    end
  end
end
