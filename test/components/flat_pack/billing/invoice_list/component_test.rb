# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Billing
    module InvoiceList
      class ComponentTest < ViewComponent::TestCase
        def test_renders_invoice_rows
          render_inline(Component.new(items: [
            {date: "1 Aug 2026", amount: "$29.00", status: :paid, href: "/invoices/1"},
            {date: "1 Jul 2026", amount: "$29.00", status: :failed, href: "/invoices/2"}
          ]))

          assert_text "1 Aug 2026"
          assert_text "$29.00"
          assert_text "Paid"
          assert_text "Failed"
          assert_text "Download"
        end

        def test_renders_empty_state
          render_inline(Component.new(items: []))

          assert_text "No invoices yet"
        end

        def test_requires_invoice_fields
          assert_raises(ArgumentError) { Component.new(items: [{amount: "$1", status: :paid}]) }
        end
      end
    end
  end
end
