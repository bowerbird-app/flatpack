# frozen_string_literal: true

module FlatPack
  module SidebarLayout
    class Component < FlatPack::BaseComponent
      renders_one :sidebar_slot
      renders_one :top_nav_slot
      renders_one :main_slot

      def initialize(
        side: :left,
        default_open: true,
        storage_key: nil,
        **system_arguments
      )
        super(**system_arguments)
        @side = side.to_sym
        @default_open = default_open
        @storage_key = storage_key

        validate_side!
      end

      def sidebar(**args, &block)
        return sidebar_slot unless block

        with_sidebar_slot(**args, &block)
      end

      def top_nav(**args, &block)
        return top_nav_slot unless block

        with_top_nav_slot(**args, &block)
      end

      def main(**args, &block)
        return main_slot unless block

        with_main_slot(**args, &block)
      end

      def sidebar?
        sidebar_slot?
      end

      def top_nav?
        top_nav_slot?
      end

      def main?
        main_slot?
      end

      def call
        content_tag(:div, **container_attributes) do
          safe_join([
            render_sidebar_and_main,
            render_backdrop
          ].compact)
        end
      end

      private

      def render_sidebar_and_main
        if @side == :right
          safe_join([
            render_main_column,
            render_sidebar_column
          ].compact)
        else
          safe_join([
            render_sidebar_column,
            render_main_column
          ].compact)
        end
      end

      def render_sidebar_column
        return unless sidebar?

        content_tag(:div, sidebar.to_s, class: sidebar_column_classes, data: sidebar_column_data)
      end

      def render_main_column
        content_tag(:div, class: main_column_classes) do
          safe_join([
            (top_nav if top_nav?),
            (main? ? main : content)
          ].compact)
        end
      end

      def render_backdrop
        content_tag(:div, "", **backdrop_attributes)
      end

      def container_attributes
        merge_attributes(
          class: container_classes,
          data: controller_data
        )
      end

      def controller_data
        {
          controller: "flat-pack--sidebar-layout",
          "flat-pack--sidebar-layout-side-value": @side.to_s,
          "flat-pack--sidebar-layout-default-open-value": @default_open,
          "flat-pack--sidebar-layout-storage-key-value": @storage_key
        }.compact
      end

      def container_classes
        classes(
          "grid",
          "h-screen",
          "overflow-hidden",
          grid_columns_classes
        )
      end

      def grid_columns_classes
        if @side == :right
          "grid-cols-[1fr_auto]"
        else
          "grid-cols-[auto_1fr]"
        end
      end

      def sidebar_column_classes
        classes(
          "h-full",
          "transition-transform",
          "md:transition-all",
          "duration-300",
          "ease-in-out",
          "transform-gpu",
          "will-change-transform",
          # Desktop styles
          "block",
          # Mobile drawer styles
          "md:relative",
          "fixed",
          "inset-y-0",
          "w-64",
          "md:w-auto",
          "z-50",
          "md:z-auto",
          ((@side == :left) ? "left-0" : "right-0"),
          ((@side == :left) ? "-translate-x-full" : "translate-x-full"),
          "md:translate-x-0"
        )
      end

      def main_column_classes
        classes(
          "flex",
          "flex-col",
          "h-full",
          "min-h-0",
          "min-w-0",
          "overflow-hidden"
        )
      end

      def sidebar_column_data
        {
          "flat-pack--sidebar-layout-target": "sidebar"
        }
      end

      def backdrop_attributes
        {
          class: backdrop_classes,
          data: {
            "flat-pack--sidebar-layout-target": "backdrop",
            action: "click->flat-pack--sidebar-layout#closeMobile"
          },
          aria: {
            hidden: true
          }
        }
      end

      def backdrop_classes
        "fixed inset-0 bg-black/50 z-40 md:hidden opacity-0 pointer-events-none transition-opacity duration-300"
      end

      def validate_side!
        return if [:left, :right].include?(@side)
        raise ArgumentError, "Invalid side: #{@side}. Must be :left or :right"
      end
    end
  end
end
