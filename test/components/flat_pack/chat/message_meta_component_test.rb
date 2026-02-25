# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Chat
    module MessageMeta
      class ComponentTest < ViewComponent::TestCase
        def test_renders_timestamp
          render_inline(Component.new(timestamp: Time.parse("2024-01-15 10:30:00")))

          assert_text "10:30 AM"
        end

        def test_renders_sent_state_with_single_check_icon
          render_inline(Component.new(timestamp: "10:30 AM", state: :sent))

          assert_includes rendered_content, "<svg"
          assert_includes rendered_content, "--chat-message-meta-color"
        end

        def test_renders_read_state_with_read_receipt_color
          render_inline(Component.new(timestamp: "10:30 AM", state: :read))

          assert_includes rendered_content, "<svg"
          assert_includes rendered_content, "--chat-read-receipt-color"
        end

        def test_renders_sending_state_label
          render_inline(Component.new(timestamp: "10:30 AM", state: :sending))

          assert_text "Sending..."
        end

        def test_renders_failed_state_label
          render_inline(Component.new(timestamp: "10:30 AM", state: :failed))

          assert_text "Failed"
        end

        def test_renders_edited_indicator
          render_inline(Component.new(timestamp: "10:30 AM", edited: true))

          assert_text "(edited)"
        end

        def test_validates_state
          assert_raises ArgumentError do
            Component.new(state: :invalid)
          end
        end
      end
    end
  end
end
