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

    test "view component dependency allows the GHSA-8qw7-6phv-7q6p fix and excludes 4.12" do
      spec = Gem::Specification.load(FlatPack::Engine.root.join("flat_pack.gemspec").to_s)
      requirement = spec.dependencies.find { |dependency| dependency.name == "view_component" }.requirement

      assert requirement.satisfied_by?(Gem::Version.new("4.14.0"))
      assert requirement.satisfied_by?(Gem::Version.new("4.19.0"))
      refute requirement.satisfied_by?(Gem::Version.new("4.12.0"))
      refute requirement.satisfied_by?(Gem::Version.new("4.13.0"))
      refute requirement.satisfied_by?(Gem::Version.new("5.0.0"))
      assert Gem::Requirement.new(">= 4.14", "< 5").satisfied_by?(Gem::Version.new(ViewComponent::VERSION::STRING))
      assert_equal "ViewComponent::ReusedInstanceError", ViewComponent::ReusedInstanceError.name
    end
  end
end
