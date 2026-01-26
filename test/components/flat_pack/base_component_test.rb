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
