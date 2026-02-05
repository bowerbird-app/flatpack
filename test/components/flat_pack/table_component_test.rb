# frozen_string_literal: true

require "test_helper"
require "ostruct"

module FlatPack
  module Table
    class ComponentTest < ViewComponent::TestCase
      def setup
        @users = [
          OpenStruct.new(id: 1, name: "Alice", email: "alice@example.com"),
          OpenStruct.new(id: 2, name: "Bob", email: "bob@example.com")
        ]
      end

      def test_renders_empty_table
        render_inline(Component.new(data: []))

        assert_selector "table"
        assert_text "No data available"
      end

      def test_renders_table_with_columns
        render_inline(Component.new(data: @users)) do |component|
          component.column(title: "Name", html: ->(user) { user.name })
          component.column(title: "Email", html: ->(user) { user.email })
        end

        assert_selector "table"
        assert_selector "th", text: "Name"
        assert_selector "th", text: "Email"
        assert_selector "td", text: "Alice"
        assert_selector "td", text: "alice@example.com"
      end

      def test_renders_table_with_block_columns
        render_inline(Component.new(data: @users)) do |component|
          component.column(title: "Name", html: ->(user) { user.name.upcase })
        end

        assert_selector "td", text: "ALICE"
        assert_selector "td", text: "BOB"
      end

      def test_renders_table_with_actions
        render_inline(Component.new(data: @users)) do |component|
          component.column(title: "Name", html: ->(user) { user.name })
          component.with_action(text: "Edit", url: ->(user) { "/users/#{user.id}/edit" })
        end

        assert_selector "th", text: "Actions"
        assert_selector "a[href='/users/1/edit']", text: "Edit"
        assert_selector "a[href='/users/2/edit']", text: "Edit"
      end

      def test_renders_table_with_stimulus_controller
        render_inline(Component.new(data: @users, stimulus: true)) do |component|
          component.column(title: "Name", html: ->(user) { user.name })
        end

        assert_selector "div[data-controller='flat-pack--table']"
      end

      def test_renders_custom_action_block
        render_inline(Component.new(data: @users)) do |component|
          component.column(title: "Name", html: ->(user) { user.name })
          component.with_action(html: ->(user) { "<span class=\"custom-action\">Custom #{user.name}</span>".html_safe })
        end

        assert_selector "span.custom-action", text: "Custom Alice"
      end

      def test_merges_custom_classes
        render_inline(Component.new(data: @users, class: "custom-table"))

        assert_selector "div.custom-table"
      end

      def test_empty_state_spans_all_columns
        render_inline(Component.new(data: [])) do |component|
          component.column(title: "Name", html: ->(user) { user.name })
          component.column(title: "Email", html: ->(user) { user.email })
          component.with_action(label: "Edit")
        end

        assert_selector "td[colspan='3']", text: "No data available"
      end

      def test_renders_sortable_column_headers
        render_inline(Component.new(
          data: @users,
          sort: "name",
          direction: "asc",
          base_url: "/users"
        )) do |component|
          component.column(title: "Name", html: ->(user) { user.name }, sortable: true, sort_key: :name)
          component.column(title: "Email", html: ->(user) { user.email }, sortable: true, sort_key: :email)
        end

        assert_selector "th a[href*='sort=name']"
        assert_selector "th a[href*='sort=email']"
      end

      def test_sortable_headers_toggle_direction
        render_inline(Component.new(
          data: @users,
          sort: "name",
          direction: "asc",
          base_url: "/users"
        )) do |component|
          component.column(title: "Name", html: ->(user) { user.name }, sortable: true, sort_key: :name)
        end

        # When currently sorted ascending, link should be for descending
        assert_selector "th a[href*='direction=desc']"
      end

      def test_sortable_headers_show_indicator_for_current_sort
        render_inline(Component.new(
          data: @users,
          sort: "name",
          direction: "asc",
          base_url: "/users"
        )) do |component|
          component.column(title: "Name", html: ->(user) { user.name }, sortable: true, sort_key: :name)
          component.column(title: "Email", html: ->(user) { user.email }, sortable: true, sort_key: :email)
        end

        # Should show ascending arrow for name column
        assert_selector "th a", text: /Name.*↑/
        # Should not show arrow for email column
        assert_no_selector "th a", text: /Email.*[↑↓]/
      end

      def test_sortable_headers_show_descending_indicator
        render_inline(Component.new(
          data: @users,
          sort: "name",
          direction: "desc",
          base_url: "/users"
        )) do |component|
          component.column(title: "Name", html: ->(user) { user.name }, sortable: true, sort_key: :name)
        end

        # Should show descending arrow for name column
        assert_selector "th a", text: /Name.*↓/
      end

      def test_non_sortable_columns_remain_static
        render_inline(Component.new(
          data: @users,
          sort: "name",
          direction: "asc",
          base_url: "/users"
        )) do |component|
          component.column(title: "Name", html: ->(user) { user.name }, sortable: true, sort_key: :name)
          component.column(title: "Email", html: ->(user) { user.email }, sortable: false)
        end

        assert_selector "th a", text: "Name"
        assert_selector "th", text: "Email"
        assert_no_selector "th a", text: "Email"
      end

      def test_sortable_links_include_turbo_frame_data
        render_inline(Component.new(
          data: @users,
          turbo_frame: "sortable_table",
          sort: "name",
          direction: "asc",
          base_url: "/users"
        )) do |component|
          component.column(title: "Name", html: ->(user) { user.name }, sortable: true, sort_key: :name)
        end

        assert_selector "th a[data-turbo-frame='sortable_table']"
      end

      def test_sortable_links_use_custom_turbo_frame_id
        render_inline(Component.new(
          data: @users,
          turbo_frame: "custom_users_table",
          sort: "name",
          direction: "asc",
          base_url: "/users"
        )) do |component|
          component.column(title: "Name", html: ->(user) { user.name }, sortable: true, sort_key: :name)
        end

        assert_selector "th a[data-turbo-frame='custom_users_table']"
        assert_no_selector "th a[data-turbo-frame='sortable_table']"
      end

      def test_wraps_table_in_turbo_frame_when_specified
        render_inline(Component.new(
          data: @users,
          turbo_frame: "sortable_table"
        )) do |component|
          component.column(title: "Name", html: ->(user) { user.name })
        end

        assert_selector "turbo-frame#sortable_table table"
      end

      def test_does_not_wrap_in_turbo_frame_when_not_specified
        render_inline(Component.new(data: @users)) do |component|
          component.column(title: "Name", html: ->(user) { user.name })
        end

        assert_no_selector "turbo-frame"
        assert_selector "table"
      end

      def test_sortable_column_uses_sort_key_when_provided
        render_inline(Component.new(
          data: @users,
          sort: "custom_sort",
          direction: "asc",
          base_url: "/users"
        )) do |component|
          component.column(
            title: "Name",
            html: ->(user) { user.name },
            sortable: true,
            sort_key: :custom_sort
          )
        end

        assert_selector "th a[href*='sort=custom_sort']"
        # Should show indicator since sort matches sort_key
        assert_selector "th a", text: /Name.*↑/
      end

      def test_sortable_column_falls_back_to_attribute_for_sort_key
        render_inline(Component.new(
          data: @users,
          sort: "name",
          direction: "asc",
          base_url: "/users"
        )) do |component|
          component.column(
            title: "Name",
            html: ->(user) { user.name },
            sortable: true,
            sort_key: :name
          )
        end

        assert_selector "th a[href*='sort=name']"
      end

      def test_sortable_column_with_formatter_still_sorts
        render_inline(Component.new(
          data: @users,
          sort: "name",
          direction: "asc",
          base_url: "/users"
        )) do |component|
          component.column(
            title: "Name",
            sortable: true,
            sort_key: :name,
            html: ->(user) { user.name.upcase }
          )
        end

        assert_selector "th a[href*='sort=name']"
        assert_selector "td", text: "ALICE"
      end
    end
  end
end
