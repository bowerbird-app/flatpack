# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Chat
    module TypingIndicator
      class ComponentTest < ViewComponent::TestCase
        def test_renders_typing_indicator_without_avatar
          render_inline(Component.new(label: "Anonymous user is typing"))

          assert_selector "div[aria-label='Anonymous user is typing']"
          assert_selector ".animate-bounce", count: 3
        end

        def test_renders_with_avatar_slot_component
          render_inline(Component.new(label: "Teammate is typing")) do |indicator|
            indicator.with_avatar do
              render FlatPack::Avatar::Component.new(name: "Teammate", initials: "TM", size: :sm)
            end
          end

          assert_selector "div[aria-label='Teammate is typing']"
          assert_selector "span", text: "TM"
        end
      end
    end
  end
end
