# frozen_string_literal: true

require "test_helper"

module FlatPack
  module SectionTitle
    class ComponentTest < ViewComponent::TestCase
      def test_renders_section_title_with_title
        render_inline(Component.new(title: "Overview"))

        assert_selector "div.fp-section-title"
        assert_selector "div.my-8"
        assert_selector "h2", text: "Overview"
        assert_selector "h2.text-2xl", text: "Overview"
      end

      def test_renders_section_title_with_subtitle
        render_inline(Component.new(
          title: "Overview",
          subtitle: "Latest metrics and progress"
        ))

        assert_selector "h2", text: "Overview"
        assert_selector "p", text: "Latest metrics and progress"
        assert_selector "p.text-base", text: "Latest metrics and progress"
      end

      def test_renders_anchor_link_when_enabled
        render_inline(Component.new(title: "Overview", anchor_link: true))

        assert_selector "div#overview[data-controller='flat-pack--section-title-anchor']"
        assert_selector "div[data-controller='flat-pack--tooltip']"
        assert_selector "a[href='#overview'][data-flat-pack--section-title-anchor-target='link']"
        assert_selector "div[role='tooltip']", text: "Copy link"
        assert_includes page.native.to_html, "mouseenter-&gt;flat-pack--section-title-anchor#show"
        assert_includes page.native.to_html, "style=\"opacity: 0\""
      end

      def test_uses_custom_anchor_id
        render_inline(Component.new(title: "Overview", anchor_link: true, anchor_id: "metrics"))

        assert_selector "div#metrics"
        assert_selector "a[href='#metrics']"
      end

      def test_does_not_render_anchor_link_when_disabled
        render_inline(Component.new(title: "Overview", anchor_link: false))

        refute_selector "div[data-controller='flat-pack--section-title-anchor']"
      end

      def test_raises_error_without_title
        assert_raises(ArgumentError) do
          Component.new
        end
      end

      def test_accepts_custom_classes
        render_inline(Component.new(title: "Overview", class: "custom-class"))

        assert_selector "div.custom-class"
      end

      def test_explicit_defaults_match_today
        render_inline(Component.new(title: "Overview", size: :lg, spacing: :lg, level: :h2))

        html = page.native.to_html
        assert_selector "div.fp-section-title"
        assert_selector "div.my-8"
        assert_selector "h2.text-2xl", text: "Overview"
        refute_includes html, "text-lg"
        refute_includes html, "my-6"
        refute_includes html, "my-4"
      end

      def test_default_keeps_wrapper_and_heading_class_names
        render_inline(Component.new(title: "Overview"))

        html = page.native.to_html
        assert_includes html, "fp-section-title"
        assert_includes html, "min-w-0"
        assert_includes html, "my-8"
        assert_includes html, "text-2xl"
        assert_includes html, "font-semibold"
        assert_includes html, "text-[var(--surface-content-color)]"
        assert_includes html, "leading-tight"
        refute_includes html, "fp-section-title-anchor"
      end

      def test_renders_medium_size
        render_inline(Component.new(
          title: "Members",
          subtitle: "Who can access this workspace",
          size: :md
        ))

        assert_selector "h2.text-lg", text: "Members"
        refute_selector "h2.text-2xl"
        assert_selector "p.text-sm", text: "Who can access this workspace"
        refute_selector "p.text-base"
        assert_selector "div.my-8"
      end

      def test_renders_small_size
        render_inline(Component.new(
          title: "Members",
          subtitle: "Who can access this workspace",
          size: :sm
        ))

        assert_selector "h2.text-base", text: "Members"
        refute_selector "h2.text-2xl"
        assert_selector "p.text-xs", text: "Who can access this workspace"
        refute_selector "p.text-base"
      end

      def test_small_size_scales_anchor_icon
        render_inline(Component.new(title: "Members", size: :sm, anchor_link: true))

        html = page.native.to_html
        assert_includes html, "w-3"
        assert_includes html, "h-3"
      end

      def test_large_anchor_icon_stays_small_kit_size
        render_inline(Component.new(title: "Members", anchor_link: true))

        html = page.native.to_html
        assert_includes html, "w-4"
        assert_includes html, "h-4"
        refute_includes html, "w-3"
      end

      def test_renders_medium_spacing
        render_inline(Component.new(title: "Members", spacing: :md))

        assert_selector "div.fp-section-title.my-6"
        refute_selector "div.my-8"
      end

      def test_renders_small_spacing
        render_inline(Component.new(title: "Members", spacing: :sm))

        assert_selector "div.fp-section-title.my-4"
        refute_selector "div.my-8"
      end

      def test_renders_none_spacing
        render_inline(Component.new(title: "Members", spacing: :none))

        assert_selector "div.fp-section-title"
        refute_selector "div.my-8"
        refute_selector "div.my-6"
        refute_selector "div.my-4"
        refute_match(/\bmy-/, page.find("div.fp-section-title")[:class].to_s)
      end

      def test_none_spacing_lets_caller_margin_win
        render_inline(Component.new(title: "Members", spacing: :none, class: "mb-2"))

        assert_selector "div.fp-section-title.mb-2"
        refute_selector "div.my-8"
      end

      def test_size_and_spacing_are_independent
        render_inline(Component.new(title: "Members", size: :sm, spacing: :lg))

        assert_selector "h2.text-base", text: "Members"
        assert_selector "div.my-8"
      end

      def test_renders_each_heading_level
        Component::LEVELS.each do |level|
          render_inline(Component.new(title: "Members", level: level))

          assert_selector level.to_s, text: "Members"
        end
      end

      def test_level_does_not_change_visual_size
        render_inline(Component.new(title: "Members", level: :h3, size: :lg))

        assert_selector "h3.text-2xl", text: "Members"
        refute_selector "h2"
      end

      def test_accepts_string_size_spacing_and_level
        render_inline(Component.new(title: "Members", size: "md", spacing: "sm", level: "h4"))

        assert_selector "h4.text-lg", text: "Members"
        assert_selector "div.my-4"
      end

      def test_raises_error_for_invalid_size
        error = assert_raises(ArgumentError) do
          Component.new(title: "Members", size: :xl)
        end

        assert_includes error.message, "Invalid size"
      end

      def test_raises_error_for_invalid_spacing
        error = assert_raises(ArgumentError) do
          Component.new(title: "Members", spacing: :xl)
        end

        assert_includes error.message, "Invalid spacing"
      end

      def test_raises_error_for_invalid_level
        error = assert_raises(ArgumentError) do
          Component.new(title: "Members", level: :h7)
        end

        assert_includes error.message, "Invalid level"
      end
    end
  end
end
