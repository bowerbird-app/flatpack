# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Billing
    module StatusAlert
      class ComponentTest < ViewComponent::TestCase
        def test_renders_status_defaults
          render_inline(Component.new(status: :past_due)) do |alert|
            alert.actions { "Update card" }
          end

          assert_text "Past due"
          assert_text "Update your payment method"
          assert_text "Update card"
        end

        def test_allows_custom_copy_without_status
          render_inline(Component.new(
            style: :warning,
            title: "Usage limit reached",
            description: "You’ve used all seats."
          ))

          assert_text "Usage limit reached"
          assert_text "You’ve used all seats."
        end

        def test_rejects_invalid_status
          assert_raises(ArgumentError) { Component.new(status: :bogus) }
        end

        def test_requires_content_without_status
          assert_raises(ArgumentError) { Component.new }
        end
      end
    end
  end
end
