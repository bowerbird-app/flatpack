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
        assert_selector "button[aria-label='Clear search']:not(.hidden)"
      end

      def test_renders_search_icon
        render_inline(Component.new)

        assert_selector "svg[data-flat-pack--icon-name-value='magnifying-glass']"
        assert_selector "svg.block.shrink-0"
        assert_includes CGI.unescapeHTML(rendered_content), "-translate-y-0.5"
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

        assert_selector "div[data-controller='flat-pack--search-input flat-pack--search']"
        assert_selector "input[data-flat-pack--search-target='input'][data-flat-pack--search-input-target='input']"
        assert_selector "div[data-flat-pack--search-target='dropdown'].hidden"
        assert_selector "div[data-flat-pack--search-target='noResults']", text: "Nothing found"
        assert_selector "button.hidden[data-flat-pack--search-input-target='clearButton'][aria-label='Clear search']"
      end

      def test_renders_local_items_configuration
        render_inline(Component.new(
          items: [
            {title: "Accordion", description: "Grouped panels", url: "/demo/accordion"}
          ],
          no_results_text: "Nothing found"
        ))

        assert_selector "div[data-controller='flat-pack--search-input flat-pack--search']"
        assert_selector "div[data-flat-pack--search-items-value]"
        assert_includes rendered_content, "Accordion"
        assert_includes rendered_content, "/demo/accordion"
        assert_selector "div[data-flat-pack--search-target='dropdown'].hidden"
        assert_selector "div[data-flat-pack--search-target='noResults']", text: "Nothing found"
      end

      def test_raises_error_with_unsafe_search_url
        assert_raises(ArgumentError) do
          Component.new(search_url: "javascript:alert('xss')")
        end
      end

      def test_default_size_is_md
        render_inline(Component.new)

        html = page.native.to_html
        assert_includes html, "py-[var(--search-padding-y-md)]"
        assert_includes html, "pl-[var(--search-padding-inline-md)]"
        assert_includes html, "pr-[var(--search-padding-inline-md)]"
        assert_includes html, "text-sm"
        assert_selector "span.left-3"
        assert_selector "button.right-3"
        assert_selector "svg.w-4.h-4"
      end

      def test_renders_small_size
        render_inline(Component.new(size: :sm))

        html = page.native.to_html
        assert_includes html, "py-[var(--search-padding-y-sm)]"
        assert_includes html, "pl-[var(--search-padding-inline-sm)]"
        assert_includes html, "pr-[var(--search-padding-inline-sm)]"
        assert_includes html, "text-xs"
        assert_selector "span.left-2"
        assert_selector "button.right-2"
        assert_selector "svg.w-4.h-4"
      end

      def test_renders_large_size
        render_inline(Component.new(size: :lg))

        html = page.native.to_html
        assert_includes html, "py-[var(--search-padding-y-lg)]"
        assert_includes html, "pl-[var(--search-padding-inline-lg)]"
        assert_includes html, "pr-[var(--search-padding-inline-lg)]"
        assert_includes html, "text-base"
        assert_selector "span.left-4"
        assert_selector "button.right-4"
        assert_selector "svg.w-5.h-5"
      end

      def test_raises_error_for_invalid_size
        assert_raises(ArgumentError) do
          Component.new(size: :xl)
        end
      end

      def test_search_result_rows_use_roomy_padding
        controller = FlatPack::Engine.root.join("app/javascript/flat_pack/controllers/search_controller.js").read

        assert_includes controller, 'link.className = "block px-4 py-4 '
        refute_includes controller, 'link.className = "block px-3 py-2 '
      end
    end
  end
end
