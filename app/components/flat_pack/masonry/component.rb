# frozen_string_literal: true

module FlatPack
  module Masonry
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "columns-1" "columns-2" "columns-3" "columns-4" "columns-5" "columns-6"
      # "sm:columns-1" "sm:columns-2" "sm:columns-3" "sm:columns-4" "sm:columns-5" "sm:columns-6"
      # "md:columns-1" "md:columns-2" "md:columns-3" "md:columns-4" "md:columns-5" "md:columns-6"
      # "lg:columns-1" "lg:columns-2" "lg:columns-3" "lg:columns-4" "lg:columns-5" "lg:columns-6"
      # "xl:columns-1" "xl:columns-2" "xl:columns-3" "xl:columns-4" "xl:columns-5" "xl:columns-6"
      # "grid-cols-1" "grid-cols-2" "grid-cols-3" "grid-cols-4" "grid-cols-5" "grid-cols-6"
      # "sm:grid-cols-1" "sm:grid-cols-2" "sm:grid-cols-3" "sm:grid-cols-4" "sm:grid-cols-5" "sm:grid-cols-6"
      # "md:grid-cols-1" "md:grid-cols-2" "md:grid-cols-3" "md:grid-cols-4" "md:grid-cols-5" "md:grid-cols-6"
      # "lg:grid-cols-1" "lg:grid-cols-2" "lg:grid-cols-3" "lg:grid-cols-4" "lg:grid-cols-5" "lg:grid-cols-6"
      # "xl:grid-cols-1" "xl:grid-cols-2" "xl:grid-cols-3" "xl:grid-cols-4" "xl:grid-cols-5" "xl:grid-cols-6"
      # "gap-2" "gap-4" "gap-6"
      renders_many :items, "FlatPack::Masonry::Item"
      undef_method :with_item, :with_item_content

      ORDERS = %i[columns rows].freeze
      GAPS = {
        sm: "gap-2",
        md: "gap-4",
        lg: "gap-6"
      }.freeze
      GAP_SIZES = {
        sm: "0.5rem",
        md: "1rem",
        lg: "1.5rem"
      }.freeze
      BREAKPOINTS = %i[base sm md lg xl].freeze
      COLUMN_COUNTS = (1..6)
      DEFAULT_COLUMNS = {base: 2, md: 3, lg: 4}.freeze
      COLUMN_COUNT_CLASSES = {
        base: {
          1 => "columns-1",
          2 => "columns-2",
          3 => "columns-3",
          4 => "columns-4",
          5 => "columns-5",
          6 => "columns-6"
        },
        sm: {
          1 => "sm:columns-1",
          2 => "sm:columns-2",
          3 => "sm:columns-3",
          4 => "sm:columns-4",
          5 => "sm:columns-5",
          6 => "sm:columns-6"
        },
        md: {
          1 => "md:columns-1",
          2 => "md:columns-2",
          3 => "md:columns-3",
          4 => "md:columns-4",
          5 => "md:columns-5",
          6 => "md:columns-6"
        },
        lg: {
          1 => "lg:columns-1",
          2 => "lg:columns-2",
          3 => "lg:columns-3",
          4 => "lg:columns-4",
          5 => "lg:columns-5",
          6 => "lg:columns-6"
        },
        xl: {
          1 => "xl:columns-1",
          2 => "xl:columns-2",
          3 => "xl:columns-3",
          4 => "xl:columns-4",
          5 => "xl:columns-5",
          6 => "xl:columns-6"
        }
      }.freeze
      GRID_COLUMN_CLASSES = {
        base: {
          1 => "grid-cols-1",
          2 => "grid-cols-2",
          3 => "grid-cols-3",
          4 => "grid-cols-4",
          5 => "grid-cols-5",
          6 => "grid-cols-6"
        },
        sm: {
          1 => "sm:grid-cols-1",
          2 => "sm:grid-cols-2",
          3 => "sm:grid-cols-3",
          4 => "sm:grid-cols-4",
          5 => "sm:grid-cols-5",
          6 => "sm:grid-cols-6"
        },
        md: {
          1 => "md:grid-cols-1",
          2 => "md:grid-cols-2",
          3 => "md:grid-cols-3",
          4 => "md:grid-cols-4",
          5 => "md:grid-cols-5",
          6 => "md:grid-cols-6"
        },
        lg: {
          1 => "lg:grid-cols-1",
          2 => "lg:grid-cols-2",
          3 => "lg:grid-cols-3",
          4 => "lg:grid-cols-4",
          5 => "lg:grid-cols-5",
          6 => "lg:grid-cols-6"
        },
        xl: {
          1 => "xl:grid-cols-1",
          2 => "xl:grid-cols-2",
          3 => "xl:grid-cols-3",
          4 => "xl:grid-cols-4",
          5 => "xl:grid-cols-5",
          6 => "xl:grid-cols-6"
        }
      }.freeze

      def initialize(
        columns: DEFAULT_COLUMNS,
        gap: :md,
        order: :columns,
        **system_arguments
      )
        super(**system_arguments)
        @columns = normalize_columns(columns)
        @gap = gap.to_sym
        @order = order.to_sym

        validate_columns!
        validate_gap!
        validate_order!
      end

      def with_item(**system_arguments, &block)
        set_slot(:items, nil, **system_arguments, &block)
        nil
      end

      def with_image(**kwargs, &block)
        with_item { render(FlatPack::Masonry::Image.new(**kwargs), &block) }
      end

      def call
        captured = content
        content_tag(:div, **container_attributes) do
          if items?
            safe_join(items)
          else
            captured
          end
        end
      end

      private

      def container_attributes
        attrs = {
          class: masonry_classes,
          style: masonry_style
        }
        attrs[:data] = rows_data if rows?

        merge_attributes(**attrs)
      end

      def masonry_classes
        classes(
          "fp-masonry",
          rows? ? "fp-masonry--rows" : "fp-masonry--columns",
          column_count_classes,
          (grid_column_classes if rows?),
          gap_classes
        )
      end

      def masonry_style
        "--fp-masonry-gap: #{GAP_SIZES.fetch(@gap)}; --fp-masonry-row: 8px"
      end

      def rows_data
        {
          controller: "flat-pack--masonry"
        }
      end

      def rows?
        @order == :rows
      end

      def column_count_classes
        @columns.map { |breakpoint, count| COLUMN_COUNT_CLASSES.fetch(breakpoint).fetch(count) }
      end

      def grid_column_classes
        @columns.map { |breakpoint, count| GRID_COLUMN_CLASSES.fetch(breakpoint).fetch(count) }
      end

      def gap_classes
        GAPS.fetch(@gap)
      end

      def normalize_columns(columns)
        if columns.is_a?(Hash)
          columns.to_h { |breakpoint, count| [breakpoint.to_sym, Integer(count)] }
        else
          {base: Integer(columns)}
        end
      rescue ArgumentError, TypeError
        columns
      end

      def validate_columns!
        unless @columns.is_a?(Hash) && @columns.any?
          raise ArgumentError, "Invalid columns: #{@columns.inspect}. Use an integer 1-6 or a hash like {base: 2, md: 3, lg: 4}."
        end

        unknown = @columns.keys - BREAKPOINTS
        if unknown.any?
          raise ArgumentError, "Invalid columns breakpoints: #{unknown.join(", ")}. Must be one of: #{BREAKPOINTS.join(", ")}"
        end

        @columns.each do |breakpoint, count|
          next if COLUMN_COUNTS.cover?(count)

          raise ArgumentError, "Invalid columns #{breakpoint}: #{count.inspect}. Must be an integer from 1 to 6."
        end
      end

      def validate_gap!
        return if GAPS.key?(@gap)

        raise ArgumentError, "Invalid gap: #{@gap}. Must be one of: #{GAPS.keys.join(", ")}"
      end

      def validate_order!
        return if ORDERS.include?(@order)

        raise ArgumentError, "Invalid order: #{@order}. Must be one of: #{ORDERS.join(", ")}"
      end
    end
  end
end
