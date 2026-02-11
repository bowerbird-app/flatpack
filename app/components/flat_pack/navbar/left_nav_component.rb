# frozen_string_literal: true

module FlatPack
  module Navbar
    class LeftNavComponent < ViewComponent::Base
      renders_many :items, NavItemComponent
      renders_many :sections, NavSectionComponent

      # Aliases for shorter syntax (optional - both work)
      def item(**kwargs, &block)
        with_item(**kwargs, &block)
      end

      def section(**kwargs, &block)
        with_section(**kwargs, &block)
      end

      def initialize(
        collapsible: true,
        show_toggle: true,
        contained: false,
        top_nav_height: nil,
        **system_arguments
      )
        @collapsible = collapsible
        @show_toggle = show_toggle
        @contained = contained
        @top_nav_height = top_nav_height
        @system_arguments = system_arguments
      end

      def call
        content_tag(:aside, **aside_attributes) do
          safe_join([
            content_tag(:nav, class: "flex-1 overflow-y-auto p-4 space-y-1") do
              safe_join([
                (items.filter_map { |item| item } if items?),
                (sections.filter_map { |section| section } if sections?)
              ].flatten.compact)
            end,
            (render_toggle_button if @show_toggle && @collapsible)
          ].compact)
        end
      end

      private

      def aside_attributes
        attrs = {
          class: aside_classes,
          data: {flat_pack__navbar_target: "leftNav"}
        }
        attrs[:style] = aside_styles if @top_nav_height
        attrs.merge(@system_arguments)
      end

      def aside_classes
        classes(
          "flatpack-navbar-left",
          @contained ? "absolute" : "fixed",
          @top_nav_height ? nil : "top-0",
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

      def aside_styles
        "top: #{@top_nav_height}"
      end

      def render_toggle_button
        content_tag(:button,
          class: "p-4 border-t border-[var(--color-border)] hover:bg-[var(--color-muted)] transition-colors flex items-center justify-center",
          data: {action: "click->flat-pack--navbar#toggleLeftNav"},
          aria: {label: "Toggle sidebar"}) do
          tag.svg(
            class: "w-5 h-5 transition-transform duration-300",
            data: {flat_pack__navbar_target: "collapseIcon"},
            xmlns: "http://www.w3.org/2000/svg",
            fill: "none",
            viewBox: "0 0 24 24",
            stroke: "currentColor",
            "stroke-width": "2"
          ) do
            tag.polyline(points: "15 18 9 12 15 6")
          end
        end
      end

      def classes(*class_list)
        class_list.compact.join(" ")
      end
    end
  end
end
