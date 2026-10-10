# frozen_string_literal: true

require "test_helper"

module FlatPack
  module InlineEdit
    class ComponentTest < ViewComponent::TestCase
      def test_renders_stimulus_controller
        render_inline(Component.new(name: "kit[title]", value: "Trail kit"))

        assert_selector "[data-controller='flat-pack--inline-edit']"
      end

      def test_renders_heading_tag_with_value
        render_inline(Component.new(tag: :h1, name: "kit[title]", value: "Trail kit", label: "Kit title"))

        assert_selector "h1.fp-inline-edit__surface[role='textbox'][aria-label='Kit title']", text: "Trail kit"
        refute_selector "h1[aria-multiline]"
      end

      def test_hidden_input_syncs_name_and_value
        render_inline(Component.new(name: "kit[title]", value: "Trail kit"))

        assert_selector "input[type='hidden'][name='kit[title]'][value='Trail kit'][data-flat-pack--inline-edit-target='field']", visible: :all
      end

      def test_omits_update_url_value_when_form_only
        render_inline(Component.new(name: "kit[title]", value: "Trail kit"))

        refute_selector "[data-flat-pack--inline-edit-update-url-value]"
      end

      def test_sets_update_url_and_method
        render_inline(Component.new(name: "kit[title]", value: "Trail kit", update_url: "/kits/1", method: :put))

        assert_selector "[data-flat-pack--inline-edit-update-url-value='/kits/1']"
        assert_selector "[data-flat-pack--inline-edit-method-value='put']"
      end

      def test_rejects_unsafe_update_url
        error = assert_raises(ArgumentError) do
          Component.new(name: "kit[title]", update_url: "javascript:alert(1)")
        end

        assert_match(/update_url/, error.message)
      end

      def test_accepts_relative_update_url
        render_inline(Component.new(name: "kit[title]", update_url: "/kits/1"))

        assert_selector "[data-flat-pack--inline-edit-update-url-value='/kits/1']"
      end

      def test_plain_mode_is_multiline
        render_inline(Component.new(name: "kit[note]", mode: :plain, tag: :p, value: "Bring socks"))

        assert_selector "p[aria-multiline='true']"
        assert_selector ".fp-inline-edit--plain"
      end

      def test_rich_mode_renders_bubble_toolbar
        render_inline(Component.new(name: "kit[intro]", mode: :rich, value: "<p>Hello</p>"))

        assert_selector ".flat-pack-richtext-bubble-menu[data-flat-pack--inline-edit-target='bubble']", visible: :all
        assert_selector "button[data-command='bold']", visible: :all
        refute_selector "button[data-flat-pack--content-editor-target]", visible: :all
        refute_selector ".flat-pack-content-editor-actions"
      end

      def test_text_mode_omits_bubble_toolbar
        render_inline(Component.new(name: "kit[title]", value: "Trail kit"))

        refute_selector ".flat-pack-richtext-bubble-menu", visible: :all
      end

      def test_sanitizes_rich_html
        render_inline(Component.new(
          name: "kit[intro]",
          mode: :rich,
          value: "<p>Hi<script>alert(1)</script></p>"
        ))

        refute_selector "script"
        assert_selector ".fp-inline-edit__surface", text: "Hi"
      end

      def test_placeholder_and_empty_state
        render_inline(Component.new(name: "kit[title]", placeholder: "Untitled kit"))

        assert_selector ".fp-inline-edit__surface.is-empty[data-placeholder='Untitled kit'][aria-placeholder='Untitled kit']"
      end

      def test_required_and_maxlength_values
        render_inline(Component.new(name: "kit[title]", value: "Trail", required: true, maxlength: 40))

        assert_selector "[data-flat-pack--inline-edit-required-value='true']"
        assert_selector "[data-flat-pack--inline-edit-maxlength-value='40']"
        assert_selector ".fp-inline-edit__surface[aria-required='true']"
      end

      def test_default_cue_is_highlight
        render_inline(Component.new(name: "kit[title]", value: "Trail"))

        assert_selector ".fp-inline-edit--cue-highlight"
        refute_selector ".fp-inline-edit--cue-underline"
      end

      def test_cue_variants
        render_inline(Component.new(name: "kit[title]", value: "Trail", cue: :tint))
        assert_selector ".fp-inline-edit--cue-tint"

        render_inline(Component.new(name: "kit[title]", value: "Trail", cue: :underline))
        assert_selector ".fp-inline-edit--cue-underline"

        render_inline(Component.new(name: "kit[title]", value: "Trail", cue: :none))
        assert_selector ".fp-inline-edit--cue-none"

        render_inline(Component.new(name: "kit[title]", value: "Trail", cue: :highlight))
        assert_selector ".fp-inline-edit--cue-highlight"
      end

      def test_save_on_blur_default
        render_inline(Component.new(name: "kit[title]", value: "Trail"))

        assert_selector "[data-flat-pack--inline-edit-save-on-blur-value='true']"
      end

      def test_live_region_and_status
        render_inline(Component.new(name: "kit[title]", value: "Trail"))

        assert_selector "[data-flat-pack--inline-edit-target='live'][aria-live='polite']", visible: :all
        assert_selector "[data-flat-pack--inline-edit-target='spinner']", visible: :all
        assert_selector "[data-flat-pack--inline-edit-target='tick']", visible: :all
      end

      def test_wraps_block_and_keeps_inner_heading
        render_inline(Component.new(name: "kit[title]", update_url: "/kits/1")) do
          "<div class='page-title'><h1>Coast path</h1></div>".html_safe
        end

        assert_selector ".fp-inline-edit--wrapped h1", text: "Coast path"
        refute_selector ".fp-inline-edit--wrapped > h1.fp-inline-edit__surface"
      end

      def test_host_class_lands_on_the_tag
        render_inline(Component.new(tag: :h1, name: "kit[title]", value: "Trail", class: "font-semibold"))

        assert_selector "h1.fp-inline-edit__surface.font-semibold"
      end

      def test_requires_name
        assert_raises(ArgumentError) { Component.new(name: "") }
      end

      def test_rejects_unknown_mode
        error = assert_raises(ArgumentError) { Component.new(name: "kit[title]", mode: :fancy) }
        assert_match(/mode/, error.message)
      end

      def test_rejects_unknown_tag
        error = assert_raises(ArgumentError) { Component.new(name: "kit[title]", tag: :section) }
        assert_match(/tag/, error.message)
      end

      def test_rejects_unknown_cue
        error = assert_raises(ArgumentError) { Component.new(name: "kit[title]", cue: :glow) }
        assert_match(/cue/, error.message)
      end

      def test_rejects_unknown_method
        error = assert_raises(ArgumentError) { Component.new(name: "kit[title]", method: :delete) }
        assert_match(/method/, error.message)
      end

      def test_default_tag_is_span_for_text
        render_inline(Component.new(name: "kit[title]", value: "Trail"))

        assert_selector "span.fp-inline-edit__surface"
      end

      def test_default_tag_is_div_for_rich
        render_inline(Component.new(name: "kit[intro]", mode: :rich, value: "<p>Hi</p>"))

        assert_selector "div.fp-inline-edit__surface"
      end
    end
  end
end
