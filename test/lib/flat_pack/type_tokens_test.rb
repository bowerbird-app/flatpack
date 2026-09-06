# frozen_string_literal: true

require "test_helper"

module FlatPack
  class TypeTokensTest < ActiveSupport::TestCase
    test "font and type scale tokens are concrete on :root so browsers can resolve them" do
      css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/variables.css").read
      root_block = css[/^:root \{.*?^\}/m]

      refute_nil root_block, "expected a :root block in variables.css"
      assert_match(/--font-sans:\s*system-ui/, root_block)
      assert_match(/--font-mono:\s*ui-monospace/, root_block)
      assert_match(/--text-xs:\s*0\.75rem/, root_block)
      assert_match(/--text-sm:\s*0\.875rem/, root_block)
      assert_match(/--text-base:\s*1rem/, root_block)
      assert_match(/--text-lg:\s*1\.125rem/, root_block)
      assert_match(/--text-xl:\s*1\.25rem/, root_block)
      assert_match(/--text-2xl:\s*1\.5rem/, root_block)
      assert_match(/--text-3xl:\s*1\.875rem/, root_block)
      assert_match(/--text-4xl:\s*2\.25rem/, root_block)
      assert_match(/--text-5xl:\s*3rem/, root_block)
      assert_match(/--page-title-h1-size:\s*var\(--text-4xl\)/, root_block)
      assert_match(/--page-title-h6-size:\s*var\(--text-base\)/, root_block)
    end

    test "root applies the kit face and antialiased smoothing" do
      css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/variables.css").read
      root_block = css[/^:root \{.*?^\}/m]

      assert_match(/font-family:\s*var\(--font-sans\)/, root_block)
      assert_includes root_block, "-webkit-font-smoothing: antialiased"
      assert_includes root_block, "-moz-osx-font-smoothing: grayscale"
    end

    test "kit CSS ships tabular nums and title wrapping without a Tailwind rebuild" do
      css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read

      assert_includes css, ".fp-tabular-nums"
      assert_includes css, "font-variant-numeric: tabular-nums"
      assert_includes css, ".fp-text-balance"
      assert_includes css, "text-wrap: balance"
      assert_includes css, ".fp-text-pretty"
      assert_includes css, "text-wrap: pretty"
    end

    test "kit components do not force all-caps tracked-out labels" do
      leftovers = Dir[FlatPack::Engine.root.join("app/components/**/*.rb")].filter_map do |path|
        next if path.end_with?("avatar/component.rb")

        source = File.read(path)
        next unless source.match?(/uppercase|tracking-widest|tracking-wider|tracking-wide/)

        path.delete_prefix("#{FlatPack::Engine.root}/")
      end

      assert_empty leftovers, "all-caps label leftover: #{leftovers.join(", ")}"
    end
  end
end
