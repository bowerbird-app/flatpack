# frozen_string_literal: true

require "test_helper"

module FlatPack
  module PageLayout
    class ComponentTest < ViewComponent::TestCase
      def test_renders_a_top_aligned_column_with_landmarks
        render_inline(Component.new(id: "notes")) do |layout|
          layout.top_nav { "Field notes" }
          layout.footer { "End" }
          "Story"
        end

        assert_selector "#notes.fp-page-layout[data-fp-page-layout-width='default'][data-fp-page-layout-align='top']"
        assert_selector "header", text: "Field notes"
        assert_selector "main.fp-page-layout-main.fp-layout-content .fp-layout-column", text: "Story"
        assert_selector "footer.fp-page-layout-footer", text: "End"
        assert_selector ".fp-layout-top-nav[data-flat-pack-content-scroll='below'][data-controller='flat-pack--top-nav']", text: "Field notes"
        refute_selector "[data-flat-pack-top-nav-floating]"
        refute_selector ".fp-layout-scroll"
        refute_selector ".fp-backdrop"
        refute_selector "[data-controller='flat-pack--sidebar-layout']"
        refute_includes page.native.to_html, "<script"
        refute_includes page.native.to_html, "localStorage"
        refute_includes page.native.to_html, "style="
      end

      def test_omitted_slots_leave_main_only
        render_inline(Component.new) { "Story" }

        assert_selector "main", text: "Story"
        refute_selector "header"
        refute_selector "footer"
        refute_selector ".fp-backdrop"
        refute_selector ".fp-layout-page-surface"
      end

      def test_width_sets_the_named_measure
        %i[narrow default wide full].each do |width|
          render_inline(Component.new(width: width)) { "Story" }

          assert_selector "[data-fp-page-layout-width='#{width}']"
        end
      end

      def test_width_accepts_the_string_form
        render_inline(Component.new(width: "narrow")) { "Story" }

        assert_selector "[data-fp-page-layout-width='narrow']"
      end

      def test_width_rejects_unknown_values
        [":nope", :fixed, "40rem", "w-full", "max-w-xl"].each do |width|
          error = assert_raises(ArgumentError) { Component.new(width: width) }
          assert_equal "width must be :narrow, :default, :wide, or :full", error.message
        end
      end

      def test_center_aligns_main_in_the_viewport
        render_inline(Component.new(align: :center)) { "Welcome" }

        assert_selector "[data-fp-page-layout-align='center'] main", text: "Welcome"
      end

      def test_align_accepts_the_string_form
        render_inline(Component.new(align: "center")) { "Welcome" }

        assert_selector "[data-fp-page-layout-align='center']"
      end

      def test_align_rejects_unknown_values
        error = assert_raises(ArgumentError) { Component.new(align: :left) }

        assert_equal "align must be :top or :center", error.message
      end

      def test_content_scroll_behind_overlays_the_page
        render_inline(Component.new(content_scroll: :behind)) do |layout|
          layout.top_nav { "Field notes" }
          "Story"
        end

        assert_selector ".fp-layout-top-nav[data-flat-pack-content-scroll='behind'] header", text: "Field notes"
        assert_selector "[data-flat-pack-layout-scroll='page'] .fp-layout-page"
        assert_selector "main.fp-layout-scroll", text: "Story"
        assert_selector ".fp-layout-page-surface[aria-hidden='true']"
        assert_selector "header", count: 1
      end

      def test_default_bar_sits_above_the_page
        render_inline(Component.new) do |layout|
          layout.top_nav { "Field notes" }
          "Story"
        end

        assert_selector "[data-flat-pack-content-scroll='below']", text: "Field notes"
        refute_selector ".fp-layout-scroll"
        refute_selector "[data-flat-pack-layout-scroll]"
        refute_selector ".fp-layout-page-surface"
      end

      def test_top_nav_keeps_one_header_landmark
        nav = FlatPack::TopNav::Component.new
        nav.left { "Field notes" }

        render_inline(Component.new(content_scroll: :behind)) do |layout|
          layout.top_nav { nav.render_in(vc_test_controller.view_context).to_s.html_safe }
          "Story"
        end

        assert_selector ".fp-layout-top-nav > header.fp-top-nav", count: 1
        assert_selector "header", count: 1
      end

      def test_content_scroll_behind_without_a_slot_stays_flush
        render_inline(Component.new(content_scroll: :behind)) { "Story" }

        refute_selector "[data-flat-pack-content-scroll]"
        refute_selector ".fp-layout-scroll"
        refute_selector ".fp-layout-page-surface"
      end

      def test_floating_top_nav_is_an_unknown_keyword
        error = assert_raises(ArgumentError) { Component.new(floating_top_nav: "yes") }

        assert_match(/unknown keyword: :?floating_top_nav/, error.message)
      end

      def test_content_scroll_rejects_unknown_values
        error = assert_raises(ArgumentError) { Component.new(content_scroll: :page) }

        assert_equal "content_scroll must be :behind or :below", error.message
      end

      def test_background_renders_backdrop_behind_the_page
        render_inline(Component.new(content_scroll: :behind)) do |layout|
          layout.background { %(<img src="/images/hero-packaging.jpg" alt="">).html_safe }
          layout.top_nav { "Field notes" }
          "Story"
        end

        assert_selector "[data-flat-pack-layout-background='true'].fp-layout-main"
        assert_selector ".fp-backdrop[aria-hidden='true']"
        assert_selector ".fp-backdrop-media img[alt=''][src='/images/hero-packaging.jpg']"
        assert_selector ".fp-backdrop-tint"
        refute_selector ".fp-layout-page-surface"

        html = page.native.to_html
        assert_operator html.index("fp-backdrop"), :<, html.index("Story")
      end

      def test_window_scroll_does_not_use_the_pane_bar
        render_inline(Component.new) { "Story" }

        refute_includes page.native.to_html, "fp-pane-scroll"
      end
    end
  end
end
