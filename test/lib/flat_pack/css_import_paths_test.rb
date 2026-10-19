# frozen_string_literal: true

require "test_helper"

module FlatPack
  class CssImportPathsTest < ActiveSupport::TestCase
    IMPORTED_SHEETS = %w[variables rich_text content_editor inline_edit].freeze

    test "application.css imports compile to digested sibling urls" do
      assembly = Rails.application.assets
      asset = assembly.load_path.find("flat_pack/application.css")
      compiled = asset.compiled_content

      assert_operator compiled.index("@import"), :<, compiled.index("@layer")
      refute_match(%r{flat_pack/flat_pack/}, compiled)
      refute_match(/@import\s+["']/, compiled)

      imports = compiled.scan(/@import\s+url\(\s*"([^"]+)"\s*\)/).flatten

      assert_equal IMPORTED_SHEETS.size, imports.size

      IMPORTED_SHEETS.zip(imports).each do |name, url|
        sibling = assembly.load_path.find("flat_pack/#{name}.css")

        assert sibling, "missing flat_pack/#{name}.css on the Propshaft load path"
        assert File.file?(sibling.path)
        assert_equal "#{assembly.prefix}#{sibling.digested_path}", url
        assert_match(%r{\A/assets/flat_pack/#{name}-[0-9a-f]{8}\.css\z}, url)
      end

      referenced = assembly.load_path.find_referenced_by(asset).map { |item| item.logical_path.to_s }
      assert_equal IMPORTED_SHEETS.map { |name| "flat_pack/#{name}.css" }.sort, referenced.sort
    end

    test "precompile writes application.css imports as digested files that exist" do
      assembly = Rails.application.assets
      output = Rails.root.join("tmp/css-import-precompile")
      FileUtils.rm_rf(output)

      Propshaft::Processor.new(
        load_path: assembly.load_path,
        output_path: output,
        compilers: assembly.compilers,
        manifest_path: output.join(".manifest.json")
      ).process

      application = assembly.load_path.find("flat_pack/application.css")
      compiled_file = output.join(application.digested_path)

      assert compiled_file.file?, compiled_file.to_s

      body = compiled_file.read
      imports = body.scan(/@import\s+url\(\s*"([^"]+)"\s*\)/).flatten

      assert_equal IMPORTED_SHEETS.size, imports.size
      imports.each do |url|
        relative = url.delete_prefix(assembly.prefix)
        digested = output.join(relative)

        assert digested.file?, digested.to_s
        assert_match(%r{\Aflat_pack/.+-[0-9a-f]{8}\.css\z}, relative)
      end
    ensure
      FileUtils.rm_rf(Rails.root.join("tmp/css-import-precompile"))
    end

    test "kit css does not use a bare string import" do
      root = FlatPack::Engine.root
      offenders = Dir[root.join("app/assets/stylesheets/**/*.css").to_s].flat_map do |path|
        File.readlines(path).filter_map.with_index(1) do |line, number|
          next unless line.match?(/@import\s+["']/)

          "#{Pathname.new(path).relative_path_from(root)}:#{number}: #{line.strip}"
        end
      end

      assert_empty offenders
    end
  end
end
