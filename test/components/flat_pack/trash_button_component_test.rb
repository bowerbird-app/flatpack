# frozen_string_literal: true

require "test_helper"

module FlatPack
  module TrashButton
    class ComponentTest < ViewComponent::TestCase
      def test_renders_icon_only_default_button
        render_inline(Component.new)

        assert_selector ".fp-trash-button[data-controller='flat-pack--trash-button']"
        assert_selector ".fp-trash-button[data-fp-armed='false']"
        assert_selector ".fp-trash-button[data-fp-expand='right']"
        assert_selector ".fp-trash-button[role='group'][aria-label='Trash']"
        assert_selector "button.fp-trash-button__arm[data-fp-style='default'][aria-label='Trash']"
        assert_selector "button.fp-trash-button__arm svg[data-flat-pack--icon-name-value='trash']"
        refute_selector "button.fp-trash-button__arm", text: "Trash"
      end

      def test_renders_visible_text_when_provided
        render_inline(Component.new(text: "Trash"))

        assert_selector "button.fp-trash-button__arm", text: "Trash"
        assert_selector "button.fp-trash-button__arm svg[data-flat-pack--icon-name-value='trash']"
      end

      def test_confirm_uses_danger_style_and_default_copy
        render_inline(Component.new)

        assert_selector "button.fp-trash-button__confirm-btn[data-fp-style='danger']", text: "Confirm"
        assert_selector "button.fp-trash-button__cancel-btn[data-fp-style='default'][aria-label='Cancel']"
        assert_selector "button.fp-trash-button__cancel-btn svg[data-flat-pack--icon-name-value='x-mark']"
      end

      def test_confirm_label_override
        render_inline(Component.new(confirm_label: "Yes, delete"))

        assert_selector "button.fp-trash-button__confirm-btn", text: "Yes, delete"
      end

      def test_sizes_match_button_tokens
        render_inline(Component.new(size: :sm))

        assert_includes page.native.to_html, "p-[var(--button-icon-only-padding-sm)]"

        render_inline(Component.new(text: "Trash", size: :lg))

        assert_includes page.native.to_html, "px-[var(--button-padding-x-lg)]"
        assert_includes page.native.to_html, "text-base"
      end

      def test_armed_starts_in_confirm_state
        render_inline(Component.new(armed: true, timeout: 0))

        assert_selector ".fp-trash-button[data-fp-armed='true']"
        assert_selector ".fp-trash-button__rest[inert]"
        refute_selector ".fp-trash-button__confirm[inert]"
      end

      def test_rest_state_inerts_the_armed_controls
        render_inline(Component.new)

        assert_selector ".fp-trash-button__confirm[inert]"
        assert_selector ".fp-trash-button__cancel-slot[inert]"
        refute_selector ".fp-trash-button__rest[inert]"
      end

      def test_expand_left
        render_inline(Component.new(expand: :left))

        assert_selector ".fp-trash-button[data-fp-expand='left']"
      end

      def test_form_submit_defaults_to_delete
        render_inline(Component.new(url: "/takes/1"))

        assert_selector "form.contents[action='/takes/1'][method='post']"
        assert_selector "form.contents input[name='_method'][value='delete']", visible: :hidden
        assert_selector "form.contents button.fp-trash-button__confirm-btn[type='submit']"
        assert_selector "form.contents[data-turbo='true']"
      end

      def test_form_method_post_skips_override
        render_inline(Component.new(url: "/takes/1", method: :post))

        assert_selector "form.contents[method='post']"
        refute_selector "form.contents input[name='_method']"
      end

      def test_without_url_confirm_is_a_button
        render_inline(Component.new)

        refute_selector "form"
        assert_selector "button.fp-trash-button__confirm-btn[type='button']"
      end

      def test_live_region_and_stimulus_values
        render_inline(Component.new(timeout: 0))

        assert_selector ".sr-only[aria-live='polite']"
        assert_selector ".fp-trash-button[data-flat-pack--trash-button-timeout-value='0']"
        assert_selector ".fp-trash-button[data-flat-pack--trash-button-armed-announcement-value='Confirm to delete']"
        assert_selector ".fp-trash-button[data-flat-pack--trash-button-restored-announcement-value='Delete cancelled']"
      end

      def test_stimulus_actions
        render_inline(Component.new)

        assert_selector "button.fp-trash-button__arm[data-action='click->flat-pack--trash-button#arm']"
        assert_selector "button.fp-trash-button__confirm-btn[data-action='click->flat-pack--trash-button#confirm']"
        assert_selector "button.fp-trash-button__cancel-btn[data-action='click->flat-pack--trash-button#cancel']"
      end

      def test_does_not_change_existing_button_class_names
        render_inline(Component.new(text: "Trash"))

        assert_selector "button.fp-button.fp-button-raised[data-fp-style='default']"
        assert_selector "button.fp-button.fp-button-raised[data-fp-style='danger']"
      end

      def test_rejects_invalid_size
        error = assert_raises(ArgumentError) { Component.new(size: :xl) }
        assert_match(/Invalid size/, error.message)
      end

      def test_rejects_invalid_expand
        error = assert_raises(ArgumentError) { Component.new(expand: :up) }
        assert_match(/Invalid expand/, error.message)
      end

      def test_rejects_invalid_method
        error = assert_raises(ArgumentError) { Component.new(url: "/takes/1", method: :head) }
        assert_match(/Invalid method/, error.message)
      end

      def test_rejects_unsafe_url
        error = assert_raises(ArgumentError) { Component.new(url: "javascript:alert(1)") }
        assert_match(/Unsafe URL/, error.message)
      end

      def test_rejects_negative_timeout
        error = assert_raises(ArgumentError) { Component.new(timeout: -1) }
        assert_match(/timeout/, error.message)
      end

      def test_timeout_false_disables_auto_revert
        render_inline(Component.new(timeout: false))

        assert_selector ".fp-trash-button[data-flat-pack--trash-button-timeout-value='0']"
      end
    end
  end
end
