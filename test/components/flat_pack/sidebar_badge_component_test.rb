# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Sidebar
    module Badge
      class ComponentTest < ViewComponent::TestCase
        def test_renders_badge_value
          render_inline(Component.new(value: "12"))

          assert_text "12"
        end

        def test_renders_muted_variant
          render_inline(Component.new(value: "3", variant: :muted))

          assert_includes page.native.to_html, "badge-default-background-color"
        end

        def test_raises_for_invalid_variant
          assert_raises(ArgumentError) do
            Component.new(value: "1", variant: :invalid)
          end
        end
      end
    end
  end
end
