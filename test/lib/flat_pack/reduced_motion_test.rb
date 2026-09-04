# frozen_string_literal: true

require "test_helper"

module FlatPack
  class ReducedMotionTest < ActiveSupport::TestCase
    test "duration tokens collapse under prefers-reduced-motion" do
      css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/variables.css").read

      assert_includes css, "@media (prefers-reduced-motion: reduce)"
      %w[--duration-fast --duration-base --duration-slow --skeleton-shimmer-duration].each do |token|
        assert_match(/#{Regexp.escape(token)}:\s*0ms/, css)
      end
    end

    test "duration tokens are concrete times on :root so browsers can resolve them" do
      css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/variables.css").read
      root_block = css[/^:root \{.*?^\}/m]

      refute_nil root_block, "expected a :root block in variables.css"
      assert_match(/--duration-fast:\s*150ms/, root_block)
      assert_match(/--duration-base:\s*200ms/, root_block)
      assert_match(/--duration-slow:\s*300ms/, root_block)
    end

    test "stimulus overlays import the reduced motion helper" do
      helper = "controllers/flat_pack/reduced_motion"
      controllers = %w[
        toast_controller.js
        modal_controller.js
        alert_controller.js
        badge_controller.js
        chip_controller.js
        button_dropdown_controller.js
        table_controller.js
        accordion_controller.js
        collapse_controller.js
        navbar_controller.js
        carousel_controller.js
        chat_image_deck_controller.js
        sidebar_group_controller.js
      ]

      controllers.each do |name|
        source = FlatPack::Engine.root.join("app/javascript/flat_pack/controllers", name).read
        assert_includes source, helper, "#{name} should import #{helper}"
      end
    end

    test "kit javascript does not copy prefers-reduced-motion matchMedia besides the helper" do
      helper = FlatPack::Engine.root.join("app/javascript/flat_pack/controllers/reduced_motion.js")
      leftovers = Dir[FlatPack::Engine.root.join("app/javascript/**/*.js")].filter_map do |path|
        next if Pathname.new(path) == helper
        next unless File.read(path).include?("prefers-reduced-motion")

        path.delete_prefix("#{FlatPack::Engine.root}/")
      end

      assert_empty leftovers, "copy-pasted reduced-motion checks: #{leftovers.join(", ")}"
    end
  end
end
