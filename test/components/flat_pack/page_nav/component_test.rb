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
        refute_selector "a[aria-label='Add']"
      end

      def test_renders_anchor_action_link_when_anchor_url_is_provided
        render_inline(Component.new(anchor_url: "/demo"))

        assert_selector "a[href='/demo'][aria-label='Close']"
        assert_selector "a[href='/demo'] svg[data-flat-pack--icon-name-value='x-mark']"
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
          anchor_label: "Dismiss"
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
