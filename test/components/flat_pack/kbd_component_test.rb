# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Kbd
    class ComponentTest < ViewComponent::TestCase
      def test_renders_key_sequence
        render_inline(Component.new(keys: ["Cmd", "K"]))

        assert_selector "kbd", text: "Cmd"
        assert_selector "kbd", text: "K"
        assert_text "+"
      end

      def test_blank_keys_raises
        error = assert_raises(ArgumentError) { Component.new(keys: [" ", nil]) }

        assert_equal "keys is required", error.message
      end
    end
  end
end
