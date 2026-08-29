# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Divider
    class ComponentTest < ViewComponent::TestCase
      def test_renders_plain_rule_without_label
        render_inline(Component.new)

        assert_selector "div[role='separator']"
        assert_includes page.native.to_html, "border-[var(--surface-border-color)]"
        refute_selector "span"
      end

      def test_renders_centered_label_when_provided
        render_inline(Component.new(label: "Or"))

        assert_selector "div[role='separator'][aria-label='Or']"
        assert_selector "span", text: "Or"
        assert_includes page.native.to_html, "text-[var(--surface-muted-content-color)]"
        assert_includes page.native.to_html, "border-[var(--surface-border-color)]"
      end

      def test_blank_label_renders_plain_rule
        render_inline(Component.new(label: ""))

        assert_selector "div[role='separator']"
        refute_selector "[aria-label]"
        refute_selector "span"
      end

      def test_rejects_non_string_label
        assert_raises(ArgumentError) do
          Component.new(label: :or)
        end
      end

      def test_merges_custom_class
        render_inline(Component.new(label: "Or", class: "my-4"))

        assert_selector "div.my-4[role='separator']"
      end

      def test_accepts_id_and_data_attributes
        render_inline(Component.new(id: "auth-divider", data: {testid: "divider"}))

        assert_selector "#auth-divider[data-testid='divider'][role='separator']"
      end

      def test_full_width_class_present
        render_inline(Component.new(label: "Or"))

        assert_includes page.native.to_html, "w-full"
      end
    end
  end
end
