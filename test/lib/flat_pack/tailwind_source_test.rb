# frozen_string_literal: true

require "test_helper"

module FlatPack
  class TailwindSourceTest < ActiveSupport::TestCase
    SELF_REFERENTIAL_VARIABLE_PATTERN = /--([a-zA-Z][\w-]*):\s*var\(--\1\)/

    test "generator tailwind template avoids self referential css variable mappings" do
      source_path = FlatPack::Engine.root.join("lib/generators/flat_pack/templates/tailwind_config.css.tt")
      content = source_path.read

      assert_no_match SELF_REFERENTIAL_VARIABLE_PATTERN, content
    end
  end
end
