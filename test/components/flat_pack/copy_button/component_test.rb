# frozen_string_literal: true

require "test_helper"

module FlatPack
  module CopyButton
    class ComponentTest < ViewComponent::TestCase
      def test_renders_a_labelled_button_for_a_string
        render_inline(Component.new(text: "sk_live_123", id: "copy-key"))

        assert_selector "span#copy-key.inline-flex[data-controller='flat-pack--clipboard']"
        assert_selector "span[data-flat-pack--clipboard-source-value='text']"
        assert_selector "span[data-flat-pack--clipboard-text-value='sk_live_123']"
        assert_selector "span[data-flat-pack--clipboard-feedback-value='button']"
        assert_selector "span[data-flat-pack--clipboard-timeout-value='2000']"
        refute_selector "span[data-flat-pack--clipboard-target-value]"
        assert_selector "button[type='button'][data-fp-style='default'][data-fp-clipboard-state='idle']"
        assert_selector "button[aria-label='Copy'][data-action='click->flat-pack--clipboard#copy']"
        assert_selector "button.fp-button.fp-copy-button"
        assert_selector "[data-flat-pack--clipboard-target='label']", text: "Copy"
        assert_selector "[data-icon='idle'] svg[data-flat-pack--icon-name-value='clipboard-document']"
        assert_selector "[data-icon='copied'] svg[data-flat-pack--icon-name-value='check']"
        assert_selector "[data-icon='error'] svg[data-flat-pack--icon-name-value='exclamation-circle']"
        assert_selector "[data-flat-pack--clipboard-target='live'][aria-live='polite']", text: ""
        assert_includes page.native.to_html, %(data-flat-pack--clipboard-error-label-value="#{I18n.t("flatpack.clipboard.error_label")}")
      end

      def test_icon_only_keeps_an_accessible_name
        render_inline(Component.new(text: "sk_live_123", icon_only: true, label: "Copy key"))

        assert_selector "button[aria-label='Copy key'].fp-hit-target"
        refute_selector "[data-flat-pack--clipboard-target='label']"
      end

      def test_target_copies_an_element_and_text_wins_when_both_are_set
        render_inline(Component.new(target: "invite-code"))

        assert_selector "span[data-flat-pack--clipboard-source-value='target']"
        assert_selector "span[data-flat-pack--clipboard-target-value='invite-code']"
        refute_selector "span[data-flat-pack--clipboard-text-value]"

        render_inline(Component.new(text: "kept", target: "#invite-code"))

        assert_selector "span[data-flat-pack--clipboard-source-value='text']"
        assert_selector "span[data-flat-pack--clipboard-text-value='kept']"
        refute_selector "span[data-flat-pack--clipboard-target-value]"
      end

      def test_accepts_a_selector_target_and_a_custom_style_and_size
        render_inline(Component.new(target: ".invite", style: :primary, size: :sm, timeout: 0, class: "mt-2"))

        assert_selector "span.mt-2[data-flat-pack--clipboard-target-value='.invite']"
        assert_selector "span[data-flat-pack--clipboard-timeout-value='0']"
        assert_selector "button[data-fp-style='primary'].fp-button-raised"
        assert_includes page.native.to_html, "px-[var(--button-padding-x-sm)]"
      end

      def test_disabled_lands_on_the_button
        render_inline(Component.new(text: "sk_live_123", disabled: true))

        assert_selector "button[disabled]"
        refute_selector "span[disabled]"
      end

      def test_french_label_comes_from_the_locale
        I18n.with_locale(:fr) do
          render_inline(Component.new(text: "bonjour"))
        end

        assert_selector "button[aria-label='Copier']"
        assert_selector "[data-flat-pack--clipboard-target='label']", text: "Copier"
        assert_includes page.native.to_html, 'data-flat-pack--clipboard-copied-label-value="Copié"'
        assert_includes page.native.to_html, 'data-flat-pack--clipboard-error-label-value="Pas copié"'
      end

      def test_requires_text_or_target
        error = assert_raises(ArgumentError) { Component.new }
        assert_match(/text: or target:/, error.message)
      end

      def test_rejects_an_unknown_style_size_and_timeout
        assert_raises(ArgumentError) { Component.new(text: "x", style: :nope) }
        assert_raises(ArgumentError) { Component.new(text: "x", size: :xl) }
        assert_raises(ArgumentError) { Component.new(text: "x", timeout: -1) }
      end
    end
  end
end
