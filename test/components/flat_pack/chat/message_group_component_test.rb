# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Chat
    module MessageGroup
      class ComponentTest < ViewComponent::TestCase
        def test_renders_incoming_message_group
          render_inline(Component.new(direction: :incoming)) do |group|
            group.message do
              "First message"
            end
            group.message do
              "Second message"
            end
          end

          assert_text "First message"
          assert_text "Second message"
        end

        def test_renders_outgoing_message_group
          render_inline(Component.new(direction: :outgoing)) do |group|
            group.message do
              "My message"
            end
          end

          assert_text "My message"
        end

        def test_renders_with_avatar
          render_inline(Component.new(direction: :incoming, show_avatar: true)) do |group|
            group.avatar do
              "Avatar"
            end
            group.message do
              "Message"
            end
          end

          assert_text "Avatar"
          assert_text "Message"
        end

        def test_renders_with_sender_name
          render_inline(Component.new(
            direction: :incoming,
            show_name: true,
            sender_name: "Alice Johnson"
          )) do |group|
            group.message do
              "Hello!"
            end
          end

          assert_text "Alice Johnson"
          assert_text "Hello!"
        end

        def test_hides_avatar_when_show_avatar_false
          render_inline(Component.new(direction: :incoming, show_avatar: false)) do |group|
            group.avatar do
              "Avatar"
            end
            group.message do
              "Message"
            end
          end

          assert_text "Message"
          # Avatar slot won't be rendered
        end

        def test_validates_direction
          assert_raises ArgumentError do
            Component.new(direction: :invalid)
          end
        end

        def test_applies_custom_class
          render_inline(Component.new(direction: :incoming, class: "custom-class")) do |group|
            group.message do
              "Test"
            end
          end

          assert_selector "div.custom-class"
        end

        def test_applies_data_attributes
          render_inline(Component.new(
            direction: :incoming,
            data: {test: "value"}
          )) do |group|
            group.message do
              "Test"
            end
          end

          assert_selector "div[data-test='value']"
        end

        def test_does_not_expose_with_prefixed_slot_setters
          component = Component.new(direction: :incoming)

          refute_respond_to component, :with_avatar
          refute_respond_to component, :with_message
        end
      end
    end
  end
end
