# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Combobox
    class ComponentTest < ViewComponent::TestCase
      def test_renders_combobox_and_listbox
        render_inline(Component.new(
          name: "city",
          label: "City",
          value: "mel",
          options: [{value: "mel", label: "Melbourne"}, {value: "syd", label: "Sydney"}]
        ))

        assert_selector "input[role='combobox'][aria-expanded='false']"
        assert_selector "label", text: "City"
        assert_selector "[role='listbox']"
        assert_selector "[role='option']", text: "Melbourne"
        assert_selector "input[type='hidden'][name='city'][value='mel']", visible: :all
      end

      def test_blank_name_raises
        error = assert_raises(ArgumentError) { Component.new(name: "", options: ["A"]) }

        assert_equal "name is required", error.message
      end

      def test_blank_options_raises
        error = assert_raises(ArgumentError) { Component.new(name: "city", options: []) }

        assert_equal "options is required", error.message
      end
    end
  end
end
