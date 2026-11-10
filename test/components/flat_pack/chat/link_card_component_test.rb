# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Chat
    module LinkCard
      class ComponentTest < ViewComponent::TestCase
        def test_linked_card_is_a_single_anchor
          render_inline(Component.new(
            title: "Help centre",
            href: "/help",
            description: "Guides and answers",
            meta: "Support",
            icon: :lifebuoy
          ))

          assert_selector "a[href='/help'][data-flat-pack-chat-link-card='true'][data-flat-pack-chat-link-card-available='true']", count: 1
          assert_selector "a", text: "Help centre"
          assert_selector "a", text: "Support"
          assert_selector "a", text: "Guides and answers"
          refute_includes rendered_content, "aria-label"
          assert_selector "a[tabindex]", count: 0
        end

        def test_unavailable_card_is_a_noninteractive_div
          render_inline(Component.new(title: "Press kit"))

          assert_selector "div[data-flat-pack-chat-link-card='true'][data-flat-pack-chat-link-card-available='false']", text: "Press kit"
          refute_selector "a"
          assert_text "Unavailable"
          refute_includes rendered_content, "hover:bg-[var(--surface-hover-background-color)]"
          refute_includes rendered_content, "focus:ring-2"
          refute_includes rendered_content, "tabindex="
        end

        def test_unavailable_uses_host_meta_when_supplied
          render_inline(Component.new(title: "Press kit", meta: "Taken down"))

          assert_text "Taken down"
          assert_no_text "Unavailable"
        end

        def test_blank_href_is_unavailable
          render_inline(Component.new(title: "Help centre", href: "  "))

          refute_selector "a"
          assert_text "Unavailable"
        end

        def test_incoming_aligns_start_and_outgoing_aligns_end
          render_inline(Component.new(title: "Help centre", href: "/help"))

          assert_includes rendered_content, "justify-start"
          assert_includes rendered_content, "max-w-[75%] sm:max-w-[500px]"

          render_inline(Component.new(title: "Help centre", href: "/help", direction: :outgoing))

          assert_includes rendered_content, "justify-end"
        end

        def test_title_truncates_and_description_clamps
          render_inline(Component.new(
            title: "A long support page title",
            href: "/help",
            description: "Line one of the summary. Line two of the summary. Extra copy that should clamp."
          ))

          assert_includes rendered_content, "truncate"
          assert_includes rendered_content, "line-clamp-2"
        end

        def test_paints_link_card_tokens
          render_inline(Component.new(title: "Help centre", href: "/help"))

          assert_includes rendered_content, "rounded-[var(--chat-link-card-radius)]"
          assert_includes rendered_content, "px-[var(--chat-link-card-padding-x)]"
          assert_includes rendered_content, "py-[var(--chat-link-card-padding-y)]"
          assert_includes rendered_content, "border-[var(--surface-border-color)]"
          assert_includes rendered_content, "bg-[var(--surface-background-color)]"
          assert_includes rendered_content, "hover:bg-[var(--surface-hover-background-color)]"
          assert_includes rendered_content, "focus:ring-[var(--color-ring)]"
        end

        def test_requires_title
          error = assert_raises(ArgumentError) { render_inline(Component.new(title: "")) }
          assert_match(/title is required/, error.message)
        end

        def test_rejects_invalid_direction
          error = assert_raises(ArgumentError) { Component.new(title: "Help centre", direction: :sideways) }
          assert_match(/Invalid direction/, error.message)
        end
      end
    end
  end
end
