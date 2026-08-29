# frozen_string_literal: true

require "test_helper"

module FlatPack
  class VersionTest < ActiveSupport::TestCase
    test "version constant is present" do
      assert_predicate FlatPack::VERSION, :present?
      assert_match(/\A\d+\.\d+\.\d+\z/, FlatPack::VERSION)
    end

    test "installation docs do not hardcode a Current Version stamp" do
      installation_docs = FlatPack::Engine.root.join("docs/installation.md").read

      refute_match(/\*\*Current Version:\*\*\s*\d+\.\d+\.\d+/, installation_docs)
    end
  end
end
