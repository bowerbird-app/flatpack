# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Spinner
    class ComponentTest < ViewComponent::TestCase
      def test_renders_status_spinner
        render_inline(Component.new)

        assert_selector "svg[role='status'][aria-label='Loading']"
        assert_includes page.native.to_html, "animate-spin"
        assert_includes page.native.to_html, "motion-reduce:animate-none"
      end

      def test_decorative_spinner_hides_from_assistive_tech
        render_inline(Component.new(label: nil))

        assert_selector "svg[aria-hidden='true']"
        refute_selector "svg[role='status']"
      end

      def test_invalid_size_raises
        error = assert_raises(ArgumentError) { Component.new(size: :tiny) }

        assert_match(/Invalid size/, error.message)
      end
    end
  end
end
