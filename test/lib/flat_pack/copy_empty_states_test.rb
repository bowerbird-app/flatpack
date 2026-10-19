# frozen_string_literal: true

require "test_helper"
require "yaml"

module FlatPack
  class CopyEmptyStatesTest < ActiveSupport::TestCase
    test "skeleton and infinite pagination use a typographic ellipsis for loading copy" do
      locales = YAML.safe_load_file(FlatPack::Engine.root.join("config/locales/flatpack.en.yml"))
      skeleton = locales.dig("en", "flatpack", "skeleton", "loading")
      loading_more = locales.dig("en", "flatpack", "pagination", "loading_more")
      loading = locales.dig("en", "flatpack", "pagination", "loading")
      infinite_js = FlatPack::Engine.root.join("app/javascript/flat_pack/controllers/pagination_infinite_controller.js").read

      assert_equal "Loading…", skeleton
      refute_includes skeleton, "..."
      assert_equal "Loading more…", loading_more
      refute_includes loading_more, "..."
      assert_equal "Loading…", loading
      refute_includes loading, "..."
      assert_includes infinite_js, 'flatPackCopy("pagination.loading")'
      refute_includes infinite_js, '"Loading..."'
    end

    test "empty state uses kit enter motion instead of leftover illustration SVGs" do
      source = FlatPack::Engine.root.join("app/components/flat_pack/empty_state/component.rb").read
      css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read

      refute_includes source, "ICONS"
      refute_match(/stroke-width="1\.5"/, source)
      assert_includes source, "fp-empty-state"
      assert_includes css, ".fp-empty-state"
      assert_includes css, ".fp-content-enter"
      assert_includes css, "@starting-style"
    end

    test "billing empty states do not lead with an inbox illustration" do
      invoice = FlatPack::Engine.root.join("app/components/flat_pack/billing/invoice_list/component.rb").read
      payment = FlatPack::Engine.root.join("app/components/flat_pack/billing/payment_method/component.rb").read

      refute_includes invoice, "icon: :inbox"
      refute_includes payment, "icon: :inbox"
    end
  end
end
