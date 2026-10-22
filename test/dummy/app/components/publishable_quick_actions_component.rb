# frozen_string_literal: true

# Demo stand-in for a gem component that replaces itself through a fixed wrapper id.
class PublishableQuickActionsComponent < ViewComponent::Base
  def initialize(dom_id: "publishable_quick_actions_demo")
    @dom_id = dom_id
  end

  def call
    render(FlatPack::Button::Component.new(text: "Publish", id: @dom_id, style: :primary, size: :sm))
  end
end
