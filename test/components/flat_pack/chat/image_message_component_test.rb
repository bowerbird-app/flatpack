# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Chat
    module ImageMessage
      class ComponentTest < ViewComponent::TestCase
        def test_renders_image_message
          render_inline(Component.new(
            direction: :incoming,
            image_name: "preview.png",
            thumbnail_url: "https://example.com/preview.png",
            timestamp: "10:24 AM",
            body: "Image preview"
          ))

          assert_text "Image preview"
          assert_selector "section[data-controller='flat-pack--carousel']"
          assert_selector "img[alt='preview.png']"
          assert_selector "button[aria-label='Expand image']"
          assert_no_selector "div.px-4.py-2 img"
          assert_text "10:24 AM"
        end

        def test_supports_reveal_actions_for_incoming
          render_inline(Component.new(
            direction: :incoming,
            image_name: "preview.png",
            thumbnail_url: "https://example.com/preview.png",
            timestamp: "10:24 AM",
            reveal_actions: true,
            body: "Tap to reveal"
          ))

          assert_includes rendered_content, "flat-pack--chat-message-actions"
          assert_includes rendered_content, "data-flat-pack--chat-message-actions-side-value=\"left\""
        end
      end
    end
  end
end
