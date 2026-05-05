# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Comments
    module InlineInput
      class ComponentTest < ViewComponent::TestCase
        def test_renders_textarea
          render_inline(Component.new)

          assert_selector "textarea"
        end

        def test_defaults_to_plain_textarea_mode
          render_inline(Component.new)

          refute_selector "[data-controller='flat-pack--tiptap']"
        end

        def test_allows_rich_text_mode
          render_inline(Component.new(rich_text: true))

          assert_selector "div[data-controller='flat-pack--tiptap']"
          refute_selector "textarea"
        end

        def test_renders_default_placeholder
          render_inline(Component.new)

          assert_selector "textarea[placeholder='Write a comment...']"
        end

        def test_renders_custom_placeholder
          render_inline(Component.new(placeholder: "Add a thought..."))

          assert_selector "textarea[placeholder='Add a thought...']"
        end

        def test_renders_name_attribute
          render_inline(Component.new(name: "comment[body]"))

          assert_selector "textarea[name='comment[body]']"
        end

        def test_renders_value
          render_inline(Component.new(value: "Draft comment"))

          assert_selector "textarea", text: "Draft comment"
        end

        def test_renders_default_rows
          render_inline(Component.new)

          assert_selector "textarea[rows='1']"
        end

        def test_renders_custom_rows
          render_inline(Component.new(rows: 3))

          assert_selector "textarea[rows='3']"
        end

        def test_renders_submit_button
          render_inline(Component.new)

          assert_selector "button[type='submit']", text: "Comment"
        end

        def test_renders_custom_submit_label
          render_inline(Component.new(submit_label: "Post"))

          assert_selector "button[type='submit']", text: "Post"
        end

        def test_supports_form_attribute
          render_inline(Component.new(form: "new-comment-form"))

          assert_selector "textarea[form='new-comment-form']"
          assert_selector "button[form='new-comment-form']"
        end

        def test_disabled_state
          render_inline(Component.new(disabled: true))

          assert_selector "textarea[disabled]"
          assert_selector "button[disabled]"
          assert_includes page.native.to_html, "opacity-60"
        end

        def test_merges_custom_classes
          render_inline(Component.new(class: "custom-class"))

          assert_selector "div.custom-class"
        end

        def test_accepts_data_attributes
          render_inline(Component.new(data: {testid: "comments-inline-input"}))

          assert_selector "div[data-testid='comments-inline-input']"
        end

        def test_wires_textarea_autogrow_controller
          render_inline(Component.new)

          assert_selector "div[data-controller~='flat-pack--text-area']"
          assert_selector "textarea[data-flat-pack--text-area-target='textarea']"
          assert_selector "textarea[data-action~='input->flat-pack--text-area#autoExpand']"
        end

        def test_filters_dangerous_onclick_attribute
          render_inline(Component.new(onclick: "alert('xss')"))

          refute_selector "div[onclick]"
        end
      end
    end
  end
end
