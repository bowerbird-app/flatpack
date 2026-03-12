# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "fileutils"
require "pathname"
require "generators/flat_pack/install_generator"

module FlatPack
  module Generators
    class InstallGeneratorTest < ActiveSupport::TestCase
      test "add_stylesheet_import prepends flatpack import and is idempotent" do
        with_temp_rails_root do |tmp_root|
          stylesheets_dir = tmp_root.join("app/assets/stylesheets")
          FileUtils.mkdir_p(stylesheets_dir)
          application_css = stylesheets_dir.join("application.css")
          application_css.write("body { color: black; }\n")

          generator = build_generator
          generator.add_stylesheet_import
          generator.add_stylesheet_import

          content = application_css.read
          assert_equal 1, content.scan('@import "flat_pack/variables.css";').length
        end
      end

      test "configure_importmap appends pin config once" do
        with_temp_rails_root do |tmp_root|
          config_dir = tmp_root.join("config")
          FileUtils.mkdir_p(config_dir)
          importmap = config_dir.join("importmap.rb")
          importmap.write("pin 'application'\n")

          generator = build_generator
          generator.configure_importmap
          generator.configure_importmap

          content = importmap.read
          assert_equal 2, content.scan("pin_all_from FlatPack::Engine.root.join").length
          assert_includes content, "controllers/flat_pack"
          assert_includes content, "preload: false"
        end
      end

      test "configure_stimulus_controllers adds lazy loader once" do
        with_temp_rails_root do |tmp_root|
          controllers_dir = tmp_root.join("app/javascript/controllers")
          FileUtils.mkdir_p(controllers_dir)
          index_js = controllers_dir.join("index.js")
          index_js.write("import { application } from \"controllers/application\"\n")

          generator = build_generator
          generator.configure_stimulus_controllers
          generator.configure_stimulus_controllers

          content = index_js.read
          assert_equal 1, content.scan('lazyLoadControllersFrom("controllers/flat_pack", application)').length
          assert_includes content, "controllers/flat_pack"
        end
      end

      test "ensure_lazy_stimulus_loader_import merges into existing import" do
        generator = build_generator
        content = 'import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"\n'

        updated = generator.send(:ensure_lazy_stimulus_loader_import, content)

        assert_includes updated, "lazyLoadControllersFrom"
        assert_includes updated, "eagerLoadControllersFrom"
      end

      private

      def build_generator
        InstallGenerator.new([], {}, destination_root: Dir.mktmpdir("flatpack-generator-destination"))
      end

      def with_temp_rails_root
        Dir.mktmpdir("flatpack-install-generator") do |tmpdir|
          temp_root = Pathname.new(tmpdir)
          original_root_method = Rails.method(:root)

          Rails.singleton_class.send(:define_method, :root) { temp_root }
          yield temp_root
        ensure
          Rails.singleton_class.send(:define_method, :root) { original_root_method.call }
        end
      end
    end
  end
end
