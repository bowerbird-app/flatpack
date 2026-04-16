# frozen_string_literal: true

require "test_helper"
require "tmpdir"
require "fileutils"
require "pathname"

module FlatPack
  class InstallVerifierTest < ActiveSupport::TestCase
    setup do
      @contract = FlatPack::InstallContract.data
    end

    test "passes when host app matches the install contract" do
      with_temp_rails_root do |root|
        write_file(root, "app/views/layouts/application.html.erb", <<~ERB)
          <html>
            <head>
              <%= stylesheet_link_tag "flat_pack/variables", "data-turbo-track": "reload" %>
              <%= stylesheet_link_tag "flat_pack/rich_text", "data-turbo-track": "reload" %>
            </head>
          </html>
        ERB
        write_file(root, "config/importmap.rb", <<~RUBY)
          pin_all_from FlatPack::Engine.root.join("app/javascript/flat_pack/controllers"), under: "controllers/flat_pack", to: "flat_pack/controllers", preload: false
          pin_all_from FlatPack::Engine.root.join("app/javascript/flat_pack/tiptap"), under: "flat_pack/tiptap", to: "flat_pack/tiptap", preload: false
          pin "flat_pack/heroicons", to: "flat_pack/heroicons.js", preload: false
        RUBY
        write_file(root, "app/javascript/controllers/index.js", <<~JS)
          import { application } from "controllers/application"
          import { lazyLoadControllersFrom } from "@hotwired/stimulus-loading"

          lazyLoadControllersFrom("controllers", application)
        JS
        write_file(root, "app/assets/stylesheets/application.tailwind.css", <<~CSS)
          @import "tailwindcss";

          @source "../../../bundle/ruby/3.2.0/gems/flat_pack-0.1.27/app/components";

          @theme {
            --color-fp-primary: oklch(0.52 0.26 250);
          }

          :root {
            --color-primary: var(--color-fp-primary);
          }
        CSS

        result = FlatPack::InstallVerifier.new(rails_root: root, contract: @contract).call

        assert_predicate result, :success?
        assert_equal [], result.failures
      end
    end

    test "fails when a required snippet is missing" do
      with_temp_rails_root do |root|
        write_file(root, "app/views/layouts/application.html.erb", <<~ERB)
          <html><head></head></html>
        ERB

        result = FlatPack::InstallVerifier.new(rails_root: root, contract: @contract).call

        refute_predicate result, :success?
        assert_includes result.failures.map(&:id), "layout_stylesheet_tags"
      end
    end

    private

    def with_temp_rails_root
      Dir.mktmpdir("flatpack-install-verifier") do |tmpdir|
        yield Pathname.new(tmpdir)
      end
    end

    def write_file(root, relative_path, content)
      absolute_path = root.join(relative_path)
      FileUtils.mkdir_p(absolute_path.dirname)
      absolute_path.write(content)
    end
  end
end
