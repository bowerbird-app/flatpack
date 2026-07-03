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

          assert_includes page.native.to_html, "md:grid-cols-[280px_1fr]"
        end

        def test_renders_sidebar_and_panel_slots
          render_inline(Component.new(variant: :split)) do |layout|
            layout.sidebar { "Sidebar content" }
            layout.panel { "Panel content" }
          end

          assert_text "Sidebar content"
          assert_text "Panel content"
        end

        def test_split_layout_with_sidebar_and_panel_uses_mobile_controller
          render_inline(Component.new(variant: :split)) do |layout|
            layout.sidebar { "Sidebar content" }
            layout.panel { "Panel content" }
          end

          assert_selector "div[data-controller='flat-pack--chat-layout']"
          assert_selector "div[data-flat-pack--chat-layout-target='sidebar'][data-action='click->flat-pack--chat-layout#openPanel']"
          assert_selector "div[data-flat-pack--chat-layout-target='panel']"
          assert_selector "button[data-action='click->flat-pack--chat-layout#showSidebar']", text: "Back"
        end

        def test_split_panel_is_hidden_until_selected_on_mobile
          render_inline(Component.new(variant: :split)) do |layout|
            layout.sidebar { "Sidebar content" }
            layout.panel { "Panel content" }
          end

          panel = page.find("div[data-flat-pack--chat-layout-target='panel']", visible: :all)

          assert_includes panel[:class], "hidden"
          assert_includes panel[:class], "md:flex"
        end

        def test_does_not_expose_with_prefixed_slot_setters
          component = Component.new

          refute_respond_to component, :with_sidebar
          refute_respond_to component, :with_panel
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

        def test_adds_root_chat_border
          render_inline(Component.new(data: {testid: "chat-layout"}))

          layout = page.find("div[data-testid='chat-layout']", visible: :all)

          assert_includes layout[:class], "border"
          assert_includes layout[:class], "border-[var(--chat-border-color)]"
          assert_includes layout[:class], "rounded-lg"
          assert_includes layout[:class], "overflow-hidden"
        end
      end
    end
  end
end
