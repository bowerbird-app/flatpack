# frozen_string_literal: true

require "test_helper"
require "open3"

class ThemeAttributeTest < ActiveSupport::TestCase
  test "theme names keep a custom theme when the base changes" do
    script = FlatPack::Engine.root.join("test/javascript/theme_attribute.test.mjs")
    output, status = Open3.capture2e("node", "--test", script.to_s)

    assert_predicate status, :success?, output
  end
end
