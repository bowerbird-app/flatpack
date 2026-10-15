# frozen_string_literal: true

module FlatPack
  module Collection
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "m-0" "list-none" "p-0" "gap-2" "gap-4" "gap-6"
      # "grid" "items-stretch" "grid-cols-[repeat(auto-fill,minmax(var(--fp-collection-min-item-width),1fr))]"
      # "flex" "flex-wrap" "items-center" "flex-col" "min-w-0"
      # "[&>*]:min-w-0" "[&>*]:w-full" "[&>*]:flex-1" "[&>*]:self-stretch"
      LIST_RESET = "m-0 list-none p-0"

      GAPS = {
        sm: "gap-2",
        md: "gap-4",
        lg: "gap-6"
      }.freeze

      LAYOUTS = {
        grid: "grid items-stretch grid-cols-[repeat(auto-fill,minmax(var(--fp-collection-min-item-width),1fr))]",
        wrap: "flex flex-wrap items-center",
        stack: "flex flex-col"
      }.freeze

      ITEM_CLASSES = {
        grid: "flex min-w-0 items-stretch [&>*]:min-w-0 [&>*]:w-full [&>*]:flex-1 [&>*]:self-stretch",
        wrap: "flex",
        stack: "min-w-0"
      }.freeze

      AS = %i[list nav].freeze
      DEFAULT_MIN_ITEM_WIDTH = "14rem"
      CSS_LENGTH = /\A\d+(?:\.\d+)?(?:px|rem|em|ch|ex|vw|vh|vmin|vmax|%)\z/

      renders_many :items

      def initialize(
        as: :list,
        layout: :stack,
        gap: :md,
        label: nil,
        min_item_width: nil,
        **system_arguments
      )
        super(**system_arguments)
        @as = as.to_sym
        @layout = layout.to_sym
        @gap = gap.to_sym
        @label = label
        @min_item_width_given = !min_item_width.nil?
        @min_item_width = min_item_width.nil? ? DEFAULT_MIN_ITEM_WIDTH : min_item_width

        validate_as!
        validate_layout!
        validate_gap!
        validate_label!
        validate_min_item_width!
      end

      def call
        list = content_tag(:ul, safe_join(item_tags), **list_attributes)
        return list unless nav?

        content_tag(:nav, list, **nav_attributes)
      end

      private

      def item_tags
        items.map { |item| content_tag(:li, item, class: ITEM_CLASSES.fetch(@layout)) }
      end

      def nav?
        @as == :nav
      end

      def grid?
        @layout == :grid
      end

      def list_attributes
        attrs = {class: list_classes}
        attrs[:style] = grid_style if grid?
        return attrs if nav?

        merge_attributes(**attrs)
      end

      def nav_attributes
        merge_attributes(aria: {label: @label})
      end

      def list_classes
        [LIST_RESET, LAYOUTS.fetch(@layout), GAPS.fetch(@gap)].join(" ")
      end

      def grid_style
        "--fp-collection-min-item-width: #{@min_item_width}"
      end

      def validate_as!
        return if AS.include?(@as)

        raise ArgumentError, "Invalid as: #{@as.inspect}. Must be one of: #{AS.join(", ")}."
      end

      def validate_layout!
        return if LAYOUTS.key?(@layout)

        raise ArgumentError, "Invalid layout: #{@layout.inspect}. Must be one of: #{LAYOUTS.keys.join(", ")}."
      end

      def validate_gap!
        return if GAPS.key?(@gap)

        raise ArgumentError, "Invalid gap: #{@gap.inspect}. Must be one of: #{GAPS.keys.join(", ")}."
      end

      def validate_label!
        if nav?
          raise ArgumentError, "label: is required when as is :nav." if @label.nil?

          validate_text_option!(@label, name: :label)
          raise ArgumentError, "label: is required when as is :nav." if @label.strip.empty?
        elsif !@label.nil?
          raise ArgumentError, "label: is only supported when as is :nav."
        end
      end

      def validate_min_item_width!
        if !grid? && @min_item_width_given
          raise ArgumentError, "min_item_width: is only supported when layout is :grid."
        end

        return unless grid?
        return if @min_item_width.is_a?(String) && @min_item_width.match?(CSS_LENGTH)

        raise ArgumentError, "Invalid min_item_width: #{@min_item_width.inspect}. Pass a CSS length such as \"14rem\"."
      end
    end
  end
end
