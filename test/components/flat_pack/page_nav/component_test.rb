# frozen_string_literal: true

require "test_helper"

module FlatPack
  module PageNav
    class ComponentTest < ViewComponent::TestCase
      def test_renders_wrapper_with_default_aria_label
        render_inline(Component.new)

        # The dummy host overrides this English label in config/locales/flatpack_overrides.en.yml.
        assert_selector "nav[aria-label='Host pages']"
      end

      def test_renders_history_back_button_with_controller_action
        render_inline(Component.new)

        assert_selector "nav[data-controller='flat-pack--page-nav']"
        assert_selector "nav > div.flex.gap-2"
        assert_selector "button[data-action='click->flat-pack--page-nav#back']"
        assert_selector "button[aria-label='Go back']"
        assert_selector "button svg[data-flat-pack--icon-name-value='chevron-left']"
        refute_selector "nav[data-flat-pack--page-nav-fallback-url-value]"
      end

      def test_omits_back_control_and_controller_when_show_back_is_false
        render_inline(Component.new(show_back: false, anchor_href: "/demo"))

        refute_selector "button"
        refute_selector "[data-action='click->flat-pack--page-nav#back']"
        refute_selector "[data-controller='flat-pack--page-nav']"
        assert_selector "a[href='/demo'][aria-label='Close']"
        assert_selector "nav > div.flex.gap-2 > div", count: 1
      end

      def test_renders_back_href_as_a_link_without_history_action
        render_inline(Component.new(back_href: "/studio"))

        assert_selector "a[href='/studio'][aria-label='Go back']"
        refute_selector "[data-action='click->flat-pack--page-nav#back']"
        refute_selector "[data-controller='flat-pack--page-nav']"
      end

      def test_sets_fallback_url_when_history_back_has_an_anchor
        render_inline(Component.new(anchor_href: "/demo"))

        assert_selector "nav[data-controller='flat-pack--page-nav'][data-flat-pack--page-nav-fallback-url-value='/demo']"
        assert_selector "button[data-action='click->flat-pack--page-nav#back']"
        assert_selector "a[href='/demo']"
      end

      def test_hides_anchor_and_right_actions_when_not_provided
        render_inline(Component.new)

        assert_selector "button", count: 1
        refute_selector "a[aria-label='Close']"
        refute_selector "a[href='/secondary']"
        refute_selector "a[aria-label='Add']"
      end

      def test_renders_anchor_action_link_when_anchor_url_is_provided
        render_inline(Component.new(anchor_href: "/demo"))

        assert_selector "a[href='/demo'][aria-label='Close']"
        assert_selector "a[href='/demo'] svg[data-flat-pack--icon-name-value='x-mark']"
      end

      def test_wraps_back_action_with_tooltip_from_deprecated_label
        render_inline(Component.new(back_label: "Return"))

        assert_selector "[data-controller='flat-pack--tooltip'] button[aria-label='Return']"
        assert_selector "[role='tooltip']", text: "Return"
      end

      def test_wraps_anchor_action_with_tooltip_from_deprecated_label
        render_inline(Component.new(anchor_href: "/demo", anchor_label: "Dismiss"))

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
        render_inline(Component.new(anchor_href: "/demo", anchor_label: "Old dismiss", anchor_tooltip: "New dismiss"))

        assert_selector "a[href='/demo'][aria-label='New dismiss']"
        assert_selector "[role='tooltip']", text: "New dismiss"
        refute_text "Old dismiss"
      end

      def test_uses_deprecated_anchor_label_when_new_tooltip_is_blank
        render_inline(Component.new(anchor_href: "/demo", anchor_label: "Dismiss", anchor_tooltip: ""))

        assert_selector "a[href='/demo'][aria-label='Dismiss']"
        assert_selector "[role='tooltip']", text: "Dismiss"
      end

      def test_secondary_anchor_arguments_are_unknown
        error = assert_raises(ArgumentError) do
          Component.new(secondary_anchor_href: "/secondary")
        end

        assert_match(/unknown keyword: :?secondary_anchor_href/, error.message)
      end

      def test_round_is_false_by_default_and_passes_through_when_true
        render_inline(Component.new(back_href: "/back"))

        back = page.find("a[href='/back']")
        assert_includes back[:class], "rounded-[var(--button-border-radius)]"
        refute_includes back[:class], "rounded-[var(--button-round-border-radius)]"

        render_inline(Component.new(
          round: true,
          back_href: "/back",
          back_size: :lg,
          anchor_href: "/close",
          anchor_tooltip: "Close",
          anchor_size: :sm
        )) do |nav|
          nav.with_link(href: "/home", icon: "home", tooltip: "Home")
          nav.right_slot do
            '<a href="/add" class="squared" aria-label="Add">Add</a>'.html_safe
          end
        end

        [page.find("a[href='/back']"), page.find("a[href='/close']"), page.find("a[href='/home']")].each do |control|
          assert_includes control[:class], "rounded-[var(--button-round-border-radius)]"
          refute_includes control[:class], "rounded-[var(--button-border-radius)]"
        end
        assert_includes page.find("a[href='/back']")[:class], "h-[var(--button-round-size-lg)]"
        assert_includes page.find("a[href='/close']")[:class], "h-[var(--button-round-size-sm)]"
        assert_includes page.find("a[href='/home']")[:class], "h-[var(--button-round-size-sm)]"
        refute_includes page.find("a[href='/add']")[:class].to_s, "button-round-border-radius"
      end

      def test_rejects_a_round_value_that_is_not_a_boolean
        error = assert_raises(ArgumentError) { Component.new(round: "yes") }

        assert_match(/Invalid round/, error.message)
      end

      def test_renders_middle_links_in_order_between_close_and_the_trailing_action
        render_inline(Component.new(
          back_style: :primary,
          anchor_href: "/close",
          anchor_tooltip: "Close",
          anchor_style: :ghost,
          anchor_size: :sm
        )) do |nav|
          nav.with_link(href: "/home", icon: "home", tooltip: "Home")
          nav.with_link(href: "/admin", icon: "squares-2x2", tooltip: "Admin")
          nav.right_slot do
            '<a href="/add" aria-label="Add">Add</a>'.html_safe
          end
        end

        assert_selector "nav > div.flex.gap-2 > div", count: 4
        assert_selector "nav > div.flex.gap-2 > div:nth-child(1) button[data-action='click->flat-pack--page-nav#back'][data-fp-style='primary']"
        assert_selector "nav > div.flex.gap-2 > div:nth-child(2) a[href='/close'][data-fp-style='ghost']"
        assert_selector "nav > div.flex.gap-2 > div:nth-child(3) a[href='/home'][aria-label='Home'][data-fp-style='ghost']"
        assert_selector "nav > div.flex.gap-2 > div:nth-child(3) a[href='/admin'][aria-label='Admin']"
        assert_selector "nav > div.flex.gap-2 > div.ml-auto a[href='/add']"
        assert_selector "[data-controller='flat-pack--tooltip'] a[href='/home']"
        assert_selector "[role='tooltip']", text: "Home"
        assert_selector "[role='tooltip']", text: "Admin"
        assert_selector "a[href='/home'] svg[data-flat-pack--icon-name-value='home']"
        assert_selector "a[href='/admin'] svg[data-flat-pack--icon-name-value='squares-2x2']"
        assert_includes page.find("a[href='/home']")[:class], "p-[var(--button-icon-only-padding-sm)]"

        html = page.native.to_html
        indexes = ["/close", "/home", "/admin", "/add"].map { |href| html.index("href=\"#{href}\"") }

        assert_equal indexes, indexes.sort
        assert_equal indexes.uniq, indexes
      end

      def test_an_empty_link_slot_leaves_the_markup_unchanged
        plain = render_inline(Component.new(anchor_href: "/demo", anchor_tooltip: "Close")).to_html
        empty = render_inline(Component.new(anchor_href: "/demo", anchor_tooltip: "Close")) { |nav| nav }.to_html

        assert_equal plain, empty
        assert_selector "nav > div.flex.gap-2 > div", count: 2
      end

      def test_rejects_an_unsafe_link_href
        error = assert_raises(ArgumentError) do
          render_inline(Component.new) do |nav|
            nav.with_link(href: "javascript:alert(1)", icon: "home", tooltip: "Home")
          end
        end

        assert_match(/Unsafe URL detected/, error.message)
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

      def test_renders_right_slot_in_separate_right_aligned_wrapper
        render_inline(Component.new(anchor_href: "/primary")) do |component|
          component.right_slot do
            '<a href="/demo/forms" aria-label="Add"><span data-flat-pack--icon-name-value="plus"></span></a>'.html_safe
          end
        end

        assert_selector "nav > div.flex.gap-2 > div", count: 3
        assert_selector "nav > div.flex.gap-2 > div:nth-child(1) button[data-action='click->flat-pack--page-nav#back']"
        assert_selector "nav > div.flex.gap-2 > div:nth-child(2) a[href='/primary']"
        assert_selector "nav > div.flex.gap-2 > div.ml-auto.flex.items-center.gap-2 a[href='/demo/forms'][aria-label='Add']"
      end

      def test_renders_custom_icons_and_labels
        render_inline(Component.new(
          anchor_href: "/demo",
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
