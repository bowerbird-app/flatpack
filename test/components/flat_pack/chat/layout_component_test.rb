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

        def test_renders_split_variant_with_a_fluid_grid_from_the_small_breakpoint
          render_inline(Component.new(variant: :split, data: {testid: "chat-layout"}))

          layout = page.find("div[data-testid='chat-layout']", visible: :all)

          assert_includes layout[:class], "sm:grid"
          assert_equal "grid-template-columns: clamp(12rem, 30%, 16rem) minmax(0, 1fr)", layout[:style]
        end

        def test_single_variant_has_no_grid_columns
          render_inline(Component.new(data: {testid: "chat-layout"}))

          layout = page.find("div[data-testid='chat-layout']", visible: :all)

          assert_nil layout[:style]
          refute_includes layout[:class], "sm:grid"
        end

        def test_split_columns_use_a_custom_sidebar_width
          render_inline(Component.new(variant: :split, sidebar_width: "minmax(12rem, 30%)", data: {testid: "chat-layout"}))

          layout = page.find("div[data-testid='chat-layout']", visible: :all)

          assert_equal "grid-template-columns: minmax(12rem, 30%) minmax(0, 1fr)", layout[:style]
        end

        def test_split_columns_keep_a_caller_style
          render_inline(Component.new(variant: :split, style: "height: 620px;", data: {testid: "chat-layout"}))

          layout = page.find("div[data-testid='chat-layout']", visible: :all)

          assert_equal "grid-template-columns: clamp(12rem, 30%, 16rem) minmax(0, 1fr); height: 620px", layout[:style]
        end

        def test_columns_can_shrink_inside_the_clipped_root
          render_inline(Component.new(variant: :split)) do |layout|
            layout.sidebar { "Sidebar content" }
            layout.panel { "Panel content" }
          end

          sidebar = page.find("div[data-flat-pack--chat-layout-target='sidebar']", visible: :all)
          panel = page.find("div[data-flat-pack--chat-layout-target='panel']", visible: :all)

          assert_includes sidebar[:class], "min-w-0"
          assert_includes panel[:class], "min-w-0"
        end

        def test_split_breakpoint_moves_the_stacked_boundary
          render_inline(Component.new(variant: :split, split_breakpoint: :lg, data: {testid: "chat-layout"})) do |layout|
            layout.sidebar { "Sidebar content" }
            layout.panel { "Panel content" }
          end

          root = page.find("div[data-testid='chat-layout']", visible: :all)
          sidebar = page.find("div[data-flat-pack--chat-layout-target='sidebar']", visible: :all)
          panel = page.find("div[data-flat-pack--chat-layout-target='panel']", visible: :all)

          assert_includes root[:class], "lg:grid"
          assert_includes sidebar[:class], "lg:border-r"
          assert_includes panel[:class], "hidden"
          assert_includes panel[:class], "lg:flex"
        end

        def test_split_breakpoint_is_published_to_the_stimulus_controller
          render_inline(Component.new(variant: :split, split_breakpoint: :md)) do |layout|
            layout.sidebar { "Sidebar content" }
            layout.panel { "Panel content" }
          end

          assert_selector "div[data-flat-pack--chat-layout-breakpoint-value='768']"
        end

        def test_default_split_breakpoint_is_published_to_the_stimulus_controller
          render_inline(Component.new(variant: :split)) do |layout|
            layout.sidebar { "Sidebar content" }
            layout.panel { "Panel content" }
          end

          assert_selector "div[data-flat-pack--chat-layout-breakpoint-value='640']"
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

        def test_split_layout_preserves_custom_controller_data
          render_inline(Component.new(variant: :split, data: {controller: "demo"})) do |layout|
            layout.sidebar { "Sidebar content" }
            layout.panel { "Panel content" }
          end

          assert_selector "div[data-controller='demo flat-pack--chat-layout']"
        end

        def test_split_panel_is_hidden_until_selected_on_mobile
          render_inline(Component.new(variant: :split)) do |layout|
            layout.sidebar { "Sidebar content" }
            layout.panel { "Panel content" }
          end

          panel = page.find("div[data-flat-pack--chat-layout-target='panel']", visible: :all)

          assert_includes panel[:class], "hidden"
          assert_includes panel[:class], "sm:flex"
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

        def test_raises_for_invalid_split_breakpoint
          error = assert_raises(ArgumentError) do
            Component.new(variant: :split, split_breakpoint: :xl)
          end

          assert_includes error.message, "Invalid split_breakpoint"
        end

        def test_raises_for_unsafe_sidebar_width
          error = assert_raises(ArgumentError) do
            Component.new(variant: :split, sidebar_width: "16rem; background: url(evil.png)")
          end

          assert_includes error.message, "Invalid sidebar_width"
        end

        def test_raises_for_blank_sidebar_width
          error = assert_raises(ArgumentError) do
            Component.new(variant: :split, sidebar_width: "")
          end

          assert_includes error.message, "Invalid sidebar_width"
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
