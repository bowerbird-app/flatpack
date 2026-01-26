# frozen_string_literal: true

require "test_helper"

module FlatPack
  module SearchInput
    class ComponentTest < ViewComponent::TestCase
      def test_renders_search_input_with_name
        render_inline(Component.new(name: "query"))

        assert_selector "input[type='search'][name='query']"
      end

      def test_renders_with_value
        render_inline(Component.new(name: "query", value: "search term"))

        assert_selector "input[value='search term']"
      end

      def test_renders_with_placeholder
        render_inline(Component.new(name: "query", placeholder: "Search..."))

        assert_selector "input[placeholder='Search...']"
      end

      def test_renders_with_label
        render_inline(Component.new(name: "query", label: "Search"))

        assert_selector "label", text: "Search"
        assert_selector "input[type='search']"
      end

      def test_renders_clear_button
        render_inline(Component.new(name: "query"))

        assert_selector "button[type='button'][aria-label='Clear search']"
      end

      def test_clear_button_initially_hidden
        render_inline(Component.new(name: "query"))

        html = page.native.to_html
        # Clear button should have hidden class initially
        assert_match(/Clear search.*?hidden/m, html)
      end

      def test_has_stimulus_controller
        render_inline(Component.new(name: "query"))

        assert_selector "input[data-controller='flat-pack--search-input']"
        assert_selector "input[data-flat-pack--search-input-target='input']"
      end

      def test_clear_button_has_correct_data_attributes
        render_inline(Component.new(name: "query"))

        assert_selector "button[data-action='flat-pack--search-input#clear']"
        assert_selector "button[data-flat-pack--search-input-target='clearButton']"
      end

      def test_input_has_toggle_action
        render_inline(Component.new(name: "query"))

        assert_selector "input[data-action='input->flat-pack--search-input#toggleClearButton']"
      end

      def test_renders_x_icon
        render_inline(Component.new(name: "query"))

        html = page.native.to_html
        assert_includes html, "lucide-x"
      end

      def test_input_has_padding_for_clear_button
        render_inline(Component.new(name: "query"))

        html = page.native.to_html
        assert_includes html, "pr-10"
      end

      def test_renders_disabled_input
        render_inline(Component.new(name: "query", disabled: true))

        assert_selector "input[disabled]"
      end

      def test_renders_required_input
        render_inline(Component.new(name: "query", required: true))

        assert_selector "input[required]"
      end

      def test_renders_with_error
        render_inline(Component.new(name: "query", error: "Search term is required"))

        assert_selector "p", text: "Search term is required"
        assert_selector "input[aria-invalid='true']"
        assert_selector "input[aria-describedby]"
      end

      def test_error_styles_applied
        render_inline(Component.new(name: "query", error: "Invalid"))

        html = page.native.to_html
        assert_includes html, "border-[var(--color-destructive)]"
      end

      def test_renders_with_custom_class
        render_inline(Component.new(name: "query", class: "custom-search"))

        assert_selector "input.custom-search"
      end

      def test_has_base_flat_pack_input_class
        render_inline(Component.new(name: "query"))

        assert_selector "input.flat-pack-input"
      end

      def test_has_wrapper_class
        render_inline(Component.new(name: "query"))

        assert_selector "div.flat-pack-input-wrapper"
      end

      def test_raises_error_without_name
        assert_raises(ArgumentError) do
          Component.new(name: nil)
        end
      end

      def test_sanitizes_dangerous_attributes
        render_inline(Component.new(name: "query", onclick: "alert('xss')"))

        refute_selector "input[onclick]"
      end

      def test_renders_with_all_parameters
        render_inline(Component.new(
          name: "query",
          value: "test",
          placeholder: "Search...",
          disabled: false,
          required: false,
          label: "Search",
          class: "custom"
        ))

        assert_selector "label", text: "Search"
        assert_selector "input[type='search'][name='query']"
        assert_selector "input[value='test']"
        assert_selector "input[placeholder='Search...']"
        assert_selector "input.custom"
        assert_selector "button[type='button']"
      end
    end
  end
end
