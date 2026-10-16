# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Reveal
    class ComponentTest < ViewComponent::TestCase
      test "box reveal renders the final state with no pending class" do
        render_inline(Component.new(reveal: :rise, class: "max-w-sm")) { "Hello" }

        assert_selector "div.fp-reveal.fp-reveal--rise.max-w-sm[data-controller='flat-pack--reveal']", text: "Hello"
        refute_selector ".is-pending"
        refute_selector ".is-revealed"
        refute_selector ".fp-reveal--stagger"
      end

      test "stagger marks the root and asks the controller to index children" do
        render_inline(Component.new(reveal: :fade, stagger: true)) { "<div>One</div><div>Two</div>".html_safe }

        assert_selector ".fp-reveal--stagger[data-flat-pack--reveal-stagger-value='true']"
      end

      test "zoom parallax is a class on the root" do
        render_inline(Component.new(reveal: :zoom, parallax: true)) { "<img alt='Stool'>".html_safe }

        assert_selector ".fp-reveal--zoom.fp-reveal--parallax"
        refute_selector "[data-flat-pack--reveal-stagger-value]"
      end

      test "words split into masked pieces and leave the sentence for screen readers" do
        render_inline(Component.new(reveal: :words, tag: :h2, text: "Pack it up"))

        assert_selector "h2.fp-reveal--words"
        assert_selector "h2 .fp-reveal__plain:not([aria-hidden])", text: "Pack it up"
        assert_selector ".fp-reveal__mask[aria-hidden='true']", count: 3
        assert_selector ".fp-reveal__mask[style*='--reveal-index: 0']", text: "Pack"
        assert_selector ".fp-reveal__mask[style*='--reveal-index: 2']", text: "up"
        refute_selector ".fp-reveal--stagger"
        refute_selector ".is-pending"
      end

      test "lines split on newlines" do
        render_inline(Component.new(reveal: :lines, tag: :p, text: "Fold the shirt.\nTape the box."))

        assert_selector "p.fp-reveal--lines"
        assert_selector ".fp-reveal__plain", text: "Fold the shirt. Tape the box."
        assert_selector ".fp-reveal__mask", count: 2
        assert_selector ".fp-reveal__chunk", text: "Fold the shirt."
        assert_selector ".fp-reveal__chunk", text: "Tape the box."
      end

      test "words can come from the block" do
        render_inline(Component.new(reveal: :words, tag: :h2)) { "Pack <em>it</em> up".html_safe }

        assert_selector ".fp-reveal__plain", text: "Pack it up"
        assert_selector ".fp-reveal__chunk", text: "it"
      end

      test "rejects text reveals without copy" do
        error = assert_raises(ArgumentError) do
          render_inline(Component.new(reveal: :words, text: "  "))
        end

        assert_equal "text is required", error.message
      end

      test "rejects an empty box" do
        error = assert_raises(ArgumentError) do
          render_inline(Component.new(reveal: :fade))
        end

        assert_equal "content is required", error.message
      end

      test "rejects an unknown reveal, tag, parallax pairing, and html-safe text" do
        assert_raises(ArgumentError) { Component.new(reveal: :spin) }
        assert_raises(ArgumentError) { Component.new(reveal: :fade, parallax: true) }
        assert_raises(ArgumentError) { Component.new(reveal: :words, text: "<b>no</b>".html_safe) }

        error = assert_raises(ArgumentError) do
          render_inline(Component.new(reveal: :fade, tag: :script)) { "Hi" }
        end

        assert_match(/Invalid tag/, error.message)
      end
    end
  end
end
