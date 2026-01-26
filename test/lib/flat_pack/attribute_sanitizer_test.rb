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
        attrs = {id: "test", attr.to_sym => "malicious"}
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
