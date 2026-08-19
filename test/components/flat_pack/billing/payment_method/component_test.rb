# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Billing
    module PaymentMethod
      class ComponentTest < ViewComponent::TestCase
        def test_renders_filled_payment_method
          render_inline(Component.new(brand: "Visa", last4: "4242", expires_text: "09/28")) do |method|
            method.actions { "Update card" }
          end

          assert_text "Visa •••• 4242"
          assert_text "Expires 09/28"
          assert_text "Update card"
        end

        def test_renders_empty_state
          render_inline(Component.new) do |method|
            method.actions { "Add payment method" }
          end

          assert_text "No card on file"
          assert_text "Add payment method"
        end
      end
    end
  end
end
