# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Collage
    class ComponentTest < ViewComponent::TestCase
      def test_default_layout
        render_inline(Component.new) do |collage|
          collage.item { "Harbour" }
        end

        assert_selector "div.fp-collage.fp-collage--subtle.fp-collage--stack-md.fp-collage--motion"
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
        assert_includes page.native.to_html, "--fp-collage-columns: 4"
      end

      def test_motion_false_skips_enter
        render_inline(Component.new(motion: false)) { |collage| collage.item { "Still" } }

        refute_selector ".fp-collage--motion"
        refute_selector ".fp-content-enter"
        assert_text "Still"
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

      def test_rejects_invalid_motion
        error = assert_raises(ArgumentError) { Component.new(motion: "yes") }
        assert_match(/Invalid motion/, error.message)
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
        assert_includes collage, "var(--duration-slow)"
        assert_includes collage, "var(--easing-enter)"
        assert_includes collage, ".fp-content-enter"
        assert_includes collage, "@media (prefers-reduced-motion: reduce)"
        assert_includes collage, "@media (width < 48rem)"
        assert_includes collage, "transform: none"
        refute_match(/position:\s*absolute/, collage)
      end

      private

      def item_styles(html)
        html.scan(/class="fp-collage__item[^"]*" style="([^"]+)"/).flatten
      end
    end
  end
end
