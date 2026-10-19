# frozen_string_literal: true

require "test_helper"

module FlatPack
  module ReadMore
    class ComponentTest < ViewComponent::TestCase
      def test_default_render
        render_inline(Component.new) { "The kettle is on." }

        root = page.find(".fp-read-more")
        clip = page.find(".fp-read-more-clip")
        button = page.find("button", visible: :all)

        assert_equal "flat-pack--read-more", root["data-controller"]
        assert_equal "false", root["data-flat-pack--read-more-open-value"]
        assert_includes root[:style], "--read-more-lines: 4"
        assert_match(/\Afp-read-more-[0-9a-f]{8}\z/, clip[:id])
        assert_equal "clip", clip["data-flat-pack--read-more-target"]
        assert_selector ".fp-read-more-clip .fp-read-more-body", text: "The kettle is on."
        assert_equal "body", page.find(".fp-read-more-body")["data-flat-pack--read-more-target"]
        assert_equal clip[:id], button[:"aria-controls"]
        assert_equal "click->flat-pack--read-more#toggle", button["data-action"]
        assert_equal "toggle", button["data-flat-pack--read-more-target"]
        assert_selector(
          "button[hidden][type='button'][data-fp-style='ghost'][aria-expanded='false']",
          text: "Show more",
          visible: :all
        )
        assert_equal "Show more", button.text
        refute_selector "[data-controller*='flat-pack--collapse']", visible: :all
      end

      def test_open_starts_expanded
        render_inline(Component.new(id: "notes", open: true)) { "The rest of the note." }

        assert_selector "#notes[data-flat-pack--read-more-open-value='true']"
        assert_selector "#notes-content.fp-read-more-clip"
        refute_selector "#notes-content[hidden]", visible: :all
        assert_selector "button[aria-expanded='true']", text: "Show less", visible: :all
        assert_equal "notes", page.find(".fp-read-more")[:id]
      end

      def test_custom_labels_reach_the_button_and_the_controller
        render_inline(Component.new(more_label: "Keep reading", less_label: "That's enough")) { "Hi" }

        root = page.find(".fp-read-more")
        assert_equal "Keep reading", root["data-flat-pack--read-more-more-label-value"]
        assert_equal "That's enough", root["data-flat-pack--read-more-less-label-value"]
        assert_selector "button", text: "Keep reading", visible: :all

        render_inline(Component.new(open: true, more_label: "Keep reading", less_label: "That's enough")) { "Hi" }

        assert_selector "button", text: "That's enough", visible: :all
      end

      def test_caller_class_merges_on_the_root
        render_inline(Component.new(class: "max-w-md", style: "color: red", data: {controller: "analytics"})) { "Hi" }

        root = page.find(".fp-read-more.max-w-md")
        assert_includes root[:class], "fp-read-more"
        assert_includes root[:style], "color: red"
        assert_includes root[:style], "--read-more-lines: 4"
        assert_equal "analytics flat-pack--read-more", root["data-controller"]
        refute_selector "button.max-w-md", visible: :all
      end

      def test_lines_must_be_a_positive_integer
        [0, -1, "4", 4.0].each do |lines|
          error = assert_raises(ArgumentError) { Component.new(lines: lines) }

          assert_equal "lines must be a positive integer", error.message
        end
      end

      def test_open_must_be_true_or_false
        ["true", nil].each do |open|
          error = assert_raises(ArgumentError) { Component.new(open: open) }

          assert_equal "open must be true or false", error.message
        end
      end

      def test_block_content_renders_inside_the_body
        render_inline(Component.new) do
          "<p>Packed lunch</p><ul><li>Apple</li></ul>".html_safe
        end

        assert_selector ".fp-read-more-body > p", text: "Packed lunch"
        assert_selector ".fp-read-more-body > ul > li", text: "Apple"
        refute_selector "[data-controller*='flat-pack--collapse']", visible: :all
      end

      def test_empty_block_is_allowed
        render_inline(Component.new)

        assert_equal "", page.find(".fp-read-more-body").text.strip
      end

      def test_blank_label_raises
        more_error = assert_raises(ArgumentError) { Component.new(more_label: " ") }
        less_error = assert_raises(ArgumentError) { Component.new(less_label: nil) }

        assert_equal "more_label must be a String", more_error.message
        assert_equal "less_label must be a String", less_error.message
      end
    end
  end
end
