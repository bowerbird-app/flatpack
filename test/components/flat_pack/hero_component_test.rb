# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Hero
    class ComponentTest < ViewComponent::TestCase
      # 1. Renders :centered with headline and description in output
      def test_renders_centered_with_headline_and_description
        render_inline(Component.new(
          variant: :centered,
          headline: "Welcome to FlatPack",
          description: "Build beautiful UIs fast."
        ))

        assert_selector "h1", text: "Welcome to FlatPack"
        assert_selector "p", text: "Build beautiful UIs fast."
      end

      # 2. Renders :centered_image and output includes background-image style attribute
      def test_renders_centered_image_with_background_style
        render_inline(Component.new(
          variant: :centered_image,
          headline: "Hero with background",
          background_image_url: "https://placehold.co/1600x800"
        ))

        assert_selector "[style*='background-image']"
        assert_selector "h1", text: "Hero with background"
      end

      # 3. Renders :screenshot and output includes <img> with correct alt text
      def test_renders_screenshot_with_image
        render_inline(Component.new(
          variant: :screenshot,
          headline: "App Screenshot",
          image_url: "https://placehold.co/1200x700",
          image_alt: "Application dashboard"
        ))

        assert_selector "img[alt='Application dashboard']"
      end

      # 4. Renders :split_image and output includes lg:grid-cols-2 grid class
      def test_renders_split_image_with_grid_class
        render_inline(Component.new(
          variant: :split_image,
          headline: "Split layout"
        ))

        assert_selector ".lg\\:grid-cols-2"
      end

      # 5. Renders :angled_image and output includes clip-path element
      def test_renders_angled_image_with_clip_path
        render_inline(Component.new(
          variant: :angled_image,
          headline: "Angled hero",
          image_url: "https://placehold.co/800x600"
        ))

        assert_selector "[style*='clip-path']"
      end

      # 6. Renders :image_tiles and output contains all tile <img> tags
      def test_renders_image_tiles_with_all_tiles
        tiles = [
          {url: "https://placehold.co/400x400", alt: "Tile 1"},
          {url: "https://placehold.co/400x400", alt: "Tile 2"},
          {url: "https://placehold.co/400x400", alt: "Tile 3"},
          {url: "https://placehold.co/400x400", alt: "Tile 4"}
        ]

        render_inline(Component.new(variant: :image_tiles, headline: "Tiles", tiles: tiles))

        assert_selector "img[alt='Tile 1']"
        assert_selector "img[alt='Tile 2']"
        assert_selector "img[alt='Tile 3']"
        assert_selector "img[alt='Tile 4']"
      end

      # 7. Renders :offset_image and output includes lg:-mr-24 offset class
      def test_renders_offset_image_with_negative_margin_class
        render_inline(Component.new(
          variant: :offset_image,
          headline: "Offset image hero",
          image_url: "https://placehold.co/800x600"
        ))

        assert_selector ".lg\\:-mr-24"
      end

      # 8. actions slot content appears in output
      def test_renders_actions_slot_content
        render_inline(Component.new(variant: :centered, headline: "CTA")) do |c|
          c.actions { "Get started now" }
        end

        assert_text "Get started now"
      end

      # 9. badge slot content appears in output
      def test_renders_badge_slot_content
        render_inline(Component.new(variant: :centered, headline: "Badged")) do |c|
          c.badge { "New feature" }
        end

        assert_text "New feature"
      end

      # 10. Unknown variant raises ArgumentError
      def test_raises_argument_error_for_unknown_variant
        assert_raises(ArgumentError) do
          Component.new(variant: :invalid_variant)
        end
      end

      # 11. javascript: URL in image_url results in a safe value (no JS in output)
      def test_sanitizes_javascript_url_in_image_url
        render_inline(Component.new(
          variant: :screenshot,
          headline: "Safe hero",
          image_url: "javascript:alert('xss')",
          image_alt: "Malicious image"
        ))

        assert_no_selector "img[src^='javascript']"
        rendered_html = page.native.to_s
        assert_no_match(/javascript:alert/, rendered_html)
      end

      # 12. Does not expose with_ slot aliases
      def test_does_not_expose_with_slot_aliases
        component = Component.new(variant: :centered)

        assert_not_respond_to component, :with_actions_slot
        assert_not_respond_to component, :with_badge_slot
      end
    end
  end
end
