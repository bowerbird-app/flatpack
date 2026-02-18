# frozen_string_literal: true

require "test_helper"

module FlatPack
  module SidebarLayout
    class ComponentTest < ViewComponent::TestCase
      def test_renders_basic_layout
        render_inline(Component.new)
        assert_selector "div[data-controller='flat-pack--sidebar-layout']"
      end

      def test_renders_with_left_sidebar_default
        render_inline(Component.new)
        assert_selector "div.grid-cols-\\[auto\\,1fr\\]"
      end

      def test_renders_with_right_sidebar
        render_inline(Component.new(side: :right))
        assert_selector "div.grid-cols-\\[1fr\\,auto\\]"
        assert_selector "div[data-flat-pack--sidebar-layout-side-value='right']"
      end

      def test_validates_side_parameter
        error = assert_raises(ArgumentError) do
          render_inline(Component.new(side: :invalid))
        end
        assert_includes error.message, "Invalid side"
      end

      def test_renders_with_default_open_true
        render_inline(Component.new(default_open: true))
        assert_selector "div[data-flat-pack--sidebar-layout-default-open-value='true']"
      end

      def test_renders_with_default_open_false
        render_inline(Component.new(default_open: false))
        assert_selector "div[data-flat-pack--sidebar-layout-default-open-value='false']"
      end

      def test_renders_with_storage_key
        render_inline(Component.new(storage_key: "my-sidebar-state"))
        assert_selector "div[data-flat-pack--sidebar-layout-storage-key-value='my-sidebar-state']"
      end

      def test_renders_sidebar_slot
        render_inline(Component.new) do |layout|
          layout.sidebar do
            "Sidebar content"
          end
        end
        assert_text "Sidebar content"
      end

      def test_renders_top_nav_slot
        render_inline(Component.new) do |layout|
          layout.top_nav do
            "TopNav content"
          end
        end
        assert_text "TopNav content"
      end

      def test_renders_main_slot
        render_inline(Component.new) do |layout|
          layout.main do
            "Main content"
          end
        end
        assert_text "Main content"
      end

      def test_renders_backdrop
        render_inline(Component.new)
        assert_selector "div[data-flat-pack--sidebar-layout-target='backdrop']"
      end

      def test_renders_all_slots
        render_inline(Component.new) do |layout|
          layout.sidebar { "Sidebar" }
          layout.top_nav { "TopNav" }
          layout.main { "Main" }
        end
        assert_text "Sidebar"
        assert_text "TopNav"
        assert_text "Main"
      end

      def test_right_sidebar_order
        render_inline(Component.new(side: :right)) do |layout|
          layout.sidebar { "Sidebar" }
          layout.main { "Main" }
        end

        # Check that the HTML contains main before sidebar
        html = page.native.to_html
        main_index = html.index("Main")
        sidebar_index = html.index("Sidebar")
        assert main_index < sidebar_index, "Main should appear before Sidebar in right layout"
      end

      def test_sidebar_has_correct_target
        render_inline(Component.new) do |layout|
          layout.sidebar { "Sidebar" }
        end
        assert_selector "div[data-flat-pack--sidebar-layout-target='sidebar']"
      end

      def test_sidebar_column_has_desktop_transition
        render_inline(Component.new) do |layout|
          layout.sidebar { "Sidebar" }
        end

        assert_includes page.native.to_html, "md:transition-all"
      end

      def test_sidebar_column_uses_mobile_only_high_z_index
        render_inline(Component.new) do |layout|
          layout.sidebar { "Sidebar" }
        end

        assert_includes page.native.to_html, "md:z-auto"
      end

      def test_merges_custom_classes
        render_inline(Component.new(class: "custom-class"))
        assert_includes page.native.to_html, "custom-class"
      end

      def test_accepts_data_attributes
        render_inline(Component.new(data: {testid: "layout"}))
        assert_selector "div[data-testid='layout']"
      end
    end
  end
end
