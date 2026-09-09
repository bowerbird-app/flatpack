# frozen_string_literal: true

require "test_helper"
require "open3"

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
        carousel_controller.js
        chat_image_deck_controller.js
        sidebar_group_controller.js
        select_controller.js
        combobox_controller.js
        flatpack_date_picker_controller.js
      ]

      controllers.each do |name|
        source = FlatPack::Engine.root.join("app/javascript/flat_pack/controllers", name).read
        assert_includes source, helper, "#{name} should import #{helper}"
      end
    end

    test "select combobox and date picker play overlay enter and exit" do
      {
        "select_controller.js" => /this\.dropdownTarget\.classList\.(add|remove)\(["']hidden["']\)/,
        "combobox_controller.js" => /this\.listTarget\.classList\.(add|remove)\(["']hidden["']\)/,
        "flatpack_date_picker_controller.js" => /this\.panelElement\.classList\.remove\(["']hidden["']\)/
      }.each do |name, snap_hidden|
        source = FlatPack::Engine.root.join("app/javascript/flat_pack/controllers", name).read
        assert_includes source, "playOverlayEnter", "#{name} should play overlay enter"
        assert_includes source, "playOverlayExit", "#{name} should play overlay exit"
        refute_match snap_hidden, source, "#{name} should not snap hidden on the overlay panel"
      end
    end

    test "node tests cover overlay enter and exit helpers" do
      test_file = FlatPack::Engine.root.join("test/javascript/reduced_motion_test.js")
      stdout, status = Open3.capture2e("node", "--test", test_file.to_s)

      assert status.success?, stdout
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
      ]

      controllers.each do |name|
        source = FlatPack::Engine.root.join("app/javascript/flat_pack/controllers", name).read
        assert(
          source.match(/easing:\s*"(enter|exit|standard)"|--easing-(enter|exit|standard)/) ||
            source.include?("playCollapseExit"),
          "#{name} should use a named easing token"
        )
        refute_match(/cubic-bezier\(/, source, "#{name} should not hardcode a cubic-bezier")
        refute_includes source, "ease-in-out", "#{name} should not hardcode ease-in-out"
      end
    end

    test "kit markup does not use Tailwind numeric durations that skip token collapse" do
      leftovers = Dir[FlatPack::Engine.root.join("app/{components,javascript,assets}/**/*.{rb,js,css,erb}")].filter_map do |path|
        source = File.read(path)
        next unless source.match?(/\bduration-(150|200|300)\b/)

        path.delete_prefix("#{FlatPack::Engine.root}/")
      end

      assert_empty leftovers, "numeric duration leftover: #{leftovers.join(", ")}"
    end

    test "kit markup does not scale up on hover" do
      leftovers = Dir[FlatPack::Engine.root.join("app/{components,javascript,assets}/**/*.{rb,js,css,erb}")].filter_map do |path|
        source = File.read(path)
        next unless source.include?("hover:scale-")

        path.delete_prefix("#{FlatPack::Engine.root}/")
      end

      assert_empty leftovers, "hover scale leftover: #{leftovers.join(", ")}"
    end

    test "kit forms do not shake on invalid" do
      leftovers = Dir[FlatPack::Engine.root.join("app/{components,javascript,assets}/**/*.{rb,js,css}")].filter_map do |path|
        source = File.read(path)
        next unless source.match?(/shake|animate-shake/i)

        path.delete_prefix("#{FlatPack::Engine.root}/")
      end

      assert_empty leftovers, "form shake leftover: #{leftovers.join(", ")}"
    end

    test "spinner pulses under reduced motion instead of freezing" do
      css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read
      spinner = FlatPack::Engine.root.join("app/components/flat_pack/spinner/component.rb").read

      assert_includes spinner, "fp-spinner"
      refute_includes spinner, "motion-reduce:animate-none"
      refute_includes spinner, "animate-spin"
      assert_includes css, "@keyframes fp-spinner-spin"
      assert_includes css, "@keyframes fp-spinner-pulse"
      assert_match(/prefers-reduced-motion:\s*reduce[\s\S]*fp-spinner-pulse/m, css)
    end

    test "password toggle does not snap hidden on the eye icons" do
      component = FlatPack::Engine.root.join("app/components/flat_pack/password_input/component.rb").read
      controller = FlatPack::Engine.root.join("app/javascript/flat_pack/controllers/password_input_controller.js").read
      css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read

      refute_includes component, 'class: "hidden"'
      refute_match(/eye(Off)?IconTarget\.classList/, controller)
      assert_includes css, ".fp-password-toggle-icons"
      assert_match(/opacity\s+var\(--duration-fast\)\s+var\(--easing-standard\)/, css)
    end

    test "buttons press with a one-pixel translate and kit colour easing" do
      button = FlatPack::Engine.root.join("app/components/flat_pack/button/component.rb").read
      css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read

      assert_includes button, "fp-button"
      assert_includes button, "ease-[var(--easing-standard)]"
      refute_includes button, "active:scale"
      assert_match(/\.fp-button:active[^{]*\{[^}]*translateY\(1px\)/m, css)
      assert_match(/\.fp-button-flat:active[^{]*\{[^}]*inset/m, css)
    end

    test "alert chip and badge collapse height instead of scaling out" do
      helper = FlatPack::Engine.root.join("app/javascript/flat_pack/controllers/reduced_motion.js").read
      %w[alert_controller.js chip_controller.js badge_controller.js].each do |name|
        source = FlatPack::Engine.root.join("app/javascript/flat_pack/controllers", name).read
        assert_includes source, "playCollapseExit", "#{name} should collapse on exit"
        refute_includes source, 'scale(0.8)', "#{name} should not scale out"
        refute_includes source, "translateY(-10px)", "#{name} should not lift out of flow"
      end

      assert_includes helper, "export function playCollapseExit"
    end
  end
end
