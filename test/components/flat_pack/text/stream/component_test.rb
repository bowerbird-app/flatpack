# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Text
    module Stream
      class ComponentTest < ViewComponent::TestCase
        test "renders the full source and hides the typed copy until javascript" do
          render_inline(Component.new(text: "Hello there", tag: :p, class: "reply"))

          assert_selector "p.fp-text-stream.reply[data-controller='flat-pack--text-stream']"
          assert_selector ".fp-text-stream__source:not([aria-hidden])", text: "Hello there", visible: :all
          assert_selector ".fp-text-stream__sizer[aria-hidden='true']", text: "Hello there", visible: :all
          assert_selector ".fp-text-stream__live[hidden][aria-hidden='true']", visible: :all
          assert_selector ".fp-text-stream__caret[aria-hidden='true']", visible: :all
          assert_selector "[data-flat-pack--text-stream-target='source']", visible: :all
          assert_selector "[data-flat-pack--text-stream-target='typed']", visible: :all
          refute_selector ".is-streaming"
        end

        test "rejects blank text, html-safe text, and an unknown tag" do
          assert_raises(ArgumentError) { Component.new(text: "  ") }
          assert_raises(ArgumentError) { Component.new(text: "<b>no</b>".html_safe) }

          error = assert_raises(ArgumentError) do
            render_inline(Component.new(text: "Hello", tag: :script))
          end

          assert_match(/Invalid tag/, error.message)
        end
      end
    end
  end
end
