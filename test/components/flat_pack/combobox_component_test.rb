# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Combobox
    class ComponentTest < ViewComponent::TestCase
      def test_renders_combobox_and_listbox
        render_inline(Component.new(
          name: "city",
          label: "City",
          value: "mel",
          options: [{value: "mel", label: "Melbourne"}, {value: "syd", label: "Sydney"}]
        ))

        assert_selector "input[role='combobox'][aria-expanded='false']"
        assert_selector "label", text: "City"
        assert_selector "[role='listbox']"
        assert_selector "[role='option']", text: "Melbourne"
        assert_selector "input[type='hidden'][name='city'][value='mel']", visible: :all
      end

      def test_blank_name_raises
        error = assert_raises(ArgumentError) { Component.new(name: "", options: ["A"]) }

        assert_equal "name is required", error.message
      end

      def test_blank_options_raises
        error = assert_raises(ArgumentError) { Component.new(name: "city", options: []) }

        assert_equal "options is required", error.message
      end

      def test_omitted_options_raises_without_async
        error = assert_raises(ArgumentError) { Component.new(name: "city") }

        assert_equal "options is required", error.message
      end

      def test_renders_optional_subtitle
        render_inline(Component.new(
          name: "place",
          options: [{value: "fed", label: "Federation Square", subtitle: "Melbourne VIC"}]
        ))

        assert_selector "[role='option']", text: /Federation Square/
        assert_selector "[role='option']", text: /Melbourne VIC/
        assert_selector "[data-subtitle='Melbourne VIC']"
      end

      def test_remote_search_sets_controller_values
        render_inline(Component.new(
          name: "place_id",
          search_endpoint: "/demo/forms/combobox/options",
          search_param: "query",
          min_search_length: 3,
          debounce: 250
        ))

        assert_selector "div[data-flat-pack--combobox-search-endpoint-value='/demo/forms/combobox/options']"
        assert_selector "div[data-flat-pack--combobox-search-param-value='query']"
        assert_selector "div[data-flat-pack--combobox-min-search-length-value='3']"
        assert_selector "div[data-flat-pack--combobox-debounce-value='250']"
        assert_selector "[data-flat-pack--combobox-target='hint']", text: "Type at least 3 characters to search", visible: :all
        assert_selector "[data-flat-pack--combobox-target='loading']", text: "Searching...", visible: :all
        refute_selector "[role='option']"
      end

      def test_loader_allows_empty_options
        render_inline(Component.new(name: "place_id", loader: true))

        assert_selector "div[data-flat-pack--combobox-loader-value='true']"
        refute_selector "[role='option']"
      end

      def test_raises_error_for_unsafe_search_endpoint
        error = assert_raises(ArgumentError) do
          Component.new(
            name: "place_id",
            search_endpoint: "javascript:alert(1)"
          )
        end

        assert_match(/Unsafe search_endpoint/, error.message)
      end
    end
  end
end
