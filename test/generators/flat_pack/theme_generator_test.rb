# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "fileutils"
require "pathname"
require "generators/flat_pack/theme_generator"

module FlatPack
  module Generators
    class ThemeGeneratorTest < ActiveSupport::TestCase
      test "creates a data-theme brand override stylesheet" do
        Dir.mktmpdir("flatpack-theme-generator") do |tmpdir|
          destination = Pathname.new(tmpdir)
          generator = ThemeGenerator.new(["Sunrise"], {hue: 35, chroma: 0.2, lightness: 0.6}, destination_root: destination.to_s)
          generator.destination_root = destination.to_s

          capture_io { generator.invoke_all }

          path = destination.join("app/assets/stylesheets/flat_pack_theme_sunrise.css")
          assert path.exist?
          content = path.read
          assert_includes content, '[data-theme~="sunrise"]'
          assert_includes content, "--brand-hue: 35"
          assert_includes content, "--brand-chroma: 0.2"
          assert_includes content, "--brand-lightness: 0.6"
          assert_includes content, ":root, [data-theme] maps those knobs to --color-primary."
          assert_includes content, "Hover and pressed mix that colour on the button."
          refute_includes content, "0.10 darker"
          assert_includes content, "Focus rings follow --color-primary."
          assert_includes content, "Active sidebar / top-nav fills follow --surface-active-background-color."
          assert_includes content, "Hover follows --surface-hover-background-color."
          refute_match(/^\s*--color-primary:/, content)
          refute_includes content, "uncomment"
          refute_includes content, "calc(var(--brand-chroma) - 0.02)"
        end
      end

      test "supports :root brand overrides" do
        Dir.mktmpdir("flatpack-theme-generator") do |tmpdir|
          destination = Pathname.new(tmpdir)
          generator = ThemeGenerator.new(["Acme"], {hue: 200, chroma: 0.15, as_root: true}, destination_root: destination.to_s)
          generator.destination_root = destination.to_s

          capture_io { generator.invoke_all }

          content = destination.join("app/assets/stylesheets/flat_pack_theme_acme.css").read
          assert_includes content, ":root {"
          assert_includes content, "--brand-hue: 200"
          refute_match(/\[data-theme[~=]/, content)
        end
      end

      test "inherits a base and writes an overrides-only stack" do
        Dir.mktmpdir("flatpack-theme-generator") do |tmpdir|
          destination = Pathname.new(tmpdir)
          generator = ThemeGenerator.new(["Harbor"], {inherits: "Rounded", hue: 180, chroma: 0.12, lightness: 0.48}, destination_root: destination.to_s)
          generator.destination_root = destination.to_s

          capture_io { generator.invoke_all }

          content = destination.join("app/assets/stylesheets/flat_pack_theme_harbor.css").read
          assert_includes content, '[data-theme~="harbor"]'
          assert_includes content, 'data-theme="rounded harbor"'
          assert_includes content, "--brand-hue: 180"
          refute_includes content, "--space-"
          refute_includes content, "--button-"
          refute_includes content, "--color-primary:"
        end
      end

      test "refuses to combine as_root and inherits" do
        Dir.mktmpdir("flatpack-theme-generator") do |tmpdir|
          destination = Pathname.new(tmpdir)
          generator = ThemeGenerator.new(["Harbor"], {as_root: true, inherits: "rounded"}, destination_root: destination.to_s)
          generator.destination_root = destination.to_s

          assert_raises(Thor::Error) do
            capture_io { generator.invoke_all }
          end
        end
      end
    end
  end
end
