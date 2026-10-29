# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Embed
    class ComponentTest < ViewComponent::TestCase
      def test_renders_iframe_with_required_src_and_title
        render_inline(Component.new(src: "https://embed.example/map", title: "Studio location"))

        assert_selector "figure.fp-embed"
        assert_selector "iframe[src='https://embed.example/map'][title='Studio location']"
        assert_no_selector "figcaption"
      end

      def test_defaults_loading_lazy_and_strict_referrer_policy
        render_inline(Component.new(src: "https://embed.example/map", title: "Studio location"))

        iframe = page.find("iframe")

        assert_equal "lazy", iframe[:loading]
        assert_equal "strict-origin-when-cross-origin", iframe[:referrerpolicy]
      end

      def test_title_is_required
        missing = assert_raises(ArgumentError) { Component.new(src: "https://embed.example/map") }
        assert_match(/title/, missing.message)

        blank = assert_raises(ArgumentError) { Component.new(src: "https://embed.example/map", title: "  ") }
        assert_equal "title is required", blank.message

        empty = assert_raises(ArgumentError) { Component.new(src: "https://embed.example/map", title: "") }
        assert_equal "title is required", empty.message

        other = assert_raises(ArgumentError) { Component.new(src: "https://embed.example/map", title: nil) }
        assert_equal "title must be a String", other.message
      end

      def test_src_must_be_http_or_relative
        error = assert_raises(ArgumentError) do
          Component.new(src: "javascript:alert(1)", title: "Studio location")
        end

        assert_match(/Invalid src/, error.message)
      end

      def test_default_frame_is_sixteen_by_nine
        render_inline(Component.new(src: "https://embed.example/map", title: "Studio location"))

        classes = page.find(".fp-embed__frame")[:class]

        assert_includes classes, "aspect-[16/9]"
        assert_includes classes, "rounded-[var(--media-radius)]"
        assert_includes classes, "overflow-hidden"
      end

      def test_aspect_ratio_uses_card_media_values
        render_inline(Component.new(src: "https://embed.example/map", title: "Studio location", aspect_ratio: "4/3"))
        assert_includes page.find(".fp-embed__frame")[:class], "aspect-[4/3]"

        render_inline(Component.new(src: "https://embed.example/map", title: "Studio location", aspect_ratio: "1/1"))
        assert_includes page.find(".fp-embed__frame")[:class], "aspect-square"

        render_inline(Component.new(src: "https://embed.example/map", title: "Studio location", aspect_ratio: "21/9"))
        assert_includes page.find(".fp-embed__frame")[:class], "aspect-[21/9]"
      end

      def test_rejects_an_unreadable_aspect_ratio
        error = assert_raises(ArgumentError) do
          Component.new(src: "https://embed.example/map", title: "Studio location", aspect_ratio: "wide")
        end

        assert_equal "aspect_ratio must look like \"16/9\"", error.message
      end

      def test_allow_and_sandbox_land_on_the_iframe
        render_inline(
          Component.new(
            src: "https://embed.example/map",
            title: "Studio location",
            allow: "geolocation",
            sandbox: "allow-scripts allow-same-origin",
            allowfullscreen: true
          )
        )

        iframe = page.find("iframe")

        assert_equal "geolocation", iframe[:allow]
        assert_equal "allow-scripts allow-same-origin", iframe[:sandbox]
        assert iframe[:allowfullscreen]
      end

      def test_omits_allow_and_sandbox_when_unset
        render_inline(Component.new(src: "https://embed.example/map", title: "Studio location"))

        html = rendered_content

        refute_match(/\sallow=/, html)
        refute_includes html, "sandbox="
        refute_includes html, "allowfullscreen"
      end

      def test_caption_renders_figcaption
        render_inline(
          Component.new(src: "https://embed.example/map", title: "Studio location", caption: "The workshop")
        )

        assert_selector "figcaption", text: "The workshop"
      end

      def test_block_supplies_caption_when_caption_is_omitted
        render_inline(Component.new(src: "https://embed.example/map", title: "Studio location")) do
          "The workshop"
        end

        assert_selector "figcaption", text: "The workshop"
      end

      def test_catalog_records_required_title_and_src
        FlatPack::ComponentCatalog.reset!
        payload = FlatPack::ComponentCatalog.show("Embed::Component")

        assert_includes payload.fetch(:examples).first.fetch(:erb), "FlatPack::Embed::Component"

        src = payload.fetch(:parameters).find { |row| row[:name] == "src" }
        title = payload.fetch(:parameters).find { |row| row[:name] == "title" }
        aspect_ratio = payload.fetch(:parameters).find { |row| row[:name] == "aspect_ratio" }
        loading = payload.fetch(:parameters).find { |row| row[:name] == "loading" }
        referrerpolicy = payload.fetch(:parameters).find { |row| row[:name] == "referrerpolicy" }

        assert src.fetch(:required)
        assert title.fetch(:required)
        assert_equal "16/9", aspect_ratio.fetch(:default)
        assert_equal "lazy", loading.fetch(:default)
        assert_equal "strict-origin-when-cross-origin", referrerpolicy.fetch(:default)
      end
    end
  end
end
