# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Media
    class ComponentTest < ViewComponent::TestCase
      def test_renders_a_lazy_image_with_reserved_ratio
        render_inline(Component.new(src: "https://example.com/harbour.jpg", alt: "Harbour at dusk", width: 1120, height: 1400))

        assert_selector "div.fp-overlay.w-full"
        assert_includes page.native.to_html, "group/media"
        assert_selector "img.fp-media__image[src='https://example.com/harbour.jpg'][alt='Harbour at dusk']"
        assert_selector "img[width='1120'][height='1400'][loading='lazy'][decoding='async']"
        html = page.native.to_html
        assert_includes html, "aspect-ratio: 1120 / 1400"
        assert_selector "div.fp-overlay > div.contents > div.fp-media__frame > img.fp-media__image"
        refute_includes page.find("img.fp-media__image")[:class], "rounded-[var(--media-radius)]"
        refute_includes page.find("img.fp-media__image")[:class], "outline"
        refute_includes page.find("img.fp-media__image")[:class], "bg-[var(--surface-muted-background-color)]"
        refute_selector "a"
      end

      def test_forwards_items_to_overlay
        render_inline(Component.new(src: "/masonry/harbour.svg", alt: "Harbour at dusk", width: "1120", height: "1400")) do |media|
          media.with_item(placement: :bottom_left, inset: :sm) { "JPG · 1120×1400 · 4:5" }
          media.with_item(placement: :top_right, inset: :lg) { "Save" }
        end

        assert_selector "[data-fp-placement='bottom_left'][data-fp-inset='sm']", text: "JPG · 1120×1400 · 4:5"
        assert_selector "[data-fp-placement='top_right'][data-fp-inset='lg']", text: "Save"
        assert_includes page.find("[data-fp-inset='sm']")[:class], "bottom-[var(--fp-overlay-item-inset)]"
        assert_includes page.find("[data-fp-inset='lg']")[:class], "top-[var(--fp-overlay-item-inset)]"
      end

      def test_item_keeps_a_badge
        render_inline(Component.new(src: "/masonry/harbour.svg", alt: "Harbour at dusk", width: 1120, height: 1400)) do |media|
          media.with_item(placement: :bottom_left, inset: :sm) do
            vc_test_controller.view_context.render(
              FlatPack::Badge::Component.new(text: "JPG · 1120×1400 · 4:5", size: :xs)
            )
          end
        end

        badge = page.find("[data-fp-placement='bottom_left']", text: "JPG · 1120×1400 · 4:5")
        assert_includes badge.native.to_html, "rounded-[var(--badge-radius)]"
      end

      def test_accepts_relative_src_and_empty_alt
        render_inline(Component.new(src: "/masonry/studio.svg", alt: "", width: 80, height: 80))

        assert_selector "img[alt=''][src='/masonry/studio.svg']"
      end

      def test_merges_root_attributes
        render_inline(Component.new(src: "/masonry/studio.svg", alt: "Studio", width: 80, height: 80, id: "studio-still", class: "mt-4", data: {testid: "still"}))

        assert_selector "div#studio-still.fp-overlay.w-full.mt-4[data-testid='still']"
      end

      def test_rejects_a_link_or_caption_argument
        error = assert_raises(ArgumentError) do
          Component.new(src: "/a.jpg", alt: "A", width: 10, height: 10, href: "/a")
        end
        assert_match(/href or caption/, error.message)

        error = assert_raises(ArgumentError) do
          Component.new(src: "/a.jpg", alt: "A", width: 10, height: 10, caption: "Harbour")
        end
        assert_match(/href or caption/, error.message)
      end

      def test_rejects_unsafe_src
        error = assert_raises(ArgumentError) do
          Component.new(src: "javascript:alert(1)", alt: "Bad", width: 100, height: 100)
        end
        assert_match(/Invalid src/, error.message)
      end

      def test_rejects_non_string_alt
        error = assert_raises(ArgumentError) do
          Component.new(src: "https://example.com/a.jpg", alt: nil, width: 100, height: 100)
        end
        assert_match(/alt must be a String/, error.message)
      end

      def test_rejects_non_positive_dimensions
        error = assert_raises(ArgumentError) do
          Component.new(src: "https://example.com/a.jpg", alt: "A", width: 0, height: 100)
        end
        assert_match(/width must be a positive integer/, error.message)

        error = assert_raises(ArgumentError) do
          Component.new(src: "https://example.com/a.jpg", alt: "A", width: 100, height: -4)
        end
        assert_match(/height must be a positive integer/, error.message)
      end

      def test_card_inner_radius_is_on_the_frame
        render_inline(Component.new(src: "/masonry/harbour.svg", alt: "Harbour", width: 80, height: 80, radius: :card_inner))

        assert_selector "div.fp-media__frame.fp-card-inner-radius"
        refute_includes page.find("div.fp-media__frame")[:class], "rounded-[var(--media-radius)]"
        refute_includes page.find("img.fp-media__image")[:class], "fp-card-inner-radius"
      end

      def test_card_inner_radius_accepts_a_string
        render_inline(Component.new(src: "/masonry/harbour.svg", alt: "Harbour", width: 80, height: 80, radius: "card_inner"))

        assert_selector "div.fp-media__frame.fp-card-inner-radius"
      end

      def test_rejects_an_unknown_radius
        error = assert_raises(ArgumentError) do
          Component.new(src: "/a.jpg", alt: "A", width: 10, height: 10, radius: :media)
        end
        assert_match(/:card_inner/, error.message)
      end

      def test_overlay_item_stays_outside_the_frame
        render_inline(Component.new(src: "/masonry/harbour.svg", alt: "Harbour", width: 80, height: 80, radius: :card_inner)) do |media|
          media.with_item(placement: :top_left, inset: :sm) { "Save" }
        end

        assert_selector "div.fp-media__frame.fp-card-inner-radius"
        assert_selector "[data-fp-placement='top_left']", text: "Save"
        refute_selector "div.fp-media__frame [data-fp-placement='top_left']"
      end

      def test_rejects_unknown_placement
        error = assert_raises(ArgumentError) do
          render_inline(Component.new(src: "/a.jpg", alt: "A", width: 40, height: 40)) do |media|
            media.with_item(placement: :diagonal) { "No" }
          end
        end
        assert_match(/Invalid placement/, error.message)
      end
    end
  end
end
