# frozen_string_literal: true

module FlatPack
  module AvatarGroup
    class Component < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "-space-x-1" "-space-x-2" "-space-x-3"
      OVERLAPS = {
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
          class: group_classes
        )
      end

      def group_classes
        classes(
          "flex items-center",
          OVERLAPS.fetch(@overlap)
        )
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
        
        content_tag(:div,
          class: "relative hover:z-10 focus-within:z-10 transition-transform hover:scale-110",
          style: avatar_attrs[:href] ? nil : "z-index: #{@items.length - index}") do
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
        overflow_text = "+#{overflow_count}"
        
        wrapper_content = content_tag(:span,
          **overflow_wrapper_attributes) do
          content_tag(:span, overflow_text, class: "font-semibold")
        end

        if @overflow_href
          content_tag(:div,
            class: "relative hover:z-10 transition-transform hover:scale-110") do
            content_tag(:a, href: @overflow_href) do
              wrapper_content
            end
          end
        else
          content_tag(:div, class: "relative") do
            wrapper_content
          end
        end
      end

      def overflow_wrapper_attributes
        size_classes = FlatPack::Avatar::Component::SIZES.fetch(@size)
        
        {
          class: classes(
            "inline-flex items-center justify-center shrink-0",
            "bg-[var(--color-muted)] text-[var(--color-foreground)]",
            "rounded-full ring-2 ring-white dark:ring-zinc-900",
            "select-none",
            size_classes,
            @overflow_href ? "hover:opacity-80 transition-opacity duration-[var(--transition-base)]" : nil
          )
        }
      end

      def overflow_count
        @items.length - @max
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
