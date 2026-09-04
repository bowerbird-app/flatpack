# frozen_string_literal: true

require "test_helper"

module FlatPack
  class AttributeSanitizerTest < ActiveSupport::TestCase
    test "sanitize_url allows http URLs" do
      url = "http://example.com"
      assert_equal url, AttributeSanitizer.sanitize_url(url)
    end

    test "sanitize_url allows https URLs" do
      url = "https://example.com"
      assert_equal url, AttributeSanitizer.sanitize_url(url)
    end

    test "sanitize_url allows mailto URLs" do
      url = "mailto:test@example.com"
      assert_equal url, AttributeSanitizer.sanitize_url(url)
    end

    test "sanitize_url allows tel URLs" do
      url = "tel:+1234567890"
      assert_equal url, AttributeSanitizer.sanitize_url(url)
    end

    test "sanitize_url allows relative URLs starting with /" do
      url = "/path/to/page"
      assert_equal url, AttributeSanitizer.sanitize_url(url)
    end

    test "sanitize_url allows relative URLs starting with ." do
      url = "./path/to/page"
      assert_equal url, AttributeSanitizer.sanitize_url(url)
    end

    test "sanitize_url allows fragment identifiers" do
      url = "#section"
      assert_equal url, AttributeSanitizer.sanitize_url(url)
    end

    test "sanitize_url blocks javascript: protocol" do
      url = "javascript:alert('xss')"
      assert_nil AttributeSanitizer.sanitize_url(url)
    end

    test "sanitize_url blocks javascript: protocol with whitespace" do
      url = "  javascript:alert('xss')"
      assert_nil AttributeSanitizer.sanitize_url(url)
    end

    test "sanitize_url blocks javascript: protocol case insensitive" do
      url = "JaVaScRiPt:alert('xss')"
      assert_nil AttributeSanitizer.sanitize_url(url)
    end

    test "sanitize_url blocks data: URLs" do
      url = "data:text/html,<script>alert('xss')</script>"
      assert_nil AttributeSanitizer.sanitize_url(url)
    end

    test "sanitize_url blocks vbscript: protocol" do
      url = "vbscript:msgbox('xss')"
      assert_nil AttributeSanitizer.sanitize_url(url)
    end

    test "sanitize_url returns nil for blank URLs" do
      assert_nil AttributeSanitizer.sanitize_url("")
      assert_nil AttributeSanitizer.sanitize_url("  ")
      assert_nil AttributeSanitizer.sanitize_url(nil)
    end

    test "sanitize_url returns nil for unknown protocols" do
      url = "ftp://example.com"
      assert_nil AttributeSanitizer.sanitize_url(url)
    end

    test "sanitize_url blocks HTML entity encoded colons" do
      url = "javascript&colon;alert('xss')"
      assert_nil AttributeSanitizer.sanitize_url(url)
    end

    test "sanitize_url blocks numeric HTML entities" do
      url = "javascript&#58;alert('xss')"
      assert_nil AttributeSanitizer.sanitize_url(url)
    end

    test "sanitize_url blocks hex HTML entities" do
      url = "javascript&#x3a;alert('xss')"
      assert_nil AttributeSanitizer.sanitize_url(url)
    end

    test "sanitize_url allows URLs without protocol" do
      url = "example.com/path"
      assert_equal url, AttributeSanitizer.sanitize_url(url)
    end

    test "sanitize_attributes removes onclick" do
      attrs = {id: "btn", onclick: "alert('xss')"}
      sanitized = AttributeSanitizer.sanitize_attributes(attrs)
      assert_equal({id: "btn"}, sanitized)
    end

    test "sanitize_attributes removes multiple dangerous attributes" do
      attrs = {
        id: "btn",
        onclick: "alert('xss')",
        onmouseover: "alert('xss')",
        onload: "alert('xss')"
      }
      sanitized = AttributeSanitizer.sanitize_attributes(attrs)
      assert_equal({id: "btn"}, sanitized)
    end

    test "sanitize_attributes removes all event handlers" do
      dangerous_attrs = %w[
        onclick onload onerror onmouseover onmouseout onmousemove
        onmouseenter onmouseleave onfocus onblur onchange onsubmit
        onkeydown onkeyup onkeypress ondblclick oncontextmenu
        onwheel ondrag ondrop onscroll oncopy oncut onpaste
      ]

      dangerous_attrs.each do |attr|
        attrs = {:id => "test", attr.to_sym => "malicious"}
        sanitized = AttributeSanitizer.sanitize_attributes(attrs)
        assert_equal({id: "test"}, sanitized, "Failed to remove #{attr}")
      end
    end

    test "sanitize_attributes is case insensitive" do
      attrs = {id: "btn", OnClick: "alert('xss')"}
      sanitized = AttributeSanitizer.sanitize_attributes(attrs)
      assert_equal({id: "btn"}, sanitized)
    end

    test "sanitize_attributes preserves safe attributes" do
      attrs = {
        id: "btn",
        class: "button",
        data: {action: "click"},
        aria: {label: "Close"}
      }
      sanitized = AttributeSanitizer.sanitize_attributes(attrs)
      assert_equal attrs, sanitized
    end

    test "sanitize_attributes handles blank input" do
      assert_equal({}, AttributeSanitizer.sanitize_attributes(nil))
      assert_equal({}, AttributeSanitizer.sanitize_attributes({}))
    end

    test "sanitize_css_color allows supported color formats" do
      assert_equal "#0f172a", AttributeSanitizer.sanitize_css_color("#0f172a")
      assert_equal "oklch(0.72 0.16 240)", AttributeSanitizer.sanitize_css_color("oklch(0.72 0.16 240)")
      assert_equal "var(--color-primary)", AttributeSanitizer.sanitize_css_color("var(--color-primary)")
    end

    test "sanitize_css_color rejects unsafe values" do
      assert_nil AttributeSanitizer.sanitize_css_color("#0f172a; background: url(javascript:alert('xss'))")
      assert_nil AttributeSanitizer.sanitize_css_color("expression(alert('xss'))")
    end

    test "sanitize_css_font_family allows supported font stacks" do
      assert_equal "ui-sans-serif", AttributeSanitizer.sanitize_css_font_family("ui-sans-serif")
      assert_equal "Georgia, serif", AttributeSanitizer.sanitize_css_font_family("Georgia, serif")
      assert_equal '"Comic Sans MS", cursive', AttributeSanitizer.sanitize_css_font_family('"Comic Sans MS", cursive')
      assert_equal "var(--font-body)", AttributeSanitizer.sanitize_css_font_family("var(--font-body)")
    end

    test "sanitize_css_font_family rejects unsafe values" do
      assert_nil AttributeSanitizer.sanitize_css_font_family("ui-sans-serif; background: url(javascript:alert('xss'))")
      assert_nil AttributeSanitizer.sanitize_css_font_family("expression(alert('xss'))")
      assert_nil AttributeSanitizer.sanitize_css_font_family("url(https://evil.example/font.woff)")
    end

    test "sanitize_css_grid_track allows supported track sizes" do
      assert_equal "16rem", AttributeSanitizer.sanitize_css_grid_track("16rem")
      assert_equal "280px", AttributeSanitizer.sanitize_css_grid_track("280px")
      assert_equal "auto", AttributeSanitizer.sanitize_css_grid_track("auto")
      assert_equal "max-content", AttributeSanitizer.sanitize_css_grid_track("max-content")
      assert_equal "var(--chat-sidebar-width)", AttributeSanitizer.sanitize_css_grid_track("var(--chat-sidebar-width)")
      assert_equal "minmax(0, 16rem)", AttributeSanitizer.sanitize_css_grid_track("minmax(0, 16rem)")
      assert_equal "minmax(12rem, 30%)", AttributeSanitizer.sanitize_css_grid_track("minmax(12rem, 30%)")
      assert_equal "clamp(12rem, 25%, 20rem)", AttributeSanitizer.sanitize_css_grid_track("clamp(12rem, 25%, 20rem)")
      assert_equal "fit-content(20rem)", AttributeSanitizer.sanitize_css_grid_track("fit-content(20rem)")
    end

    test "sanitize_css_grid_track rejects unsafe or unsupported values" do
      assert_nil AttributeSanitizer.sanitize_css_grid_track(nil)
      assert_nil AttributeSanitizer.sanitize_css_grid_track("")
      assert_nil AttributeSanitizer.sanitize_css_grid_track("16rem; background: url(https://evil.example/x.png)")
      assert_nil AttributeSanitizer.sanitize_css_grid_track("expression(alert('xss'))")
      assert_nil AttributeSanitizer.sanitize_css_grid_track("16rem 1fr")
      assert_nil AttributeSanitizer.sanitize_css_grid_track("repeat(2, 1fr)")
    end

    test "validate_href! returns sanitized href for safe URLs" do
      url = "https://example.com"
      assert_equal url, AttributeSanitizer.validate_href!(url)
    end

    test "validate_href! raises error for javascript URLs" do
      error = assert_raises(ArgumentError) do
        AttributeSanitizer.validate_href!("javascript:alert('xss')")
      end
      assert_match(/Unsafe URL detected/, error.message)
    end

    test "validate_href! raises error for data URLs" do
      error = assert_raises(ArgumentError) do
        AttributeSanitizer.validate_href!("data:text/html,<script>alert('xss')</script>")
      end
      assert_match(/Unsafe URL detected/, error.message)
    end

    test "validate_href! raises error for unknown protocols" do
      error = assert_raises(ArgumentError) do
        AttributeSanitizer.validate_href!("ftp://example.com")
      end
      assert_match(/Unsafe URL detected/, error.message)
    end
  end
end
