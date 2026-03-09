# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Chat
    module MessageList
      class ComponentTest < ViewComponent::TestCase
        def test_renders_message_list
          render_inline(Component.new) do
            "Messages go here"
          end

          assert_text "Messages go here"
        end

        def test_renders_with_stick_to_bottom_true
          render_inline(Component.new(stick_to_bottom: true)) do
            "Content"
          end

          assert_selector "div[data-controller='flat-pack--chat-scroll']"
          assert_selector "div[data-flat-pack--chat-scroll-stick-to-bottom-value='true']"
        end

        def test_renders_with_stick_to_bottom_false
          render_inline(Component.new(stick_to_bottom: false)) do
            "Content"
          end

          assert_selector "div[data-flat-pack--chat-scroll-stick-to-bottom-value='false']"
        end

        def test_renders_jump_button
          render_inline(Component.new) do
            "Content"
          end

          assert_selector "button[data-action='click->flat-pack--chat-scroll#jump']"
          assert_text "Jump to latest"
        end

        def test_has_scroll_target
          render_inline(Component.new) do
            "Content"
          end

          assert_selector "div[data-flat-pack--chat-scroll-target='messages']"
          assert_selector "div[data-controller~='flat-pack--chat-grouping']"
        end

        def test_has_jump_button_container_target
          render_inline(Component.new) do
            "Content"
          end

          assert_selector "div[data-flat-pack--chat-scroll-target='jumpButtonContainer']"
        end

        def test_applies_custom_class
          render_inline(Component.new(class: "custom-class")) do
            "Content"
          end

          assert_selector "div.custom-class"
        end

        def test_applies_data_attributes
          render_inline(Component.new(data: {test: "value"})) do
            "Content"
          end

          assert_selector "div[data-test='value']"
        end

        def test_has_overflow_hidden
          render_inline(Component.new) do
            "Content"
          end

          assert_selector "div.overflow-hidden"
        end

        def test_renders_history_loader_when_enabled
          render_inline(Component.new(
            history_url: "/messages/history",
            history_has_more: true,
            history_limit: 20
          )) do
            "Content"
          end

          assert_selector "[data-controller='flat-pack--pagination-infinite']"
          assert_selector "[data-flat-pack--pagination-infinite-insert-mode-value='prepend']"
          assert_selector "[data-flat-pack--pagination-infinite-cursor-param-value='before_id']"
          assert_selector "[data-flat-pack--pagination-infinite-batch-size-value='20']"
        end

        def test_does_not_render_history_loader_without_url
          render_inline(Component.new(history_has_more: true)) do
            "Content"
          end

          refute_selector "[data-controller='flat-pack--pagination-infinite']"
        end
      end
    end
  end
end
