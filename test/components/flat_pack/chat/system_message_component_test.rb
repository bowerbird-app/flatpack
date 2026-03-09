# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Chat
    module SystemMessage
      class ComponentTest < ViewComponent::TestCase
        def test_renders_centered_system_message
          render_inline(Component.new) do
            "System event"
          end

          assert_selector "div", text: "System event"
          assert_includes rendered_content, "justify-center"
          assert_selector "div[data-flat-pack-chat-group-break='true']"
        end
      end
    end
  end
end
