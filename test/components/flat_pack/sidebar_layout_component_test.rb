# frozen_string_literal: true

require "test_helper"

module FlatPack
  module SidebarLayout
    class ComponentTest < ViewComponent::TestCase
      def layout_html(**kwargs)
        render_inline(Component.new(**kwargs)) do |layout|
          layout.sidebar { "Sidebar" }
          layout.top_nav { "TopNav" }
          layout.main { "Main" }
        end
        page.native.to_html
      end

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

        column = page.find("div[data-flat-pack-sidebar-floating='true'][data-mobile-drawer-side='right']")
        assert_includes column["class"].to_s.split, "fp-sidebar-drawer"
        assert_includes column["style"], "--sidebar-background-color: var(--sidebar-float-background-color)"
        assert_includes column["style"], "--sidebar-header-background-color: var(--sidebar-float-background-color)"
        assert_includes column["style"], "--sidebar-collapsed-frame: 2px"
        refute_includes page.native.to_html, "menu.setAttribute"
      end

      def test_floating_aside_column_carries_the_same_surface
        render_inline(Component.new(floating: true, side: :left)) do |layout|
          layout.sidebar { "Sidebar" }
          layout.aside { "Notes" }
        end

        page.all("[data-flat-pack-sidebar-floating='true']").each do |column|
          assert_includes column["class"].to_s.split, "fp-sidebar-drawer"
          assert_includes column["style"], "--sidebar-collapsed-frame: 2px"
          assert_includes column["style"], "--sidebar-background-color: var(--sidebar-float-background-color)"
        end
        assert_selector "[data-flat-pack-panel='aside'].fp-sidebar-drawer", text: "Notes"
      end

      def test_flush_column_does_not_set_the_floating_frame
        render_inline(Component.new(floating: false)) do |layout|
          layout.sidebar { "Sidebar" }
          layout.aside { "Notes" }
        end

        refute_includes page.native.to_html, "--sidebar-collapsed-frame"
        refute_includes page.native.to_html, "--sidebar-float-background-color"
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
        assert_selector ".fp-layout-top-nav[data-flat-pack-content-scroll='below'][data-controller='flat-pack--top-nav'][data-scrolled='false']", text: "TopNav"
        refute_includes html, "data-flat-pack-top-nav-floating"
        refute_includes html, "fp-layout-scroll"
        assert_selector "div.flex-1.min-h-0.overflow-y-auto", text: "Main"
        column = page.native.at_css("div.flex.flex-col.min-w-0")
        refute_includes column["class"].to_s.split, "relative"
      end

      def test_content_scroll_behind_lays_the_bar_over_the_pane
        render_inline(Component.new(content_scroll: :behind)) do |layout|
          layout.top_nav { "TopNav" }
          layout.main { "Main" }
        end

        assert_selector ".fp-layout-top-nav[data-flat-pack-content-scroll='behind']", text: "TopNav"
        assert_selector ".fp-layout-scroll", text: "Main"
        bar = page.find(".fp-layout-top-nav")
        assert_nil bar["aria-hidden"]

        html = page.native.to_html
        assert_operator html.index("TopNav"), :<, html.index("Main")
        column = page.native.at_css("div.flex.flex-col.min-w-0")
        assert_includes column["class"].to_s.split, "relative"
      end

      def test_default_content_scroll_keeps_the_bar_above_the_pane
        render_inline(Component.new) do |layout|
          layout.top_nav { "TopNav" }
          layout.main { "Main" }
        end

        assert_selector "[data-flat-pack-content-scroll='below']", text: "TopNav"
        refute_selector ".fp-layout-scroll"
        assert_selector "div.flex-1.min-h-0.overflow-y-auto", text: "Main"
      end

      def test_top_nav_keeps_the_header_landmark
        nav = FlatPack::TopNav::Component.new
        nav.left { "Preview" }
        nav.right { "Bell" }

        render_inline(Component.new(floating: true)) do |layout|
          layout.sidebar { "Rail" }
          layout.top_nav { nav.render_in(vc_test_controller.view_context).to_s.html_safe }
          layout.main { "Main" }
        end

        assert_selector ".fp-layout-top-nav header.fp-top-nav", text: "Preview"
        assert_selector ".fp-top-nav__left", text: "Preview"
        assert_selector ".fp-top-nav__right", text: "Bell"
        assert_selector "[data-flat-pack-sidebar-floating='true']"
        refute_includes page.native.to_html, "data-flat-pack-top-nav-section"
      end

      def test_content_scroll_behind_without_a_slot_stays_flush
        render_inline(Component.new(content_scroll: :behind)) do |layout|
          layout.main { "Main" }
        end

        refute_includes page.native.to_html, "data-flat-pack-content-scroll"
        refute_includes page.native.to_html, "fp-layout-scroll"
        refute_includes page.native.to_html, "fp-layout-top-nav"
      end

      def test_floating_top_nav_is_an_unknown_keyword
        error = assert_raises(ArgumentError) do
          Component.new(floating_top_nav: true)
        end

        assert_match(/unknown keyword: :?floating_top_nav/, error.message)
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
        render_inline(Component.new(content_scroll: "behind")) do |layout|
          layout.top_nav { "TopNav" }
        end

        assert_selector "[data-flat-pack-content-scroll='behind']"
      end

      def test_omitted_scroll_matches_pane
        assert_equal layout_html, layout_html(scroll: :pane)
        assert_equal layout_html(content_scroll: :behind), layout_html(content_scroll: :behind, scroll: :pane)
      end

      def test_page_scroll_unlocks_the_shell
        render_inline(Component.new(scroll: :page)) do |layout|
          layout.sidebar { "Sidebar" }
          layout.top_nav { "TopNav" }
          layout.main { "Main" }
        end

        shell = page.native.at_css("[data-controller='flat-pack--sidebar-layout']")
        assert_equal "page", shell["data-flat-pack-layout-scroll"]
        shell_classes = shell["class"].to_s.split
        refute_includes shell_classes, "h-screen"
        refute_includes shell_classes, "overflow-hidden"

        pane = page.native.at_css("div.flex-1.min-h-0")
        pane_classes = pane["class"].to_s.split
        refute_includes pane_classes, "overflow-y-auto"
        refute_includes pane_classes, "overscroll-y-contain"

        column = page.native.at_css("div.flex.flex-col.min-w-0")
        refute_includes column["class"].to_s.split, "overflow-hidden"
      end

      def test_page_scroll_behind_the_bar_paints_a_surface
        render_inline(Component.new(scroll: :page, content_scroll: :behind)) do |layout|
          layout.sidebar { "Sidebar" }
          layout.top_nav { "TopNav" }
          layout.main { "Main" }
        end

        assert_selector ".fp-layout-top-nav[data-flat-pack-content-scroll='behind']", text: "TopNav"
        assert_selector ".fp-layout-scroll", text: "Main"
        assert_selector ".fp-layout-page"
        assert_selector ".fp-layout-page-surface[aria-hidden='true']"
      end

      def test_page_scroll_with_a_background_omits_the_surface
        render_inline(Component.new(scroll: :page, content_scroll: :behind)) do |layout|
          layout.background { "Photo" }
          layout.sidebar { "Sidebar" }
          layout.top_nav { "TopNav" }
          layout.main { "Main" }
        end

        refute_selector ".fp-layout-page-surface"
      end

      def test_page_scroll_can_keep_the_bar_in_flow
        render_inline(Component.new(scroll: :page, content_scroll: :below)) do |layout|
          layout.top_nav { "TopNav" }
          layout.main { "Main" }
        end

        assert_selector "[data-flat-pack-content-scroll='below']", text: "TopNav"
        refute_selector ".fp-layout-scroll"
        refute_selector ".fp-layout-page-surface"
        refute_selector ".fp-layout-page"
      end

      def test_scroll_rejects_unknown_values
        error = assert_raises(ArgumentError) do
          Component.new(scroll: :window)
        end

        assert_equal "scroll must be :pane or :page", error.message
      end

      def test_scroll_accepts_the_string_form
        render_inline(Component.new(scroll: "page")) do |layout|
          layout.main { "Main" }
        end

        assert_selector "[data-flat-pack-layout-scroll='page']"
      end

      def test_background_slot_is_absent_by_default
        render_inline(Component.new) do |layout|
          layout.sidebar { "Sidebar" }
          layout.main { "Main" }
        end

        refute_selector ".fp-backdrop"
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
        assert_selector ".fp-backdrop[aria-hidden='true']"
        assert_selector ".fp-backdrop-media img[alt=''][src='/images/hero-packaging.jpg']"
        assert_selector ".fp-backdrop-tint"
        assert_selector ".fp-layout-main"
        refute_selector ".fp-layout-background"
        refute_selector ".fp-backdrop img[alt]:not([alt=''])"

        html = page.native.to_html
        assert_operator html.index("fp-backdrop"), :<, html.index("Sidebar")
      end

      def test_background_image_is_hidden_from_assistive_tech
        render_inline(Component.new) do |layout|
          layout.background { %(<img src="/images/hero-packaging.jpg" alt="">).html_safe }
        end

        layer = page.find(".fp-backdrop")
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

      def test_without_an_aside_keeps_the_two_column_shell
        render_inline(Component.new(side: :left, storage_key: "app-shell")) do |layout|
          layout.sidebar { "Sidebar" }
          layout.main { "Main" }
        end

        html = page.native.to_html
        assert_includes html, "grid-cols-[auto_1fr]"
        refute_includes html, "grid-cols-[auto_1fr_auto]"
        refute_includes html, "data-flat-pack-layout-columns"
        refute_includes html, "fp-aside"
        refute_includes html, "data-flat-pack-panel"
        refute_includes html, "data-flat-pack-aside-open"
        refute_includes html, "flat-pack--panel-resize"
        refute_includes html, "aside-open-value"
        refute_includes html, "aside-storage-key"
        assert_selector "[data-flat-pack--sidebar-layout-target='sidebar']", count: 1
        assert_includes html, ".setAttribute('data-flat-pack-sidebar-collapsed',c?'true':'false')"
        refute_includes html, "menu.setAttribute"
        assert_selector "[data-flat-pack--sidebar-layout-target='backdrop'][data-action='click->flat-pack--sidebar-layout#closeMobile']", count: 1
        assert_includes html, "s!==null?s==='true':!d"
      end

      def test_resizable_rail_adds_a_handle_without_an_aside
        render_inline(Component.new(resizable: true, storage_key: "app-shell", width: :content)) do |layout|
          layout.sidebar { "Sidebar" }
        end

        html = page.native.to_html
        assert_includes html, "grid-cols-[auto_1fr]"
        refute_includes html, "fp-aside"
        assert_selector "[data-flat-pack--sidebar-layout-target='sidebar'][data-controller='flat-pack--panel-resize'][data-flat-pack-sidebar-width='content']"
        assert_selector "[role='separator'][aria-orientation='vertical'][aria-label='Resize sidebar'][tabindex='0'].fp-panel-resize.hidden"
        assert_includes html, 'data-flat-pack--panel-resize-storage-key-value="app-shell:rail:width"'
        assert_includes html, 'data-flat-pack--panel-resize-collapses-value="true"'
        assert_selector "[data-action='pointerdown->flat-pack--panel-resize#start keydown->flat-pack--panel-resize#nudge dblclick->flat-pack--panel-resize#reset']"
        assert_includes html, "app-shell:rail:width"
        refute_selector "[aria-label='Resize aside']"
      end

      def test_resize_handle_is_absent_when_resizable_is_false
        render_inline(Component.new(resizable: false)) do |layout|
          layout.sidebar { "Sidebar" }
          layout.aside(resizable: false) { "Details" }
        end

        refute_selector "[role='separator']"
        refute_includes page.native.to_html, "flat-pack--panel-resize"
      end

      def test_aside_sits_on_the_opposite_edge_when_the_rail_is_left
        render_inline(Component.new(side: :left, storage_key: "app-shell", floating: true, height: :content)) do |layout|
          layout.sidebar { "Sidebar" }
          layout.main { "Main" }
          layout.aside(open: true, resizable: true) { "Details" }
        end

        html = page.native.to_html
        assert_includes html, 'data-flat-pack-layout-columns="three"'
        refute_includes html, "grid-cols-[auto_1fr"
        assert_operator html.index("Sidebar"), :<, html.index("Main")
        assert_operator html.index("Main"), :<, html.index("Details")
        assert_selector "aside.fp-aside.h-full.min-h-0.overflow-y-auto.overscroll-y-contain", text: "Details"
        assert_selector "[data-flat-pack--sidebar-layout-target='aside'][data-flat-pack-panel='aside'][data-flat-pack-aside-open='true'][data-mobile-drawer-side='right'][data-flat-pack-sidebar-floating='true'][data-flat-pack-sidebar-height='content']"
        refute_selector "[data-flat-pack-panel='aside'][data-flat-pack-sidebar-width]"
        assert_selector "[data-flat-pack--sidebar-layout-target='backdrop']", count: 1
        assert_includes html, 'data-flat-pack--sidebar-layout-aside-open-value="true"'
        assert_includes html, 'data-flat-pack--sidebar-layout-aside-storage-key-value="app-shell:aside"'
        assert_includes html, 'data-flat-pack--panel-resize-storage-key-value="app-shell:aside:width"'
        assert_includes html, 'data-flat-pack--panel-resize-collapses-value="false"'
        assert_selector "[data-flat-pack-panel='aside'] [role='separator'][aria-label='Resize aside']"
        refute_selector "[data-flat-pack--sidebar-layout-target='sidebar'] [role='separator']"
        assert_includes html, 'var stored=localStorage.getItem("app-shell:aside")'
        assert_includes html, "var open=stored===null?true:stored===\"true\""
        assert_includes html, "s!==null?s==='true':!d"
      end

      def test_aside_sits_on_the_left_when_the_rail_is_right
        render_inline(Component.new(side: :right, storage_key: "app-shell")) do |layout|
          layout.sidebar { "Sidebar" }
          layout.main { "Main" }
          layout.aside(open: false) { "Details" }
        end

        html = page.native.to_html
        assert_includes html, 'data-flat-pack-layout-columns="three"'
        refute_includes html, "grid-cols-"
        assert_operator html.index("Details"), :<, html.index("Main")
        assert_operator html.index("Main"), :<, html.index("Sidebar")
        assert_selector "[data-flat-pack-panel='aside'][data-flat-pack-aside-open='false'][data-mobile-drawer-side='left'][inert]"
        assert_includes html, "var open=stored===null?false:stored===\"true\""
        refute_selector "[data-flat-pack--sidebar-layout-target='sidebar'][data-flat-pack-panel]"
      end

      def test_aside_only_uses_a_two_track_grid_on_its_edge
        render_inline(Component.new(side: :left)) do |layout|
          layout.main { "Main" }
          layout.aside { "Details" }
        end

        html = page.native.to_html
        assert_includes html, 'data-flat-pack-layout-columns="main-aside"'
        refute_includes html, "grid-cols-"
        refute_selector "[data-flat-pack--sidebar-layout-target='sidebar']"
        assert_selector "[data-flat-pack-panel='aside'][data-mobile-drawer-side='right'][data-flat-pack-aside-open='true']"
        assert_operator html.index("Main"), :<, html.index("Details")
        refute_includes html, "localStorage"

        render_inline(Component.new(side: :right)) do |layout|
          layout.main { "Main" }
          layout.aside(open: false) { "Notes" }
        end

        html = page.native.to_html
        assert_includes html, 'data-flat-pack-layout-columns="aside-main"'
        refute_includes html, "grid-cols-"
        assert_selector "[data-flat-pack-panel='aside'][data-mobile-drawer-side='left'][data-flat-pack-aside-open='false'][inert]"
        assert_operator html.index("Notes"), :<, html.index("Main")
      end

      def test_aside_open_defaults_to_true
        render_inline(Component.new) do |layout|
          layout.aside { "Details" }
        end

        assert_selector "[data-flat-pack-aside-open='true']"
        assert_selector "[data-flat-pack--sidebar-layout-aside-open-value='true']"
        refute_selector "[data-flat-pack--sidebar-layout-aside-storage-key-value]"
      end

      def test_aside_mobile_defaults_to_a_drawer
        render_inline(Component.new(side: :left)) do |layout|
          layout.main { "Main" }
          layout.aside { "Details" }
        end

        aside = page.find("[data-flat-pack-panel='aside']")
        assert_equal "drawer", aside["data-flat-pack-aside-mobile"]
        assert_includes aside[:class].to_s.split, "translate-x-full"
        assert_includes aside[:class].to_s.split, "fixed"
        assert_equal "drawer", page.find("[data-flat-pack-layout-columns]")["data-flat-pack-aside-mobile"]
        assert_equal "drawer", page.find("[data-controller='flat-pack--sidebar-layout']")["data-flat-pack--sidebar-layout-aside-mobile-value"]
      end

      def test_aside_mobile_stack_renders_in_flow_under_main
        render_inline(Component.new(side: :left, storage_key: "app-shell")) do |layout|
          layout.sidebar { "Sidebar" }
          layout.main { "Main" }
          layout.aside(mobile: :stack, open: false) { "Details" }
        end

        html = page.native.to_html
        aside = page.find("[data-flat-pack-panel='aside']")
        assert_equal "stack", aside["data-flat-pack-aside-mobile"]
        refute_includes aside[:class].to_s.split, "fixed"
        refute_includes aside[:class].to_s.split, "translate-x-full"
        refute_includes aside[:class].to_s.split, "-translate-x-full"
        assert_includes aside[:class].to_s.split, "fp-aside-stack"
        assert_nil aside["inert"]
        assert_includes html, 'if(open||!window.matchMedia("(min-width: 768px)").matches)'
        assert_equal "stack", page.find("[data-flat-pack-layout-columns]")["data-flat-pack-aside-mobile"]
        assert_selector "[data-flat-pack-layout-main='true']", text: "Main"
      end

      def test_aside_mobile_accepts_the_string_form_and_rejects_anything_else
        render_inline(Component.new) do |layout|
          layout.aside(mobile: "stack") { "Details" }
        end

        assert_equal "stack", page.find("[data-flat-pack-panel='aside']")["data-flat-pack-aside-mobile"]

        error = assert_raises(ArgumentError) do
          render_inline(Component.new) do |layout|
            layout.aside(mobile: :side) { "Details" }
          end
        end
        assert_equal "mobile must be :drawer or :stack", error.message
      end

      def test_aside_trigger_names_the_panel
        render_inline(Component.new) do |layout|
          layout.aside(open: true) { "Notes" }
          layout.top_nav { layout.aside_trigger("Details") }
        end

        button = page.find("button", text: "Details")
        aside = page.find("[data-flat-pack-panel='aside']")
        assert_equal "asideToggle", button["data-flat-pack--sidebar-layout-target"]
        assert_equal "click->flat-pack--sidebar-layout#toggleAside", button["data-action"]
        assert_equal "true", button["aria-expanded"]
        assert_equal "flat-pack-aside", aside["id"]
        assert_equal aside["id"], button["aria-controls"]

        closed = assert_raises(ArgumentError) { Component.new.aside_trigger(" ") }
        assert_equal "Aside trigger needs a label.", closed.message
      end

      def test_resizable_rejects_non_booleans
        error = assert_raises(ArgumentError) do
          Component.new(resizable: "yes")
        end
        assert_includes error.message, "resizable must be true or false"

        error = assert_raises(ArgumentError) do
          render_inline(Component.new) do |layout|
            layout.aside(open: "yes") { "Details" }
          end
        end
        assert_includes error.message, "open must be true or false"

        error = assert_raises(ArgumentError) do
          render_inline(Component.new) do |layout|
            layout.aside(resizable: nil) { "Details" }
          end
        end
        assert_includes error.message, "resizable must be true or false"
      end

      def test_panel_storage_keys_stay_on_the_record
        rail = Panel.rail(
          edge: :left,
          open: true,
          resizable: true,
          width_mode: :content,
          floating: false,
          content_height: false,
          storage_key: "app-shell"
        )
        aside = Panel.aside(
          edge: :right,
          open: false,
          resizable: true,
          floating: true,
          content_height: true,
          storage_key: "app-shell"
        )
        unstored = Panel.aside(
          edge: :right,
          open: true,
          resizable: false,
          floating: false,
          content_height: false,
          storage_key: nil
        )

        assert_equal :rail, rail.role
        assert_equal true, rail.collapses
        assert_equal :content, rail.width_mode
        assert_nil rail.open_storage_key
        assert_equal "app-shell:rail:width", rail.width_storage_key

        assert_equal :aside, aside.role
        assert_equal false, aside.collapses
        assert_equal :fixed, aside.width_mode
        assert_equal "app-shell:aside", aside.open_storage_key
        assert_equal "app-shell:aside:width", aside.width_storage_key
        assert_nil unstored.open_storage_key
        assert_nil unstored.width_storage_key
      end

      def test_resized_width_beats_the_content_width_rule
        kit = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read
        dummy = FlatPack::Engine.root.join("test/dummy/app/assets/stylesheets/application.tailwind.css").read
        content = '[data-flat-pack-sidebar-collapsed="false"][data-flat-pack-sidebar-width="content"] aside'
        resized = '[data-flat-pack-panel-resized="true"][data-flat-pack-sidebar-collapsed="false"][data-flat-pack-sidebar-width="content"] aside'

        [kit, dummy].each do |sheet|
          compact = sheet.gsub(/\s+/, " ")
          content_at = compact.index(content)
          resized_at = compact.index(resized)

          assert content_at
          assert resized_at
          assert_operator resized_at, :>, content_at
          assert_operator (selector_rank(resized) <=> selector_rank(content)), :>=, 0
        end
      end

      def test_pane_scroll_hides_the_bar_and_stays_in_tab_order
        render_inline(Component.new) do |layout|
          layout.main { "Main" }
          layout.aside { "Details" }
        end

        pane = page.find("div.fp-pane-scroll", text: "Main")
        assert_includes pane[:class], "overflow-y-auto"
        assert_equal "0", pane["tabindex"]
        assert_equal "Content", pane["aria-label"]
        assert_nil pane["role"]
        assert_nil pane["data-pane-scrollbar"]

        aside = page.find("aside.fp-pane-scroll", text: "Details")
        assert_equal "0", aside["tabindex"]
        assert_equal "Side panel", aside["aria-label"]
        assert_nil aside["role"]
        assert_nil aside["data-pane-scrollbar"]
      end

      def test_visible_scrollbar_resets_the_main_pane_and_the_aside
        render_inline(Component.new(scrollbar: :visible)) do |layout|
          layout.main { "Main" }
          layout.aside { "Details" }
        end

        pane = page.find("div.fp-pane-scroll", text: "Main")
        assert_equal "visible", pane["data-pane-scrollbar"]
        assert_nil pane["tabindex"]
        assert_nil pane["aria-label"]

        aside = page.find("aside.fp-aside", text: "Details")
        assert_equal "visible", aside["data-pane-scrollbar"]
        assert_nil aside["tabindex"]
        assert_nil aside["aria-label"]
      end

      def test_scrollbar_accepts_the_string_form
        render_inline(Component.new(scrollbar: "visible")) do |layout|
          layout.main { "Main" }
        end

        assert_equal "visible", page.find("div.fp-pane-scroll")["data-pane-scrollbar"]
      end

      def test_scrollbar_rejects_unknown_values
        error = assert_raises(ArgumentError) { Component.new(scrollbar: :thin) }

        assert_equal "scrollbar must be :hidden or :visible", error.message
      end

      def test_page_scroll_leaves_the_window_bar_and_still_hides_the_aside
        render_inline(Component.new(scroll: :page)) do |layout|
          layout.main { "Main" }
          layout.aside { "Details" }
        end

        pane = page.find("div.flex-1.min-h-0", text: "Main")
        refute_includes pane[:class], "fp-pane-scroll"
        assert_nil pane["tabindex"]
        assert_selector "aside.fp-pane-scroll", text: "Details"
      end

      def selector_rank(selector)
        working = selector.gsub(/:not\(([^)]*)\)/, "\\1")
        ids = working.scan(/#[A-Za-z0-9_-]+/).length
        attributes = working.scan(/\[[^\]]+\]/).length
        classes = working.scan(/\.[\w-]+/).length
        pseudos = working.scan(/:(?!not\b)[\w-]+/).length
        stripped = working.gsub(/\[[^\]]+\]/, " ").gsub(/\.[\w-]+/, " ").gsub(/::?[\w-]+/, " ")
        elements = stripped.scan(/[a-zA-Z][\w-]*/).length
        [ids, attributes + classes + pseudos, elements]
      end
    end
  end
end
