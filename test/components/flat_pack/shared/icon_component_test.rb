# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Shared
    class IconComponentTest < ViewComponent::TestCase
      setup do
        FlatPack.configuration = nil
      end

      # --- SVG shell structure --------------------------------------------------

      def test_renders_an_svg_element
        render_inline(IconComponent.new(name: :search))
        assert_selector "svg"
      end

      def test_svg_has_correct_viewbox
        render_inline(IconComponent.new(name: :search))
        # Nokogiri lowercases attribute names in HTML fragment parsing
        assert_selector "svg[viewbox='0 0 24 24']"
      end

      def test_svg_is_aria_hidden
        render_inline(IconComponent.new(name: :search))
        assert_selector "svg[aria-hidden='true']"
      end

      # --- Stimulus controller wiring ------------------------------------------

      def test_has_icon_stimulus_controller
        render_inline(IconComponent.new(name: :search))
        assert_selector "svg[data-controller='flat-pack--icon']"
      end

      def test_name_value_uses_heroicons_canonical_name
        # :search maps to "magnifying-glass" via NAME_MAP
        render_inline(IconComponent.new(name: :search))
        assert_selector "svg[data-flat-pack--icon-name-value='magnifying-glass']"
      end

      def test_dash_name_passed_through_directly
        render_inline(IconComponent.new(name: "chevron-down"))
        assert_selector "svg[data-flat-pack--icon-name-value='chevron-down']"
      end

      def test_underscore_name_converted_to_dash
        render_inline(IconComponent.new(name: :chevron_left))
        assert_selector "svg[data-flat-pack--icon-name-value='chevron-left']"
      end

      def test_default_variant_is_outline
        render_inline(IconComponent.new(name: :search))
        assert_selector "svg[data-flat-pack--icon-variant-value='outline']"
      end

      def test_default_variant_uses_flat_pack_configuration
        FlatPack.configure { |config| config.default_icon_variant = :mini }

        render_inline(IconComponent.new(name: :search))

        assert_selector "svg[data-flat-pack--icon-variant-value='mini'][viewbox='0 0 20 20']"
      end

      def test_solid_variant_is_passed_through
        render_inline(IconComponent.new(name: :search, variant: :solid))
        assert_selector "svg[data-flat-pack--icon-variant-value='solid']"
      end

      def test_explicit_variant_overrides_configured_default
        FlatPack.configure { |config| config.default_icon_variant = :micro }

        render_inline(IconComponent.new(name: :search, variant: :solid))

        assert_selector "svg[data-flat-pack--icon-variant-value='solid'][viewbox='0 0 24 24']"
      end

      def test_micro_variant_sets_micro_viewbox
        render_inline(IconComponent.new(name: :search, variant: :micro))

        assert_selector "svg[data-flat-pack--icon-variant-value='micro'][viewbox='0 0 16 16']"
      end

      # --- Size classes ---------------------------------------------------------

      def test_default_size_is_md
        render_inline(IconComponent.new(name: :search))
        assert_selector "svg.w-5.h-5"
      end

      def test_sm_size
        render_inline(IconComponent.new(name: :search, size: :sm))
        assert_selector "svg.w-4.h-4"
      end

      def test_lg_size
        render_inline(IconComponent.new(name: :search, size: :lg))
        assert_selector "svg.w-6.h-6"
      end

      def test_xl_size
        render_inline(IconComponent.new(name: :search, size: :xl))
        assert_selector "svg.w-8.h-8"
      end

      def test_invalid_size_raises
        assert_raises(ArgumentError) { IconComponent.new(name: :search, size: :xxl) }
      end

      # --- NAME_MAP coverage ---------------------------------------------------

      def test_cog_maps_to_cog_6_tooth
        render_inline(IconComponent.new(name: :cog))
        assert_selector "svg[data-flat-pack--icon-name-value='cog-6-tooth']"
      end

      def test_menu_maps_to_bars_3
        render_inline(IconComponent.new(name: :menu))
        assert_selector "svg[data-flat-pack--icon-name-value='bars-3']"
      end

      def test_dashboard_maps_to_squares_2x2
        render_inline(IconComponent.new(name: :dashboard))
        assert_selector "svg[data-flat-pack--icon-name-value='squares-2x2']"
      end

      def test_unknown_name_passes_through_unchanged
        # Names not in NAME_MAP are passed directly (heroicons may handle them)
        render_inline(IconComponent.new(name: "academic-cap"))
        assert_selector "svg[data-flat-pack--icon-name-value='academic-cap']"
      end

      # --- Extra HTML attributes -----------------------------------------------

      def test_accepts_extra_class
        render_inline(IconComponent.new(name: :search, class: "text-red-500"))
        assert_selector "svg.text-red-500"
      end

      def test_accepts_data_attributes
        render_inline(IconComponent.new(name: :search, data: {testid: "my-icon"}))
        assert_selector "svg[data-testid='my-icon']"
      end
    end
  end
end
