# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Lightbox
    class ComponentTest < ViewComponent::TestCase
      def photos
        [
          {type: :image, src: "https://images.example.com/one.jpg", alt: "Harbour", caption: "Harbour at dusk"},
          {type: :image, src: "https://images.example.com/two.jpg", alt: "Cliff", caption: "Sea cliff"},
          {src: "https://videos.example.com/walk.mp4", caption: "Walk along the quay", poster: "https://images.example.com/poster.jpg"}
        ]
      end

      def test_renders_a_dialog_overlay_and_reuses_carousel_for_several_items
        render_inline(Component.new(group: "wall", items: photos, loop: true, show_count: true))

        dialog = page.find("dialog[data-controller='flat-pack--lightbox']", visible: :all)
        assert_equal "wall", dialog["data-flat-pack--lightbox-group-value"]
        assert_equal "Lightbox", dialog["aria-label"]
        assert_includes dialog[:class], "h-dvh"
        assert_includes dialog[:class], "backdrop:bg-[var(--modal-backdrop-color)]"
        assert_includes dialog[:class], "bg-transparent"
        assert page.has_css?(".fp-overlay-pad.grid.place-items-center, .fp-overlay-pad .place-items-center", visible: :all)
        assert_includes dialog.native.to_html, "place-items-center"
        refute_includes dialog[:class], "justify-center"

        stage = dialog.find("[data-flat-pack-lightbox-stage='true']", visible: :all)
        assert_equal "true", stage["data-flat-pack--carousel-loop-value"]
        assert_includes stage[:class], "flex-col"
        image = stage.find("img[alt='Harbour']", visible: :all)
        assert_includes image[:class], "object-contain"
        assert_includes image[:class], "bg-[var(--carousel-lightbox-image-background-color)]"
        viewport = stage.find("[data-flat-pack--carousel-target='viewport']", visible: :all)
        refute_includes viewport[:style].to_s, "aspect-ratio"
        assert_selector "[data-flat-pack-lightbox-stage='true'] button[data-action='click->flat-pack--carousel#prev']", visible: :all
        assert_selector "[data-flat-pack-lightbox-stage='true'] button[data-action='click->flat-pack--carousel#next']", visible: :all
        assert_selector "[data-flat-pack-lightbox-stage='true'] [data-flat-pack--carousel-target='counter']", visible: :all
        assert_no_selector "button[data-flat-pack--carousel-target='lightboxToggle']", visible: :all
        assert_selector "button[aria-label='Close lightbox']", visible: :all
        assert_selector "img[alt='Harbour']", visible: :all
        assert_selector "video source[src='https://videos.example.com/walk.mp4']", visible: :all
      end

      def test_one_item_hides_arrows_and_the_count
        render_inline(Component.new(group: "single", items: [photos.first], show_count: true))

        assert_no_selector "button[data-action='click->flat-pack--carousel#prev']", visible: :all
        assert_no_selector "button[data-action='click->flat-pack--carousel#next']", visible: :all
        assert_no_selector "[data-flat-pack--carousel-target='counter']", visible: :all
        assert_selector "img[alt='Harbour']", visible: :all
      end

      def test_show_count_false_omits_the_counter_when_several_items_remain
        render_inline(Component.new(group: "quiet", items: photos.first(2), show_count: false, loop: false))

        stage = page.find("[data-flat-pack-lightbox-stage='true']", visible: :all)
        assert_equal "false", stage["data-flat-pack--carousel-loop-value"]
        assert_no_selector "[data-flat-pack--carousel-target='counter']", visible: :all
        assert_selector "button[data-action='click->flat-pack--carousel#next']", visible: :all
      end

      def test_trigger_helper_names_the_group_and_index
        render_inline(Trigger.new(group: "wall", index: 2)) { "Open" }

        button = page.find("button", text: "Open")
        assert_equal "button", button[:type]
        assert_equal "wall", button["data-flat-pack-lightbox-group"]
        assert_equal "2", button["data-flat-pack-lightbox-index"]
        assert_equal(
          {flat_pack_lightbox_group: "wall", flat_pack_lightbox_index: 2},
          FlatPack::Lightbox.trigger_data(group: "wall", index: 2)
        )
      end

      def test_rejects_class_style_bad_group_bad_type_and_empty_items
        assert_raises(ArgumentError) { Component.new(group: "wall", items: photos, class: "bg-black") }
        assert_raises(ArgumentError) { Component.new(group: "wall", items: photos, style: "color: red") }
        assert_raises(ArgumentError) { Component.new(group: "9wall", items: photos) }
        assert_raises(ArgumentError) { Component.new(group: "wall", items: [{type: :html, html: "<p>No</p>"}]) }
        assert_raises(ArgumentError) { Component.new(group: "wall", items: []) }
        assert_raises(ArgumentError) { Component.new(group: "wall", items: photos, loop: "yes") }
        assert_raises(ArgumentError) { Trigger.new(group: "wall", index: 0, class: "ring") }
        assert_raises(ArgumentError) { Trigger.new(group: "wall", index: -1) }
      end

      def test_drops_unsafe_urls
        render_inline(Component.new(group: "wall", items: [
          {src: "javascript:alert(1)", alt: "Bad"},
          {src: "https://images.example.com/ok.jpg", alt: "Ok"}
        ]))

        refute_includes rendered_content, "javascript:"
        assert_selector "img[alt='Ok']", visible: :all
      end
    end
  end
end
