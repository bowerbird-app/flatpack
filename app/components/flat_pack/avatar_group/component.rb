# frozen_string_literal: true

module FlatPack
  module AvatarGroup
    class Component < FlatPack::BaseComponent
      OVERLAPS = {
        sm: "var(--avatar-group-overlap-sm)",
        md: "var(--avatar-group-overlap-md)",
        lg: "var(--avatar-group-overlap-lg)"
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
          class: "relative hover:!z-[999] focus-within:!z-[999]",
          style: styles.join("; ")) do
          render_avatar_content(avatar_attrs)
        end
      end

      def render_avatar_content(avatar_attrs)
        avatar = FlatPack::Avatar::Component.new(
          src: avatar_attrs[:src],
          alt: avatar_attrs[:alt],
          name: avatar_attrs[:name],
          initials: avatar_attrs[:initials],
          size: @size,
          shape: :circle,
          status: avatar_attrs[:status],
          href: avatar_attrs[:href],
          class: "ring-2 ring-[var(--avatar-group-ring-color)] transition-transform hover:scale-110"
        )

        tooltip_text = avatar_attrs[:name].presence || avatar_attrs[:alt].presence
        return avatar.render_in(view_context) if tooltip_text.blank?

        FlatPack::Tooltip::Component.new(text: tooltip_text, placement: :bottom).render_in(view_context) do
          avatar.render_in(view_context)
        end
      end

      def render_overflow
        content_tag(:div,
          class: "relative hover:!z-[999]",
          style: overflow_styles) do
          render_overflow_content
        end
      end

      def render_overflow_content
        overflow_avatar = FlatPack::Avatar::Component.new(
          initials: "+#{overflow_count}",
          size: @size,
          shape: :circle,
          href: @overflow_href,
          class: "ring-2 ring-[var(--avatar-group-ring-color)] transition-transform hover:scale-110"
        )

        tooltip_text = overflow_tooltip_text
        return overflow_avatar.render_in(view_context) if tooltip_text.blank?

        tooltip = FlatPack::Tooltip::Component.new(placement: :bottom)
        tooltip.content do
          content_tag(:ul, class: "list-none m-0 p-0 space-y-1") do
            safe_join(tooltip_text.map { |name| content_tag(:li, name) })
          end
        end

        tooltip.render_in(view_context) do
          overflow_avatar.render_in(view_context)
        end
      end

      def overflow_count
        @items.length - @max
      end

      def overflow_tooltip_text
        hidden_names = hidden_items.filter_map do |item|
          attrs = item.is_a?(Hash) ? item.symbolize_keys : {}
          attrs[:name].presence || attrs[:alt].presence
        end

        hidden_names.uniq
      end

      def hidden_items
        @items.drop(@max)
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
