# frozen_string_literal: true

require "test_helper"

module FlatPack
  module List
    class ComponentTest < ViewComponent::TestCase
      def test_renders_unordered_list_by_default
        render_inline(Component.new) { "content" }

        assert_selector "ul.flat-pack-list[role='list']"
        refute_selector "ol"
      end

      def test_renders_ordered_list_when_ordered
        render_inline(Component.new(ordered: true)) { "content" }

        assert_selector "ol.flat-pack-list[role='list']"
        refute_selector "ul"
      end

      def test_renders_list_items
        render_inline(Component.new) do
          "<li>Item 1</li><li>Item 2</li><li>Item 3</li>".html_safe
        end

        assert_selector "li", count: 3
        assert_text "Item 1"
        assert_text "Item 2"
        assert_text "Item 3"
      end

      def test_includes_spacing_classes
        render_inline(Component.new) { "content" }

        assert_includes page.native.to_html, "space-y-3"
      end

      def test_merges_custom_classes
        render_inline(Component.new(class: "custom-class")) { "content" }

        assert_selector ".custom-class"
      end

      def test_accepts_data_attributes
        render_inline(Component.new(data: {testid: "my-list"})) { "content" }

        assert_selector "[data-testid='my-list']"
      end

      def test_renders_dense_spacing
        render_inline(Component.new(spacing: :dense)) { "content" }
        assert_includes page.native.to_html, "space-y-1"
      end

      def test_enables_selectable_behavior_when_requested
        render_inline(Component.new(selectable: true)) { "content" }

        assert_selector "ul[data-controller='flat-pack--list-selectable']"
        assert_selector "ul[data-action='click->flat-pack--list-selectable#activate']"
      end

      def test_enables_orderable_behavior_when_requested
        render_inline(Component.new(
          orderable: true,
          orderable_url: "/demo/list/reorder",
          param_uuid_name: "moving_recording_id",
          param_target_position_name: "target_position"
        )) { "content" }

        assert_selector "ul[data-controller='flat-pack--list-orderable']"
        assert_selector "ul[data-flat-pack--list-orderable-orderable-url-value='/demo/list/reorder']"
        assert_selector "ul[data-flat-pack--list-orderable-orderable-method-value='PATCH']"
        assert_selector "ul[data-flat-pack--list-orderable-param-uuid-name-value='moving_recording_id']"
        assert_selector "ul[data-flat-pack--list-orderable-param-target-position-name-value='target_position']"
      end

      def test_combines_selectable_and_orderable_controllers
        render_inline(Component.new(
          selectable: true,
          orderable: true,
          orderable_url: "/demo/list/reorder",
          param_uuid_name: "moving_recording_id",
          param_target_position_name: "target_position"
        )) { "content" }

        assert_selector "ul[data-controller='flat-pack--list-orderable flat-pack--list-selectable']"
        assert_selector "ul[data-action='click->flat-pack--list-selectable#activate']"
      end

      def test_ordered_list_wrapping_items_renders_markers
        render_inline(Component.new(ordered: true)) { rendered_items("First", "Second") }

        assert_selector "ol.flat-pack-list > li .flat-pack-list-item-marker", count: 2
        assert_selector "ol.flat-pack-list > li .flat-pack-list-item-marker[aria-hidden='true']", count: 2
        assert_text "First"
        assert_text "Second"
      end

      def test_unordered_list_wrapping_items_keeps_marker_slots
        render_inline(Component.new) { rendered_items("First", "Second") }

        assert_selector "ul.flat-pack-list > li .flat-pack-list-item-marker", count: 2
        refute_selector "ol"
      end

      def test_marker_css_is_unlayered
        css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read
        layer_end = layered_components_end_index(css)

        assert_includes css, "counter-reset: flat-pack-list-item"
        assert_includes css, "ol.flat-pack-list"
        assert_operator css.index("ol.flat-pack-list"), :>, layer_end
      end

      def test_marker_css_targets_only_direct_item_slots
        css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read

        assert_includes css, "ol.flat-pack-list > li > .flat-pack-list-item-marker"
        assert_includes css, "ol.flat-pack-list > li > a.flat-pack-list-item-link > .flat-pack-list-item-marker"
        refute_includes css, "ol.flat-pack-list > li .flat-pack-list-item-marker {"
        refute_includes css, "ol.flat-pack-list > li .flat-pack-list-item-marker::before"
      end

      def test_nested_unordered_list_keeps_hidden_marker_slots
        nested = Component.new.with_content(rendered_items("Nested")).render_in(vc_test_controller.view_context)
        outer_item = Item.new.with_content(nested).render_in(vc_test_controller.view_context)
        render_inline(Component.new(ordered: true)) { outer_item }

        assert_selector "ol.flat-pack-list > li > span.flat-pack-list-item-marker", count: 1
        assert_selector "ol.flat-pack-list ul.flat-pack-list > li > span.flat-pack-list-item-marker", count: 1
      end

      def test_ordered_list_keeps_icons_beside_markers
        first = Item.new(icon: :sun).with_content("Heat the pan").render_in(vc_test_controller.view_context)
        second = Item.new(icon: :star).with_content("Crack two eggs").render_in(vc_test_controller.view_context)
        render_inline(Component.new(ordered: true)) { [first, second].join.html_safe }

        assert_selector "ol.flat-pack-list > li > span.flat-pack-list-item-marker", count: 2
        assert_selector "ol.flat-pack-list > li > span.flat-pack-list-item-icon", count: 2
        assert_selector "span.flat-pack-list-item-icon svg[data-flat-pack--icon-name-value='sun']"
        assert_selector "span.flat-pack-list-item-icon svg[data-flat-pack--icon-name-value='star']"
      end

      private

      def rendered_items(*labels)
        labels.map { |label|
          Item.new.with_content(label).render_in(vc_test_controller.view_context)
        }.join.html_safe
      end

      def layered_components_end_index(css)
        start = css.index("@layer components")
        raise "missing @layer components" unless start

        open_at = css.index("{", start)
        depth = 0
        css.each_char.with_index do |char, index|
          next if index < open_at

          depth += 1 if char == "{"
          depth -= 1 if char == "}"
          return index if depth.zero? && index > open_at
        end

        raise "unclosed @layer components"
      end
    end
  end
end
