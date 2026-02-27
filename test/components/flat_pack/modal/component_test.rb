# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Modal
    class ComponentTest < ViewComponent::TestCase
      def test_renders_modal_with_id
        render_inline(Component.new(id: "my-modal")) do |component|
          component.with_body { "Modal content" }
        end

        assert_selector "div#my-modal"
        assert_text "Modal content"
      end

      def test_renders_modal_with_title
        render_inline(Component.new(id: "my-modal", title: "Confirm Action")) do |component|
          component.with_body { "Are you sure?" }
        end

        assert_selector "h2", text: "Confirm Action"
      end

      def test_renders_modal_with_header_slot
        render_inline(Component.new(id: "my-modal")) do |component|
          component.with_header { "Custom header" }
          component.with_body { "Content" }
        end

        assert_text "Custom header"
        assert_text "Content"
      end

      def test_renders_modal_with_footer_slot
        render_inline(Component.new(id: "my-modal")) do |component|
          component.with_body { "Content" }
          component.with_footer { "Footer buttons" }
        end

        assert_text "Footer buttons"
      end

      def test_renders_close_button
        render_inline(Component.new(id: "my-modal")) do |component|
          component.with_body { "Content" }
        end

        assert_selector "button[aria-label='Close']"
      end

      def test_modal_has_dialog_role
        render_inline(Component.new(id: "my-modal")) do |component|
          component.with_body { "Content" }
        end

        assert_selector "div[role='dialog']"
        assert_selector "div[aria-modal='true']"
      end

      def test_modal_hidden_by_default
        render_inline(Component.new(id: "my-modal")) do |component|
          component.with_body { "Content" }
        end

        assert_selector "div.hidden"
      end

      def test_modal_has_stimulus_controller
        render_inline(Component.new(id: "my-modal")) do |component|
          component.with_body { "Content" }
        end

        assert_selector "div[data-controller='flat-pack--modal']"
      end

      def test_modal_size_small
        render_inline(Component.new(id: "my-modal", size: :sm)) do |component|
          component.with_body { "Content" }
        end

        assert_selector "div.max-w-sm"
      end

      def test_modal_size_medium
        render_inline(Component.new(id: "my-modal", size: :md)) do |component|
          component.with_body { "Content" }
        end

        assert_selector "div.max-w-xl"
      end

      def test_modal_size_large
        render_inline(Component.new(id: "my-modal", size: :lg)) do |component|
          component.with_body { "Content" }
        end

        assert_selector "div.max-w-2xl"
      end

      def test_raises_error_without_id
        assert_raises(ArgumentError) do
          Component.new
        end
      end

      def test_raises_error_for_invalid_size
        assert_raises(ArgumentError) do
          Component.new(id: "my-modal", size: :invalid)
        end
      end

      def test_accepts_custom_classes
        render_inline(Component.new(id: "my-modal", class: "custom-class")) do |component|
          component.with_body { "Content" }
        end

        assert_selector "div.custom-class"
      end

      def test_close_on_backdrop_value
        render_inline(Component.new(id: "my-modal", close_on_backdrop: false)) do |component|
          component.with_body { "Content" }
        end

        assert_selector "div[data-flat-pack--modal-close-on-backdrop-value='false']"
      end

      def test_close_on_escape_value
        render_inline(Component.new(id: "my-modal", close_on_escape: false)) do |component|
          component.with_body { "Content" }
        end

        assert_selector "div[data-flat-pack--modal-close-on-escape-value='false']"
      end

      def test_supports_fixed_body_height
        render_inline(Component.new(id: "my-modal", body_height_mode: :fixed, body_height: "24rem")) do |component|
          component.with_body { "Content" }
        end

        assert_selector "div[style*='--flatpack-modal-body-height: 24rem'][style*='height: var(--flatpack-modal-body-height)']"
      end

      def test_supports_min_body_height
        render_inline(Component.new(id: "my-modal", body_height_mode: :min, body_height: "20rem")) do |component|
          component.with_body { "Content" }
        end

        assert_selector "div[style*='--flatpack-modal-body-height: 20rem'][style*='min-height: var(--flatpack-modal-body-height)']"
      end

      def test_raises_error_for_invalid_body_height_mode
        assert_raises(ArgumentError) do
          Component.new(id: "my-modal", body_height_mode: :invalid)
        end
      end

      def test_raises_error_when_non_auto_body_height_missing
        assert_raises(ArgumentError) do
          Component.new(id: "my-modal", body_height_mode: :fixed)
        end
      end
    end
  end
end
