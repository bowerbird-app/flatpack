# frozen_string_literal: true

# Stub for a stateful page action. The wrapper id is the Turbo Stream target.
module PressKitQuickActions
  class Component < ViewComponent::Base
    def call
      helpers.tag.div(
        helpers.render(
          FlatPack::Button::Component.new(
            text: "Publish",
            href: "/press-kits/publish",
            style: :secondary,
            size: :sm
          )
        ),
        id: "publishable_quick_actions_demo"
      )
    end
  end
end
