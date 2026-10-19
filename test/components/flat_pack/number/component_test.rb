# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Number
    class ComponentTest < ViewComponent::TestCase
      test "renders the finished number and keeps the stage blank" do
        render_inline(Component.new(value: 2480, class: "total"))

        assert_selector "span.fp-number.fp-number--count.total[data-controller='flat-pack--number']"
        assert_selector ".fp-number__final:not([aria-hidden])", text: "2,480", visible: :all
        assert_selector ".fp-number__sizer[aria-hidden='true']", text: "2,480", visible: :all
        assert_selector ".fp-number__stage[aria-hidden='true']", text: "", visible: :all
        assert_selector "[data-flat-pack--number-target='final']", visible: :all
        assert_selector "[data-flat-pack--number-target='stage']", visible: :all
        assert_selector "[data-flat-pack--number-value-value='2480']", visible: :all
        assert_selector "[data-flat-pack--number-from-value='0']", visible: :all
        assert_selector "[data-flat-pack--number-from-text-value='0']", visible: :all
        assert_selector "[data-flat-pack--number-format-value='number']", visible: :all
        assert_selector "[data-flat-pack--number-animate-value='count']", visible: :all
        assert_selector "[data-flat-pack--number-duration-value='slow']", visible: :all
        assert_selector "[data-flat-pack--number-locale-value='en']", visible: :all
        assert_includes rendered_content, "--fp-number-duration: var(--motion-duration-slow)"
        refute_includes rendered_content, "aria-live"
        refute_includes rendered_content, "is-pending"
        refute_includes rendered_content, "is-settled"
        refute_includes rendered_content, "data-flat-pack--number-decimals-value"
        refute_includes rendered_content, "data-flat-pack--number-currency-value"
      end

      test "formats currency, percent, compact, decimals, and affixes" do
        render_inline(Component.new(value: 1240, format: :currency, currency: "USD"))
        assert_selector ".fp-number__final", text: "$1,240.00", visible: :all
        assert_selector "[data-flat-pack--number-currency-value='USD']", visible: :all

        render_inline(Component.new(value: "0.18", format: :percent))
        assert_selector ".fp-number__final", text: "18%", visible: :all

        render_inline(Component.new(value: 12_000, format: :compact))
        assert_selector ".fp-number__final", text: "12K", visible: :all

        render_inline(Component.new(value: 12, decimals: 0, prefix: "About ", suffix: " left", animate: :none, duration: :fast))
        assert_selector ".fp-number.is-static.fp-number--none", visible: :all
        assert_selector ".fp-number__final", text: "About 12 left", visible: :all
        assert_selector "[data-flat-pack--number-decimals-value='0']", visible: :all
        assert_selector "[data-flat-pack--number-prefix-value='About ']", visible: :all
        assert_selector "[data-flat-pack--number-suffix-value=' left']", visible: :all
        assert_includes rendered_content, "--fp-number-duration: var(--motion-duration-fast)"
      end

      test "keeps a caller style and the duration token" do
        render_inline(Component.new(value: 4, style: "color: red", from: 1))

        assert_includes rendered_content, "color: red"
        assert_includes rendered_content, "--fp-number-duration: var(--motion-duration-slow)"
        assert_selector "[data-flat-pack--number-from-text-value='1']", visible: :all
        assert_selector "[data-flat-pack--number-from-value='1']", visible: :all
      end

      test "rejects bad numbers, currency, decimals, and tags" do
        assert_raises(ArgumentError) { Component.new(value: "nope") }
        assert_raises(ArgumentError) { Component.new(value: "<b>1</b>".html_safe) }
        assert_raises(ArgumentError) { Component.new(value: Float::NAN) }
        assert_raises(ArgumentError) { Component.new(value: 1, currency: "USD") }
        assert_raises(ArgumentError) { Component.new(value: 1, format: :currency) }
        assert_raises(ArgumentError) { Component.new(value: 1, format: :currency, currency: "us") }
        assert_raises(ArgumentError) { Component.new(value: 1, decimals: 21) }
        assert_raises(ArgumentError) { Component.new(value: 1, prefix: "<b>x</b>".html_safe) }
        assert_raises(ArgumentError) { Component.new(value: 1, animate: :bounce) }
        assert_raises(ArgumentError) { Component.new(value: 1, duration: :glacial) }
        assert_raises(ArgumentError) { Component.new(value: 1, format: :spell) }

        error = assert_raises(ArgumentError) { render_inline(Component.new(value: 1, tag: :script)) }
        assert_match(/Invalid tag/, error.message)
      end

      test "stylesheet keeps the width steady and restores the finished value" do
        css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read

        assert_includes css, "font-variant-numeric: tabular-nums"
        assert_includes css, ".fp-number:not(.is-static) .fp-number__final"
        assert_includes css, ".fp-number.is-pending .fp-number__strip"
        assert_match(/@media \(prefers-reduced-motion: reduce\)[\s\S]*\.fp-number:not\(\.is-static\) \.fp-number__final/, css)
        assert_match(/@media \(scripting: none\)[\s\S]*\.fp-number:not\(\.is-static\) \.fp-number__final/, css)
      end
    end
  end
end
