# frozen_string_literal: true

require "test_helper"

module FlatPack
  module CommandPalette
    class ComponentTest < ViewComponent::TestCase
      def test_renders_grouped_commands
        render_inline(Component.new(
          id: "commands",
          items: [
            {label: "Theme variables", href: "/themes", icon: "cog", group: "Go to"},
            {label: "Copy last command", group: "Actions"}
          ]
        ))

        html = page.native.to_html

        assert_includes html, "data-controller=\"flat-pack--command-palette\""
        assert_includes html, "fp-overlay-pad"
        assert_selector "[role='dialog'][aria-modal='true']"
        assert_selector "a[role='option'][href='/themes']", text: "Theme variables"
        assert_selector "button[role='option']", text: "Copy last command"
        assert_text "Go to"
        assert_text "Actions"
      end

      def test_requires_labels
        error = assert_raises(ArgumentError) do
          Component.new(id: "commands", items: [{href: "/themes"}])
        end

        assert_match(/label:/, error.message)
      end

      def test_blank_id_raises
        error = assert_raises(ArgumentError) { Component.new(id: "", items: [{label: "Go"}]) }

        assert_equal "id is required", error.message
      end
    end
  end
end
