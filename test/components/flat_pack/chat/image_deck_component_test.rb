# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Chat
    module ImageDeck
      class ComponentTest < ViewComponent::TestCase
        def test_renders_overlapping_cards_and_overflow_badge
          render_inline(Component.new(images: sample_images(5), direction: :incoming))

          assert_selector "div[data-flat-pack-chat-image-deck='true'][data-flat-pack-chat-image-deck-direction='incoming']"
          assert_selector "div[data-controller~='flat-pack--chat-image-deck']"
          assert_selector "div[data-action*='mouseenter->flat-pack--chat-image-deck#fanOut']"
          assert_selector "div[data-flat-pack--chat-image-deck-target='card']", count: 3
          assert_selector "div[data-flat-pack--chat-image-deck-target='card'][data-flat-pack-chat-image-deck-index='0']"
          assert_selector "div[data-flat-pack--chat-image-deck-target='card'][data-flat-pack-chat-image-deck-index='1']"
          assert_selector "div[data-flat-pack--chat-image-deck-target='card'][data-flat-pack-chat-image-deck-index='2']"
          assert_text "+2"
        end

        def test_renders_outgoing_alignment
          render_inline(Component.new(images: sample_images(3), direction: :outgoing))

          assert_selector "div[data-flat-pack-chat-image-deck-direction='outgoing'].ml-auto"
          assert_includes rendered_content, "right: 0"
        end

        def test_requires_at_least_one_thumbnail
          assert_raises ArgumentError do
            Component.new(images: [{name: "no-thumb"}])
          end
        end

        private

        def sample_images(count)
          Array.new(count) do |index|
            {
              name: "image-#{index + 1}.png",
              thumbnail_url: "https://picsum.photos/seed/image-#{index + 1}/480/280"
            }
          end
        end
      end
    end
  end
end
