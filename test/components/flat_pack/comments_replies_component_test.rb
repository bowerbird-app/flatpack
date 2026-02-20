# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Comments
    module Replies
      class ComponentTest < ViewComponent::TestCase
        def test_renders_replies_container
          render_inline(Component.new)

          assert_selector "div"
        end

        def test_renders_comment_slots
          component = Component.new
          component.with_comment { "Reply 1" }
          component.with_comment { "Reply 2" }
          render_inline(component)

          assert_text "Reply 1"
          assert_text "Reply 2"
        end

        def test_renders_collapsed_state
          render_inline(Component.new(collapsed: true))

          assert_selector "button", text: "Show replies"
        end

        def test_hides_comments_when_collapsed
          component = Component.new(collapsed: true)
          component.with_comment { "Hidden Reply" }
          render_inline(component)

          refute_text "Hidden Reply"
        end

        def test_shows_comments_when_not_collapsed
          component = Component.new(collapsed: false)
          component.with_comment { "Visible Reply" }
          render_inline(component)

          assert_text "Visible Reply"
        end

        def test_custom_collapsed_label
          render_inline(Component.new(
            collapsed: true,
            collapsed_label: "View responses"
          ))

          assert_selector "button", text: "View responses"
        end

        def test_renders_with_depth
          render_inline(Component.new(depth: 2))

          assert_includes page.native.to_html, "ml-11"
        end

        def test_default_depth_is_1
          render_inline(Component.new)

          assert_includes page.native.to_html, "ml-11"
        end

        def test_includes_border_left
          render_inline(Component.new)

          assert_includes page.native.to_html, "border-l-2"
        end

        def test_merges_custom_classes
          render_inline(Component.new(class: "custom-class"))

          assert_selector "div.custom-class"
        end

        def test_accepts_data_attributes
          render_inline(Component.new(data: {testid: "replies"}))

          assert_selector "div[data-testid='replies']"
        end

        def test_accepts_aria_attributes
          render_inline(Component.new(aria: {label: "Reply thread"}))

          assert_selector "div[aria-label='Reply thread']"
        end

        def test_filters_dangerous_onclick_attribute
          render_inline(Component.new(onclick: "alert('xss')"))

          refute_selector "div[onclick]"
        end
      end
    end
  end
end
