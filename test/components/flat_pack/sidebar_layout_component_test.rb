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
        assert_includes page.native.to_html, "grid-cols-[auto_1fr]"
      end

      def test_renders_with_right_sidebar
        render_inline(Component.new(side: :right)) do |layout|
          layout.sidebar { "Sidebar" }
        end
        assert_includes page.native.to_html, "grid-cols-[1fr_auto]"
        assert_selector "div[data-flat-pack--sidebar-layout-side-value='right']"
        assert_includes page.native.to_html, 'data-mobile-drawer-side="right"'
      end

      def test_validates_side_parameter
        error = assert_raises(ArgumentError) do
          render_inline(Component.new(side: :invalid))
        end
        assert_includes error.message, "Invalid side"
      end

      def test_renders_with_default_open_true
        render_inline(Component.new(open: true))
        assert_selector "div[data-flat-pack--sidebar-layout-open-value='true']"
      end

      def test_renders_with_default_open_false
        render_inline(Component.new(open: false))
        assert_selector "div[data-flat-pack--sidebar-layout-open-value='false']"
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
        assert_includes page.native.to_html, "bg-[var(--drawer-backdrop-color)]"
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
        assert_includes page.native.to_html, "fp-sidebar-drawer"
        assert_includes page.native.to_html, 'data-mobile-drawer-side="left"'
      end

      def test_sidebar_column_has_desktop_transition
        render_inline(Component.new) do |layout|
          layout.sidebar { "Sidebar" }
        end

        assert_includes page.native.to_html, "md:transition-[width,transform]"
        assert_includes page.native.to_html, "ease-[var(--easing-standard)]"
        refute_includes page.native.to_html, "overflow-x-hidden"
      end

      def test_sidebar_column_uses_mobile_only_high_z_index
        render_inline(Component.new) do |layout|
          layout.sidebar { "Sidebar" }
        end

        assert_includes page.native.to_html, "md:z-auto"
      end

      def test_sidebar_column_constrains_height_for_internal_scroll
        render_inline(Component.new) do |layout|
          layout.sidebar { "Sidebar" }
        end

        assert_includes page.native.to_html, "md:h-screen"
        assert_includes page.native.to_html, "md:self-start"
        assert_includes page.native.to_html, "min-h-0"
      end

      def test_main_column_uses_flexible_content_flow
        render_inline(Component.new)

        assert_includes page.native.to_html, "min-w-0"
        assert_includes page.native.to_html, "min-h-0"
        assert_includes page.native.to_html, "overflow-hidden"
      end

      def test_container_is_locked_to_viewport_height
        render_inline(Component.new)

        assert_includes page.native.to_html, "h-screen"
        assert_includes page.native.to_html, "overflow-hidden"
      end

      def test_main_content_scrolls_independently
        render_inline(Component.new) do |layout|
          layout.top_nav { "TopNav" }
          layout.main { "Main" }
        end

        assert_selector "div.flex-1.min-h-0.overflow-y-auto", text: "Main"
      end

      def test_merges_custom_classes
        render_inline(Component.new(class: "custom-class"))
        assert_includes page.native.to_html, "custom-class"
      end

      def test_accepts_data_attributes
        render_inline(Component.new(data: {testid: "layout"}))
        assert_selector "div[data-testid='layout']"
      end

      def test_flush_sidebar_is_the_default
        render_inline(Component.new) do |layout|
          layout.sidebar { "Sidebar" }
        end

        refute_includes page.native.to_html, "data-flat-pack-sidebar-floating"
      end

      def test_floating_sidebar_marks_the_column
        render_inline(Component.new(floating: true, side: :right)) do |layout|
          layout.sidebar { "Sidebar" }
        end

        assert_selector "div[data-flat-pack-sidebar-floating='true'][data-mobile-drawer-side='right']"
      end

      def test_floating_false_matches_the_flush_rail
        render_inline(Component.new(floating: false)) do |layout|
          layout.sidebar { "Sidebar" }
        end

        refute_includes page.native.to_html, "data-flat-pack-sidebar-floating"
      end

      def test_floating_rejects_non_boolean
        error = assert_raises(ArgumentError) do
          Component.new(floating: "yes")
        end

        assert_includes error.message, "floating must be true or false"
      end

      def test_default_top_nav_stays_out_of_the_scroll_pane
        render_inline(Component.new(content_scroll: :below)) do |layout|
          layout.top_nav { "TopNav" }
          layout.main { "Main" }
        end

        html = page.native.to_html
        assert_operator html.index("TopNav"), :<, html.index("Main")
        refute_includes html, "data-flat-pack-top-nav-floating"
        refute_includes html, "fp-layout-top-nav"
        refute_includes html, "fp-layout-scroll"
        assert_selector "div.flex-1.min-h-0.overflow-y-auto", text: "Main"
        column = page.native.at_css("div.flex.flex-col.min-w-0")
        refute_includes column["class"].to_s.split, "relative"
      end

      def test_floating_top_nav_scrolls_content_behind_the_cards
        render_inline(Component.new(floating_top_nav: true)) do |layout|
          layout.top_nav { "TopNav" }
          layout.main { "Main" }
        end

        assert_selector ".fp-layout-top-nav[data-flat-pack-top-nav-floating='behind']", text: "TopNav"
        assert_selector ".fp-layout-scroll", text: "Main"
        float = page.find(".fp-layout-top-nav")
        assert_nil float["aria-hidden"]

        html = page.native.to_html
        assert_operator html.index("TopNav"), :<, html.index("Main")
        column = page.native.at_css("div.flex.flex-col.min-w-0")
        assert_includes column["class"].to_s.split, "relative"
      end

      def test_floating_top_nav_can_leave_content_below_the_cards
        render_inline(Component.new(floating_top_nav: true, content_scroll: :below)) do |layout|
          layout.top_nav { "TopNav" }
          layout.main { "Main" }
        end

        assert_selector "[data-flat-pack-top-nav-floating='below']", text: "TopNav"
        refute_selector ".fp-layout-scroll"
        assert_selector "div.flex-1.min-h-0.overflow-y-auto", text: "Main"
      end

      def test_floating_top_nav_keeps_the_header_landmark
        nav = FlatPack::TopNav::Component.new
        nav.left { "Preview" }
        nav.right { "Bell" }

        render_inline(Component.new(floating_top_nav: true, floating: true)) do |layout|
          layout.sidebar { "Rail" }
          layout.top_nav { nav.render_in(vc_test_controller.view_context).to_s.html_safe }
          layout.main { "Main" }
        end

        assert_selector ".fp-layout-top-nav header.fp-top-nav", text: "Preview"
        assert_selector "[data-flat-pack-top-nav-section='left']", text: "Preview"
        assert_selector "[data-flat-pack-top-nav-section='right']", text: "Bell"
        assert_selector "[data-flat-pack-sidebar-floating='true']"
      end

      def test_floating_top_nav_without_a_slot_matches_the_flush_bar
        render_inline(Component.new(floating_top_nav: true)) do |layout|
          layout.main { "Main" }
        end

        refute_includes page.native.to_html, "data-flat-pack-top-nav-floating"
        refute_includes page.native.to_html, "fp-layout-scroll"
      end

      def test_floating_top_nav_rejects_non_boolean
        error = assert_raises(ArgumentError) do
          Component.new(floating_top_nav: "yes")
        end

        assert_includes error.message, "floating_top_nav must be true or false"
      end

      def test_content_scroll_rejects_unknown_values
        error = assert_raises(ArgumentError) do
          Component.new(content_scroll: :page)
        end

        assert_includes error.message, "content_scroll must be :behind or :below"
      end

      def test_floating_rail_stays_full_height_by_default
        render_inline(Component.new(floating: true, height: :full)) do |layout|
          layout.sidebar { "Sidebar" }
        end

        refute_includes page.native.to_html, "data-flat-pack-sidebar-height"
        assert_includes page.native.to_html, "md:h-screen"
      end

      def test_floating_rail_can_size_to_its_content
        render_inline(Component.new(floating: true, height: :content)) do |layout|
          layout.sidebar { "Sidebar" }
        end

        assert_selector "[data-flat-pack-sidebar-floating='true'][data-flat-pack-sidebar-height='content']", text: "Sidebar"
      end

      def test_content_height_without_floating_matches_the_flush_rail
        render_inline(Component.new(floating: false, height: :content)) do |layout|
          layout.sidebar { "Sidebar" }
        end

        html = page.native.to_html
        refute_includes html, "data-flat-pack-sidebar-floating"
        refute_includes html, "data-flat-pack-sidebar-height"
        assert_includes html, "md:h-screen"
      end

      def test_content_height_accepts_the_string_form
        render_inline(Component.new(floating: true, height: "content")) do |layout|
          layout.sidebar { "Sidebar" }
        end

        assert_selector "[data-flat-pack-sidebar-height='content']"
      end

      def test_height_rejects_unknown_values
        error = assert_raises(ArgumentError) do
          Component.new(height: :page)
        end

        assert_includes error.message, "height must be :full or :content"
      end

      def test_fixed_width_is_the_default
        render_inline(Component.new(floating: true, height: :content)) do |layout|
          layout.sidebar { "Sidebar" }
        end

        html = page.native.to_html
        refute_includes html, "data-flat-pack-sidebar-width"
        refute_includes html, "w-64"
        assert_includes html, "md:w-auto"
        assert_includes html, "fp-sidebar-drawer"
      end

      def test_content_width_sets_the_desktop_hook
        render_inline(Component.new(width: :content)) do |layout|
          layout.sidebar { "Sidebar" }
        end

        assert_selector "[data-flat-pack-sidebar-width='content']", text: "Sidebar"
        refute_includes page.native.to_html, "w-64"
      end

      def test_content_width_accepts_the_string_form
        render_inline(Component.new(width: "content", floating: true, height: :content)) do |layout|
          layout.sidebar { "Sidebar" }
        end

        assert_selector "[data-flat-pack-sidebar-width='content'][data-flat-pack-sidebar-floating='true'][data-flat-pack-sidebar-height='content']"
      end

      def test_fixed_width_accepts_the_symbol
        render_inline(Component.new(width: :fixed)) do |layout|
          layout.sidebar { "Sidebar" }
        end

        refute_includes page.native.to_html, "data-flat-pack-sidebar-width"
      end

      def test_width_rejects_unknown_values
        error = assert_raises(ArgumentError) do
          Component.new(width: :page)
        end

        assert_includes error.message, "width must be :fixed or :content"
      end

      def test_content_scroll_accepts_the_string_form
        render_inline(Component.new(floating_top_nav: true, content_scroll: "below")) do |layout|
          layout.top_nav { "TopNav" }
        end

        assert_selector "[data-flat-pack-top-nav-floating='below']"
      end

      def test_background_slot_is_absent_by_default
        render_inline(Component.new) do |layout|
          layout.sidebar { "Sidebar" }
          layout.main { "Main" }
        end

        refute_selector ".fp-layout-background"
        refute_selector ".fp-layout-main"
        refute_includes page.native.to_html, "data-flat-pack-layout-background"
      end

      def test_background_slot_renders_a_decorative_layer
        render_inline(Component.new(floating: true)) do |layout|
          layout.background { %(<img src="/images/hero-packaging.jpg" alt="">).html_safe }
          layout.sidebar { "Sidebar" }
          layout.main { "Main" }
        end

        assert_selector "[data-flat-pack-layout-background='true']"
        assert_selector ".fp-layout-background[aria-hidden='true']"
        assert_selector ".fp-layout-background-media img[alt=''][src='/images/hero-packaging.jpg']"
        assert_selector ".fp-layout-background-tint"
        assert_selector ".fp-layout-main"
        refute_selector ".fp-layout-background img[alt]:not([alt=''])"

        html = page.native.to_html
        assert_operator html.index("fp-layout-background"), :<, html.index("Sidebar")
      end

      def test_background_image_is_hidden_from_assistive_tech
        render_inline(Component.new) do |layout|
          layout.background { %(<img src="/images/hero-packaging.jpg" alt="">).html_safe }
        end

        layer = page.find(".fp-layout-background")
        assert_equal "true", layer["aria-hidden"]
        assert_equal "", layer.find("img")["alt"]
        refute layer.has_selector?("[tabindex]")
      end

      def test_shell_does_not_register_legacy_navbar_controller
        render_inline(Component.new) do |layout|
          layout.sidebar { "Sidebar" }
          layout.top_nav { "TopNav" }
          layout.main { "Main" }
        end

        assert_selector "[data-controller='flat-pack--sidebar-layout']"
        refute_selector "[data-controller='flat-pack--navbar']"
      end
    end
  end
end
