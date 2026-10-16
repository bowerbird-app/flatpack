# frozen_string_literal: true

module FlatPack
  module Collage
    class Component < FlatPack::BaseComponent
      renders_many :items, "FlatPack::Collage::Item"
      undef_method :with_item, :with_item_content

      SCATTERS = %i[subtle loose none].freeze
      STACK_BELOWS = %i[sm md lg xl].freeze
      COLUMN_COUNTS = (1..6)
      ROW_LIMIT = 8
      PATTERN_LIMIT = 6

      def initialize(
        columns: 3,
        rows: nil,
        scatter: :subtle,
        stack_below: :md,
        motion: true,
        **system_arguments
      )
        super(**system_arguments)
        @columns = normalize_columns(columns)
        @rows = normalize_rows(rows)
        @scatter = scatter.to_sym
        @stack_below = stack_below.to_sym
        @motion = motion

        validate_columns!
        validate_rows!
        validate_scatter!
        validate_stack_below!
        validate_motion!
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
          item.motion = @motion
          item.rows = @rows
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
          "fp-collage--stack-#{@stack_below}",
          ("fp-collage--brick" if @rows),
          ("fp-collage--motion" if @motion)
        )
      end

      def collage_style
        parts = ["--fp-collage-columns: #{@columns}"]
        parts << "--fp-collage-tracks: #{@rows.max * 2}" if @rows
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

      def validate_stack_below!
        return if STACK_BELOWS.include?(@stack_below)

        raise ArgumentError, "Invalid stack_below: #{@stack_below.inspect}. Must be one of: #{STACK_BELOWS.join(", ")}."
      end

      def validate_motion!
        return if @motion == true || @motion == false

        raise ArgumentError, "Invalid motion: #{@motion.inspect}. Must be true or false."
      end
    end
  end
end
