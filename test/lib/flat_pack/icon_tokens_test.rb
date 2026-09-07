# frozen_string_literal: true

require "test_helper"

module FlatPack
  class IconTokensTest < ActiveSupport::TestCase
    test "outline stroke width is concrete on :root" do
      css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/variables.css").read
      root_block = css[/^:root \{.*?^\}/m]

      refute_nil root_block, "expected a :root block in variables.css"
      assert_match(/--icon-stroke-width:\s*1\.5/, root_block)
    end

    test "kit CSS applies the stroke token and RTL directional flip" do
      css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read

      assert_includes css, "stroke-width: var(--icon-stroke-width, 1.5)"
      assert_includes css, "[dir=\"rtl\"] .fp-icon-directional"
      assert_includes css, "scale: -1 1"
    end

    test "icon controller outline stroke uses the token" do
      js = FlatPack::Engine.root.join("app/javascript/flat_pack/controllers/icon_controller.js").read

      assert_includes js, '"stroke-width": "var(--icon-stroke-width, 1.5)"'
    end

    test "components do not ship lucide leftover class names" do
      leftovers = Dir[FlatPack::Engine.root.join("app/components/**/*.rb")].filter_map do |path|
        source = File.read(path)
        next unless source.match?(/\blucide\b/)

        path.delete_prefix("#{FlatPack::Engine.root}/")
      end

      assert_empty leftovers, "lucide leftover: #{leftovers.join(", ")}"
    end
  end
end
