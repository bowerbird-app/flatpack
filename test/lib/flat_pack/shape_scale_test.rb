# frozen_string_literal: true

require "test_helper"

module FlatPack
  class ShapeScaleTest < ActiveSupport::TestCase
    # Circles, capsules, and dots that stay round on every theme.
    GEOMETRIC_ROUNDED_FULL = %w[
      app/components/flat_pack/avatar/component.rb
      app/components/flat_pack/badge/component.rb
      app/components/flat_pack/carousel/component.rb
      app/components/flat_pack/chat/message_group/component.rb
      app/components/flat_pack/chat/typing_indicator/component.rb
      app/components/flat_pack/fab/component.rb
      app/components/flat_pack/font_swatch/component.rb
      app/components/flat_pack/lightbox/component.rb
      app/components/flat_pack/notification/component.rb
      app/components/flat_pack/radio_group/component.rb
      app/components/flat_pack/skeleton/component.rb
      app/components/flat_pack/stepper/component.rb
      app/components/flat_pack/switch/component.rb
      app/components/flat_pack/timeline/item.rb
      app/components/flat_pack/tree/component.rb
      app/components/flat_pack/video_preview/component.rb
      app/javascript/flat_pack/controllers/picker_controller.js
    ].freeze

    setup do
      @css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/variables.css").read
    end

    test "themeable kit files do not hard-code rounded-full" do
      root = FlatPack::Engine.root
      offenders = []

      %w[app/components app/javascript].each do |directory|
        Dir[root.join(directory, "**/*.{rb,js}")].each do |path|
          relative = Pathname.new(path).relative_path_from(root).to_s
          next if GEOMETRIC_ROUNDED_FULL.include?(relative)
          next unless File.read(path).include?("rounded-full")

          offenders << relative
        end
      end

      assert_empty offenders
    end

    test "9999px stays on geometric circles and the full step" do
      assert_equal 4, @css.scan("9999px").size
      refute_includes @css, "--chip-border-radius: 0.5rem"
      refute_includes @css, "--checkbox-radius: 0.125rem"
      refute_includes @css, "--tabs-pill-corner-radius: 9999px"
      refute_includes @css, "--comments-inline-input-radius: 9999px"
      assert_includes @css, "--avatar-radius-circle: 9999px"
      assert_includes @css, "--color-swatch-radius: 9999px"
      assert_includes @css, "--font-swatch-radius: 9999px"

      application = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read
      assert_equal 5, application.scan(/border-radius:\s*9999px/).size
    end

    test "dark and ocean inherit the default shape" do
      dark_block = @css[/\[data-theme="dark"\]\s*\{(.*?)\}/m, 1]
      ocean_block = @css[/\[data-theme="ocean"\]\s*\{(.*?)\}/m, 1]

      %w[--radius- --button-border-radius --form-control-radius --card-radius --menu-radius --modal-radius --badge-radius --chip-border-radius].each do |token|
        refute_includes dark_block, token
        refute_includes ocean_block, token
      end
    end
  end
end
