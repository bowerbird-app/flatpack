# frozen_string_literal: true

require "test_helper"
require "open3"

module FlatPack
  class RemoteQueryTest < ActiveSupport::TestCase
    CALLERS = %w[
      select_controller.js
      picker_controller.js
      search_controller.js
      combobox_controller.js
    ].freeze

    test "node tests cover debounce, abort, and stop" do
      test_file = FlatPack::Engine.root.join("test/javascript/remote_query_test.js")
      stdout, status = Open3.capture2e("node", "--test", test_file.to_s)

      assert status.success?, stdout
    end

    test "select picker search and combobox share one remote query helper" do
      helper = FlatPack::Engine.root.join("app/javascript/flat_pack/remote_query.js").read

      assert_includes helper, "export function createRemoteQuery"
      assert_equal 1, helper.scan("new AbortController").length
      assert_equal 1, helper.scan("setTimeout").length

      CALLERS.each do |name|
        source = controller_source(name)

        assert_includes source, 'from "flat_pack/remote_query"', name
        assert_includes source, "createRemoteQuery", name
        refute_includes source, "new AbortController", name
        refute_includes source, "debounceTimer", name
        refute_includes source, "setTimeout", name
      end

      select = controller_source("select_controller.js")
      picker = controller_source("picker_controller.js")
      search = controller_source("search_controller.js")
      combobox = controller_source("combobox_controller.js")

      assert_includes select, "this.remote.debounce(250"
      assert_includes picker, "this.remote.debounce(250"
      assert_includes search, "this.remote.debounce(this.debounceValue"
      assert_includes combobox, "this.remote.debounce(this.debounceValue"
      assert_includes picker, "params.kinds"
      assert_includes search, "payload.results"
      assert_includes combobox, "payload?.items"
      refute_includes combobox, "addEventListener(\"mousedown\""
    end

    private

    def controller_source(name)
      FlatPack::Engine.root.join("app/javascript/flat_pack/controllers", name).read
    end
  end
end
