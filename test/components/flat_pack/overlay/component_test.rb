# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Overlay
    class ComponentTest < ViewComponent::TestCase
      def test_places_media_under_a_default_item
        render_inline(Component.new) do |overlay|
          overlay.with_media { image_markup }
          overlay.with_item { "New" }
        end

        assert_selector "div.fp-overlay.relative.inline-flex"
        assert_selector "div.fp-overlay > div.contents img[alt='Stool in a box']"
        assert_selector "[data-fp-placement='top_left'][data-fp-inset='md']", text: "New"
        assert_includes page.native.to_html, "top-[var(--fp-overlay-item-inset)]"
        assert_includes page.native.to_html, "left-[var(--fp-overlay-item-inset)]"
      end

      def test_nine_placements_use_the_grid
        render_inline(Component.new) do |overlay|
          overlay.with_media { image_markup }
          Item::PLACEMENTS.each do |placement|
            overlay.with_item(placement: placement, inset: :md) { placement.to_s }
          end
        end

        Item::PLACEMENTS.each do |placement|
          assert_selector "[data-fp-placement='#{placement}'][data-fp-inset='md']", text: placement.to_s
        end

        html = page.native.to_html
        assert_includes html, "top-[var(--fp-overlay-item-inset)] left-[var(--fp-overlay-item-inset)]"
        assert_includes html, "top-[var(--fp-overlay-item-inset)] left-1/2 -translate-x-1/2"
        assert_includes html, "top-[var(--fp-overlay-item-inset)] right-[var(--fp-overlay-item-inset)]"
        assert_includes html, "top-1/2 left-[var(--fp-overlay-item-inset)] -translate-y-1/2"
        assert_includes html, "top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2"
        assert_includes html, "top-1/2 right-[var(--fp-overlay-item-inset)] -translate-y-1/2"
        assert_includes html, "bottom-[var(--fp-overlay-item-inset)] left-[var(--fp-overlay-item-inset)]"
        assert_includes html, "bottom-[var(--fp-overlay-item-inset)] left-1/2 -translate-x-1/2"
        assert_includes html, "bottom-[var(--fp-overlay-item-inset)] right-[var(--fp-overlay-item-inset)]"
      end

      def test_inset_steps_use_the_inset_tokens
        render_inline(Component.new) do |overlay|
          overlay.with_media { image_markup }
          overlay.with_item(placement: :top_left, inset: :sm) { "Small" }
          overlay.with_item(placement: :bottom_right, inset: :lg) { "Large" }
        end

        small = page.find("[data-fp-placement='top_left'][data-fp-inset='sm']")
        large = page.find("[data-fp-placement='bottom_right'][data-fp-inset='lg']")
        assert_includes small[:class], "top-[var(--fp-overlay-item-inset)]"
        assert_includes small[:class], "left-[var(--fp-overlay-item-inset)]"
        assert_includes large[:class], "bottom-[var(--fp-overlay-item-inset)]"
        assert_includes large[:class], "right-[var(--fp-overlay-item-inset)]"
        assert_equal "Small", small.text
        assert_equal "Large", large.text
      end

      def test_edge_centers_use_inset_on_the_edge_axis_only
        render_inline(Component.new) do |overlay|
          overlay.with_item(placement: :top_center, inset: :md) { "Top" }
          overlay.with_item(placement: :middle_left, inset: :lg) { "Side" }
        end

        top = page.find("[data-fp-placement='top_center']")
        side = page.find("[data-fp-placement='middle_left']")
        assert_includes top[:class], "top-[var(--fp-overlay-item-inset)]"
        refute_includes top[:class], "left-[var(--fp-overlay-item-inset)]"
        assert_includes side[:class], "left-[var(--fp-overlay-item-inset)]"
        refute_includes side[:class], "top-[var(--fp-overlay-item-inset)]"
      end

      def test_center_ignores_inset
        render_inline(Component.new) do |overlay|
          overlay.with_item(placement: :center, inset: :sm) { "Center" }
        end
        sm = page.native.to_html

        render_inline(Component.new) do |overlay|
          overlay.with_item(placement: :center, inset: :lg) { "Center" }
        end
        lg = page.native.to_html

        assert_includes sm, "top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2"
        assert_includes lg, "top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2"
        refute_includes sm, "--overlay-inset-"
        refute_includes lg, "--overlay-inset-"
      end

      def test_items_keep_their_own_markup
        render_inline(Component.new) do |overlay|
          overlay.with_media { image_markup }
          overlay.with_item(placement: :top_left, inset: :sm) do
            vc_test_controller.view_context.render(
              FlatPack::Badge::Component.new(text: "New", style: :primary, size: :sm)
            )
          end
          overlay.with_item(placement: :bottom_right, inset: :lg) do
            vc_test_controller.view_context.render(
              FlatPack::Button::Component.new(text: "Share", style: :primary, size: :sm)
            )
          end
        end

        assert_selector "[data-fp-placement='top_left'] span", text: "New"
        assert_selector "[data-fp-placement='bottom_right'] button", text: "Share"
      end

      def test_wrapper_does_not_paint_the_item
        render_inline(Component.new) do |overlay|
          overlay.with_item { "New" }
        end

        classes = page.find("[data-fp-placement='top_left']")[:class]
        refute_match(/\b(bg-|text-|border-|shadow|rounded|theme)\b/, classes)
      end

      def test_accepts_custom_classes_and_data
        render_inline(Component.new(class: "w-full", id: "stool", data: {testid: "overlay"})) do |overlay|
          overlay.with_media { image_markup }
          overlay.with_item(placement: :top_right, id: "corner") { "Mark" }
        end

        assert_selector "div.fp-overlay.w-full#stool[data-testid='overlay']"
        assert_selector "#corner[data-fp-placement='top_right']", text: "Mark"
      end

      def test_rejects_invalid_placement
        error = assert_raises(ArgumentError) do
          render_inline(Component.new) do |overlay|
            overlay.with_item(placement: :top) { "New" }
          end
        end

        assert_match(/Invalid placement: top/, error.message)
      end

      def test_rejects_invalid_inset
        error = assert_raises(ArgumentError) do
          render_inline(Component.new) do |overlay|
            overlay.with_item(inset: :xl) { "New" }
          end
        end

        assert_match(/Invalid inset: xl/, error.message)
      end

      private

      def image_markup
        %(<img alt="Stool in a box" src="/images/hero-stool.jpg">).html_safe
      end
    end
  end
end
