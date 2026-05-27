# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Collapse
    class ComponentTest < ViewComponent::TestCase
      def test_renders_collapse_with_title
        render_inline(Component.new(id: "test", title: "Click to expand"))

        assert_selector "button", text: "Click to expand"
      end

      def test_renders_trigger_button
        render_inline(Component.new(id: "test", title: "Section"))

        assert_selector "button[type='button']"
        assert_selector "button[aria-expanded]"
        assert_selector "button.cursor-pointer"
      end

      def test_renders_content_area
        render_inline(Component.new(id: "test", title: "Section")) { "Content here" }

        assert_text "Content here"
      end

      def test_renders_with_open_state
        render_inline(Component.new(id: "test", title: "Section", open: true))

        assert_selector "button[aria-expanded='true']"
        refute_selector "[hidden]"
      end

      def test_renders_with_closed_state
        render_inline(Component.new(id: "test", title: "Section", open: false))

        assert_selector "button[aria-expanded='false']"
      end

      def test_includes_stimulus_controller
        render_inline(Component.new(id: "test", title: "Section"))

        assert_selector "[data-controller='flat-pack--collapse']"
      end

      def test_includes_stimulus_targets
        render_inline(Component.new(id: "test", title: "Section"))

        assert_selector "[data-flat-pack--collapse-target='trigger']"
        assert_selector "[data-flat-pack--collapse-target='content']", visible: false
        assert_selector "[data-flat-pack--collapse-target='icon']"
      end

      def test_includes_toggle_action
        render_inline(Component.new(id: "test", title: "Section"))

        assert_selector "[data-action='flat-pack--collapse#toggle']"
      end

      def test_renders_chevron_icon
        render_inline(Component.new(id: "test", title: "Section"))

        assert_selector "svg"
      end

      def test_raises_error_without_id
        assert_raises(ArgumentError) do
          Component.new(title: "Section")
        end
      end

      def test_raises_error_without_title
        assert_raises(ArgumentError) do
          Component.new(id: "test")
        end
      end

      def test_content_has_correct_id
        render_inline(Component.new(id: "my-section", title: "Section"))

        assert_selector "#my-section-content", visible: false
        assert_selector "[aria-controls='my-section-content']"
      end

      def test_merges_custom_classes
        render_inline(Component.new(id: "test", title: "Section", class: "custom-class"))

        assert_selector ".custom-class"
      end

      def test_border_enabled_by_default
        render_inline(Component.new(id: "test", title: "Section"))

        assert_selector "[data-controller='flat-pack--collapse'].border"
        refute_selector "button[class*='px-0']"
        refute_selector "#test-content > div[class*='px-0']", visible: false
        assert_selector "button[class*='hover:bg-[var(--collapse-trigger-hover-background-color)]']"
      end

      def test_renders_borderless_without_horizontal_padding
        render_inline(Component.new(id: "test", title: "Section", border: false)) { "Content here" }

        refute_selector "[data-controller='flat-pack--collapse'].border"
        assert_selector "button[class*='px-0']"
        assert_selector "#test-content > div[class*='px-0']", visible: false
        refute_selector "button[class*='hover:bg-[var(--collapse-trigger-hover-background-color)]']"
      end
    end
  end
end
