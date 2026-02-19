# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Comments
    module Composer
      class ComponentTest < ViewComponent::TestCase
        def test_renders_composer_with_textarea
          render_inline(Component.new)

          assert_selector "textarea"
        end

        def test_renders_with_placeholder
          render_inline(Component.new(placeholder: "Add a comment..."))

          assert_selector "textarea[placeholder='Add a comment...']"
        end

        def test_renders_with_custom_rows
          render_inline(Component.new(rows: 5))

          assert_selector "textarea[rows='5']"
        end

        def test_renders_with_name_attribute
          render_inline(Component.new(name: "post_comment"))

          assert_selector "textarea[name='post_comment']"
        end

        def test_renders_with_value
          render_inline(Component.new(value: "Draft text"))

          assert_selector "textarea", text: "Draft text"
        end

        def test_renders_with_form_attribute
          render_inline(Component.new(form: "comment-form"))

          assert_selector "textarea[form='comment-form']"
        end

        def test_renders_submit_button
          render_inline(Component.new)

          assert_selector "button[type='submit']", text: "Comment"
        end

        def test_renders_custom_submit_label
          render_inline(Component.new(submit_label: "Post"))

          assert_selector "button", text: "Post"
        end

        def test_renders_cancel_button_when_show_cancel
          render_inline(Component.new(show_cancel: true))

          assert_selector "button[type='button']", text: "Cancel"
        end

        def test_hides_cancel_button_by_default
          render_inline(Component.new)

          refute_selector "button[type='button']", text: "Cancel"
        end

        def test_renders_custom_cancel_label
          render_inline(Component.new(show_cancel: true, cancel_label: "Discard"))

          assert_selector "button", text: "Discard"
        end

        def test_disabled_state
          render_inline(Component.new(disabled: true))

          assert_selector "textarea[disabled]"
          assert_selector "button[disabled]"
          assert_includes page.native.to_html, "opacity-60"
        end

        def test_compact_mode
          render_inline(Component.new(compact: true))

          assert_includes page.native.to_html, "p-2"
        end

        def test_renders_toolbar_slot
          component = Component.new
          component.with_toolbar { "Toolbar" }
          render_inline(component)

          assert_text "Toolbar"
        end

        def test_renders_attachments_slot
          component = Component.new
          component.with_attachments { "Attachments" }
          render_inline(component)

          assert_text "Attachments"
        end

        def test_renders_custom_actions_slot
          component = Component.new
          component.with_actions { "Custom Actions" }
          render_inline(component)

          assert_text "Custom Actions"
        end

        def test_default_placeholder
          render_inline(Component.new)

          assert_selector "textarea[placeholder='Write a comment...']"
        end

        def test_default_rows_is_3
          render_inline(Component.new)

          assert_selector "textarea[rows='3']"
        end

        def test_default_name_is_comment
          render_inline(Component.new)

          assert_selector "textarea[name='comment']"
        end

        def test_merges_custom_classes
          render_inline(Component.new(class: "custom-class"))

          assert_selector "div.custom-class"
        end

        def test_accepts_data_attributes
          render_inline(Component.new(data: {testid: "composer"}))

          assert_selector "div[data-testid='composer']"
        end

        def test_accepts_aria_attributes
          render_inline(Component.new(aria: {label: "Comment composer"}))

          assert_selector "div[aria-label='Comment composer']"
        end

        def test_filters_dangerous_onclick_attribute
          render_inline(Component.new(onclick: "alert('xss')"))

          refute_selector "div[onclick]"
        end
      end
    end
  end
end
