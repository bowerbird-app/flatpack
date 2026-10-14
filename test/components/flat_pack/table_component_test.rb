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

      def test_scrollable_container_applies_default_minimum_width
        render_inline(Component.new(data: @users))

        assert_selector "div.overflow-x-auto > table.min-w-\\[40rem\\]"
      end

      def test_minimum_width_accepts_named_sizes
        render_inline(Component.new(data: @users, min_width: :lg))

        assert_selector "table.min-w-\\[48rem\\]"
      end

      def test_minimum_width_accepts_custom_class
        render_inline(Component.new(data: @users, min_width: "min-w-[72rem]"))

        assert_selector "table.min-w-\\[72rem\\]"
      end

      def test_minimum_width_can_be_disabled
        render_inline(Component.new(data: @users, min_width: :none))

        assert_selector "table.w-full"
        refute_includes page.native.to_html, "min-w-["
      end

      def test_minimum_width_rejects_unknown_values
        error = assert_raises(ArgumentError) do
          render_inline(Component.new(data: @users, min_width: :enormous))
        end

        assert_includes error.message, "min_width must be one of"
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

      def test_renders_table_with_actual_block_syntax
        render_inline(Component.new(data: @users)) do |component|
          component.column(title: "Name") do |user|
            user.name.upcase
          end
        end

        assert_selector "td", text: "ALICE"
        assert_selector "td", text: "BOB"
      end

      def test_renders_table_with_block_and_html_formatting
        render_inline(Component.new(data: @users)) do |component|
          component.column(title: "Formatted Name") do |user|
            "<strong>#{user.name}</strong>".html_safe
          end
        end

        assert_selector "td strong", text: "Alice"
        assert_selector "td strong", text: "Bob"
      end

      def test_renders_table_with_actions_column
        render_inline(Component.new(data: @users)) do |component|
          component.column(title: "Name", html: ->(user) { user.name })
          component.column(title: "Actions", html: ->(_user) { "Edit" })
        end

        assert_selector "th", text: "Actions"
        assert_selector "td", text: "Edit", count: 2
      end

      def test_renders_table_with_stimulus_controller
        render_inline(Component.new(data: @users, stimulus: true)) do |component|
          component.column(title: "Name", html: ->(user) { user.name })
        end

        assert_selector "div[data-controller='flat-pack--table']"
      end

      def test_renders_table_with_custom_column_block
        render_inline(Component.new(data: @users)) do |component|
          component.column(title: "Name", html: ->(user) { user.name })
          component.column(title: "Custom") do |user|
            "<span class=\"custom-action\">Custom #{user.name}</span>".html_safe
          end
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
        end

        assert_selector "td[colspan='2']", text: "No data available"
      end

      def test_shows_column_headers_by_default
        render_inline(Component.new(data: @users)) do |component|
          component.column(title: "Name", html: ->(user) { user.name })
        end

        assert_selector "thead.bg-\\[var\\(--table-header-background-color\\)\\]"
        assert_selector "th", text: "Name"
        refute_selector "thead.sr-only"
      end

      def test_hides_headers_visually_and_keeps_them_for_screen_readers
        render_inline(Component.new(data: @users, headers: false, base_url: "/users", sort: "email", direction: "asc")) do |component|
          component.column(title: "Name", html: ->(user) { user.name })
          component.column(title: "Email", sortable: true, sort_key: :email) { |user| user.email }
        end

        assert_selector "thead.sr-only", visible: :all
        assert_selector "thead.sr-only th", text: "Name", visible: :all
        assert_selector "thead.sr-only th", text: "Email", visible: :all
        assert_selector "thead.sr-only a", text: "Email", visible: :all
        assert_selector "td", text: "Alice"
        refute_selector "thead.bg-\\[var\\(--table-header-background-color\\)\\]"
      end

      def test_column_title_stays_required_when_headers_are_hidden
        error = assert_raises(ArgumentError) do
          render_inline(Component.new(data: @users, headers: false)) do |component|
            component.column(html: ->(user) { user.name })
          end
        end

        assert_includes error.message, "title"
      end

      def test_headers_rejects_non_boolean_values
        error = assert_raises(ArgumentError) do
          Component.new(data: @users, headers: :hidden)
        end

        assert_includes error.message, "headers must be true or false"
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

      def test_sortable_headers_render_sort_tooltips
        render_inline(Component.new(
          data: @users,
          sort: "name",
          direction: "asc",
          base_url: "/users"
        )) do |component|
          component.column(title: "Name", html: ->(user) { user.name }, sortable: true, sort_key: :name)
          component.column(title: "Email", html: ->(user) { user.email }, sortable: true, sort_key: :email)
        end

        assert_selector "th [data-controller='flat-pack--tooltip']", count: 2
        assert_selector "th [role='tooltip']", text: "Sort", count: 2
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

      def test_renders_draggable_rows_controller_and_reorder_values
        render_inline(Component.new(
          data: @users,
          draggable_rows: true,
          reorder: {
            url: "/demo/tables/reorder",
            version: "123.45",
            scope: {list_key: "tables-demo"}
          }
        )) do |component|
          component.column(title: "Name", html: ->(user) { user.name })
        end

        assert_selector "div[data-controller~='flat-pack--table-sortable']"
        assert_selector "div[data-flat-pack--table-sortable-reorder-url-value='/demo/tables/reorder']"
        assert_selector "div[data-flat-pack--table-sortable-resource-value='open_structs']"
        assert_selector "div[data-flat-pack--table-sortable-strategy-value='dense_integer']"
        assert_selector "div[data-flat-pack--table-sortable-version-value='123.45']"
      end

      def test_renders_draggable_row_targets_with_ids
        render_inline(Component.new(
          data: @users,
          draggable_rows: true
        )) do |component|
          component.column(title: "Name", html: ->(user) { user.name })
        end

        assert_selector "tr[data-flat-pack--table-sortable-target='row'][data-id='1']"
        assert_selector "tr[data-flat-pack--table-sortable-target='row'][data-id='2']"
      end

      def test_headers_are_sentence_case_not_all_caps
        render_inline(Component.new(data: @users)) do |component|
          component.column(title: "Name", html: ->(user) { user.name })
        end

        html = page.native.to_html
        refute_includes html, "uppercase"
        refute_includes html, "tracking-wider"
        assert_selector "th", text: "Name"
      end

      def test_default_alignment_is_logical_start
        render_inline(Component.new(data: @users)) do |component|
          component.column(title: "Name", html: ->(user) { user.name })
        end

        assert_selector "th.text-start", text: "Name"
        assert_selector "td.text-start", text: "Alice"
        refute_includes page.native.to_html, "text-left"
      end

      def test_align_center_and_end_apply_to_header_and_cells
        render_inline(Component.new(data: @users)) do |component|
          component.column(title: "Name", align: :center, html: ->(user) { user.name })
          component.column(title: "Email", align: "end", html: ->(user) { user.email })
        end

        assert_selector "th.text-center", text: "Name"
        assert_selector "td.text-center", text: "Alice"
        assert_selector "th.text-end", text: "Email"
        assert_selector "td.text-end", text: "alice@example.com"
      end

      def test_column_widths_render_on_col_and_a_length_stays_capped_beside_fit
        render_inline(Component.new(data: @users)) do |component|
          component.column(title: "Name", width: :fit, html: ->(user) { user.name })
          component.column(title: "Role", width: "12rem", min_width: "8rem", max_width: "20rem", html: ->(user) { user.email })
          component.column(title: "Email", width: :fill, html: ->(user) { user.email })
        end

        assert_selector "table.min-w-\\[40rem\\]"
        refute_selector "table.table-fixed"
        assert_selector "colgroup col", count: 3
        assert_selector "col[style='width: 1%']"
        assert_selector "col[style='width: 12rem; min-width: 8rem; max-width: 20rem']"
        assert_selector "th[style='min-width: 8rem; max-width: min(12rem, 20rem)']", text: "Role"
        assert_selector "td[style='min-width: 8rem; max-width: min(12rem, 20rem)']", text: "alice@example.com"
        assert_selector "col:not([style])", count: 1
      end

      def test_a_length_without_fit_uses_fixed_layout
        render_inline(Component.new(data: @users, min_width: :none)) do |component|
          component.column(title: "Role", width: "12rem", html: ->(user) { user.email })
          component.column(title: "Email", width: :fill, html: ->(user) { user.email })
        end

        assert_selector "table.table-fixed"
        assert_selector "col[style='width: 12rem']"
        assert_selector "th[style='max-width: 12rem']", text: "Role"
        assert_selector "td[style='max-width: 12rem']", text: "alice@example.com"
      end

      def test_fit_and_fill_alone_keep_automatic_table_layout
        render_inline(Component.new(data: @users, min_width: :none)) do |component|
          component.column(title: "Name", width: :fit, html: ->(user) { user.name })
          component.column(title: "Email", width: :fill, html: ->(user) { user.email })
        end

        assert_selector "col[style='width: 1%']"
        refute_selector "table.table-fixed"
        refute_includes page.native.to_html, "min-w-["
      end

      def test_wrap_nowrap_and_truncate_with_full_text_title
        render_inline(Component.new(data: @users)) do |component|
          component.column(title: "Name", wrap: :nowrap, html: ->(user) { user.name })
          component.column(title: "Email", width: "12rem", wrap: :truncate, html: ->(user) { user.email })
          component.column(
            title: "Bio",
            wrap: :truncate,
            html: ->(user) { "<strong>#{user.name}</strong> lives here".html_safe }
          )
        end

        assert_selector "td.whitespace-nowrap", text: "Alice"
        assert_selector "td.truncate[style='max-width: 12rem'][title='alice@example.com']", text: "alice@example.com"
        assert_selector "th.truncate[title='Email']", text: "Email"
        assert_selector "td[title='Alice lives here'] strong", text: "Alice"
        assert_selector "table.table-fixed"
      end

      def test_fill_truncate_uses_leftover_space_instead_of_growing_the_table
        render_inline(Component.new(data: @users, min_width: :none)) do |component|
          component.column(title: "Name", width: :fit, wrap: :nowrap, html: ->(user) { user.name })
          component.column(title: "Email", width: :fill, wrap: :truncate, html: ->(user) { user.email })
        end

        assert_selector "td.truncate[style='max-width: 0'][title='alice@example.com']", text: "alice@example.com"
        refute_selector "table.table-fixed"
      end

      def test_truncate_omits_title_when_the_cell_has_no_text
        render_inline(Component.new(data: @users)) do |component|
          component.column(title: "Name", wrap: :truncate, html: ->(_user) { "  " })
        end

        assert_selector "td.truncate", count: 2
        refute_selector "td[title]"
      end

      def test_hide_below_keeps_column_count_and_colspan
        render_inline(Component.new(data: [])) do |component|
          component.column(title: "Name", html: ->(user) { user.name })
          component.column(title: "Notes", hide_below: :md, html: ->(user) { user.email })
          component.column(title: "Email", hide_below: "lg", html: ->(user) { user.email })
        end

        assert_selector "th.max-md\\:hidden", text: "Notes", visible: :all
        assert_selector "th.max-lg\\:hidden", text: "Email", visible: :all
        assert_selector "col.max-md\\:\\[visibility\\:collapse\\]", visible: :all
        assert_selector "col.max-lg\\:\\[visibility\\:collapse\\]", visible: :all
        assert_selector "td[colspan='3']", text: "No data available"
      end

      def test_hide_below_hides_header_and_cells_together
        render_inline(Component.new(data: @users)) do |component|
          component.column(title: "Name", html: ->(user) { user.name })
          component.column(title: "Notes", hide_below: :sm, html: ->(user) { user.email })
        end

        assert_selector "th.max-sm\\:hidden", text: "Notes", visible: :all
        assert_selector "td.max-sm\\:hidden", text: "alice@example.com", visible: :all
        assert_selector "td.max-sm\\:hidden", text: "bob@example.com", visible: :all
      end

      def test_column_options_work_with_sortable_headers
        render_inline(Component.new(
          data: @users,
          sort: "email",
          direction: "asc",
          base_url: "/users"
        )) do |component|
          component.column(
            title: "Email address",
            sortable: true,
            sort_key: :email,
            align: :end,
            wrap: :truncate,
            hide_below: :lg,
            width: "10rem",
            html: ->(user) { user.email }
          )
        end

        assert_selector "th.text-end.truncate.max-lg\\:hidden.cursor-pointer[title='Email address']"
        assert_selector "th a[href*='sort=email'][href*='direction=desc']", text: /Email address/
        assert_selector "th a .shrink-0", text: "↑"
        assert_selector "td.text-end.truncate.max-lg\\:hidden[title='alice@example.com']"
        refute_selector "td.cursor-pointer"
        assert_selector "table.table-fixed"
      end

      def test_plain_style_drops_frame_and_row_hover
        render_inline(Component.new(data: @users, style: :plain, headers: false, min_width: :none)) do |component|
          component.column(title: "Name", width: :fit, html: ->(user) { user.name })
          component.column(title: "Email", width: "8rem", html: ->(user) { user.email })
          component.column(title: "Note", width: :fill, html: ->(user) { user.email })
        end

        assert_selector "div.overflow-x-auto"
        assert_selector "thead.sr-only", visible: :all
        refute_selector "table.table-fixed"
        assert_selector "td[style='max-width: 8rem']", text: "alice@example.com"
        refute_selector "div.border"
        refute_selector "div.rounded-\\[var\\(--radius-lg\\)\\]"
        refute_selector "tr[class]"
        assert_selector "td", text: "Alice"
      end

      def test_dividers_can_be_removed
        render_inline(Component.new(data: @users, dividers: false)) do |component|
          component.column(title: "Name", html: ->(user) { user.name })
        end

        html = page.native.to_html
        refute_includes html, "divide-y"
        refute_includes html, "border-[var(--table-header-border-color)]"
        assert_selector "thead.bg-\\[var\\(--table-header-background-color\\)\\]"
      end

      def test_default_style_keeps_frame_dividers_and_hover
        render_inline(Component.new(data: @users)) do |component|
          component.column(title: "Name", html: ->(user) { user.name })
        end

        assert_selector "div.overflow-x-auto.rounded-\\[var\\(--radius-lg\\)\\].border"
        assert_selector "tbody.divide-y"
        assert_selector "thead.border-b"
        assert_selector "tr.hover\\:bg-\\[var\\(--table-row-hover-background-color\\)\\]"
        refute_selector "table.table-fixed"
        refute_selector "colgroup"
      end

      def test_draggable_handle_column_can_fit_its_content
        render_inline(Component.new(data: @users, draggable_rows: true, reorder_url: "/demo/tables/reorder")) do |component|
          component.column(title: "Reorder", width: :fit, wrap: :nowrap, align: :center, html: ->(_user) { "⋮⋮" })
          component.column(title: "Name", width: :fill, html: ->(user) { user.name })
        end

        assert_selector "div[data-controller~='flat-pack--table-sortable']"
        assert_selector "tr[data-flat-pack--table-sortable-target='row'][data-id='1']"
        assert_selector "col[style='width: 1%']"
        assert_selector "td.whitespace-nowrap.text-center", text: "⋮⋮"
        refute_selector "table.table-fixed"
      end

      def test_column_rejects_class_and_raw_style_overrides
        render_inline(Component.new(data: @users)) do |component|
          class_error = assert_raises(ArgumentError) do
            component.column(title: "Name", class: "text-red-500")
          end
          style_error = assert_raises(ArgumentError) do
            component.column(title: "Name", style: "color: red")
          end

          assert_includes class_error.message, "unknown keyword"
          assert_includes style_error.message, "unknown keyword"
        end
      end

      def test_column_rejects_unknown_width_align_wrap_and_breakpoint
        render_inline(Component.new(data: @users)) do |component|
          assert_raises(ArgumentError) { component.column(title: "Name", width: "w-12") }
          assert_raises(ArgumentError) { component.column(title: "Name", width: "12rem; color: red") }
          assert_raises(ArgumentError) { component.column(title: "Name", min_width: :md) }
          assert_raises(ArgumentError) { component.column(title: "Name", max_width: "8") }
          assert_raises(ArgumentError) { component.column(title: "Name", align: :left) }
          assert_raises(ArgumentError) { component.column(title: "Name", wrap: :clip) }
          assert_raises(ArgumentError) { component.column(title: "Name", hide_below: :xxl) }
        end
      end

      def test_table_style_and_dividers_reject_unknown_values
        style_error = assert_raises(ArgumentError) { Component.new(data: @users, style: :ghost) }
        dividers_error = assert_raises(ArgumentError) { Component.new(data: @users, dividers: :none) }

        assert_includes style_error.message, "style must be one of"
        assert_includes dividers_error.message, "dividers must be true or false"
      end

      def test_accepts_zero_and_fractional_lengths
        render_inline(Component.new(data: @users, min_width: :none)) do |component|
          component.column(title: "Name", width: "0.5rem", min_width: "0", html: ->(user) { user.name })
        end

        assert_selector "col[style='width: 0.5rem; min-width: 0']"
        assert_selector "td[style='min-width: 0; max-width: 0.5rem']", text: "Alice"
        assert_selector "table.table-fixed"
      end
    end
  end
end
