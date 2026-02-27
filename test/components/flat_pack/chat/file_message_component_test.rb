# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Chat
    module FileMessage
      class ComponentTest < ViewComponent::TestCase
        def test_renders_file_message_with_attachment
          render_inline(Component.new(
            direction: :outgoing,
            file_name: "brief.pdf",
            file_meta: "420 KB",
            timestamp: "10:21 AM",
            body: "Shared file"
          ))

          assert_text "Shared file"
          assert_text "brief.pdf"
          assert_text "420 KB"
          assert_text "10:21 AM"
        end
      end
    end
  end
end
