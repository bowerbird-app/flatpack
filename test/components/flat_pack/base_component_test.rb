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

    test "words, a missing reveal, and a bad parallax pairing raise" do
      assert_raises(ArgumentError) { TestComponent.new(reveal: :words) }
      assert_raises(ArgumentError) { TestComponent.new(stagger: true) }
      assert_raises(ArgumentError) { TestComponent.new(reveal: :scale, parallax: true) }
      assert_raises(ArgumentError) { TestComponent.new(reveal: :fade, stagger: "yes") }
      assert_raises(ArgumentError) { TestComponent.new(reveal: :fade, intensity: :loud) }
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
