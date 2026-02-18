# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Search
    class ComponentTest < ViewComponent::TestCase
      def test_renders_search_input
        render_inline(Component.new)

        assert_selector "input[type='text'][name='q'][placeholder='Search...']"
      end

      def test_renders_with_custom_name_placeholder_and_value
        render_inline(Component.new(
          name: "query",
          placeholder: "Search components...",
          value: "flatpack"
        ))

        assert_selector "input[type='text'][name='query'][placeholder='Search components...'][value='flatpack']"
      end

      def test_renders_search_icon
        render_inline(Component.new)

        assert_includes page.native.to_html, "#icon-search"
      end

      def test_merges_custom_classes
        render_inline(Component.new(class: "custom-search-wrapper"))

        assert_selector "div.custom-search-wrapper"
      end

      def test_renders_live_search_configuration
        render_inline(Component.new(
          search_url: "/demo/search_results",
          no_results_text: "Nothing found"
        ))

        assert_selector "div[data-controller='flat-pack--search']"
        assert_selector "input[data-flat-pack--search-target='input']"
        assert_selector "div[data-flat-pack--search-target='dropdown'].hidden"
        assert_selector "div[data-flat-pack--search-target='noResults']", text: "Nothing found"
      end

      def test_raises_error_with_unsafe_search_url
        assert_raises(ArgumentError) do
          Component.new(search_url: "javascript:alert('xss')")
        end
      end
    end
  end
end
