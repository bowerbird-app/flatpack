# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Backdrop
    class ComponentTest < ViewComponent::TestCase
      def test_renders_host_content_over_the_host_media
        render_inline(Component.new(id: "morning", class: "min-h-96", data: {testid: "wash"})) do |backdrop|
          backdrop.with_media { image_tag.html_safe }
          '<p class="host-copy">Pack the morning</p>'.html_safe
        end

        assert_selector "#morning.fp-backdrop.min-h-96[data-testid='wash']"
        assert_selector ".fp-backdrop > p.host-copy", text: "Pack the morning"
        assert_selector ".fp-backdrop-media img[alt=''][src='/images/hero-packaging.jpg']"
        assert_selector ".fp-backdrop-layers[aria-hidden='true'] .fp-backdrop-tint"
        refute_selector ".fp-backdrop[aria-hidden='true']"
        refute_selector "p.host-copy[aria-hidden]"
      end

      def test_keeps_a_picture_and_a_video_as_the_host_wrote_them
        render_inline(Component.new) do |backdrop|
          backdrop.with_media { picture_and_video.html_safe }
          "On the photo"
        end

        assert_selector ".fp-backdrop-media picture source[srcset='/images/hero-stool.jpg']"
        assert_selector ".fp-backdrop-media picture img[alt='Stool'][src='/images/hero-stool.jpg']"
        assert_selector ".fp-backdrop-media video[src='/videos/packing-sample.mp4']"
        assert_text "On the photo"
      end

      def test_decorative_media_is_hidden_when_there_is_no_content
        component = Component.new
        component.with_media { image_tag.html_safe }
        render_inline(component)

        layer = page.find(".fp-backdrop")
        assert_equal "true", layer["aria-hidden"]
        assert_equal "", layer.find("img")["alt"]
        refute layer.has_selector?("[tabindex]")
        assert_selector ".fp-backdrop-tint"
      end

      def test_without_media_renders_content_and_no_layers
        render_inline(Component.new) { "Just words" }

        assert_text "Just words"
        assert_no_selector ".fp-backdrop-media"
        assert_no_selector ".fp-backdrop-tint"
        assert_no_selector ".fp-backdrop-layers"
        assert_no_selector "[aria-hidden]"
      end

      private

      def image_tag
        '<img src="/images/hero-packaging.jpg" alt="">'
      end

      def picture_and_video
        <<~HTML
          <picture>
            <source srcset="/images/hero-stool.jpg" />
            <img src="/images/hero-stool.jpg" alt="Stool">
          </picture>
          <video src="/videos/packing-sample.mp4"></video>
        HTML
      end
    end
  end
end
