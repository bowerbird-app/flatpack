# frozen_string_literal: true

require "test_helper"

module FlatPack
  module IconPicker
    class ComponentTest < ViewComponent::TestCase
      def test_field_chrome_shows_the_icon_name_and_submits_it
        render_inline(Component.new(
          name: "category[icon]",
          id: "category-icon",
          label: "Icon",
          help_text: "Shown beside the name.",
          icons: %w[star heart],
          value: "star"
        ))

        assert_selector "label[for='category-icon']", text: "Icon"
        assert_selector "p#category-icon_help_text", text: "Shown beside the name."
        assert_selector "input[type='hidden'][name='category[icon]'][value='star']", visible: :all
        assert_selector "button#category-icon[aria-haspopup='dialog'][aria-expanded='false'][aria-controls='category-icon_panel']", text: "Star"
        assert_selector "button#category-icon[aria-describedby='category-icon_help_text']"
        assert_selector "[data-flat-pack--icon-picker-show-name-value='true']"
        assert_selector "button.border"
        assert_includes rendered_content, 'data-icon-name="star"'
        assert_includes rendered_content, 'aria-label="Star"'
        assert_includes rendered_content, 'aria-pressed="true"'
      end

      def test_cell_chrome_is_icon_only_and_borderless
        render_inline(Component.new(name: "row[icon]", icons: %w[star heart], value: "heart", chrome: :cell))

        assert_no_selector "label"
        assert_selector "button[aria-label='Heart']"
        assert_selector "button.border-0.bg-transparent"
        assert_selector "[data-flat-pack--icon-picker-show-name-value='false']"
        assert_selector "[data-flat-pack--icon-picker-target='valueLabel'][hidden]", visible: :all
      end

      def test_show_name_can_be_forced_on_a_cell
        render_inline(Component.new(name: "row[icon]", icons: %w[star], value: "star", chrome: :cell, show_name: true))

        assert_selector "button", text: "Star"
        assert_selector "[data-flat-pack--icon-picker-show-name-value='true']"
      end

      def test_placeholder_and_clear_when_nothing_is_selected
        render_inline(Component.new(name: "icon", icons: %w[star], include_blank: true))

        assert_selector "button[data-empty='true']", text: "Choose an icon"
        assert_selector "input[type='hidden'][value='']", visible: :all
        assert_selector "[data-flat-pack--icon-picker-target='clear']", text: "None", visible: :all
        assert_selector "[data-flat-pack--icon-picker-target='search'][placeholder='Search icons']", visible: :all
        assert_includes rendered_content, "No icons found"
      end

      def test_include_blank_accepts_a_custom_label
        render_inline(Component.new(name: "icon", icons: %w[star], include_blank: "No icon"))

        assert_selector "[data-flat-pack--icon-picker-target='clear']", text: "No icon", visible: :all
      end

      def test_error_marks_the_trigger_and_the_hidden_input
        render_inline(Component.new(name: "icon", id: "broken-icon", icons: %w[star], error: "Pick an icon"))

        assert_selector "p#broken-icon_error", text: "Pick an icon"
        assert_selector "button[aria-invalid='true'][aria-describedby='broken-icon_error']"
        assert_selector "input[aria-invalid='true']", visible: :all
        assert_selector "button.border-\\[var\\(--color-error\\)\\]"
      end

      def test_unknown_icon_in_the_allow_list_raises
        error = assert_raises(ArgumentError) do
          Component.new(name: "icon", icons: %w[star not-a-real-icon])
        end

        assert_match(/not-a-real-icon/, error.message)
      end

      def test_value_outside_the_allow_list_is_blank
        render_inline(Component.new(name: "icon", icons: %w[star], value: "heart"))

        assert_selector "input[type='hidden'][value='']", visible: :all
        assert_selector "button[data-empty='true']"
      end

      def test_alias_in_the_allow_list_submits_the_heroicon_name
        render_inline(Component.new(name: "icon", icons: %w[search], value: "search"))

        assert_selector "input[type='hidden'][value='magnifying-glass']", visible: :all
        assert_includes rendered_content, 'data-icon-name="magnifying-glass"'
        assert_includes rendered_content, 'data-icon-search="magnifyingglass"'
      end

      def test_default_catalog_includes_shipped_heroicons_without_repeating_them_on_the_trigger
        render_inline(Component.new(name: "icon", id: "all-icons", value: "star"))

        template = rendered_content[/<template\b.*?<\/template>/m]
        refute_nil template
        assert_includes template, 'data-icon-name="star"'
        assert_includes template, 'data-icon-name="arrow-right"'
        outside = rendered_content.sub(template, "")
        assert_equal 2, outside.scan("<svg").size
      end

      def test_two_pickers_share_one_catalog_template
        html = render_pickers(<<~ERB)
          <%= render FlatPack::IconPicker::Component.new(name: "a", icons: %w[star heart]) %>
          <%= render FlatPack::IconPicker::Component.new(name: "b", icons: %w[star heart]) %>
        ERB

        assert_equal 1, html.scan("<template").size
        assert_equal 2, html.scan('data-flat-pack--icon-picker-catalog-id-value="').size
      end

      def test_a_different_allow_list_gets_its_own_template
        html = render_pickers(<<~ERB)
          <%= render FlatPack::IconPicker::Component.new(name: "a", icons: %w[star heart]) %>
          <%= render FlatPack::IconPicker::Component.new(name: "b", icons: %w[bolt]) %>
        ERB

        assert_equal 2, html.scan("<template").size
      end

      def render_pickers(markup)
        vc_test_view_context.render(inline: markup)
      end

      def test_rejects_bad_chrome_variant_and_blank_name
        assert_raises(ArgumentError) { Component.new(name: "icon", icons: %w[star], chrome: :grid) }
        assert_raises(ArgumentError) { Component.new(name: "icon", icons: %w[star], variant: :sketch) }
        assert_raises(ArgumentError) { Component.new(name: "", icons: %w[star]) }
        assert_raises(ArgumentError) { Component.new(name: "icon", icons: []) }
      end

      def test_closed_panel_is_a_dialog
        render_inline(Component.new(name: "icon", id: "dialog-icon", icons: %w[star]))

        assert_selector "#dialog-icon_panel[role='dialog'][aria-hidden='true']", visible: :all
        assert_selector "#dialog-icon_panel[aria-label='Choose an icon']", visible: :all
      end
    end
  end
end
