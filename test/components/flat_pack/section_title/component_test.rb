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
    end
  end
end
