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

        assert_selector "input[role='combobox'][aria-expanded='false'][spellcheck='false']"
        assert_selector "label", text: "City"
        assert_selector "[role='listbox']"
        assert_selector "[role='option']", text: "Melbourne"
        assert_selector "input[type='hidden'][name='city'][value='mel']", visible: :all
      end

      def test_omitted_name_renders_no_hidden_field
        render_inline(Component.new(label: "City", options: ["Melbourne"]))

        assert_selector "label", text: "City"
        assert_selector "input[role='combobox']"
        refute_selector "input[type='hidden']", visible: :all
        input_id = page.find("input[role='combobox']")["id"]
        assert_match(/\Afp-combobox-input-[0-9a-f]+\z/, input_id)
        assert_selector "label[for='#{input_id}']"
      end

      def test_same_name_on_two_comboboxes_uses_unique_ids
        context = vc_test_controller.view_context
        first = Component.new(name: "city", label: "First", options: ["Melbourne"]).render_in(context)
        second = Component.new(name: "city", label: "Second", options: ["Sydney"]).render_in(context)
        document = Nokogiri::HTML.fragment(first + second)
        ids = document.css("input[role='combobox']").map { |node| node["id"] }

        assert_equal 2, ids.uniq.length
        assert_equal ids, document.css("label").map { |node| node["for"] }
        assert_equal 2, document.css("input[type='hidden'][name='city']").length
        refute_includes ids, "city-combobox"
      end

      def test_id_sets_the_input_and_label
        render_inline(Component.new(name: "city", id: "city-field", label: "City", options: ["Melbourne"]))

        assert_selector "input#city-field[role='combobox']"
        assert_selector "label[for='city-field']"
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
          search_mode: :remote,
          search_endpoint: "/demo/forms/combobox/options",
          search_param: "query",
          min_search_length: 3,
          debounce: 250
        ))

        assert_selector "div[data-flat-pack--combobox-search-mode-value='remote']"
        assert_selector "div[data-flat-pack--combobox-search-endpoint-value='/demo/forms/combobox/options']"
        assert_selector "div[data-flat-pack--combobox-search-param-value='query']"
        assert_selector "div[data-flat-pack--combobox-min-search-length-value='3']"
        assert_selector "div[data-flat-pack--combobox-debounce-value='250']"
        assert_selector "input[spellcheck='false']"
        assert_selector "[data-flat-pack--combobox-target='hint'][role='status'][aria-live='polite']", text: "Type at least 3 characters to search", visible: :all
        assert_selector "[data-flat-pack--combobox-target='loading'][role='status'][aria-live='polite']", text: "Searching...", visible: :all
        refute_selector "[role='option']"
      end

      def test_remote_allows_empty_options
        render_inline(Component.new(
          name: "place_id",
          search_mode: :remote,
          search_endpoint: "/demo/forms/combobox/options"
        ))

        assert_selector "div[data-flat-pack--combobox-search-mode-value='remote']"
        refute_selector "[role='option']"
      end

      def test_raises_error_for_invalid_search_mode
        error = assert_raises(ArgumentError) do
          Component.new(name: "place_id", options: ["A"], search_mode: :invalid)
        end

        assert_match(/Invalid search_mode/, error.message)
      end

      def test_remote_requires_search_endpoint
        error = assert_raises(ArgumentError) do
          Component.new(name: "place_id", search_mode: :remote)
        end

        assert_equal "search_endpoint is required when search_mode is :remote", error.message
      end

      def test_renders_option_data_and_search_params
        render_inline(Component.new(
          name: "place",
          search_mode: :remote,
          search_endpoint: "/demo/forms/combobox/options",
          search_params: {region: "au", limit: 5},
          options: [{value: "fed", label: "Federation Square", data: {city: "melbourne", featured: true}}]
        ))

        raw = page.find("[data-flat-pack--combobox-search-params-value]")["data-flat-pack--combobox-search-params-value"]
        assert_equal({"region" => "au", "limit" => 5}, JSON.parse(raw))
        data = JSON.parse(page.find("[role='option']")["data-option-data"])
        assert_equal({"city" => "melbourne", "featured" => true}, data)
      end

      def test_renders_empty_action_error_text_and_leading_icon
        render_inline(Component.new(
          name: "place",
          label: "Place",
          icon: "map-pin",
          empty_action: {label: "Add a place", value: "add-place"},
          search_mode: :remote,
          search_endpoint: "/demo/forms/combobox/options"
        ))

        assert_selector "svg[data-flat-pack--icon-name-value='map-pin']"
        assert_selector "input.pl-1[role='combobox']"
        assert_selector "svg[data-flat-pack--icon-name-value='chevron-down']"
        assert_selector "[data-flat-pack--combobox-error-text-value='Search failed']"
        assert_selector "[data-flat-pack--combobox-target='empty'][role='status'][aria-live='polite']", text: "No matches", visible: :all
        assert_selector "[role='option'][data-empty-action='true']", text: "Add a place", visible: :all
      end

      def test_rejects_non_scalar_search_params_and_option_data
        search_error = assert_raises(ArgumentError) do
          Component.new(name: "place", options: ["A"], search_params: {region: {code: "au"}})
        end
        data_error = assert_raises(ArgumentError) do
          Component.new(name: "place", options: [{value: "a", label: "A", data: {city: {name: "melbourne"}}}])
        end
        action_error = assert_raises(ArgumentError) do
          Component.new(name: "place", options: ["A"], empty_action: {label: "Add"})
        end

        assert_match(/search_params values must be strings, numbers, or booleans/, search_error.message)
        assert_match(/data values must be strings, numbers, or booleans/, data_error.message)
        assert_equal "empty_action requires label and value", action_error.message
      end

      def test_raises_error_for_unsafe_search_endpoint
        error = assert_raises(ArgumentError) do
          Component.new(
            name: "place_id",
            search_mode: :remote,
            search_endpoint: "javascript:alert(1)"
          )
        end

        assert_match(/Unsafe search_endpoint/, error.message)
      end
    end
  end
end
