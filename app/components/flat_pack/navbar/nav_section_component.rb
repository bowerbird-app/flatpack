# frozen_string_literal: true

module FlatPack
  module Navbar
    class NavSectionComponent < FlatPack::BaseComponent
      renders_many :items_slot, NavItemComponent

      # Custom setter methods that provide cleaner syntax
      def item(**args, &block)
        with_items_slot(**args, &block)
      end

      def items
        items_slot
      end

      # Custom predicate method
      def items?
        items_slot?
      end

      def initialize(
        title: nil,
        collapsible: false,
        collapsed: false,
        **system_arguments
      )
        super(**system_arguments)
        @title = title
        @collapsible = collapsible
        @collapsed = collapsed
      end

      def call
        content_tag(:div, **section_attributes) do
          safe_join([
            (render_header if @title),
            render_items
          ].compact)
        end
      end

      private

      def render_header
        if @collapsible
          content_tag(:button,
            class: "w-full flex items-center justify-between px-3 py-2 rounded-lg hover:bg-[var(--color-muted)] transition-colors",
            data: {
              action: "click->left-nav#toggleSection"
            }) do
            safe_join([
              content_tag(:span, @title, class: "text-xs font-semibold uppercase tracking-wider text-[var(--color-muted-foreground)]", data: { navbar_target: "collapseText" }),
              render_chevron
            ])
          end
        else
          content_tag(:div, class: "px-3 py-2") do
            content_tag(:span, @title, class: "text-xs font-semibold uppercase tracking-wider text-[var(--color-muted-foreground)]", data: { navbar_target: "collapseText" })
          end
        end
      end

      def render_chevron
        content_tag(:svg,
          class: chevron_classes,
          fill: "none",
          stroke: "currentColor",
          viewBox: "0 0 24 24",
          data: { navbar_target: "collapseText" }) do
          tag.path("stroke-linecap": "round", "stroke-linejoin": "round", "stroke-width": "2", d: "M19 9l-7 7-7-7")
        end
      end

      def chevron_classes
        classes(
          "w-4 h-4 transition-transform duration-200",
          (@collapsed ? "" : "rotate-180")
        )
      end

      def render_items
        content_tag(:div, class: items_container_classes) do
          safe_join([
            *items,
            (content unless items?)
          ].compact)
        end
      end

      def section_attributes
        merge_attributes(
          class: "space-y-1"
        )
      end

      def items_container_classes
        classes(
          "space-y-1",
          (@collapsible && @collapsed ? "hidden" : nil)
        )
      end
    end
  end
end
