# frozen_string_literal: true

module FlatPack
  module Sidebar
    class Component < FlatPack::BaseComponent
      renders_one :header_slot
      renders_one :items_slot
      renders_one :footer_slot

      def initialize(
        collapsed: false,
        collapsible: true,
        side: :left,
        **system_arguments
      )
        super(**system_arguments)
        @collapsed = collapsed
        @collapsible = collapsible
        @side = side.to_sym

        validate_side!
      end

      def header(**args, &block)
        return header_slot unless block

        with_header_slot(**args, &block)
      end

      def items(**args, &block)
        return items_slot unless block

        with_items_slot(**args, &block)
      end

      def footer(**args, &block)
        return footer_slot unless block

        with_footer_slot(**args, &block)
      end

      def header?
        header_slot?
      end

      def items?
        items_slot?
      end

      def footer?
        footer_slot?
      end

      def collapsed?
        @collapsed
      end

      def collapsible?
        @collapsible
      end

      def call
        content_tag(:aside, **sidebar_attributes) do
          safe_join([
            (header if header?),
            render_items_container,
            (footer if footer?)
          ].compact)
        end
      end

      private

      def render_items_container
        return unless items?

        content_tag(:div, items.to_s, class: items_container_classes)
      end

      def sidebar_attributes
        merge_attributes(
          class: sidebar_classes
        )
      end

      def sidebar_classes
        classes(
          "flex",
          "flex-col",
          "h-full",
          "min-h-0",
          "overflow-hidden",
          "bg-background",
          side_border_class,
          "border-border",
          "transition-none",
          "md:transition-all",
          "duration-300",
          "w-64"
        )
      end

      def side_border_class
        (@side == :right) ? "border-l" : "border-r"
      end

      def validate_side!
        return if [:left, :right].include?(@side)
        raise ArgumentError, "Invalid side: #{@side}. Must be :left or :right"
      end

      def items_container_classes
        "flex-1 min-h-0 overflow-y-auto overscroll-y-contain"
      end
    end
  end
end
