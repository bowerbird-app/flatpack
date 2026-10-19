# frozen_string_literal: true

module FlatPack
  module Collage
    class Component < FlatPack::BaseComponent
      renders_many :items, "FlatPack::Collage::Item"
      undef_method :with_item, :with_item_content

      SCATTERS = %i[subtle loose none].freeze
      ENTRANCES = %i[rise deal none].freeze
      IDLES = %i[none drift].freeze
      HOVERS = %i[lift focus none].freeze
      STACK_BELOWS = %i[sm md lg xl].freeze
      COLUMN_COUNTS = (1..6)
      ROW_LIMIT = 8
      PATTERN_LIMIT = 6
      MOBILE_ITEM_COUNTS = (1..24)
      MOBILE_ITEMS_DEFAULT = 4

      def initialize(
        columns: 3,
        rows: nil,
        scatter: :subtle,
        stack_below: nil,
        mobile_items: MOBILE_ITEMS_DEFAULT,
        entrance: :rise,
        idle: :none,
        hover: :lift,
        **system_arguments
      )
        if system_arguments.key?(:motion)
          raise ArgumentError, "motion: is gone. Pass entrance:, idle:, and hover:."
        end

        super(**system_arguments)
        @columns = normalize_columns(columns)
        @rows = normalize_rows(rows)
        @scatter = normalize_choice(scatter)
        @stack_below = normalize_stack_below(stack_below)
        @mobile_items = normalize_mobile_items(mobile_items)
        @entrance = normalize_choice(entrance)
        @idle = normalize_choice(idle)
        @hover = normalize_choice(hover)

        validate_columns!
        validate_rows!
        validate_scatter!
        validate_stack_below!
        validate_mobile_items!
        validate_entrance!
        validate_idle!
        validate_hover!
      end

      def item(**kwargs, &block)
        set_slot(:items, nil, **kwargs, &block)
        nil
      end

      def call
        content
        prepare_items!
        content_tag(:div, safe_join(items), **container_attributes)
      end

      private

      def prepare_items!
        items.each_with_index do |item, index|
          item.index = index
          item.entrance = @entrance
          item.idle = @idle
          item.rows = @rows
          item.spare = index >= @mobile_items
          next unless @entrance == :deal

          x, y = item_place(index)
          item.place_x = x
          item.place_y = y
        end
      end

      def container_attributes
        user_style = @system_arguments.delete(:style)
        merge_attributes(
          class: collage_classes,
          style: join_styles(collage_style, user_style)
        )
      end

      def collage_classes
        classes(
          "fp-collage",
          "fp-collage--#{@scatter}",
          ("fp-collage--stack-#{@stack_below}" if @stack_below),
          ("fp-collage--teaser" unless @stack_below),
          ("fp-collage--brick" if @rows),
          "fp-collage--entrance-#{@entrance}",
          "fp-collage--idle-#{@idle}",
          "fp-collage--hover-#{@hover}"
        )
      end

      def collage_style
        parts = ["--fp-collage-columns: #{@columns}"]
        parts << "--fp-collage-tracks: #{@rows.max * 2}" if @rows
        if @entrance == :deal
          parts << "--fp-collage-center-x: #{css_number(center_x)}"
          parts << "--fp-collage-center-y: #{css_number(center_y)}"
          parts << "--fp-collage-count: #{items.size}"
          parts << "--fp-collage-mobile: #{@mobile_items}"
        end
        parts.join("; ")
      end

      def join_styles(*parts)
        joined = parts.compact.map { |part| part.to_s.strip }.reject(&:empty?).join("; ")
        joined.empty? ? nil : joined
      end

      def normalize_columns(columns)
        Integer(columns)
      rescue ArgumentError, TypeError
        columns
      end

      def validate_columns!
        return if @columns.is_a?(Integer) && COLUMN_COUNTS.cover?(@columns)

        raise ArgumentError, "Invalid columns: #{@columns.inspect}. Must be an integer from 1 to 6."
      end

      def normalize_rows(rows)
        return nil if rows.nil?

        Array(rows).map { |count| Integer(count) }
      rescue ArgumentError, TypeError
        rows
      end

      def validate_rows!
        return if @rows.nil?
        return if @rows.is_a?(Array) && @rows.any? && @rows.size <= PATTERN_LIMIT &&
          @rows.all? { |count| count.is_a?(Integer) && count >= 1 && count <= ROW_LIMIT }

        raise ArgumentError, "Invalid rows: #{@rows.inspect}. Pass a list of counts from 1 to #{ROW_LIMIT}, up to #{PATTERN_LIMIT} rows."
      end

      def validate_scatter!
        return if SCATTERS.include?(@scatter)

        raise ArgumentError, "Invalid scatter: #{@scatter.inspect}. Must be one of: #{SCATTERS.join(", ")}."
      end

      def normalize_stack_below(value)
        return if value.nil?

        value.to_sym
      rescue NoMethodError
        value
      end

      def validate_stack_below!
        return if @stack_below.nil?
        return if STACK_BELOWS.include?(@stack_below)

        raise ArgumentError, "Invalid stack_below: #{@stack_below.inspect}. Must be one of: #{STACK_BELOWS.join(", ")}, or omit it."
      end

      def normalize_mobile_items(value)
        Integer(value)
      rescue ArgumentError, TypeError
        value
      end

      def validate_mobile_items!
        return if @mobile_items.is_a?(Integer) && MOBILE_ITEM_COUNTS.cover?(@mobile_items)

        raise ArgumentError, "Invalid mobile_items: #{@mobile_items.inspect}. Must be an integer from 1 to 24."
      end

      def validate_entrance!
        return if ENTRANCES.include?(@entrance)

        raise ArgumentError, "Invalid entrance: #{@entrance.inspect}. Must be one of: #{ENTRANCES.join(", ")}."
      end

      def validate_idle!
        return if IDLES.include?(@idle)

        raise ArgumentError, "Invalid idle: #{@idle.inspect}. Must be one of: #{IDLES.join(", ")}."
      end

      def validate_hover!
        return if HOVERS.include?(@hover)

        raise ArgumentError, "Invalid hover: #{@hover.inspect}. Must be one of: #{HOVERS.join(", ")}."
      end

      def normalize_choice(value)
        value.to_sym
      rescue NoMethodError
        value
      end

      # Card widths from the collage centre. CSS multiplies by --collage-deal.
      # A shorter brick row is already centered, so its place sits on the wide row's scale.
      def item_place(index)
        if @rows
          spot = Item.spot(index, @rows)
          [(spot[:start] - 1) / spot[:span].to_f, spot[:row] - 1]
        else
          [index % @columns, index / @columns]
        end
      end

      def center_x
        wide = @rows ? @rows.max : @columns
        (wide - 1) / 2.0
      end

      def center_y
        count = items.size
        return 0.0 if count.zero?

        if @rows
          (Item.spot(count - 1, @rows)[:row] - 1) / 2.0
        else
          ((count.to_f / @columns).ceil - 1) / 2.0
        end
      end

      def css_number(number)
        format("%.2f", number).sub(/0+\z/, "").sub(/\.\z/, "")
      end
    end
  end
end
