# frozen_string_literal: true

module FlatPack
  module Table
    module Column
      class Component < ViewComponent::Base
        # A simple length only. Callers cannot pass a class or a raw style
        # string; these values are the only CSS written onto the column.
        CSS_LENGTH = /
          \A
          (?:
            0
            |
            (?:0|[1-9]\d*)(?:\.\d+)?
              (?:px|rem|em|ch|ex|%|vw|vh|vmin|vmax|cm|mm|in|pt|pc|lh|rlh|svw|svh|dvw|dvh|lvw|lvh|cqw|cqh|cqi|cqb)
          )
          \z
        /x

        WIDTHS = %i[fit fill].freeze

        # Tailwind CSS scanning requires these classes to be present as string literals.
        # DO NOT REMOVE - These duplicates ensure CSS generation:
        # "text-start" "text-center" "text-end"
        ALIGNS = {
          start: "text-start",
          center: "text-center",
          end: "text-end"
        }.freeze

        # Tailwind CSS scanning requires these classes to be present as string literals.
        # DO NOT REMOVE - These duplicates ensure CSS generation:
        # "whitespace-nowrap" "truncate"
        WRAPS = {
          wrap: nil,
          nowrap: "whitespace-nowrap",
          truncate: "truncate"
        }.freeze

        # Tailwind CSS scanning requires these classes to be present as string literals.
        # DO NOT REMOVE - These duplicates ensure CSS generation:
        # "max-sm:hidden" "max-md:hidden" "max-lg:hidden" "max-xl:hidden"
        HIDE_BELOW = {
          sm: "max-sm:hidden",
          md: "max-md:hidden",
          lg: "max-lg:hidden",
          xl: "max-xl:hidden"
        }.freeze

        # Tailwind CSS scanning requires these classes to be present as string literals.
        # DO NOT REMOVE - These duplicates ensure CSS generation:
        # "max-sm:[visibility:collapse]" "max-md:[visibility:collapse]" "max-lg:[visibility:collapse]" "max-xl:[visibility:collapse]"
        HIDE_BELOW_COLUMNS = {
          sm: "max-sm:[visibility:collapse]",
          md: "max-md:[visibility:collapse]",
          lg: "max-lg:[visibility:collapse]",
          xl: "max-xl:[visibility:collapse]"
        }.freeze

        attr_reader :sortable, :sort_key, :width, :hide_below

        def initialize(
          title:,
          html: nil,
          sortable: false,
          sort_key: nil,
          width: nil,
          min_width: nil,
          max_width: nil,
          align: :start,
          wrap: :wrap,
          hide_below: nil
        )
          @title = title
          @html = html
          @sortable = sortable
          @sort_key = sort_key
          @width = normalize_width(width)
          @min_width = normalize_length("min_width", min_width)
          @max_width = normalize_length("max_width", max_width)
          @align = normalize_choice("align", align, ALIGNS)
          @wrap = normalize_choice("wrap", wrap, WRAPS)
          @hide_below = normalize_hide_below(hide_below)
        end

        def fixed_width?
          @width.is_a?(String)
        end

        def fit_width?
          @width == :fit
        end

        def colgroup_needed?
          @width.present? || @min_width.present? || @max_width.present? || @hide_below.present?
        end

        def render_col
          attributes = {}
          collapse = HIDE_BELOW_COLUMNS[@hide_below]
          attributes[:class] = collapse if collapse
          style = col_style
          attributes[:style] = style if style
          tag.col(**attributes)
        end

        def render_header(current_sort: nil, current_direction: nil, base_url: nil, turbo_frame: nil, render_context: nil)
          @rendering_header = true
          if @sortable
            tag.th(**cell_attributes(title: @title)) do
              if base_url
                sort_link(current_sort, current_direction, base_url, turbo_frame, render_context)
              else
                header_label
              end
            end
          else
            tag.th(**cell_attributes(title: @title)) { header_label }
          end
        ensure
          @rendering_header = false
        end

        def render_cell(row)
          content = cell_content(row)
          tag.td(**cell_attributes(content: content)) { content }
        end

        private

        def header_label
          return @title unless @wrap == :truncate

          tag.span(@title, class: "min-w-0 truncate")
        end

        def cell_content(row)
          return "" unless @html

          rendered = @html.call(row)
          rendered.nil? ? "" : rendered
        end

        def cell_attributes(content: nil, title: nil)
          attributes = {class: cell_classes}
          style = cell_constraint_style
          attributes[:style] = style if style
          tooltip = truncate_title(content: content, title: title)
          attributes[:title] = tooltip if tooltip
          attributes
        end

        def cell_classes
          [
            "px-[var(--table-padding-x)] py-[var(--table-padding-y)]",
            (@rendering_header ? header_chrome_classes : "text-sm text-[var(--table-cell-text-color)]"),
            ALIGNS.fetch(@align),
            WRAPS[@wrap],
            HIDE_BELOW[@hide_below]
          ].compact.join(" ")
        end

        def header_chrome_classes
          classes = ["text-xs", "font-medium", "text-[var(--table-header-text-color)]"]
          classes << "cursor-pointer" << "select-none" if @sortable
          classes.join(" ")
        end

        def col_style
          declarations = []
          case @width
          when :fit
            # 1% is a preferred width. Automatic layout then grows the column
            # to its content instead of sharing leftover space.
            declarations << "width: 1%"
          when String
            declarations << "width: #{@width}"
          end
          declarations << "min-width: #{@min_width}" if @min_width
          declarations << "max-width: #{@max_width}" if @max_width
          declarations.join("; ").presence
        end

        # Browsers ignore min-width and max-width on <col>. The cells honor them.
        # A length width is also a cap, so an unbreakable string cannot grow the
        # column past it when a :fit sibling keeps automatic layout.
        def cell_constraint_style
          parts = []
          parts << "min-width: #{@min_width}" if @min_width
          cap = width_cap
          parts << "max-width: #{cap}" if cap
          parts.join("; ").presence
        end

        def width_cap
          return "min(#{@width}, #{@max_width})" if @width.is_a?(String) && @max_width
          return @width if @width.is_a?(String)
          return @max_width if @max_width
          # A fill column's content is nowrap when truncated. max-width: 0 lets
          # that column keep the leftover space and ellipsize, instead of
          # growing the table to the full string.
          return "0" if @width == :fill && @wrap == :truncate

          nil
        end

        def truncate_title(content: nil, title: nil)
          return unless @wrap == :truncate

          text = title.nil? ? plain_text(content) : title.to_s.squish
          text.presence
        end

        def plain_text(content)
          string = content.to_s
          return string.squish unless content.respond_to?(:html_safe?) && content.html_safe?

          Rails::HTML::FullSanitizer.new.sanitize(string).to_s.squish
        end

        def sort_link(current_sort, current_direction, base_url, turbo_frame, render_context)
          new_direction = calculate_new_direction(current_sort, current_direction)
          sort_url = build_sort_url(base_url, new_direction)
          frame_id = turbo_frame || "sortable_table"

          FlatPack::Tooltip::Component.new(text: FlatPack::Copy.t("table.sort"), placement: :top).render_in(render_context) do
            tag.a(href: sort_url, data: {turbo_frame: frame_id}, class: sort_link_classes) do
              safe_join([
                header_label,
                sort_indicator(current_sort, current_direction)
              ])
            end
          end
        end

        def sort_link_classes
          [
            "group inline-flex items-center gap-1 hover:text-[var(--table-sort-link-hover-color)] transition-colors",
            ("min-w-0 max-w-full" if @wrap == :truncate)
          ].compact.join(" ")
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

          arrow = (current_direction == "asc") ? "↑" : "↓"
          tag.span(arrow, class: "ms-1 shrink-0 text-primary font-bold")
        end

        def normalize_width(width)
          return if width.nil?
          return width.to_sym if width.is_a?(Symbol) && WIDTHS.include?(width.to_sym)
          return width if width.is_a?(String) && width.match?(CSS_LENGTH)

          raise ArgumentError, %(width must be :fit, :fill, or a CSS length such as "12rem")
        end

        def normalize_length(name, length)
          return if length.nil?
          return length if length.is_a?(String) && length.match?(CSS_LENGTH)

          raise ArgumentError, %(#{name} must be a CSS length such as "8rem")
        end

        def normalize_choice(name, value, choices)
          key = value.to_sym
          return key if choices.key?(key)

          raise ArgumentError, "#{name} must be one of #{choices.keys.join(", ")}"
        end

        def normalize_hide_below(hide_below)
          return if hide_below.nil?

          key = hide_below.to_sym
          return key if HIDE_BELOW.key?(key)

          raise ArgumentError, "hide_below must be one of #{HIDE_BELOW.keys.join(", ")}"
        end
      end
    end
  end
end
