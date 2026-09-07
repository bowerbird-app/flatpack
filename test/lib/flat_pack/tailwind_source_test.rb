# frozen_string_literal: true

require "test_helper"

module FlatPack
  class TailwindSourceTest < ActiveSupport::TestCase
    SELF_REFERENTIAL_VARIABLE_PATTERN = /--([a-zA-Z][\w-]*):\s*var\(--\1\)/
    TEMPLATE_PATH = FlatPack::Engine.root.join("lib/generators/flat_pack/templates/tailwind_config.css.tt")
    DUMMY_TAILWIND_PATH = Rails.root.join("app/assets/stylesheets/application.tailwind.css")

    test "generator tailwind template avoids self referential css variable mappings" do
      content = TEMPLATE_PATH.read

      assert_no_match SELF_REFERENTIAL_VARIABLE_PATTERN, content
    end

    test "dummy tailwind scaffold avoids self referential css variable mappings" do
      content = DUMMY_TAILWIND_PATH.read

      assert_no_match SELF_REFERENTIAL_VARIABLE_PATTERN, content
    end

    test "dummy host stylesheet re-sets kit radii on unlayered :root" do
      content = DUMMY_TAILWIND_PATH.read
      root_block = content[/^:root \{.*?^\}/m]

      refute_nil root_block, "expected an unlayered :root block in dummy application.tailwind.css"
      assert_includes root_block, "--radius-sm: 0.75rem;"
      assert_includes root_block, "--radius-md: 1rem;"
      assert_includes root_block, "--radius-lg: 1.5rem;"
      assert_includes root_block, "--radius-xl: 2rem;"
      refute_includes root_block, "@layer"
    end

    test "install generator template re-sets kit radii on unlayered :root" do
      content = TEMPLATE_PATH.read
      root_block = content[/^:root \{.*?^\}/m]

      refute_nil root_block, "expected an unlayered :root block in tailwind_config.css.tt"
      assert_includes root_block, "--radius-sm: 0.75rem;"
      assert_includes root_block, "--radius-md: 1rem;"
      assert_includes root_block, "--radius-lg: 1.5rem;"
      assert_includes root_block, "--radius-xl: 2rem;"
      assert_no_match SELF_REFERENTIAL_VARIABLE_PATTERN, content
    end

    test "compiled dummy CSS keeps kit radii outside @layer theme" do
      compiled = Rails.root.join("app/assets/builds/application.css").read
      layered_defaults = compiled[/@layer theme \{.*?--radius-md:\s*0\.375rem;.*?^\}/m]
      unlayered_root = compiled.scan(/^:root \{.*?^\}/m).find { |block| block.include?("--radius-md: 1rem;") }

      refute_nil layered_defaults, "expected Tailwind @layer theme to still emit --radius-md: 0.375rem"
      refute_nil unlayered_root, "expected compiled dummy CSS to re-set --radius-md: 1rem on unlayered :root"
      assert_includes unlayered_root, "--radius-sm: 0.75rem;"
      assert_includes unlayered_root, "--radius-lg: 1.5rem;"
      assert_includes unlayered_root, "--radius-xl: 2rem;"
    end
  end
end
