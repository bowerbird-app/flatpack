# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Chat
    module Composer
      class ComponentTest < ViewComponent::TestCase
        def test_renders_default_composer
          render_inline(Component.new)

          # Should have default textarea and send button
          assert_selector "textarea"
          assert_selector "button[type='submit']"
        end

        def test_renders_custom_textarea
          render_inline(Component.new) do |composer|
            composer.center do
              "Custom textarea"
            end
          end

          assert_text "Custom textarea"
        end

        def test_renders_custom_actions
          render_inline(Component.new) do |composer|
            composer.right do
              "Custom actions"
            end
          end

          assert_text "Custom actions"
        end

        def test_renders_with_attachments
          render_inline(Component.new) do |composer|
            composer.attachment do
              "Attachment preview"
            end
          end

          assert_text "Attachment preview"
        end

        def test_renders_complete_custom_composer
          render_inline(Component.new) do |composer|
            composer.left do
              "Left"
            end
            composer.center do
              "Center"
            end
            composer.right do
              "Right"
            end
            composer.attachment do
              "Attachments"
            end
          end

          assert_text "Left"
          assert_text "Center"
          assert_text "Right"
          assert_text "Attachments"
        end

        def test_renders_custom_left_slot
          render_inline(Component.new) do |composer|
            composer.left do
              "Left controls"
            end
          end

          assert_text "Left controls"
        end

        def test_renders_custom_center_slot
          render_inline(Component.new) do |composer|
            composer.center do
              "Center field"
            end
          end

          assert_text "Center field"
        end

        def test_renders_custom_right_slot
          render_inline(Component.new) do |composer|
            composer.right do
              "Right controls"
            end
          end

          assert_text "Right controls"
        end

        def test_does_not_expose_with_left_center_right_aliases
          component = Component.new

          assert_not_respond_to component, :with_left
          assert_not_respond_to component, :with_center
          assert_not_respond_to component, :with_right
        end

        def test_does_not_expose_with_textarea_or_with_actions_aliases
          component = Component.new

          assert_not_respond_to component, :with_textarea
          assert_not_respond_to component, :with_actions
        end

        def test_applies_custom_class
          render_inline(Component.new(class: "custom-class"))

          assert_selector "div.custom-class"
        end

        def test_applies_data_attributes
          render_inline(Component.new(data: {controller: "test"}))

          assert_selector "div[data-controller='test']"
        end

        def test_does_not_have_border_top
          render_inline(Component.new)

          assert_no_selector "div.border-t"
        end

        def test_uses_theme_token_for_corner_radius
          render_inline(Component.new)

          assert_includes rendered_content, "rounded-[var(--chat-composer-radius)]"
        end

        def test_aligns_textarea_and_actions_vertically
          render_inline(Component.new)

          assert_selector "div.flex.items-center.gap-2"
          assert_includes rendered_content, "min-h-[var(--chat-composer-control-height)]"
        end
      end
    end
  end
end
