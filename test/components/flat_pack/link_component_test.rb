# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Link
    class ComponentTest < ViewComponent::TestCase
      test "renders link with safe URL" do
        render_inline(Component.new(href: "https://example.com")) { "Click me" }

        assert_selector "a[href='https://example.com']", text: "Click me"
      end

      test "renders link with relative URL" do
        render_inline(Component.new(href: "/path/to/page")) { "Click me" }

        assert_selector "a[href='/path/to/page']", text: "Click me"
      end

      test "renders link with mailto URL" do
        render_inline(Component.new(href: "mailto:test@example.com")) { "Email" }

        assert_selector "a[href='mailto:test@example.com']", text: "Email"
      end

      test "renders link with tel URL" do
        render_inline(Component.new(href: "tel:+1234567890")) { "Call" }

        assert_selector "a[href='tel:+1234567890']", text: "Call"
      end

      test "renders link with target blank and adds security attributes" do
        render_inline(Component.new(href: "https://example.com", target: "_blank")) { "External" }

        assert_selector "a[href='https://example.com'][target='_blank']", text: "External"
        assert_selector "a[rel='noopener noreferrer']"
      end

      test "renders link with method" do
        render_inline(Component.new(href: "/path", method: :delete)) { "Delete" }

        assert_selector "a[href='/path']", text: "Delete"
      end

      test "raises error for javascript URL" do
        error = assert_raises(ArgumentError) do
          Component.new(href: "javascript:alert('xss')")
        end
        assert_match(/Unsafe URL detected/, error.message)
      end

      test "raises error for data URL" do
        error = assert_raises(ArgumentError) do
          Component.new(href: "data:text/html,<script>alert('xss')</script>")
        end
        assert_match(/Unsafe URL detected/, error.message)
      end

      test "raises error for vbscript URL" do
        error = assert_raises(ArgumentError) do
          Component.new(href: "vbscript:msgbox('xss')")
        end
        assert_match(/Unsafe URL detected/, error.message)
      end

      test "raises error for ftp URL" do
        error = assert_raises(ArgumentError) do
          Component.new(href: "ftp://example.com")
        end
        assert_match(/Unsafe URL detected/, error.message)
      end

      test "accepts custom classes" do
        render_inline(Component.new(href: "/path", class: "custom-link")) { "Link" }

        assert_selector "a.custom-link"
      end

      test "accepts data attributes" do
        render_inline(Component.new(href: "/path", data: {action: "click"})) { "Link" }

        assert_selector "a[data-action='click']"
      end

      test "accepts aria attributes" do
        render_inline(Component.new(href: "/path", aria: {label: "Custom label"})) { "Link" }

        assert_selector "a[aria-label='Custom label']"
      end

      test "accepts id attribute" do
        render_inline(Component.new(href: "/path", id: "my-link")) { "Link" }

        assert_selector "a#my-link"
      end
    end
  end
end
