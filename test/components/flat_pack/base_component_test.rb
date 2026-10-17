# frozen_string_literal: true

require "test_helper"

module FlatPack
  class BaseComponentTest < ViewComponent::TestCase
    # Create a simple test component to verify base functionality
    class TestComponent < BaseComponent
      def call
        content_tag :div, "Test", **merge_attributes
      end
    end

    test "sanitizes dangerous onclick attribute" do
      render_inline(TestComponent.new(onclick: "alert('xss')"))

      refute_selector "div[onclick]"
    end

    test "sanitizes dangerous onmouseover attribute" do
      render_inline(TestComponent.new(onmouseover: "alert('xss')"))

      refute_selector "div[onmouseover]"
    end

    test "sanitizes multiple dangerous attributes" do
      render_inline(TestComponent.new(
        onclick: "alert('xss')",
        onload: "alert('xss')",
        onerror: "alert('xss')"
      ))

      refute_selector "div[onclick]"
      refute_selector "div[onload]"
      refute_selector "div[onerror]"
    end

    test "preserves safe attributes" do
      render_inline(TestComponent.new(
        id: "test-id",
        class: "test-class",
        data: {action: "click"},
        aria: {label: "Test"}
      ))

      assert_selector "div#test-id.test-class[data-action='click'][aria-label='Test']"
    end

    test "sanitizes case-insensitive dangerous attributes" do
      render_inline(TestComponent.new(OnClick: "alert('xss')"))

      refute_selector "div[onclick]"
      refute_selector "div[OnClick]"
    end

    class TwiceComponent < BaseComponent
      def call
        content_tag(:div, **merge_attributes(class: "outer", data: {controller: "flat-pack--button"})) do
          content_tag(:span, "inner", **merge_attributes(class: "inner"))
        end
      end
    end

    test "reveal is a system argument on the first merged root" do
      render_inline(TestComponent.new(reveal: :fade, class: "card"))

      assert_selector "div.fp-reveal.fp-reveal--fade.card[data-controller='flat-pack--reveal']"
      refute_selector ".is-pending"
    end

    test "stagger and parallax pass through when they are valid" do
      render_inline(TestComponent.new(reveal: :wipe, stagger: true, parallax: true))

      assert_selector ".fp-reveal--wipe.fp-reveal--stagger.fp-reveal--parallax[data-flat-pack--reveal-stagger-value='true']"
    end

    test "reveal merges with a controller the component already sets" do
      render_inline(TwiceComponent.new(reveal: :rise))

      assert_selector "div.outer.fp-reveal--rise[data-controller='flat-pack--button flat-pack--reveal']"
      assert_selector "span.inner"
      refute_selector "span[data-controller]"
    end

    test "omitting reveal leaves the root alone" do
      render_inline(TestComponent.new(id: "plain"))

      assert_selector "div#plain"
      refute_selector "[data-controller]"
      refute_selector ".fp-reveal"
    end

    test "strong intensity adds one class" do
      render_inline(TestComponent.new(reveal: :scale, intensity: :strong))

      assert_selector ".fp-reveal--scale.fp-reveal--strong"
    end

    test "named delay and duration set instance timing on the root" do
      render_inline(TestComponent.new(reveal: :fade, delay: :md, duration: :slower, style: "color: red"))

      assert_selector ".fp-reveal--fade[style*='color: red']"
      assert_selector "[style*='--reveal-delay: var(--motion-delay-md)']"
      assert_selector "[style*='--reveal-duration: var(--motion-duration-slower)']"
      refute_selector "[delay]"
      refute_selector "[duration]"
    end

    test "a millisecond delay is the escape hatch" do
      render_inline(TestComponent.new(reveal: :rise, delay: 250, duration: 600))

      assert_selector "[style*='--reveal-delay: 250ms']"
      assert_selector "[style*='--reveal-duration: 600ms']"
    end

    test "stagger steps turn on child indexing and set the step" do
      render_inline(TestComponent.new(reveal: :fade, stagger: :lg))

      assert_selector ".fp-reveal--stagger[data-flat-pack--reveal-stagger-value='true']"
      assert_selector "[style*='--reveal-stagger: var(--motion-stagger-lg)']"
    end

    test "stagger true keeps the theme stagger token" do
      render_inline(TestComponent.new(reveal: :fade, stagger: true))

      assert_selector ".fp-reveal--stagger"
      refute_selector "[style*='--reveal-stagger']"
    end

    test "card reveal keeps the delay when the card rewrites style" do
      render_inline(FlatPack::Card::Component.new(reveal: :rise, delay: :lg, shadow: :sm)) { "Hi" }

      assert_selector ".fp-card.fp-reveal--rise[style*='--reveal-delay: var(--motion-delay-lg)']"
    end

    test "words, a missing reveal, and a bad parallax pairing raise" do
      assert_raises(ArgumentError) { TestComponent.new(reveal: :words) }
      assert_raises(ArgumentError) { TestComponent.new(stagger: true) }
      assert_raises(ArgumentError) { TestComponent.new(reveal: :scale, parallax: true) }
      assert_raises(ArgumentError) { TestComponent.new(reveal: :fade, stagger: "yes") }
      assert_raises(ArgumentError) { TestComponent.new(reveal: :fade, intensity: :loud) }

      delay = assert_raises(ArgumentError) { TestComponent.new(reveal: :fade, delay: :huge) }
      assert_equal "Invalid delay: huge. Must be :sm, :md, :lg, or a number of milliseconds", delay.message

      duration = assert_raises(ArgumentError) { TestComponent.new(reveal: :fade, duration: 12.5) }
      assert_match(/Invalid duration: 12\.5/, duration.message)

      stagger = assert_raises(ArgumentError) { TestComponent.new(reveal: :fade, stagger: -1) }
      assert_equal "Invalid stagger: -1. Must be true, false, :sm, :md, :lg, or a number of milliseconds", stagger.message
    end

    test "allows all safe HTML attributes" do
      render_inline(TestComponent.new(
        id: "test",
        class: "test-class",
        title: "Test Title",
        style: "color: red;",
        tabindex: "0"
      ))

      assert_selector "div#test.test-class[title='Test Title'][style='color: red;'][tabindex='0']"
    end
  end
end
