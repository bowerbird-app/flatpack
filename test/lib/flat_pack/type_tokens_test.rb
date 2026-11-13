# frozen_string_literal: true

require "test_helper"

module FlatPack
  class TypeTokensTest < ActiveSupport::TestCase
    test "font and type scale tokens are concrete on :root so browsers can resolve them" do
      css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/variables.css").read
      root_block = css[/^:root(?:,\s*\[data-theme\])?\s*\{.*?^\}/m]

      refute_nil root_block, "expected a :root, [data-theme] block in variables.css"
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
      assert_match(/--text-6xl:\s*3\.75rem/, root_block)
      assert_match(/--text-6xl--line-height:\s*1/, root_block)
      assert_match(/--text-7xl:\s*4\.5rem/, root_block)
      assert_match(/--text-7xl--line-height:\s*1/, root_block)
      assert_match(/--text-8xl:\s*6rem/, root_block)
      assert_match(/--text-8xl--line-height:\s*1/, root_block)
      assert_match(/--type-display-size-min:\s*var\(--text-5xl\)/, root_block)
      assert_match(/--type-display-size-max:\s*5\.5rem/, root_block)
      assert_match(/--type-display-size:\s*clamp\(var\(--type-display-size-min\), 1rem \+ 5vw, var\(--type-display-size-max\)\)/, root_block)
      assert_match(/--type-display-tracking:\s*-0\.03em/, root_block)
      assert_match(/--type-display-leading:\s*1\.05/, root_block)
      assert_match(/--type-display-weight:\s*600/, root_block)
      assert_match(/--display-size-min:\s*var\(--type-display-size-min\)/, root_block)
      assert_match(/--display-size:\s*var\(--type-display-size\)/, root_block)
      assert_match(/--display-weight:\s*var\(--type-display-weight\)/, root_block)
      assert_match(/--type-section-size:\s*var\(--text-2xl\)/, root_block)
      assert_match(/--type-section-weight:\s*600/, root_block)
      assert_match(/--type-heading-size:\s*var\(--text-2xl\)/, root_block)
      assert_match(/--type-heading-weight:\s*600/, root_block)
      assert_match(/--type-heading-tracking:\s*-0\.025em/, root_block)
      assert_match(/--card-title-size:\s*var\(--type-heading-size\)/, root_block)
      assert_match(/--card-title-weight:\s*var\(--type-heading-weight\)/, root_block)
      assert_match(/--type-body-size:\s*var\(--text-base\)/, root_block)
      assert_match(/--type-body-leading:\s*1\.75/, root_block)
      assert_match(/--type-body-weight:\s*400/, root_block)
      assert_match(/--type-control-size:\s*var\(--text-sm\)/, root_block)
      assert_match(/--type-control-weight:\s*500/, root_block)
      assert_match(/--type-pill-size:\s*var\(--text-sm\)/, root_block)
      assert_match(/--type-pill-weight:\s*500/, root_block)
      assert_match(/--page-title-h1-size:\s*var\(--text-4xl\)/, root_block)
      assert_match(/--page-title-h6-size:\s*var\(--text-base\)/, root_block)
      assert_match(/--content-p-size:\s*var\(--text-lg\)/, root_block)
      assert_match(/--content-kicker-size:\s*var\(--text-lg\)/, root_block)
      assert_match(/--content-lead-size:\s*var\(--text-2xl\)/, root_block)
      assert_match(/--content-h1-size:\s*var\(--text-5xl\)/, root_block)
      assert_match(/--content-h2-size:\s*var\(--text-3xl\)/, root_block)
      assert_match(/--content-h3-size:\s*var\(--text-2xl\)/, root_block)
      assert_match(/--content-h4-size:\s*var\(--text-xl\)/, root_block)
      assert_match(/--content-h5-size:\s*var\(--text-lg\)/, root_block)
      assert_match(/--content-h6-size:\s*var\(--text-lg\)/, root_block)
      assert_match(/--hero-headline-size:\s*var\(--text-5xl\)/, root_block)
      assert_match(/--hero-description-size:\s*var\(--text-xl\)/, root_block)
      assert_match(/--hero-title-md-size-min:\s*var\(--text-4xl\)/, root_block)
      assert_match(/--hero-title-md-size-max:\s*var\(--text-6xl\)/, root_block)
      assert_match(/--hero-title-md-size:\s*clamp\(var\(--hero-title-md-size-min\), 1rem \+ 3\.5vw, var\(--hero-title-md-size-max\)\)/, root_block)
      assert_match(/--hero-title-lg-size-min:\s*var\(--text-5xl\)/, root_block)
      assert_match(/--hero-title-lg-size-max:\s*var\(--text-7xl\)/, root_block)
      assert_match(/--hero-title-lg-size:\s*clamp\(var\(--hero-title-lg-size-min\), 1rem \+ 4\.5vw, var\(--hero-title-lg-size-max\)\)/, root_block)
      assert_match(/--hero-title-xl-size:\s*var\(--display-size\)/, root_block)
      assert_match(/--hero-title-xxl-size-min:\s*var\(--text-5xl\)/, root_block)
      assert_match(/--hero-title-xxl-size-max:\s*var\(--text-8xl\)/, root_block)
      assert_match(/--hero-title-xxl-size:\s*clamp\(var\(--hero-title-xxl-size-min\), 1rem \+ 5\.5vw, var\(--hero-title-xxl-size-max\)\)/, root_block)
    end

    test "root applies the kit face and antialiased smoothing" do
      css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/variables.css").read
      root_block = css[/^:root(?:,\s*\[data-theme\])?\s*\{.*?^\}/m]

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
      assert_includes css, ".fp-hero-title"
      assert_includes css, ".fp-hero-title--md"
      assert_includes css, ".fp-hero-title--xl"
      assert_includes css, ".fp-hero-title--xxl"
      assert_includes css, "font-size: var(--hero-title-xl-size)"
      assert_includes css, ".fp-display"
      assert_includes css, "font-size: var(--type-display-size)"
      assert_includes css, "font-weight: var(--type-display-weight)"
      assert_includes css, "letter-spacing: var(--type-display-tracking)"
      assert_includes css, "line-height: var(--type-display-leading)"
      assert_includes css, ".fp-type-heading"
      assert_includes css, ".fp-type-body"
      assert_includes css, ".fp-type-control"
      assert_includes css, ".fp-type-pill"
      assert_includes css, "font-weight: var(--type-heading-weight)"
      assert_includes css, "font-weight: var(--type-body-weight)"
      assert_includes css, ".fp-display-subtitle"
      assert_includes css, "/* Cover type. Unlayered so Tailwind preflight cannot collapse"
      assert_includes css, ".fp-text-pretty"
      assert_includes css, "text-wrap: pretty"
      assert_includes css, ".fp-content"
      assert_includes css, "font-size: var(--content-p-size, var(--text-lg, 1.125rem))"
      assert_includes css, "font-size: var(--content-h1-size, var(--text-5xl, 3rem))"
      refute_match(/@media \(min-width: 640px\) \{\s*\.fp-content h1/, css)
      assert_includes css, "/* Long-form reading type. Unlayered so Tailwind preflight cannot collapse"
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

    test "rounded owns Inter and the Figma cover metrics" do
      css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/variables.css").read
      rounded = css[/^\[data-theme~="rounded"\]\s*\{.*?^\}/m]

      assert_match(/--font-sans:\s*"Inter", system-ui/, rounded)
      assert_match(/--type-display-size-min:\s*2\.5rem/, rounded)
      assert_match(/--type-display-size-max:\s*6\.5rem/, rounded)
      assert_match(/--type-display-leading:\s*0\.98/, rounded)
      assert_match(/--type-display-weight:\s*500/, rounded)
      assert_match(/--type-display-tracking:\s*-0\.03em/, rounded)
      assert_match(/--type-section-size-min:\s*1\.3125rem/, rounded)
      assert_match(/--type-section-size-max:\s*2\.25rem/, rounded)
      assert_match(/--type-section-leading:\s*1\.286/, rounded)
      assert_match(/--type-section-weight:\s*500/, rounded)
      assert_match(/--type-section-tracking:\s*-0\.02em/, rounded)
      assert_match(/--type-heading-weight:\s*500/, rounded)
      assert_match(/--type-heading-tracking:\s*-0\.02em/, rounded)
      assert_match(/--type-body-weight:\s*400/, rounded)
      assert_match(/--type-control-weight:\s*500/, rounded)
      assert_match(/--type-control-tracking:\s*-0\.015em/, rounded)
      assert_match(/--type-pill-weight:\s*600/, rounded)
      assert_match(/@media \(max-width: 639px\) \{\s*\[data-theme~="rounded"\] \{\s*--type-display-leading:\s*1\.075/m, css)
      assert_match(/--type-display-tracking:\s*-0\.025em/, css)
      assert_includes css, 'font-family: "Inter"'
      assert_includes css, 'url("../flat_pack/inter-latin-400.woff2")'
      assert_includes css, "inter-latin-500.woff2"
      assert_includes css, "inter-latin-600.woff2"
      assert_includes css, "inter-latin-700.woff2"
      %w[400 500 600 700].each do |weight|
        path = FlatPack::Engine.root.join("app/assets/fonts/flat_pack/inter-latin-#{weight}.woff2")
        assert path.file?, "missing Inter #{weight}"
        assert path.size > 10_000, "Inter #{weight} looks empty"
      end
    end

    test "dark and ocean do not reset the type roles or the face" do
      css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/variables.css").read

      %w[dark ocean].each do |theme|
        block = css[/^\[data-theme~="#{theme}"\]\s*\{.*?^\}/m]
        refute_includes block, "--font-sans"
        refute_includes block, "--type-display"
        refute_includes block, "--type-heading"
      end
    end

    test "email components stay on Arial" do
      %w[email_button email_card email_footer_links email_template_example].each do |name|
        source = Dir[FlatPack::Engine.root.join("app/components/flat_pack/#{name}/**/*.rb")].map { |path| File.read(path) }.join
        assert_includes source, "Arial,sans-serif"
      end
    end
  end
end
