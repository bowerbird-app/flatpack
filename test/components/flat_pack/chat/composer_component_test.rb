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
            composer.with_textarea do
              "Custom textarea"
            end
          end

          assert_text "Custom textarea"
        end

        def test_renders_custom_actions
          render_inline(Component.new) do |composer|
            composer.with_actions do
              "Custom actions"
            end
          end

          assert_text "Custom actions"
        end

        def test_renders_with_attachments
          render_inline(Component.new) do |composer|
            composer.with_attachments do
              "Attachment preview"
            end
          end

          assert_text "Attachment preview"
        end

        def test_renders_complete_custom_composer
          render_inline(Component.new) do |composer|
            composer.with_textarea do
              "Textarea"
            end
            composer.with_actions do
              "Actions"
            end
            composer.with_attachments do
              "Attachments"
            end
          end

          assert_text "Textarea"
          assert_text "Actions"
          assert_text "Attachments"
        end

        def test_applies_custom_class
          render_inline(Component.new(class: "custom-class"))

          assert_selector "div.custom-class"
        end

        def test_applies_data_attributes
          render_inline(Component.new(data: {controller: "test"}))

          assert_selector "div[data-controller='test']"
        end

        def test_has_border_top
          render_inline(Component.new)

          assert_selector "div.border-t"
        end
      end
    end
  end
end
