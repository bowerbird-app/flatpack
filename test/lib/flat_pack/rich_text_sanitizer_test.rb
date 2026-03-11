# frozen_string_literal: true

require "test_helper"

module FlatPack
  class RichTextSanitizerTest < ActiveSupport::TestCase
    test "strips script tags" do
      html = "<p>Hello</p><script>alert('xss')</script>"
      result = RichTextSanitizer.sanitize(html)
      assert_includes result, "<p>Hello</p>"
      refute_includes result, "<script>"
    end

    test "strips onclick event handlers" do
      html = '<p onclick="alert(1)">Click</p>'
      result = RichTextSanitizer.sanitize(html)
      refute_includes result, "onclick"
      assert_includes result, "<p>"
    end

    test "strips onerror event handlers" do
      html = '<img src="x" onerror="alert(1)">'
      result = RichTextSanitizer.sanitize(html)
      refute_includes result, "onerror"
    end

    test "preserves data-type on ul for TaskList" do
      html = '<ul data-type="taskList"><li>item</li></ul>'
      result = RichTextSanitizer.sanitize(html)
      assert_includes result, 'data-type="taskList"'
    end

    test "preserves data-checked on li for TaskItem" do
      html = '<ul><li data-checked="true">Done</li></ul>'
      result = RichTextSanitizer.sanitize(html)
      assert_includes result, 'data-checked="true"'
    end

    test "preserves data-color on mark for Highlight" do
      html = '<mark data-color="#ff0">highlight</mark>'
      result = RichTextSanitizer.sanitize(html)
      assert_includes result, 'data-color="#ff0"'
    end

    test "preserves colspan and rowspan on td" do
      html = '<table><tbody><tr><td colspan="2" rowspan="1">cell</td></tr></tbody></table>'
      result = RichTextSanitizer.sanitize(html)
      assert_includes result, 'colspan="2"'
      assert_includes result, 'rowspan="1"'
    end

    test "preserves data-colwidth on th" do
      html = '<table><thead><tr><th data-colwidth="120">Header</th></tr></thead></table>'
      result = RichTextSanitizer.sanitize(html)
      assert_includes result, 'data-colwidth="120"'
    end

    test "preserves class on code for CodeBlockLowlight" do
      html = '<pre><code class="language-ruby">puts "hi"</code></pre>'
      result = RichTextSanitizer.sanitize(html)
      assert_includes result, 'class="language-ruby"'
    end

    test "preserves style on p for TextAlign" do
      html = '<p style="text-align: center">centered</p>'
      result = RichTextSanitizer.sanitize(html)
      # Rails normalises CSS whitespace; check the property name is present
      assert_match(/style="text-align/, result)
      assert_includes result, "center"
    end

    test "strips unknown data attributes not in allowlist" do
      html = '<p data-unknown="bad">text</p>'
      result = RichTextSanitizer.sanitize(html)
      refute_includes result, "data-unknown"
      assert_includes result, "<p>"
    end

    test "returns empty string for nil-like blank input" do
      assert_equal "", RichTextSanitizer.sanitize("").strip
    end

    test "preserves allowed inline elements" do
      html = "<p><strong>bold</strong> <em>italic</em> <u>under</u></p>"
      result = RichTextSanitizer.sanitize(html)
      assert_includes result, "<strong>bold</strong>"
      assert_includes result, "<em>italic</em>"
      assert_includes result, "<u>under</u>"
    end
  end
end
