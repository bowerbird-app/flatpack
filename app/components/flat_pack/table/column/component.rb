# frozen_string_literal: true

module FlatPack
  module Table
    module Column
      class Component < ViewComponent::Base
        attr_reader :sortable, :sort_key

        def initialize(title:, html: nil, sortable: false, sort_key: nil)
          @title = title
          # Support both html: proc (includes block-converted-to-proc)
          @html = html
          @sortable = sortable
          @sort_key = sort_key
        end

        def render_header(current_sort: nil, current_direction: nil, base_url: nil, turbo_frame: nil)
          return tag.th(@title, class: header_classes) unless @sortable

          tag.th(class: sortable_header_classes) do
            if base_url
              sort_link(current_sort, current_direction, base_url, turbo_frame)
            else
              @title
            end
          end
        end

        def render_cell(row)
          # Get the content from html proc
          cell_content = if @html
            @html.call(row)
          else
            ""
          end

          # SECURITY: Cell content from the html proc is marked html_safe only if it's
          # already marked as safe (e.g., from Rails helpers like link_to). Otherwise,
          # content is HTML-escaped to prevent XSS. This ensures user-provided data
          # is always escaped while allowing safe HTML from Rails helpers.
          escaped_content = cell_content.html_safe? ? cell_content : ERB::Util.html_escape(cell_content)
          "<td class=\"#{cell_classes}\">#{escaped_content}</td>".html_safe
        end

        private

        def sort_link(current_sort, current_direction, base_url, turbo_frame)
          new_direction = calculate_new_direction(current_sort, current_direction)
          sort_url = build_sort_url(base_url, new_direction)

          # Use provided turbo_frame or default to "sortable_table"
          frame_id = turbo_frame || "sortable_table"

          tag.a(href: sort_url, data: {turbo_frame: frame_id}, class: "group inline-flex items-center gap-1 hover:text-[var(--table-sort-link-hover-color)] transition-colors") do
            safe_join([
              @title,
              sort_indicator(current_sort, current_direction)
            ])
          end
        end

        def calculate_new_direction(current_sort, current_direction)
          if current_sort.to_s == @sort_key.to_s
            (current_direction == "asc") ? "desc" : "asc"
          else
            "asc"
          end
        end

        def build_sort_url(base_url, direction)
          uri = URI.parse(base_url)
          params = Rack::Utils.parse_nested_query(uri.query || "")
          params["sort"] = @sort_key.to_s
          params["direction"] = direction
          uri.query = URI.encode_www_form(params)
          uri.to_s
        end

        def sort_indicator(current_sort, current_direction)
          return "" unless current_sort.to_s == @sort_key.to_s

          arrow = (current_direction == "asc") ? "↓" : "↑"
          tag.span(arrow, class: "ms-1 text-primary font-bold")
        end

        def header_classes
          "px-[var(--table-padding)] py-[var(--table-padding)] text-left text-xs font-medium text-[var(--table-header-text-color)] uppercase tracking-wider"
        end

        def sortable_header_classes
          "#{header_classes} cursor-pointer select-none"
        end

        def cell_classes
          "px-[var(--table-padding)] py-[var(--table-padding)] text-sm text-[var(--table-cell-text-color)]"
        end
      end
    end
  end
end
