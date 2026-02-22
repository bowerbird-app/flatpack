# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Chip
    class ComponentTest < ViewComponent::TestCase
      def test_renders_chip_with_text
        render_inline(Component.new(text: "Ruby"))

        assert_selector "span", text: "Ruby"
      end

      def test_renders_block_content_when_no_text
        render_inline(Component.new) do
          "Block Content"
        end

        assert_selector "span", text: "Block Content"
      end

      def test_renders_default_style
        render_inline(Component.new(text: "Default"))

        assert_selector "span", text: "Default"
        assert_includes page.native.to_html, "bg-muted"
      end

      def test_renders_primary_style
        render_inline(Component.new(text: "Primary", style: :primary))

        assert_selector "span", text: "Primary"
        assert_includes page.native.to_html, "bg-primary"
      end

      def test_renders_success_style
        render_inline(Component.new(text: "Success", style: :success))

        assert_selector "span", text: "Success"
        assert_includes page.native.to_html, "bg-success"
      end

      def test_renders_warning_style
        render_inline(Component.new(text: "Warning", style: :warning))

        assert_selector "span", text: "Warning"
        assert_includes page.native.to_html, "bg-warning"
      end

      def test_renders_danger_style
        render_inline(Component.new(text: "Danger", style: :danger))

        assert_selector "span", text: "Danger"
        assert_includes page.native.to_html, "bg-red-500"
      end

      def test_renders_info_style
        render_inline(Component.new(text: "Info", style: :info))

        assert_selector "span", text: "Info"
        assert_includes page.native.to_html, "bg-blue-500"
      end

      def test_renders_small_size
        render_inline(Component.new(text: "Small", size: :sm))

        assert_selector "span", text: "Small"
        assert_includes page.native.to_html, "text-xs"
        assert_includes page.native.to_html, "px-2"
      end

      def test_renders_medium_size
        render_inline(Component.new(text: "Medium", size: :md))

        assert_selector "span", text: "Medium"
        assert_includes page.native.to_html, "text-sm"
        assert_includes page.native.to_html, "px-3"
      end

      def test_renders_large_size
        render_inline(Component.new(text: "Large", size: :lg))

        assert_selector "span", text: "Large"
        assert_includes page.native.to_html, "text-base"
        assert_includes page.native.to_html, "px-4"
      end

      def test_default_size_is_medium
        render_inline(Component.new(text: "Default"))

        assert_includes page.native.to_html, "text-sm"
      end

      def test_static_type_renders_span
        render_inline(Component.new(text: "Static", type: :static))

        assert_selector "span", text: "Static"
      end

      def test_button_type_renders_button
        render_inline(Component.new(text: "Button", type: :button))

        assert_selector "button[type='button']", text: "Button"
      end

      def test_link_type_renders_link
        render_inline(Component.new(text: "Link", type: :link, href: "/test"))

        assert_selector "a[href='/test']", text: "Link"
      end

      def test_disabled_link_renders_as_span
        render_inline(Component.new(text: "Disabled Link", type: :link, href: "/test", disabled: true))

        assert_selector "span", text: "Disabled Link"
        refute_selector "a[href='/test']"
      end

      def test_disabled_adds_classes
        render_inline(Component.new(text: "Disabled", disabled: true))

        assert_includes page.native.to_html, "opacity-50"
        assert_includes page.native.to_html, "cursor-not-allowed"
      end

      def test_disabled_button_has_disabled_attribute
        render_inline(Component.new(text: "Disabled Button", type: :button, disabled: true))

        assert_selector "button[disabled]"
      end

      def test_selected_button_has_aria_pressed_true
        render_inline(Component.new(text: "Selected", type: :button, selected: true))

        assert_selector "button[aria-pressed='true']"
      end

      def test_unselected_button_has_aria_pressed_false
        render_inline(Component.new(text: "Not Selected", type: :button, selected: false))

        assert_selector "button[aria-pressed='false']"
      end

      def test_selected_button_has_ring_classes
        render_inline(Component.new(text: "Selected", type: :button, selected: true))

        assert_includes page.native.to_html, "ring-2"
        assert_includes page.native.to_html, "ring-ring"
      end

      def test_selected_static_does_not_add_ring_classes
        render_inline(Component.new(text: "Selected Static", type: :static, selected: true))

        refute_includes page.native.to_html, "ring-2"
      end

      def test_removable_adds_controller
        render_inline(Component.new(text: "Removable", removable: true))

        assert_selector "span[data-controller='flat-pack--chip']"
        assert_selector "span[data-flat-pack--chip-target='chip']"
      end

      def test_removable_adds_remove_button
        render_inline(Component.new(text: "Tag", removable: true))

        assert_selector "button[type='button'][aria-label='Remove']"
        assert_selector "button svg"
      end

      def test_removable_with_value
        render_inline(Component.new(text: "Tag", removable: true, value: "ruby"))

        assert_selector "span[data-flat-pack--chip-value-value='ruby']"
      end

      def test_disabled_overrides_removable
        render_inline(Component.new(text: "Disabled", removable: true, disabled: true))

        refute_selector "button[aria-label='Remove']"
        refute_selector "span[data-controller='flat-pack--chip']"
      end

      def test_button_has_focus_ring
        render_inline(Component.new(text: "Button", type: :button))

        assert_includes page.native.to_html, "focus:outline-none"
        assert_includes page.native.to_html, "focus:ring-2"
      end

      def test_link_has_focus_ring
        render_inline(Component.new(text: "Link", type: :link, href: "/test"))

        assert_includes page.native.to_html, "focus:outline-none"
        assert_includes page.native.to_html, "focus:ring-2"
      end

      def test_renders_leading_slot
        render_inline(Component.new(text: "With Icon")) do |c|
          c.with_leading { "🔥" }
        end

        assert_selector "span", text: /🔥.*With Icon/
      end

      def test_renders_trailing_slot
        render_inline(Component.new(text: "With Icon")) do |c|
          c.with_trailing { "✓" }
        end

        assert_selector "span", text: /With Icon.*✓/
      end

      def test_merges_custom_classes
        render_inline(Component.new(text: "Custom", class: "custom-class"))

        assert_selector "span.custom-class", text: "Custom"
      end

      def test_accepts_data_attributes
        render_inline(Component.new(text: "Data", data: {testid: "chip"}))

        assert_selector "span[data-testid='chip']"
      end

      def test_accepts_aria_attributes
        render_inline(Component.new(text: "Aria", aria: {label: "Chip label"}))

        assert_selector "span[aria-label='Chip label']"
      end

      def test_accepts_id_attribute
        render_inline(Component.new(text: "ID", id: "my-chip"))

        assert_selector "span#my-chip"
      end

      def test_filters_dangerous_onclick_attribute
        render_inline(Component.new(text: "Chip", onclick: "alert('xss')"))

        refute_selector "span[onclick]"
      end

      def test_raises_error_for_invalid_style
        assert_raises(ArgumentError) do
          Component.new(text: "Invalid", style: :invalid)
        end
      end

      def test_raises_error_for_invalid_size
        assert_raises(ArgumentError) do
          Component.new(text: "Invalid", size: :xl)
        end
      end

      def test_raises_error_for_invalid_type
        assert_raises(ArgumentError) do
          Component.new(text: "Invalid", type: :invalid)
        end
      end
    end
  end
end
