# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Collage
    class ComponentTest < ViewComponent::TestCase
      def test_default_layout
        render_inline(Component.new) do |collage|
          collage.item { "Harbour" }
        end

        assert_selector "div.fp-collage.fp-collage--subtle.fp-collage--teaser.fp-collage--entrance-rise.fp-collage--idle-none.fp-collage--hover-lift"
        refute_selector ".fp-collage--motion"
        refute_selector ".fp-collage--stack-md"
        assert_selector ".fp-collage__item > .fp-content-enter", text: "Harbour"
        html = page.native.to_html
        assert_includes html, "--fp-collage-columns: 3"
        refute_includes html, "position: absolute"
        refute_includes html, "position:absolute"
      end

      def test_scatter_loose_and_none
        render_inline(Component.new(scatter: :loose)) { |collage| collage.item { "Cliff" } }
        assert_selector ".fp-collage--loose"
        refute_selector ".fp-collage--subtle"

        render_inline(Component.new(scatter: :none)) { |collage| collage.item { "Cliff" } }
        assert_selector ".fp-collage--none"
      end

      def test_stack_below_and_columns
        render_inline(Component.new(columns: 4, stack_below: :lg)) { |collage| collage.item { "Jetty" } }

        assert_selector ".fp-collage--stack-lg"
        refute_selector ".fp-collage--teaser"
        assert_includes page.native.to_html, "--fp-collage-columns: 4"
      end

      def test_phone_row_hides_items_past_mobile_items_and_keeps_source_order
        render_inline(Component.new(rows: [5, 4], mobile_items: 4)) do |collage|
          6.times { |index| collage.item { "Card #{index}" } }
        end

        items = page.all(".fp-collage__item")
        assert_equal ["Card 0", "Card 1", "Card 2", "Card 3", "Card 4", "Card 5"], items.map(&:text)
        assert_equal [false, false, false, false, true, true], items.map { |item| item[:class].include?("fp-collage__item--spare") }
        items.each { |item| assert_nil item[:"aria-hidden"] }
      end

      def test_rejects_invalid_mobile_items
        error = assert_raises(ArgumentError) { Component.new(mobile_items: 0) }
        assert_match(/Invalid mobile_items/, error.message)
      end

      def test_rows_place_a_shorter_row_between_the_one_above
        render_inline(Component.new(rows: [5, 4])) do |collage|
          9.times { |index| collage.item { "Card #{index}" } }
        end

        assert_selector ".fp-collage--brick"
        assert_includes page.native.to_html, "--fp-collage-tracks: 10"
        styles = item_styles(page.native.to_html)
        assert_includes styles[0], "--fp-collage-column: 1 / span 2"
        assert_includes styles[0], "--fp-collage-row: 1"
        assert_includes styles[4], "--fp-collage-column: 9 / span 2"
        assert_includes styles[5], "--fp-collage-column: 2 / span 2"
        assert_includes styles[5], "--fp-collage-row: 2"
        assert_includes styles[8], "--fp-collage-column: 8 / span 2"
        assert_equal %w[Card\ 0 Card\ 1 Card\ 2 Card\ 3 Card\ 4 Card\ 5 Card\ 6 Card\ 7 Card\ 8],
          page.all(".fp-collage__item").map(&:text)
      end

      def test_rows_repeat_and_reject_bad_counts
        spot = Item.spot(9, [5, 4])
        assert_equal({start: 1, span: 2, row: 3}, spot)

        error = assert_raises(ArgumentError) { Component.new(rows: [0, 4]) }
        assert_match(/Invalid rows/, error.message)

        error = assert_raises(ArgumentError) { Component.new(rows: []) }
        assert_match(/Invalid rows/, error.message)
      end

      def test_still_entrance_skips_enter
        render_inline(Component.new(entrance: :none, hover: :none)) { |collage| collage.item { "Still" } }

        assert_selector ".fp-collage--entrance-none.fp-collage--hover-none"
        refute_selector ".fp-content-enter"
        refute_selector ".fp-collage__drift"
        assert_text "Still"
      end

      def test_deal_places_each_item_against_the_centre
        render_inline(Component.new(rows: [5, 4], entrance: :deal, idle: :drift, hover: :focus)) do |collage|
          9.times { |index| collage.item { "Card #{index}" } }
        end

        assert_selector ".fp-collage--entrance-deal.fp-collage--idle-drift.fp-collage--hover-focus"
        assert_selector ".fp-collage__item > .fp-collage__drift", count: 9
        refute_selector ".fp-content-enter"
        html = page.native.to_html
        assert_includes html, "--fp-collage-center-x: 2"
        assert_includes html, "--fp-collage-center-y: 0.5"
        assert_includes html, "--fp-collage-count: 9"
        assert_includes html, "--fp-collage-mobile: 4"
        styles = item_styles(html)
        assert_includes styles[0], "--fp-collage-place-x: 0"
        assert_includes styles[0], "--fp-collage-place-y: 0"
        assert_includes styles[5], "--fp-collage-place-x: 0.5"
        assert_includes styles[5], "--fp-collage-place-y: 1"
      end

      def test_even_grid_deal_centres_one_row
        render_inline(Component.new(columns: 4, entrance: :deal)) do |collage|
          4.times { |index| collage.item { "Card #{index}" } }
        end

        html = page.native.to_html
        assert_includes html, "--fp-collage-center-x: 1.5"
        assert_includes html, "--fp-collage-center-y: 0"
        styles = item_styles(html)
        assert_includes styles[0], "--fp-collage-place-x: 0"
        assert_includes styles[3], "--fp-collage-place-x: 3"
        assert_includes styles[3], "--fp-collage-place-y: 0"
      end

      def test_rise_and_drift_share_one_inner_wrapper
        render_inline(Component.new(entrance: :rise, idle: :drift)) { |collage| collage.item { "Sway" } }

        assert_selector ".fp-collage__item > .fp-content-enter.fp-collage__drift", text: "Sway"
      end

      def test_reading_order_matches_source_order
        render_inline(Component.new) do |collage|
          collage.item { "One" }
          collage.item { "Two" }
          collage.item { "Three" }
        end

        assert_equal %w[One Two Three], page.all(".fp-collage__item").map(&:text)
      end

      def test_scatter_is_stable_for_the_same_index
        first = render_inline(Component.new) { |collage|
          collage.item { "A" }
          collage.item { "B" }
        }.to_html
        second = render_inline(Component.new) { |collage|
          collage.item { "A" }
          collage.item { "B" }
        }.to_html

        assert_equal item_styles(first), item_styles(second)
        styles = item_styles(first)
        refute_equal styles[0], styles[1]
        assert_includes styles[0], "--fp-collage-index: 0"
        assert_includes styles[1], "--fp-collage-index: 1"
        assert_includes styles[0], "--fp-collage-z: 1"
        assert_includes styles[1], "--fp-collage-z: 2"
      end

      def test_units_stay_inside_minus_one_to_one
        12.times do |index|
          Item.units(index).each_value do |unit|
            assert_operator unit, :>=, -1
            assert_operator unit, :<=, 1
          end
        end
        assert_equal Item.units(4), Item.units(4)
      end

      def test_rotate_and_offset_override_the_scatter
        render_inline(Component.new) do |collage|
          collage.item(rotate: -4, offset: ["0.5rem", "-8px"], z: 7) { "Pinned" }
        end

        style = page.find(".fp-collage__item")["style"]
        assert_includes style, "--fp-collage-angle: -4deg"
        assert_includes style, "--fp-collage-x: 0.5rem"
        assert_includes style, "--fp-collage-y: -8px"
        assert_includes style, "--fp-collage-z: 7"
      end

      def test_offset_hash_and_pixel_numbers
        render_inline(Component.new) do |collage|
          collage.item(offset: {x: 12, y: "var(--space-2)"}) { "Shift" }
        end

        style = page.find(".fp-collage__item")["style"]
        assert_includes style, "--fp-collage-x: 12px"
        assert_includes style, "--fp-collage-y: var(--space-2)"
      end

      def test_accepts_a_css_angle_string
        render_inline(Component.new) { |collage| collage.item(rotate: "2.5deg") { "Tilt" } }

        assert_includes page.find(".fp-collage__item")["style"], "--fp-collage-angle: 2.5deg"
      end

      def test_holds_a_card_and_a_badge
        view = vc_test_controller.view_context

        render_inline(Component.new) do |collage|
          collage.item do
            view.render(FlatPack::Card::Component.new(shadow: :sm)) do |card|
              card.body do
                view.render(FlatPack::Badge::Component.new(text: "Harbour", size: :xs))
              end
            end
          end
        end

        assert_selector ".fp-collage__item .fp-content-enter"
        assert_text "Harbour"
      end

      def test_merges_system_arguments
        render_inline(Component.new(id: "wall", class: "mt-4", data: {testid: "collage"}, style: "outline: none")) do |collage|
          collage.item(class: "photo", id: "harbour") { "Harbour" }
        end

        assert_selector "#wall.fp-collage.mt-4[data-testid='collage']"
        assert_includes page.find("#wall")["style"], "--fp-collage-columns: 3"
        assert_includes page.find("#wall")["style"], "outline: none"
        assert_selector "#harbour.fp-collage__item.photo"
      end

      def test_rejects_invalid_scatter
        error = assert_raises(ArgumentError) { Component.new(scatter: :wild) }
        assert_match(/Invalid scatter/, error.message)
      end

      def test_rejects_invalid_columns
        error = assert_raises(ArgumentError) { Component.new(columns: 9) }
        assert_match(/Invalid columns/, error.message)
      end

      def test_rejects_invalid_stack_below
        error = assert_raises(ArgumentError) { Component.new(stack_below: :phone) }
        assert_match(/Invalid stack_below/, error.message)
      end

      def test_rejects_invalid_entrance_idle_and_hover
        error = assert_raises(ArgumentError) { Component.new(entrance: :zoom) }
        assert_match(/Invalid entrance/, error.message)

        error = assert_raises(ArgumentError) { Component.new(idle: :bounce) }
        assert_match(/Invalid idle/, error.message)

        error = assert_raises(ArgumentError) { Component.new(hover: :spin) }
        assert_match(/Invalid hover/, error.message)

        error = assert_raises(ArgumentError) { Component.new(motion: true) }
        assert_match(/motion: is gone/, error.message)
      end

      def test_rejects_invalid_rotate_offset_and_z
        component = Component.new
        error = assert_raises(ArgumentError) { component.item(rotate: "sideways") }
        assert_match(/Invalid rotate/, error.message)

        error = assert_raises(ArgumentError) { component.item(rotate: 400) }
        assert_match(/Invalid rotate/, error.message)

        error = assert_raises(ArgumentError) { component.item(offset: "1rem") }
        assert_match(/Invalid offset/, error.message)

        error = assert_raises(ArgumentError) { component.item(offset: ["url(x)", "1px"]) }
        assert_match(/Invalid offset/, error.message)

        error = assert_raises(ArgumentError) { component.item(z: 1.5) }
        assert_match(/Invalid z/, error.message)
      end

      def test_stylesheet_uses_tokens_grid_and_reduced_motion
        css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read
        collage = css[/\/\* Collage:.*?\n\/\* Sliding active indicator/m]

        refute_nil collage
        assert_includes collage, "display: grid"
        assert_includes collage, "var(--collage-rotate)"
        assert_includes collage, "var(--collage-offset-x)"
        assert_includes collage, "var(--collage-offset-y)"
        assert_includes collage, "var(--collage-lift)"
        assert_includes collage, "var(--collage-stagger)"
        assert_includes collage, "var(--collage-loose)"
        assert_includes collage, "var(--collage-bleed)"
        assert_includes collage, "var(--collage-margin)"
        assert_includes collage, "var(--collage-overlap)"
        assert_includes collage, "var(--collage-duration)"
        assert_includes collage, "var(--collage-easing)"
        assert_includes collage, "var(--collage-rise)"
        assert_includes collage, "var(--collage-deal)"
        assert_includes collage, "var(--collage-deal-duration)"
        assert_includes collage, "var(--collage-drift)"
        assert_includes collage, "var(--collage-drift-duration)"
        assert_includes collage, "var(--collage-drift-easing)"
        assert_includes collage, "var(--collage-focus-lift)"
        assert_includes collage, "var(--collage-focus-scale)"
        assert_includes collage, "var(--collage-focus-dim)"
        assert_includes collage, "fp-collage--brick"
        assert_includes collage, "fp-collage--entrance-deal"
        assert_includes collage, "fp-collage--entrance-rise"
        assert_includes collage, "fp-collage--idle-drift"
        assert_includes collage, "fp-collage--hover-lift"
        assert_includes collage, "fp-collage--hover-focus"
        assert_includes collage, "@keyframes fp-collage-deal"
        assert_includes collage, "@keyframes fp-collage-drift"
        assert_includes collage, "(hover: hover)"
        assert_includes collage, ":focus-visible"
        assert_includes collage, ":focus-within"
        assert_includes collage, ":has("
        assert_includes collage, "padding: calc(var(--collage-pad) + (var(--collage-offset-y) + var(--collage-bleed)) * var(--fp-collage-scatter))"
        assert_includes collage, "padding: var(--collage-pad)"
        assert_includes collage, ".fp-content-enter"
        assert_includes collage, "@media (prefers-reduced-motion: reduce)"
        assert_includes collage, "animation: none"
        assert_includes collage, "var(--collage-item-size-sm)"
        assert_includes collage, "var(--collage-item-size-md)"
        assert_includes collage, "fp-collage--teaser"
        assert_includes collage, "33dvh"
        assert_includes collage, "@media (width < 48rem)"
        assert_includes collage, "@media (width >= 48rem) and (width < 64rem)"
        assert_includes collage, "transform: none"
        refute_includes collage, "var(--duration-slow)"
        refute_includes collage, "var(--easing-enter)"
        refute_match(/position:\s*absolute/, collage)
      end

      private

      def item_styles(html)
        html.scan(/class="fp-collage__item[^"]*" style="([^"]+)"/).flatten
      end
    end
  end
end
