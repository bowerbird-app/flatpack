# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Chat
    module Panel
      class ComponentTest < ViewComponent::TestCase
        def test_renders_header_messages_and_composer_slots
          render_inline(Component.new) do |panel|
            panel.with_header { "Header" }
            panel.with_messages { "Messages" }
            panel.with_composer { "Composer" }
          end

          assert_text "Header"
          assert_text "Messages"
          assert_text "Composer"
        end

        def test_applies_header_container_styles
          render_inline(Component.new) do |panel|
            panel.with_header { "Header" }
          end

          assert_selector "div.border-b"
          assert_includes page.native.to_html, "border-[var(--chat-header-border-color)]"
        end

        def test_merges_custom_class
          render_inline(Component.new(class: "custom-panel"))

          assert_selector "div.custom-panel"
        end
      end
    end
  end
end
