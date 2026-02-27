# frozen_string_literal: true

require "test_helper"

module FlatPack
  module PaginationInfinite
    class ComponentTest < ViewComponent::TestCase
      def test_renders_trigger_sentinel
        render_inline(Component.new(url: "/items?page=2"))

        assert_selector "[data-flat-pack--pagination-infinite-target='trigger']"
        refute_selector "a"
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

        assert_selector "[data-flat-pack--pagination-infinite-target='loading']", visible: false
        assert_selector "[role='status']", visible: false
      end

      def test_loading_indicator_hidden_by_default
        render_inline(Component.new(url: "/items?page=2"))

        assert_selector "[data-flat-pack--pagination-infinite-target='loading'][hidden]", visible: false
      end

      def test_renders_custom_loading_text
        render_inline(Component.new(url: "/items?page=2", loading_text: "Fetching more..."))

        assert_selector "[data-flat-pack--pagination-infinite-target='loading']", visible: false
      end

      def test_does_not_render_when_has_more_false
        result = render_inline(Component.new(url: "/items?page=2", has_more: false))

        assert_empty result.css("[data-controller='flat-pack--pagination-infinite']")
      end

      def test_includes_trigger_target
        render_inline(Component.new(url: "/items?page=2"))

        assert_selector "[data-flat-pack--pagination-infinite-target='trigger']"
      end

      def test_trigger_is_non_interactive
        render_inline(Component.new(url: "/items?page=2"))

        assert_selector "[data-flat-pack--pagination-infinite-target='trigger'][aria-hidden='true']"
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

      def test_container_has_proper_styling
        render_inline(Component.new(url: "/items?page=2"))

        assert_includes page.native.to_html, "flex flex-col items-center gap-4 py-8"
      end

      def test_supports_prepend_insert_mode_configuration
        render_inline(Component.new(
          url: "/messages/history",
          insert_mode: :prepend,
          cursor_selector: "[data-pagination-cursor]",
          cursor_param: "before_id",
          batch_size: 15,
          observe_root_selector: "[data-flat-pack--chat-scroll-target='messages']",
          preserve_scroll_position: true,
          loading_variant: :inline
        ))

        assert_selector "[data-flat-pack--pagination-infinite-insert-mode-value='prepend']"
        assert_selector "[data-flat-pack--pagination-infinite-cursor-selector-value='[data-pagination-cursor]']"
        assert_selector "[data-flat-pack--pagination-infinite-cursor-param-value='before_id']"
        assert_selector "[data-flat-pack--pagination-infinite-batch-size-value='15']"
        assert_selector "[data-flat-pack--pagination-infinite-preserve-scroll-position-value='true']"
      end

      def test_raises_error_for_invalid_insert_mode
        assert_raises(ArgumentError) do
          Component.new(url: "/items", insert_mode: :middle)
        end
      end

      def test_raises_error_for_invalid_batch_size
        assert_raises(ArgumentError) do
          Component.new(url: "/items", batch_size: 0)
        end
      end
    end
  end
end
