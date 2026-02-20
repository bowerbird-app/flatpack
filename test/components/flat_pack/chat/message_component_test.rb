# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Chat
    module Message
      class ComponentTest < ViewComponent::TestCase
        def test_renders_incoming_message
          render_inline(Component.new(direction: :incoming)) do
            "Hello, world!"
          end

          assert_selector "div", text: "Hello, world!"
        end

        def test_renders_outgoing_message
          render_inline(Component.new(direction: :outgoing)) do
            "Hi there!"
          end

          assert_selector "div", text: "Hi there!"
        end

        def test_renders_system_message
          render_inline(Component.new(variant: :system)) do
            "Alice joined the conversation"
          end

          assert_selector "div", text: "Alice joined the conversation"
        end

        def test_renders_with_state_sending
          render_inline(Component.new(direction: :outgoing, state: :sending)) do
            "Sending message..."
          end

          assert_selector "div[data-chat-message-state='sending']"
        end

        def test_renders_with_state_failed
          render_inline(Component.new(direction: :outgoing, state: :failed)) do
            "Failed message"
          end

          assert_selector "div[data-chat-message-state='failed']"
        end

        def test_renders_with_state_read
          render_inline(Component.new(direction: :outgoing, state: :read)) do
            "Read message"
          end

          assert_selector "div[data-chat-message-state='read']"
        end

        def test_renders_with_timestamp
          time = Time.parse("2024-01-15 10:30:00")
          render_inline(Component.new(direction: :incoming, timestamp: time)) do
            "Message with timestamp"
          end

          assert_selector "div", text: "Message with timestamp"
        end

        def test_renders_with_attachments
          render_inline(Component.new(direction: :incoming)) do |component|
            component.with_attachment do
              "Attachment"
            end
            "Message with attachment"
          end

          assert_text "Message with attachment"
          assert_text "Attachment"
        end

        def test_renders_with_meta
          render_inline(Component.new(direction: :outgoing)) do |component|
            component.with_meta do
              "Meta info"
            end
            "Message with meta"
          end

          assert_text "Message with meta"
          assert_text "Meta info"
        end

        def test_uses_pre_line_whitespace_for_message_body
          render_inline(Component.new(direction: :incoming)) do
            "Line 1\nLine 2"
          end

          assert_selector "div.break-words.whitespace-pre-line", text: "Line 1"
        end

        def test_validates_direction
          assert_raises ArgumentError do
            Component.new(direction: :invalid)
          end
        end

        def test_validates_variant
          assert_raises ArgumentError do
            Component.new(variant: :invalid)
          end
        end

        def test_validates_state
          assert_raises ArgumentError do
            Component.new(state: :invalid)
          end
        end

        def test_applies_custom_class
          render_inline(Component.new(direction: :incoming, class: "custom-class")) do
            "Test"
          end

          assert_selector "div.custom-class"
        end

        def test_applies_data_attributes
          render_inline(Component.new(
            direction: :incoming,
            data: {controller: "test"}
          )) do
            "Test"
          end

          assert_selector "div[data-controller='test']"
        end
      end
    end
  end
end
