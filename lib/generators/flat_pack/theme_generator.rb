# frozen_string_literal: true

require "rails/generators/base"

module FlatPack
  module Generators
    class ThemeGenerator < Rails::Generators::Base
      source_root File.expand_path("templates", __dir__)

      argument :name, type: :string, required: true, desc: "Theme name (e.g. sunrise, BrandName)"

      class_option :hue,
        type: :numeric,
        default: 160,
        desc: "Brand hue (0-360) used by --brand-hue"

      class_option :chroma,
        type: :numeric,
        default: 0.18,
        desc: "Brand chroma used by --brand-chroma"

      class_option :lightness,
        type: :numeric,
        default: 0.52,
        desc: "Brand lightness used by --brand-lightness (primary only)"

      class_option :as_root,
        type: :boolean,
        default: false,
        desc: "Write overrides to :root instead of [data-theme]"

      desc "Generate a FlatPack brand theme override stylesheet"

      def create_theme_stylesheet
        destination = "app/assets/stylesheets/flat_pack_theme_#{theme_slug}.css"
        template "theme.css.tt", destination

        say "\n✓ Created #{destination}", :green
        say "\nApply the theme:", :cyan
        if options[:as_root]
          say "  Ensure this stylesheet loads after flat_pack/variables.", :cyan
          say "  Brand overrides are on :root — no data-theme attribute needed.", :cyan
        else
          say "  Ensure this stylesheet loads after flat_pack/variables, then set:", :cyan
          say "  <html data-theme=\"#{theme_slug}\">", :cyan
          say "  Or use the flat-pack--theme Stimulus controller.", :cyan
        end
        say "\nTweaking color later:", :cyan
        say "  Change --brand-hue / --brand-chroma / --brand-lightness in #{destination}", :cyan
        say "  Component tokens inherit from semantic tokens automatically.", :cyan
      end

      private

      def theme_slug
        name.to_s.strip.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-|-\z/, "")
      end

      def brand_hue
        options[:hue].to_f
      end

      def brand_chroma
        options[:chroma].to_f
      end

      def brand_lightness
        options[:lightness].to_f
      end

      def selector
        options[:as_root] ? ":root" : %([data-theme="#{theme_slug}"])
      end
    end
  end
end
