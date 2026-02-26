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
          assert_selector "img[alt='preview.png']"
          assert_text "10:24 AM"
        end
      end
    end
  end
end
