# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Chat
    module Images
      class ComponentTest < ViewComponent::TestCase
        def test_renders_chat_images_with_carousel_hash
          render_inline(Component.new(
            direction: :incoming,
            state: :sent,
            timestamp: "10:24 AM",
            body: "Image preview",
            carousel: {
              slides: [
                {
                  type: :image,
                  src: "https://example.com/preview.png",
                  thumb_src: "https://example.com/preview-thumb.png",
                  lightbox: true
                }
              ],
              show_controls: true,
              show_indicators: false,
              show_thumbs: false,
              show_captions: false
            }
          ))

          assert_text "Image preview"
          assert_selector "section[data-controller='flat-pack--carousel']"
          assert_selector "img[alt='Slide 1']"
          assert_selector "button[aria-label='Expand image']"
          assert_text "10:24 AM"
        end

        def test_normalizes_attachment_like_hashes_into_carousel_slides
          render_inline(Component.new(
            direction: :outgoing,
            body: "Sharing a quick preview",
            carousel: {
              slides: [
                {
                  thumbnail_url: "https://example.com/preview-thumb.png",
                  href: "https://example.com/preview.png"
                }
              ]
            }
          ))

          assert_selector "section[data-controller='flat-pack--carousel']"
          assert_selector "img[alt='Slide 1'][src='https://example.com/preview.png']"
          assert_no_selector "button[aria-label='Show slide 1']"
          assert_includes rendered_content, 'data-lightbox-enabled="true"'
        end

        def test_requires_at_least_one_valid_slide
          assert_raises ArgumentError do
            Component.new(carousel: {slides: [{type: :image}]})
          end
        end
      end
    end
  end
end
