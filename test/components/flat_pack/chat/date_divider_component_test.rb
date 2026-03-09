# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Chat
    module DateDivider
      class ComponentTest < ViewComponent::TestCase
        def test_renders_label_text
          render_inline(Component.new(label: "Today"))

          assert_text "Today"
        end

        def test_renders_separator_role_and_aria_label
          render_inline(Component.new(label: "Yesterday"))

          assert_selector "div[role='separator'][aria-label='Yesterday']"
          assert_selector "div[data-flat-pack-chat-group-break='true']"
        end

        def test_raises_when_label_missing
          assert_raises(ArgumentError) do
            Component.new(label: nil)
          end
        end

        def test_merges_custom_class
          render_inline(Component.new(label: "Now", class: "custom-divider"))

          assert_selector "div.custom-divider"
        end
      end
    end
  end
end
