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
          generator = ThemeGenerator.new(["Sunrise"], {hue: 35, chroma: 0.2}, destination_root: destination.to_s)
          generator.destination_root = destination.to_s

          capture_io { generator.invoke_all }

          path = destination.join("app/assets/stylesheets/flat_pack_theme_sunrise.css")
          assert path.exist?
          content = path.read
          assert_includes content, '[data-theme="sunrise"]'
          assert_includes content, "--brand-hue: 35"
          assert_includes content, "--brand-chroma: 0.2"
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
          refute_includes content, "data-theme"
        end
      end
    end
  end
end
