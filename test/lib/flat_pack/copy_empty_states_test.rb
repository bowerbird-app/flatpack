# frozen_string_literal: true

require "test_helper"

module FlatPack
  class CopyEmptyStatesTest < ActiveSupport::TestCase
    test "skeleton and infinite pagination use a typographic ellipsis for loading copy" do
      skeleton = FlatPack::Engine.root.join("app/components/flat_pack/skeleton/component.rb").read
      pagination = FlatPack::Engine.root.join("app/components/flat_pack/pagination_infinite/component.rb").read
      numbered = FlatPack::Engine.root.join("app/components/flat_pack/pagination/component.rb").read
      infinite_js = FlatPack::Engine.root.join("app/javascript/flat_pack/controllers/pagination_infinite_controller.js").read

      assert_includes skeleton, '"Loading…"'
      refute_includes skeleton, '"Loading..."'
      assert_includes pagination, '"Loading more…"'
      refute_includes pagination, '"Loading more..."'
      assert_includes numbered, '"Loading more…"'
      refute_includes numbered, '"Loading more..."'
      assert_includes infinite_js, '"Loading…"'
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
