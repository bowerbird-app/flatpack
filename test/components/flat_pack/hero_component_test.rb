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
          description: "Overlay copy on the image.",
          background_image_url: "https://placehold.co/1600x800"
        ))

        assert_selector "[style*='background-image']"
        assert_selector "h1", text: "Hero with background"
        html = page.native.to_html
        assert_includes html, "fp-hero-overlay"
        assert_includes html, "bg-[var(--hero-overlay-background-color)]"
        assert_includes html, "text-[var(--hero-overlay-text-color)]"
        assert_includes html, "text-[var(--hero-overlay-muted-text-color)]"
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
      def test_renders_slot_content
        render_inline(Component.new(variant: :centered, headline: "CTA")) do |c|
          c.slot { "Get started now" }
        end

        assert_text "Get started now"
      end

      def test_actions_is_deprecated_in_favor_of_slot
        _stdout, stderr = capture_io do
          render_inline(Component.new(variant: :centered, headline: "CTA")) do |c|
            c.actions { "Get started now" }
          end
        end

        assert_includes stderr, "FlatPack::Hero::Component#actions is deprecated"
        assert_includes stderr, "#slot"
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

      def test_tagline_is_sentence_case_not_tracked_out_caps
        render_inline(Component.new(
          variant: :centered,
          tagline: "Introducing FlatPack",
          headline: "Build the desk",
          description: "A product kit, not a landing template."
        ))

        html = page.native.to_html
        refute_includes html, "uppercase"
        refute_includes html, "tracking-widest"
        refute_includes html, "lg:text-6xl"
        refute_includes html, "leading-tight"
        refute_includes html, "text-lg"
        assert_includes html, "--hero-description-size"
        assert_includes html, "--hero-headline-size"
        assert_includes html, "fp-text-balance"
        assert_includes html, "fp-text-pretty"
        assert_includes html, "--text-4xl"
        assert_selector "p", text: "Introducing FlatPack"
      end

      def test_centered_image_overlay_tagline_uses_overlay_muted_color
        render_inline(Component.new(
          variant: :centered_image,
          tagline: "North coast kiln",
          headline: "Hero with background",
          background_image_url: "https://placehold.co/1600x800"
        ))

        html = page.native.to_html
        assert_includes html, "text-[var(--hero-overlay-muted-text-color)]"
        refute_match(/text-sm font-medium text-\[var\(--surface-muted-content-color\)\]/, html)
      end

      def test_centered_image_defaults_to_centered_copy
        render_inline(Component.new(
          variant: :centered_image,
          headline: "Hero with background",
          description: "Overlay copy on the image.",
          background_image_url: "https://placehold.co/1600x800"
        )) do |c|
          c.slot { "Start" }
        end

        html = page.native.to_html
        assert_includes html, "flex items-start justify-center"
        assert_includes html, "text-center"
        assert_includes html, "leading-tight"
        assert_includes html, "--text-2xl"
        assert_includes html, "fp-hero-overlay"
        refute_includes html, "min-h-[560px]"
        refute_includes html, "flex items-center"
        assert_match(/<h1[^>]*fp-text-balance/, html)
        assert_match(/<p[^>]*--text-2xl[^>]*fp-text-pretty/, html)
        refute_includes html, "text-left"
        refute_includes html, "justify-start"
        refute_includes html, "max-w-2xl"
        refute_includes html, "fp-hero-overlay-on-light"
        assert_includes html, "justify-center"
      end

      def test_centered_image_left_docks_copy_below_the_nav
        render_inline(Component.new(
          variant: :centered_image,
          align: :left,
          headline: "Hero with background",
          description: "Overlay copy on the image.",
          background_image_url: "https://placehold.co/1600x800"
        )) do |c|
          c.slot { "Start" }
        end

        html = page.native.to_html
        assert_includes html, "flex items-start justify-start"
        assert_includes html, "text-left"
        assert_includes html, "max-w-2xl"
        assert_includes html, "lg:ps-16"
        assert_includes html, "justify-start"
        assert_includes html, "hero-overlay-left-background"
        assert_includes html, "leading-tight"
        assert_includes html, "--text-2xl"
        assert_match(/<h1[^>]*fp-text-pretty/, html)
        refute_match(/<h1[^>]*fp-text-balance/, html)
        assert_match(/<p[^>]*--text-2xl[^>]*fp-text-pretty/, html)
        refute_includes html, "bg-[var(--hero-overlay-background-color)]"
        refute_match(/relative z-10 text-center/, html)
        refute_includes html, "flex items-center"
        refute_includes html, "flex items-start justify-center"
      end

      def test_omitted_align_matches_explicit_center_on_centered_image
        omitted = render_inline(Component.new(
          variant: :centered_image,
          headline: "Same copy"
        )).to_html

        explicit = render_inline(Component.new(
          variant: :centered_image,
          align: :center,
          headline: "Same copy"
        )).to_html

        assert_equal omitted, explicit
      end

      def test_centered_image_on_light_paints_light_overlay
        render_inline(Component.new(
          variant: :centered_image,
          on: :light,
          headline: "Hero with background",
          background_image_url: "https://placehold.co/1600x800"
        )) do |c|
          c.slot { "Start" }
        end

        html = page.native.to_html
        assert_includes html, "fp-hero-overlay-on-light"
        assert_includes html, "fp-hero-overlay"
      end

      def test_omitted_on_matches_explicit_dark_on_centered_image
        omitted = render_inline(Component.new(
          variant: :centered_image,
          headline: "Same copy"
        )).to_html

        explicit = render_inline(Component.new(
          variant: :centered_image,
          on: :dark,
          headline: "Same copy"
        )).to_html

        assert_equal omitted, explicit
      end

      def test_raises_argument_error_for_unknown_on
        error = assert_raises(ArgumentError) do
          Component.new(variant: :centered_image, on: :sunset)
        end

        assert_includes error.message, "Invalid on: sunset"
        assert_includes error.message, "dark"
        assert_includes error.message, "light"
      end

      def test_host_style_tokens_merge_with_background
        render_inline(Component.new(
          variant: :centered,
          headline: "Tinted",
          background: "var(--surface-muted-background-color)",
          style: "--hero-overlay-text-color: oklch(0.2 0.05 80)"
        ))

        html = page.native.to_html
        assert_includes html, "--hero-overlay-text-color: oklch(0.2 0.05 80)"
        assert_includes html, "background: var(--surface-muted-background-color)"
      end

      def test_centered_image_accepts_viewport_min_height_token
        render_inline(Component.new(
          variant: :centered_image,
          headline: "Fill the first viewport",
          style: "--hero-overlay-min-height: 100dvh"
        ))

        html = page.native.to_html
        assert_includes html, "--hero-overlay-min-height: 100dvh"
        refute_includes html, "min-h-[560px]"
      end

      def test_raises_argument_error_for_unknown_align
        error = assert_raises(ArgumentError) do
          Component.new(variant: :centered_image, align: :right)
        end

        assert_includes error.message, "Invalid align: right"
        assert_includes error.message, "left"
        assert_includes error.message, "center"
      end

      def test_split_image_ignores_align
        render_inline(Component.new(
          variant: :split_image,
          align: :center,
          headline: "Split layout"
        ))

        html = page.native.to_html
        assert_selector ".lg\\:grid-cols-2"
        refute_includes html, "text-center"
      end

      def test_split_image_ignores_on
        render_inline(Component.new(
          variant: :split_image,
          on: :light,
          headline: "Split layout"
        ))

        html = page.native.to_html
        refute_includes html, "fp-hero-overlay-on-light"
        refute_includes html, "fp-hero-overlay"
      end

      def test_centered_left_aligns_copy_and_actions
        render_inline(Component.new(
          variant: :centered,
          align: :left,
          headline: "Left copy"
        )) do |c|
          c.slot { "Start" }
        end

        html = page.native.to_html
        assert_includes html, "text-left"
        assert_includes html, "mr-auto"
        assert_includes html, "justify-start"
        refute_includes html, "text-center"
      end

      def test_screenshot_left_aligns_copy_and_keeps_image_centered
        render_inline(Component.new(
          variant: :screenshot,
          align: :left,
          headline: "App Screenshot",
          image_url: "https://placehold.co/1200x700",
          image_alt: "Application dashboard"
        )) do |c|
          c.slot { "Start" }
        end

        html = page.native.to_html
        assert_includes html, "text-left"
        assert_includes html, "mr-auto"
        assert_includes html, "justify-start"
        assert_includes html, "max-w-5xl mx-auto"
        refute_match(/max-w-2xl mx-auto text-center/, html)
      end
    end
  end
end
