# frozen_string_literal: true

require "test_helper"

module FlatPack
  module PageNav
    class ComponentTest < ViewComponent::TestCase
      def test_renders_wrapper_with_default_aria_label
        render_inline(Component.new)

        assert_selector "nav[aria-label='Page navigation']"
      end

      def test_renders_history_back_button_with_controller_action
        render_inline(Component.new)

        assert_selector "nav[data-controller='flat-pack--page-nav']"
        assert_selector "button[data-action='click->flat-pack--page-nav#back']"
        assert_selector "button[aria-label='Go back']"
        assert_selector "button svg[data-flat-pack--icon-name-value='chevron-left']"
      end

      def test_hides_anchor_and_right_actions_when_not_provided
        render_inline(Component.new)

        assert_selector "button", count: 1
        refute_selector "a[aria-label='Close']"
        refute_selector "a[href='/secondary']"
        refute_selector "a[aria-label='Add']"
      end

      def test_renders_anchor_action_link_when_anchor_url_is_provided
        render_inline(Component.new(anchor_url: "/demo"))

        assert_selector "a[href='/demo'][aria-label='Close']"
        assert_selector "a[href='/demo'] svg[data-flat-pack--icon-name-value='x-mark']"
      end

      def test_wraps_back_action_with_tooltip_from_deprecated_label
        render_inline(Component.new(back_label: "Return"))

        assert_selector "[data-controller='flat-pack--tooltip'] button[aria-label='Return']"
        assert_selector "[role='tooltip']", text: "Return"
      end

      def test_wraps_anchor_action_with_tooltip_from_deprecated_label
        render_inline(Component.new(anchor_url: "/demo", anchor_label: "Dismiss"))

        assert_selector "[data-controller='flat-pack--tooltip'] a[href='/demo'][aria-label='Dismiss']"
        assert_selector "[role='tooltip']", text: "Dismiss"
      end

      def test_uses_new_back_tooltip_over_deprecated_label
        render_inline(Component.new(back_label: "Old return", back_tooltip: "New return"))

        assert_selector "button[aria-label='New return']"
        assert_selector "[role='tooltip']", text: "New return"
        refute_text "Old return"
      end

      def test_uses_deprecated_back_label_when_new_tooltip_is_blank
        render_inline(Component.new(back_label: "Return", back_tooltip: ""))

        assert_selector "button[aria-label='Return']"
        assert_selector "[role='tooltip']", text: "Return"
      end

      def test_uses_new_anchor_tooltip_over_deprecated_label
        render_inline(Component.new(anchor_url: "/demo", anchor_label: "Old dismiss", anchor_tooltip: "New dismiss"))

        assert_selector "a[href='/demo'][aria-label='New dismiss']"
        assert_selector "[role='tooltip']", text: "New dismiss"
        refute_text "Old dismiss"
      end

      def test_uses_deprecated_anchor_label_when_new_tooltip_is_blank
        render_inline(Component.new(anchor_url: "/demo", anchor_label: "Dismiss", anchor_tooltip: ""))

        assert_selector "a[href='/demo'][aria-label='Dismiss']"
        assert_selector "[role='tooltip']", text: "Dismiss"
      end

      def test_renders_secondary_anchor_action_with_tooltip
        render_inline(Component.new(
          secondary_anchor_url: "/secondary",
          secondary_anchor_tooltip: "Previous item"
        ))

        assert_selector "[data-controller='flat-pack--tooltip'] a[href='/secondary'][aria-label='Previous item']"
        assert_selector "[role='tooltip']", text: "Previous item"
      end

      def test_renders_secondary_anchor_with_default_accessible_label_without_tooltip
        render_inline(Component.new(secondary_anchor_url: "/secondary"))

        assert_selector "a[href='/secondary'][aria-label='Previous page']"
        refute_selector "[data-controller='flat-pack--tooltip'] a[href='/secondary']"
      end

      def test_renders_secondary_anchor_to_left_of_anchor_action
        render_inline(Component.new(
          secondary_anchor_url: "/secondary",
          secondary_anchor_tooltip: "Previous item",
          anchor_url: "/primary",
          anchor_tooltip: "Close item"
        ))

        secondary = page.find("a[href='/secondary']")
        primary = page.find("a[href='/primary']")

        assert_operator page.native.to_html.index(secondary.native.to_html), :<, page.native.to_html.index(primary.native.to_html)
      end

      def test_renders_right_slot_content_when_provided
        render_inline(Component.new) do |component|
          component.right_slot do
            '<a href="/demo/forms" aria-label="Add"><span data-flat-pack--icon-name-value="plus"></span></a>'.html_safe
          end
        end

        assert_selector "a[href='/demo/forms'][aria-label='Add']"
        assert_selector "a[href='/demo/forms'] span[data-flat-pack--icon-name-value='plus']"
      end

      def test_renders_custom_icons_and_labels
        render_inline(Component.new(
          anchor_url: "/demo",
          anchor_icon: "trash",
          anchor_tooltip: "Dismiss"
        )) do |component|
          component.right_slot do
            '<a href="/demo/forms" aria-label="Confirm"><span data-flat-pack--icon-name-value="check"></span></a>'.html_safe
          end
        end

        assert_selector "a[href='/demo'][aria-label='Dismiss'] svg[data-flat-pack--icon-name-value='trash']"
        assert_selector "a[href='/demo/forms'][aria-label='Confirm'] span[data-flat-pack--icon-name-value='check']"
      end

      def test_applies_custom_wrapper_class
        render_inline(Component.new(class: "custom-page-nav"))

        assert_selector "nav.custom-page-nav"
      end
    end
  end
end
