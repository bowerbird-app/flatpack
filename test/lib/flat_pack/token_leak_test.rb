# frozen_string_literal: true

require "test_helper"

module FlatPack
  class TokenLeakTest < ActiveSupport::TestCase
    KIT_GLOBS = [
      "app/components/**/*.{rb,erb}",
      "app/javascript/**/*.{js,ts}"
    ].freeze

    LEAK_PATTERNS = [
      /text-green-600/,
      /text-red-600/,
      /bg-black(?:\/|\b)/,
      /hover:bg-black/,
      /bg-\[rgba\(0,\s*0,\s*0/,
      /ring-black\//,
      /text-white/,
      /\bborder-white\b/,
      /\bbg-white\b/
    ].freeze

    test "kit Ruby and JavaScript do not hardcode Tailwind palette overlays" do
      leaks = []

      KIT_GLOBS.flat_map { |pattern| Dir[FlatPack::Engine.root.join(pattern)] }.each do |path|
        File.read(path).each_line.with_index(1) do |line, line_number|
          LEAK_PATTERNS.each do |pattern|
            next unless line.match?(pattern)

            relative = Pathname.new(path).relative_path_from(FlatPack::Engine.root)
            leaks << "#{relative}:#{line_number}: #{line.strip}"
          end
        end
      end

      assert_empty leaks, -> { "Hardcoded palette leaks:\n#{leaks.join("\n")}" }
    end

    test "picker grid chrome references overlay tokens" do
      js = FlatPack::Engine.root.join("app/javascript/flat_pack/controllers/picker_controller.js").read

      assert_includes js, "--picker-badge-background-color"
      assert_includes js, "--picker-badge-text-color"
      assert_includes js, "--picker-selection-idle-background-color"
      assert_includes js, "--picker-selection-idle-ring-color"
      assert_includes js, "--picker-selection-indicator-border-color"
      assert_includes js, "--picker-selection-indicator-fill-color"
      refute_includes js, "border-white"
      refute_includes js, "bg-white"
    end
  end
end
