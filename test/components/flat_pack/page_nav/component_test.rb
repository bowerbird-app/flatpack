# frozen_string_literal: true

require "test_helper"

module FlatPack
  module PageNav
    class ComponentTest < ViewComponent::TestCase
      def test_renders_wrapper_with_default_aria_label
        render_inline(Component.new)

        # The dummy host overrides this English label in config/locales/flatpack_overrides.en.yml.
        assert_selector "nav[aria-label='Host pages']"
        refute_selector "button"
        refute_selector "[data-controller='flat-pack--page-nav']"
      end

      def test_renders_history_back_button_with_controller_action
        render_inline(Component.new) { |nav| nav.with_back }

        assert_selector "nav[data-controller='flat-pack--page-nav']"
        assert_selector "nav > div.flex.items-center.gap-2"
        assert_selector "button[data-action='click->flat-pack--page-nav#back']"
        assert_selector "button[aria-label='Go back']"
        assert_selector "button svg[data-flat-pack--icon-name-value='chevron-left']"
        refute_selector "nav[data-flat-pack--page-nav-fallback-url-value]"
      end

      def test_removed_structure_keywords_raise
        show_back = assert_raises(ArgumentError) { Component.new(show_back: false) }
        right_slot = assert_raises(ArgumentError) { Component.new(right_slot: "end") }
        secondary = assert_raises(ArgumentError) { Component.new(secondary_anchor_href: "/secondary") }

        assert_match(/unknown keyword: :show_back/, show_back.message)
        assert_match(/unknown keyword: :right_slot/, right_slot.message)
        assert_match(/unknown keyword: :?secondary_anchor_href/, secondary.message)
      end

      def test_renders_back_href_as_a_link_without_history_action
        render_inline(Component.new) { |nav| nav.with_back(href: "/studio") }

        assert_selector "a[href='/studio'][aria-label='Go back']"
        refute_selector "[data-action='click->flat-pack--page-nav#back']"
        refute_selector "[data-controller='flat-pack--page-nav']"
      end

      def test_sets_fallback_url_when_history_back_has_one
        render_inline(Component.new) do |nav|
          nav.with_back(fallback_url: "/demo")
          nav.with_close(href: "/demo")
        end

        assert_selector "nav[data-controller='flat-pack--page-nav'][data-flat-pack--page-nav-fallback-url-value='/demo']"
        assert_selector "button[data-action='click->flat-pack--page-nav#back']"
        assert_selector "a[href='/demo'][aria-label='Close']"
      end

      def test_renders_close_link_and_action
        render_inline(Component.new) do |nav|
          nav.with_close(href: "/demo", icon: "trash", tooltip: "Dismiss")
          nav.with_action(icon: "plus", icon_only: true, href: "/add", aria: {label: "Add"})
        end

        assert_selector "a[href='/demo'][aria-label='Dismiss'] svg[data-flat-pack--icon-name-value='trash']"
        assert_selector "a[href='/add'][aria-label='Add'] svg[data-flat-pack--icon-name-value='plus']"
        refute_selector "[data-controller='flat-pack--page-nav']"
      end

      def test_round_is_false_by_default_and_passes_through_when_true
        render_inline(Component.new) { |nav| nav.with_back(href: "/back") }

        back = page.find("a[href='/back']")
        assert_includes back[:class], "rounded-[var(--button-border-radius)]"
        refute_includes back[:class], "rounded-[var(--button-round-border-radius)]"

        render_inline(Component.new(round: true)) do |nav|
          nav.with_back(href: "/back", size: :lg)
          nav.with_close(href: "/close", tooltip: "Close", size: :sm)
          nav.with_link(href: "/home", icon: "home", tooltip: "Home", size: :sm)
          nav.with_action(icon: "plus", icon_only: true, href: "/add", aria: {label: "Add"}, size: :sm)
          nav.with_item { '<a href="/raw" class="squared" aria-label="Raw">Raw</a>'.html_safe }
        end

        ["/back", "/close", "/home", "/add"].each do |href|
          control = page.find("a[href='#{href}']")
          assert_includes control[:class], "rounded-[var(--button-round-border-radius)]"
          refute_includes control[:class], "rounded-[var(--button-border-radius)]"
        end
        assert_includes page.find("a[href='/back']")[:class], "h-[var(--button-round-size-lg)]"
        assert_includes page.find("a[href='/close']")[:class], "h-[var(--button-round-size-sm)]"
        assert_includes page.find("a[href='/home']")[:class], "h-[var(--button-round-size-sm)]"
        assert_includes page.find("a[href='/add']")[:class], "h-[var(--button-round-size-sm)]"
        refute_includes page.find("a[href='/raw']")[:class].to_s, "button-round-border-radius"
      end

      def test_rejects_a_round_value_that_is_not_a_boolean
        error = assert_raises(ArgumentError) { Component.new(round: "yes") }

        assert_match(/Invalid round/, error.message)
      end

      def test_renders_items_in_call_order
        render_inline(Component.new) do |nav|
          nav.with_back(style: :primary)
          nav.with_link(href: "/home", icon: "home", tooltip: "Home", style: :ghost, size: :sm)
          nav.with_link(href: "/admin", icon: "squares-2x2", tooltip: "Admin", style: :ghost, size: :sm)
          nav.with_close(href: "/close", tooltip: "Close", style: :ghost, size: :sm)
        end

        assert_selector "nav > div.flex.gap-2 > div", count: 4
        assert_selector "nav > div.flex.gap-2 > div:nth-child(1) button[data-action='click->flat-pack--page-nav#back'][data-fp-style='primary']"
        assert_selector "nav > div.flex.gap-2 > div:nth-child(2) a[href='/home'][aria-label='Home'][data-fp-style='ghost']"
        assert_selector "nav > div.flex.gap-2 > div:nth-child(3) a[href='/admin'][aria-label='Admin']"
        assert_selector "nav > div.flex.gap-2 > div:nth-child(4) a[href='/close'][aria-label='Close'][data-fp-style='ghost']"
        assert_selector "[data-controller='flat-pack--tooltip'] a[href='/home']"
        assert_selector "[role='tooltip']", text: "Home"
        assert_selector "[role='tooltip']", text: "Admin"
        assert_selector "a[href='/home'] svg[data-flat-pack--icon-name-value='home']"
        assert_selector "a[href='/admin'] svg[data-flat-pack--icon-name-value='squares-2x2']"
        assert_includes page.find("a[href='/home']")[:class], "p-[var(--button-icon-only-padding-sm)]"
        refute_selector ".ml-auto"

        html = page.native.to_html
        indexes = ["page-nav#back", 'href="/home"', 'href="/admin"', 'href="/close"'].map { |token| html.index(token) }

        assert_equal indexes, indexes.sort
        assert_equal indexes.uniq, indexes
      end

      def test_an_empty_item_block_matches_a_nav_with_no_items
        plain = render_inline(Component.new).to_html
        empty = render_inline(Component.new) { |nav| nav }.to_html

        assert_equal plain, empty
        assert_selector "nav > div.flex.gap-2 > div", count: 0
      end

      def test_rejects_an_unsafe_link_href
        error = assert_raises(ArgumentError) do
          render_inline(Component.new) do |nav|
            nav.with_link(href: "javascript:alert(1)", icon: "home", tooltip: "Home")
          end
        end

        assert_match(/Unsafe URL detected/, error.message)
      end

      def test_rejects_a_link_that_is_missing_a_tooltip
        error = assert_raises(ArgumentError) do
          render_inline(Component.new) do |nav|
            nav.with_link(href: "/home", icon: "home", tooltip: "")
          end
        end

        assert_match(/needs a tooltip/, error.message)
      end

      def test_applies_custom_wrapper_class
        render_inline(Component.new(class: "custom-page-nav"))

        assert_selector "nav.custom-page-nav"
      end
    end
  end
end
