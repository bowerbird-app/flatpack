# frozen_string_literal: true

module FlatPack
  module AvatarGroup
    class Component < FlatPack::BaseComponent
      OVERLAPS = {
        sm: "-0.25rem",
        md: "-0.5rem",
        lg: "-0.75rem"
      }.freeze

      OVERLAP_CLASSES = {
        sm: "-space-x-1",
        md: "-space-x-2",
        lg: "-space-x-3"
      }.freeze

      def initialize(
        items:,
        max: 5,
        size: :sm,
        overlap: :md,
        show_overflow: true,
        overflow_href: nil,
        **system_arguments
      )
        super(**system_arguments)
        @items = items || []
        @max = max
        @size = size.to_sym
        @overlap = overlap.to_sym
        @show_overflow = show_overflow
        @overflow_href = overflow_href

        validate_items!
        validate_overlap!
      end

      def call
        content_tag(:div, **group_attributes) do
          safe_join(render_avatars)
        end
      end

      private

      def group_attributes
        merge_attributes(
          class: group_classes,
          style: "--fp-avatar-overlap: #{overlap_margin}"
        )
      end

      def group_classes
        classes("flex items-center", OVERLAP_CLASSES.fetch(@overlap))
      end

      def render_avatars
        avatars = []
        visible_items = @items.take(@max)
        
        visible_items.each_with_index do |item, index|
          avatars << render_avatar(item, index)
        end

        if @show_overflow && overflow_count > 0
          avatars << render_overflow
        end

        avatars
      end

      def render_avatar(item, index)
        avatar_attrs = item.is_a?(Hash) ? item.symbolize_keys : {}
        styles = ["z-index: #{@items.length - index}"]
        styles << "margin-left: #{overlap_margin}" if index.positive?
        
        content_tag(:div,
          class: "relative hover:z-10 focus-within:z-10 transition-transform hover:scale-110",
          style: styles.join("; ")) do
          FlatPack::Avatar::Component.new(
            src: avatar_attrs[:src],
            alt: avatar_attrs[:alt],
            name: avatar_attrs[:name],
            initials: avatar_attrs[:initials],
            size: @size,
            shape: :circle,
            status: avatar_attrs[:status],
            href: avatar_attrs[:href],
            class: "ring-2 ring-white dark:ring-zinc-900"
          ).render_in(view_context)
        end
      end

      def render_overflow
        content_tag(:div,
          class: "relative hover:z-10 transition-transform hover:scale-110",
          style: overflow_styles) do
          FlatPack::Avatar::Component.new(
            initials: "+#{overflow_count}",
            size: @size,
            shape: :circle,
            href: @overflow_href,
            class: "ring-2 ring-white dark:ring-zinc-900"
          ).render_in(view_context)
        end
      end

      def overflow_count
        @items.length - @max
      end

      def overlap_margin
        OVERLAPS.fetch(@overlap)
      end

      def overflow_styles
        return nil if @max.zero?
        "margin-left: #{overlap_margin}"
      end

      def validate_items!
        unless @items.is_a?(Array)
          raise ArgumentError, "items must be an Array"
        end
      end

      def validate_overlap!
        return if OVERLAPS.key?(@overlap)
        raise ArgumentError, "Invalid overlap: #{@overlap}. Must be one of: #{OVERLAPS.keys.join(", ")}"
      end
    end
  end
end
