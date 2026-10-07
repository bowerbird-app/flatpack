# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Fieldset
    class ComponentTest < ViewComponent::TestCase
      def test_renders_legend_inside_fieldset
        render_inline(Component.new(title: "Shipping address"))

        assert_selector "fieldset.fp-fieldset > legend", text: "Shipping address"
        assert_selector "legend.font-semibold"
      end

      def test_renders_yielded_fields_inside_fieldset
        render_inline(Component.new(title: "Shipping address")) { "Street" }

        assert_selector "fieldset > div", text: "Street"
        assert_selector "fieldset > legend", text: "Shipping address"
      end

      def test_renders_description_and_links_it
        render_inline(Component.new(
          title: "Shipping address",
          id: "shipping",
          description: "Where should we send this order?"
        ))

        assert_selector "fieldset#shipping[aria-describedby='shipping_description']"
        assert_selector "p#shipping_description", text: "Where should we send this order?"
        refute_selector "fieldset[aria-invalid]"
      end

      def test_escapes_title_description_and_error
        render_inline(Component.new(
          title: "<em>Address</em>",
          description: "<strong>Hint</strong>",
          error: "<script>alert(1)</script>"
        ))

        assert_text "<em>Address</em>"
        assert_text "<strong>Hint</strong>"
        assert_text "<script>alert(1)</script>"
        refute_selector "legend em"
        refute_selector "p strong"
        refute_selector "script"
      end

      def test_omits_blank_description
        render_inline(Component.new(title: "Shipping address", description: "   "))

        refute_selector "p[id$='_description']"
        refute_selector "fieldset[aria-describedby]"
      end

      def test_renders_error_state
        render_inline(Component.new(
          title: "Billing address",
          id: "billing",
          description: "Used on the invoice.",
          error: "Add a street."
        ))

        assert_selector "fieldset#billing[aria-invalid='true'][aria-describedby='billing_description billing_error']"
        assert_selector "p#billing_error", text: "Add a street."
        assert_includes page.native.to_html, "text-[var(--color-error)]"
      end

      def test_keeps_caller_describedby_tokens
        render_inline(Component.new(
          title: "Billing address",
          id: "billing",
          error: "Add a street.",
          aria: {describedby: "invoice_hint"}
        ))

        assert_selector "fieldset[aria-describedby='invoice_hint billing_error']"
      end

      def test_renders_disabled_fieldset
        render_inline(Component.new(title: "Account owner", disabled: true)) { "Name" }

        assert_selector "fieldset[disabled].opacity-50"
        assert_selector "fieldset", text: "Name"
      end

      def test_merges_custom_class
        render_inline(Component.new(title: "Shipping address", class: "mt-6"))

        assert_selector "fieldset.fp-fieldset.mt-6.border-0.min-w-0"
      end

      def test_raises_when_title_is_blank
        assert_raises(ArgumentError) do
          Component.new(title: "  ")
        end
      end

      def test_raises_when_title_is_missing
        assert_raises(ArgumentError) do
          Component.new(title: nil)
        end
      end

      def test_raises_when_title_is_html_safe
        assert_raises(ArgumentError) do
          Component.new(title: "Shipping address".html_safe)
        end
      end

      def test_raises_when_description_is_not_a_string
        assert_raises(ArgumentError) do
          Component.new(title: "Shipping address", description: {text: "Hint"})
        end
      end

      def test_raises_when_description_is_html_safe
        assert_raises(ArgumentError) do
          Component.new(title: "Shipping address", description: "<strong>Hint</strong>".html_safe)
        end
      end

      def test_raises_when_error_is_not_a_string
        assert_raises(ArgumentError) do
          Component.new(title: "Shipping address", error: ["Add a street."])
        end
      end
    end
  end
end
