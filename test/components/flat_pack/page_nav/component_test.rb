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

      def test_hides_close_and_add_actions_when_urls_not_provided
        render_inline(Component.new)

        assert_selector "button", count: 1
        refute_selector "a[aria-label='Close']"
        refute_selector "a[aria-label='Add']"
      end

      def test_renders_close_action_link_when_close_url_is_provided
        render_inline(Component.new(close_url: "/demo"))

        assert_selector "a[href='/demo'][aria-label='Close']"
        assert_selector "a[href='/demo'] svg[data-flat-pack--icon-name-value='x-mark']"
      end

      def test_renders_add_action_link_when_add_url_is_provided
        render_inline(Component.new(add_url: "/demo/forms"))

        assert_selector "a[href='/demo/forms'][aria-label='Add']"
        assert_selector "a[href='/demo/forms'] svg[data-flat-pack--icon-name-value='plus']"
      end

      def test_renders_custom_icons_and_labels
        render_inline(Component.new(
          close_url: "/demo",
          close_icon: "trash",
          close_label: "Dismiss",
          add_url: "/demo/forms",
          add_icon: "check",
          add_label: "Confirm"
        ))

        assert_selector "a[href='/demo'][aria-label='Dismiss'] svg[data-flat-pack--icon-name-value='trash']"
        assert_selector "a[href='/demo/forms'][aria-label='Confirm'] svg[data-flat-pack--icon-name-value='check']"
      end

      def test_applies_custom_wrapper_class
        render_inline(Component.new(class: "custom-page-nav"))

        assert_selector "nav.custom-page-nav"
      end
    end
  end
end
