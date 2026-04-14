# frozen_string_literal: true

require "test_helper"

module FlatPack
  class InstallContractTest < ActiveSupport::TestCase
    setup do
      FlatPack::InstallContract.reset!
    end

    test "loads the shipped install contract" do
      assert_predicate FlatPack::InstallContract.path, :exist?

      data = FlatPack::InstallContract.data

      assert_equal 1, data.fetch("schema_version")
      assert_equal FlatPack::VERSION, data.dig("gem", "version")
      assert_equal "docs/ai/README.md", data.dig("artifacts", "ai_entrypoint")
      assert_equal "bin/rake flat_pack:verify_install", data.dig("install", "verification_command")
    end

    test "pretty_json returns parseable json" do
      parsed = JSON.parse(FlatPack::InstallContract.pretty_json)

      assert_equal FlatPack::InstallContract.data, parsed
    end
  end
end
