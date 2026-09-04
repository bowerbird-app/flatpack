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

    test "easing tokens are concrete curves on :root so browsers can resolve them" do
      css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/variables.css").read
      root_block = css[/^:root \{.*?^\}/m]

      refute_nil root_block, "expected a :root block in variables.css"
      assert_match(/--easing-standard:\s*cubic-bezier\(0\.2, 0, 0, 1\)/, root_block)
      assert_match(/--easing-enter:\s*cubic-bezier\(0\.05, 0\.7, 0\.1, 1\)/, root_block)
      assert_match(/--easing-exit:\s*cubic-bezier\(0\.3, 0, 1, 1\)/, root_block)
    end

    test "stimulus overlays import the reduced motion helper" do
      helper = "controllers/flat_pack/reduced_motion"
      controllers = %w[
        toast_controller.js
        modal_controller.js
        popover_controller.js
        tooltip_controller.js
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

    test "javascript transitions use named easing tokens" do
      controllers = %w[
        toast_controller.js
        modal_controller.js
        button_dropdown_controller.js
        popover_controller.js
        tooltip_controller.js
        alert_controller.js
        chip_controller.js
        badge_controller.js
        table_controller.js
        sidebar_group_controller.js
        sidebar_layout_controller.js
        navbar_controller.js
      ]

      controllers.each do |name|
        source = FlatPack::Engine.root.join("app/javascript/flat_pack/controllers", name).read
        assert_match(/--easing-(enter|exit|standard)/, source, "#{name} should use a named --easing-* token")
        refute_match(/cubic-bezier\(/, source, "#{name} should not hardcode a cubic-bezier")
        refute_includes source, "ease-in-out", "#{name} should not hardcode ease-in-out"
      end
    end

    test "kit forms do not shake on invalid" do
      leftovers = Dir[FlatPack::Engine.root.join("app/{components,javascript,assets}/**/*.{rb,js,css}")].filter_map do |path|
        source = File.read(path)
        next unless source.match?(/shake|animate-shake/i)

        path.delete_prefix("#{FlatPack::Engine.root}/")
      end

      assert_empty leftovers, "form shake leftover: #{leftovers.join(", ")}"
    end
  end
end
