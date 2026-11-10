# frozen_string_literal: true

require "test_helper"
require "open3"

module FlatPack
  class ChatTimestampRevealControllerTest < ActiveSupport::TestCase
    test "node tests cover tap toggle on coarse pointers" do
      test_file = FlatPack::Engine.root.join("test/javascript/chat_timestamp_reveal_controller_test.js")
      stdout, status = Open3.capture2e("node", "--test", test_file.to_s)

      assert status.success?, stdout
    end

    test "controller toggles is-open and ignores fine pointers" do
      source = FlatPack::Engine.root.join("app/javascript/flat_pack/controllers/chat_timestamp_reveal_controller.js").read

      assert_includes source, "is-open"
      assert_includes source, "(hover: hover) and (pointer: fine)"
    end

    test "kit css clips rest timestamps to zero height" do
      css = FlatPack::Engine.root.join("app/assets/stylesheets/flat_pack/application.css").read
      rest = css[/\.fp-chat-timestamp-reveal \.fp-chat-timestamp \{[^}]+\}/]
      hover = css[/\.fp-chat-timestamp-reveal:hover \.fp-chat-timestamp,.*?\{[^}]+\}/m]

      assert rest
      assert hover
      assert_includes rest, "display: block;"
      assert_includes rest, "height: 0;"
      assert_includes rest, "line-height: 0;"
      assert_includes rest, "overflow: hidden;"
      refute_includes rest, "display: none"
      refute_includes rest, "visibility: hidden"
      assert_includes hover, "height: auto;"
      assert_includes hover, "line-height: var(--text-xs--line-height, 1rem);"
    end
  end
end
