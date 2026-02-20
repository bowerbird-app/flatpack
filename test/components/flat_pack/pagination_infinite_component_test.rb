# frozen_string_literal: true

require "test_helper"

module FlatPack
  module PaginationInfinite
    class ComponentTest < ViewComponent::TestCase
      def test_renders_load_more_button
        render_inline(Component.new(url: "/items?page=2"))

        assert_selector "a", text: "Load more"
      end

      def test_renders_with_stimulus_controller
        render_inline(Component.new(url: "/items?page=2"))

        assert_selector "[data-controller='flat-pack--pagination-infinite']"
      end

      def test_includes_url_value
        render_inline(Component.new(url: "/items?page=2"))

        assert_selector "[data-flat-pack--pagination-infinite-url-value='/items?page=2']"
      end

      def test_includes_page_value
        render_inline(Component.new(url: "/items?page=3", page: 3))

        assert_selector "[data-flat-pack--pagination-infinite-page-value='3']"
      end

      def test_renders_loading_indicator
        render_inline(Component.new(url: "/items?page=2"))

        assert_selector "[data-flat-pack--pagination-infinite-target='loading']"
        assert_selector "svg.animate-spin"
      end

      def test_loading_indicator_hidden_by_default
        render_inline(Component.new(url: "/items?page=2"))

        assert_selector "[data-flat-pack--pagination-infinite-target='loading'][hidden]"
      end

      def test_renders_custom_loading_text
        render_inline(Component.new(url: "/items?page=2", loading_text: "Fetching more..."))

        assert_text "Fetching more..."
      end

      def test_does_not_render_when_has_more_false
        result = render_inline(Component.new(url: "/items?page=2", has_more: false))

        assert_empty result.css("a")
      end

      def test_includes_trigger_target
        render_inline(Component.new(url: "/items?page=2"))

        assert_selector "[data-flat-pack--pagination-infinite-target='trigger']"
      end

      def test_includes_load_more_action
        render_inline(Component.new(url: "/items?page=2"))

        assert_selector "[data-action='click->flat-pack--pagination-infinite#loadMore']"
      end

      def test_raises_error_without_url
        assert_raises(ArgumentError) do
          Component.new
        end
      end

      def test_raises_error_for_invalid_page
        assert_raises(ArgumentError) do
          Component.new(url: "/items", page: 0)
        end
      end

      def test_merges_custom_classes
        render_inline(Component.new(url: "/items?page=2", class: "custom-class"))

        assert_selector ".custom-class"
      end

      def test_button_has_proper_styling
        render_inline(Component.new(url: "/items?page=2"))

        assert_includes page.native.to_html, "bg-[var(--color-primary)]"
      end
    end
  end
end
