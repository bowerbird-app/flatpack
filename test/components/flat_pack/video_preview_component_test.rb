# frozen_string_literal: true

require "test_helper"

module FlatPack
  module VideoPreview
    class ComponentTest < ViewComponent::TestCase
      def test_keeps_the_player_inside_a_template_until_activation
        render_preview

        html = rendered_content
        live = html.gsub(%r{<template\b[^>]*>.*?</template>}m, "")

        assert_includes html, "<template"
        assert_match(%r{<template\b[^>]*>.*embed\.example/trailer.*</template>}m, html)
        refute_includes live, "<iframe"
        refute_includes live, "<video"
        assert_selector "button[aria-label='Play: Launch trailer']"
        assert_selector "[data-controller='flat-pack--video-preview']"
        assert_selector "[data-flat-pack--video-preview-target='poster']"
        assert_selector "[data-flat-pack--video-preview-target='play']"
      end

      def test_video_tag_stays_inside_the_template
        render_inline(Component.new(label: "Play: Packing the stool")) do |preview|
          preview.with_media { %(<img src="/images/hero-stool.jpg" alt="">).html_safe }
          preview.with_player { %(<video src="/videos/packing-sample.mp4" controls></video>).html_safe }
        end

        html = rendered_content
        live = html.gsub(%r{<template\b[^>]*>.*?</template>}m, "")

        assert_match(%r{<template\b[^>]*>.*<video\b.*</template>}m, html)
        refute_includes live, "<video"
      end

      def test_label_is_required
        missing = assert_raises(ArgumentError) { Component.new }
        assert_match(/label/, missing.message)

        blank = assert_raises(ArgumentError) { Component.new(label: "  ") }
        assert_equal "label is required", blank.message

        empty = assert_raises(ArgumentError) { Component.new(label: "") }
        assert_equal "label is required", empty.message

        other = assert_raises(ArgumentError) { Component.new(label: nil) }
        assert_equal "label must be a String", other.message
      end

      def test_default_frame_matches_card_media_rounding_and_sixteen_by_nine
        render_preview

        frame = page.find(".fp-video-preview")
        classes = frame[:class]

        assert_includes classes, "aspect-[16/9]"
        assert_includes classes, "rounded-[var(--media-radius)]"
        assert_includes classes, "overflow-hidden"
      end

      def test_aspect_ratio_uses_card_media_values
        render_preview(aspect_ratio: "4/3")
        assert_includes page.find(".fp-video-preview")[:class], "aspect-[4/3]"

        render_preview(aspect_ratio: "1/1")
        assert_includes page.find(".fp-video-preview")[:class], "aspect-square"

        render_preview(aspect_ratio: "21/9")
        assert_includes page.find(".fp-video-preview")[:class], "aspect-[21/9]"
      end

      def test_rejects_an_unreadable_aspect_ratio
        error = assert_raises(ArgumentError) do
          Component.new(label: "Play: Launch trailer", aspect_ratio: "wide")
        end

        assert_equal "aspect_ratio must look like \"16/9\"", error.message
      end

      def test_passes_overlay_items_through_with_placement_and_inset
        render_preview

        badge = page.find("[data-fp-placement='bottom_left']")

        assert_equal "sm", badge["data-fp-inset"]
        assert_includes badge.text, "2:14"
        assert_selector "[data-fp-placement='center'] button.fp-video-preview__play"
      end

      def test_media_and_player_slots_are_required
        media_missing = assert_raises(ArgumentError) do
          render_inline(Component.new(label: "Play: Launch trailer")) do |preview|
            preview.with_player { %(<iframe src="https://embed.example/trailer" title="Launch trailer"></iframe>).html_safe }
          end
        end
        assert_equal "media slot is required", media_missing.message

        player_missing = assert_raises(ArgumentError) do
          render_inline(Component.new(label: "Play: Launch trailer")) do |preview|
            preview.with_media { %(<img alt="" src="/images/hero-stool.jpg">).html_safe }
          end
        end
        assert_equal "player slot is required", player_missing.message
      end

      def test_component_source_does_not_name_a_video_provider
        ruby = File.read(File.expand_path("../../../app/components/flat_pack/video_preview/component.rb", __dir__))
        javascript = File.read(File.expand_path("../../../app/javascript/flat_pack/controllers/video_preview_controller.js", __dir__))
        source = ruby + javascript

        refute_match(/youtube|vimeo|embed_url/i, source)
      end

      def test_catalog_records_required_label_and_slots
        FlatPack::ComponentCatalog.reset!
        payload = FlatPack::ComponentCatalog.show("VideoPreview::Component")
        names = payload.fetch(:slots).map { |slot| slot[:name] }

        assert_includes names, "media"
        assert_includes names, "player"
        assert_includes names, "items"
        assert_includes payload.fetch(:examples).first.fetch(:erb), "FlatPack::VideoPreview::Component"

        label = payload.fetch(:parameters).find { |row| row[:name] == "label" }
        aspect_ratio = payload.fetch(:parameters).find { |row| row[:name] == "aspect_ratio" }

        assert label.fetch(:required)
        assert_equal "16/9", aspect_ratio.fetch(:default)
      end

      private

      def render_preview(label: "Play: Launch trailer", aspect_ratio: "16/9")
        render_inline(Component.new(label: label, aspect_ratio: aspect_ratio)) do |preview|
          preview.with_media { %(<img src="/images/hero-stool.jpg" alt="">).html_safe }
          preview.with_item(placement: :bottom_left, inset: :sm) { %(<span class="duration">2:14</span>).html_safe }
          preview.with_player { %(<iframe src="https://embed.example/trailer" title="Launch trailer"></iframe>).html_safe }
        end
      end
    end
  end
end
