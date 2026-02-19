# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Comments
    module Thread
      class ComponentTest < ViewComponent::TestCase
        def test_renders_thread_with_title
          render_inline(Component.new(title: "Discussion"))

          assert_selector "h3", text: "Discussion"
        end

        def test_renders_comment_count
          render_inline(Component.new(count: 42))

          assert_selector "span", text: "42"
        end

        def test_renders_custom_header_slot
          component = Component.new
          component.with_header { "Custom Header" }
          render_inline(component)

          assert_text "Custom Header"
        end

        def test_renders_composer_slot
          component = Component.new
          component.with_composer { "Composer" }
          render_inline(component)

          assert_text "Composer"
        end

        def test_renders_comment_slots
          component = Component.new(count: 2)
          component.with_comment { "Comment 1" }
          component.with_comment { "Comment 2" }
          render_inline(component)

          assert_text "Comment 1"
          assert_text "Comment 2"
        end

        def test_renders_footer_slot
          component = Component.new
          component.with_footer { "Footer Content" }
          render_inline(component)

          assert_text "Footer Content"
        end

        def test_renders_empty_state_when_no_comments
          render_inline(Component.new)

          assert_selector "h4", text: "No comments yet"
          assert_selector "p", text: "Be the first to share your thoughts."
        end

        def test_custom_empty_state_messages
          render_inline(Component.new(
            empty_title: "Custom Empty",
            empty_body: "Custom message"
          ))

          assert_selector "h4", text: "Custom Empty"
          assert_selector "p", text: "Custom message"
        end

        def test_renders_locked_indicator
          render_inline(Component.new(locked: true))

          assert_selector "svg"
          assert_selector "span", text: "Locked"
        end

        def test_hides_composer_when_locked
          component = Component.new(locked: true)
          component.with_composer { "Composer" }
          render_inline(component)

          refute_text "Composer"
        end

        def test_shows_composer_when_not_locked
          component = Component.new(locked: false)
          component.with_composer { "Composer" }
          render_inline(component)

          assert_text "Composer"
        end

        def test_default_variant
          render_inline(Component.new)

          assert_includes page.native.to_html, "space-y-4"
        end

        def test_compact_variant
          render_inline(Component.new(variant: :compact))

          assert_includes page.native.to_html, "space-y-2"
        end

        def test_raises_error_for_invalid_variant
          assert_raises(ArgumentError) do
            Component.new(variant: :invalid)
          end
        end

        def test_merges_custom_classes
          render_inline(Component.new(class: "custom-class"))

          assert_selector "div.custom-class"
        end

        def test_accepts_data_attributes
          render_inline(Component.new(data: {testid: "thread"}))

          assert_selector "div[data-testid='thread']"
        end

        def test_accepts_aria_attributes
          render_inline(Component.new(aria: {label: "Comments section"}))

          assert_selector "div[aria-label='Comments section']"
        end

        def test_filters_dangerous_onclick_attribute
          render_inline(Component.new(onclick: "alert('xss')"))

          refute_selector "div[onclick]"
        end
      end
    end
  end
end
