# frozen_string_literal: true

module FlatPack
  module Navbar
    class LeftNavComponent < ViewComponent::Base
      renders_many :items_slot, NavItemComponent
      renders_many :sections_slot, NavSectionComponent

      # Custom setter methods that provide the cleaner syntax
      def item(**args, &block)
        with_items_slot(**args, &block)
      end

      def section(**args, &block)
        with_sections_slot(**args, &block)
      end

      # Custom predicate methods
      def items?
        items_slot?
      end

      def sections?
        sections_slot?
      end

      def initialize(
        collapsible: true,
        show_toggle: true,
        **system_arguments
      )
        @collapsible = collapsible
        @show_toggle = show_toggle
        @system_arguments = system_arguments
      end

      def call
        content_tag(:aside, **aside_attributes) do
          safe_join([
            render_nav_content,
            (render_collapse_toggle if @show_toggle && @collapsible)
          ].compact)
        end
      end

      private

      def aside_attributes
        {
          class: aside_classes,
          data: {navbar_target: "leftNav"}
        }.merge(@system_arguments)
      end

      def aside_classes
        classes(
          "flatpack-navbar-left",
          "fixed",
          "top-0",
          "left-0",
          "bottom-0",
          "z-30",
          "flex",
          "flex-col",
          "bg-[var(--color-background)]",
          "border-r",
          "border-[var(--color-border)]",
          "transition-all",
          "duration-300",
          "ease-in-out",
          "overflow-hidden"
        )
      end

      def render_nav_content
        content_tag(:nav, class: "flex-1 overflow-y-auto p-4 space-y-1") do
          safe_join([
            render_items,
            render_sections
          ].compact)
        end
      end

      def render_items
        return nil unless items?

        safe_join(items_slot.map { |item| item })
      end

      def render_sections
        return nil unless sections?

        safe_join(sections_slot.map { |section| section })
      end

      def render_collapse_toggle
        content_tag(:button,
          class: "p-4 border-t border-[var(--color-border)] hover:bg-[var(--color-muted)] transition-colors flex items-center justify-center",
          data: {action: "click->navbar#toggleLeftNav"},
          aria: {label: "Toggle sidebar"}) do
          # Chevron icon
          content_tag(:svg,
            class: "w-5 h-5 transition-transform duration-300",
            data: {navbar_target: "collapseIcon"},
            xmlns: "http://www.w3.org/2000/svg",
            fill: "none",
            viewBox: "0 0 24 24",
            stroke: "currentColor",
            "stroke-width": "2") do
            content_tag(:polyline, nil, points: "15 18 9 12 15 6")
          end
        end
      end

      def classes(*class_list)
        class_list.compact.join(" ")
      end
    end
  end
end
