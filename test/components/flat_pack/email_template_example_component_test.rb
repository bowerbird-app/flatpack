# frozen_string_literal: true

require "test_helper"

module FlatPack
  module EmailTemplateExample
    class ComponentTest < ViewComponent::TestCase
      def test_renders_composed_email_template_example
        render_inline(Component.new)

        assert_selector "table[role='presentation']"
        assert_selector "a[href='https://example.com/confirm']", text: "Confirm details"
        assert_selector "a[href='https://example.com/settings']", text: "Review settings"
        assert_selector "a[href='https://example.com/unsubscribe']", text: "Unsubscribe"
      end
    end
  end
end
