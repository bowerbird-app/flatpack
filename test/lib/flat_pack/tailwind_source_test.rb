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
  end
end
