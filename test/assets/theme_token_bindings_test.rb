# frozen_string_literal: true

require "test_helper"

module FlatPack
  class ThemeTokenBindingsTest < ActiveSupport::TestCase
    def rich_text_css
      FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/rich_text.css").read
    end

    def application_css
      FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read
    end

    def content_editor_css
      FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/content_editor.css").read
    end

    test "rich text focus and selection chrome use ring/primary tokens without blue oklch fallbacks" do
      css = rich_text_css

      assert_includes css, "box-shadow: 0 0 0 2px inset var(--color-ring);"
      assert_includes css, "background: color-mix(in oklab, var(--color-primary) 15%, transparent);"
      assert_includes css, "outline: 2px solid color-mix(in oklab, var(--color-ring) 40%, transparent);"
      assert_includes css, "box-shadow: 0 0 0 2px color-mix(in oklab, var(--color-primary) 15%, transparent);"
      refute_includes css, "oklch(0.52 0.26 250"
      refute_includes css, "#2563eb"
    end

    test "donut chart tooltips bind to tooltip/surface tokens instead of frozen white" do
      css = application_css

      assert_includes css, "background: var(--tooltip-background-color, var(--surface-background-color)) !important;"
      assert_includes css, "color: var(--tooltip-text-color, var(--surface-content-color)) !important;"
      refute_match(/\[data-flat-pack--chart-type-value="donut"\][^{]*\{[^}]*background:\s*#fff/m, css)
      refute_includes css, "background: #fff !important;"
    end

    test "rich text and content editor radius fallbacks match the kit scale" do
      [rich_text_css, content_editor_css].each do |css|
        assert_includes css, "var(--radius-md, 1rem)"
        assert_includes css, "var(--radius-sm, 0.75rem)"
        refute_includes css, "var(--radius-md, 0.375rem)"
        refute_includes css, "var(--radius-sm, 0.25rem)"
      end
    end

    test "content editor article body is 1.125rem with em headings" do
      css = content_editor_css

      assert_includes css, "Unlayered type scale."
      content_roots = css.scan(/\.flat-pack-content-editor-content \{[^}]+\}/m)
      assert content_roots.any? { |block| block.include?("font-size: 1.125rem;") }

      paragraph_block = css[/\.flat-pack-content-editor-content p \{[^}]+\}/m]
      refute_nil paragraph_block, "expected .flat-pack-content-editor-content p rule"
      refute_match(/font-size/, paragraph_block)

      assert_includes css, ".flat-pack-content-editor-content h1 { font-size: 1.875em; }"
      assert_includes css, ".flat-pack-content-editor-content h2 { font-size: 1.5em; }"
      assert_includes css, ".flat-pack-content-editor-content h3 { font-size: 1.25em; }"
      assert_includes css, ".flat-pack-content-editor-content h4 { font-size: 1.125em; }"
      assert_includes css, ".flat-pack-content-editor-content h6 { font-size: 1em; }"

      heading_sizes = css.scan(/\.flat-pack-content-editor-content h[1-6][^{]*\{[^}]*font-size:\s*[^;]+/)
      assert_predicate heading_sizes, :any?
      heading_sizes.each do |declaration|
        refute_match(/rem/, declaration, "heading size should use em, got: #{declaration}")
      end

      pre_blocks = css.scan(/\.flat-pack-content-editor-content pre \{[^}]+\}/m)
      assert pre_blocks.any? { |block| block.include?("font-size: 0.8125em;") }
      refute_match(/\.flat-pack-content-editor-content pre \{[^}]*0\.8125rem/, css)
    end

    test "form rich text keeps a compact ProseMirror root" do
      css = rich_text_css
      prose_block = css.scan(/\.flat-pack-richtext-editor \.ProseMirror \{[^}]+\}/m).find { |block|
        block.include?("min-height: 8rem;")
      }

      refute_nil prose_block, "expected the form ProseMirror content root rule"
      assert_includes prose_block, "font-size: 0.875rem;"
      refute_includes prose_block, "font-size: 1.125rem;"
    end
  end
end
