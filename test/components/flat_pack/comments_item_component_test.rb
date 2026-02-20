# frozen_string_literal: true

require "test_helper"

module FlatPack
  module Comments
    module Item
      class ComponentTest < ViewComponent::TestCase
        def test_renders_comment_with_author_name
          render_inline(Component.new(author_name: "John Doe"))

          assert_selector "span", text: "John Doe"
        end

        def test_renders_author_meta
          render_inline(Component.new(
            author_name: "John Doe",
            author_meta: "Software Engineer"
          ))

          assert_selector "div", text: "Software Engineer"
        end

        def test_renders_timestamp
          render_inline(Component.new(
            author_name: "John Doe",
            timestamp: "2 hours ago"
          ))

          assert_selector "time", text: "2 hours ago"
        end

        def test_renders_timestamp_with_iso
          render_inline(Component.new(
            author_name: "John Doe",
            timestamp: "2 hours ago",
            timestamp_iso: "2024-01-01T12:00:00Z"
          ))

          assert_selector "time[datetime='2024-01-01T12:00:00Z']"
        end

        def test_renders_body_text
          render_inline(Component.new(
            author_name: "John Doe",
            body: "This is a comment"
          ))

          assert_selector "div", text: "This is a comment"
        end

        def test_renders_body_html
          render_inline(Component.new(
            author_name: "John Doe",
            body_html: "<strong>Bold</strong> text"
          ))

          assert_selector "strong", text: "Bold"
        end

        def test_renders_edited_indicator
          render_inline(Component.new(
            author_name: "John Doe",
            timestamp: "2 hours ago",
            edited: true
          ))

          assert_selector "span", text: "(edited)"
        end

        def test_renders_avatar
          render_inline(Component.new(
            author_name: "John Doe",
            avatar: {src: "https://example.com/avatar.jpg"}
          ))

          assert_selector "img[src='https://example.com/avatar.jpg']"
        end

        def test_renders_actions_slot
          component = Component.new(author_name: "John Doe")
          component.with_actions { "Actions" }
          render_inline(component)

          assert_text "Actions"
        end

        def test_renders_footer_slot
          component = Component.new(author_name: "John Doe")
          component.with_footer { "Footer" }
          render_inline(component)

          assert_text "Footer"
        end

        def test_default_state
          render_inline(Component.new(author_name: "John Doe"))

          assert_includes page.native.to_html, Component::STATES[:default]
        end

        def test_system_state
          render_inline(Component.new(
            author_name: "System",
            state: :system
          ))

          assert_selector "span", text: "System"
          assert_includes page.native.to_html, "bg-zinc-50"
        end

        def test_deleted_state
          render_inline(Component.new(
            author_name: "John Doe",
            state: :deleted
          ))

          assert_selector "div", text: "This comment has been deleted."
          assert_includes page.native.to_html, "opacity-60"
        end

        def test_deleted_state_hides_actions
          component = Component.new(author_name: "John Doe", state: :deleted)
          component.with_actions { "Actions" }
          render_inline(component)

          refute_text "Actions"
        end

        def test_raises_error_without_author_name
          assert_raises(ArgumentError) do
            Component.new
          end
        end

        def test_raises_error_for_invalid_state
          assert_raises(ArgumentError) do
            Component.new(author_name: "John Doe", state: :invalid)
          end
        end

        def test_merges_custom_classes
          render_inline(Component.new(author_name: "John Doe", class: "custom-class"))

          assert_selector "div.custom-class"
        end

        def test_accepts_data_attributes
          render_inline(Component.new(author_name: "John Doe", data: {testid: "comment"}))

          assert_selector "div[data-testid='comment']"
        end

        def test_accepts_aria_attributes
          render_inline(Component.new(author_name: "John Doe", aria: {label: "Comment"}))

          assert_selector "div[aria-label='Comment']"
        end

        def test_filters_dangerous_onclick_attribute
          render_inline(Component.new(author_name: "John Doe", onclick: "alert('xss')"))

          refute_selector "div[onclick]"
        end
      end
    end
  end
end
