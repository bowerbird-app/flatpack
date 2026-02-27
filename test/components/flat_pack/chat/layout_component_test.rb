# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Chat
    module Layout
      class ComponentTest < ViewComponent::TestCase
        def test_renders_single_variant_by_default
          render_inline(Component.new)

          assert_includes page.native.to_html, "flex flex-col"
        end

        def test_renders_split_variant
          render_inline(Component.new(variant: :split))

          assert_includes page.native.to_html, "grid-cols-[280px_1fr]"
        end

        def test_renders_sidebar_and_panel_slots
          render_inline(Component.new(variant: :split)) do |layout|
            layout.with_sidebar { "Sidebar content" }
            layout.with_panel { "Panel content" }
          end

          assert_text "Sidebar content"
          assert_text "Panel content"
        end

        def test_raises_for_invalid_variant
          error = assert_raises(ArgumentError) do
            Component.new(variant: :invalid)
          end

          assert_includes error.message, "Invalid variant"
        end

        def test_merges_custom_data_attributes
          render_inline(Component.new(data: {testid: "chat-layout"}))

          assert_selector "div[data-testid='chat-layout']"
        end
      end
    end
  end
end
