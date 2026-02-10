# frozen_string_literal: true

module FlatPack
  module Navbar
    class LeftNavComponent < FlatPack::BaseComponent
      renders_many :items, NavItemComponent
      renders_many :sections, NavSectionComponent
      renders_one :footer

      def initialize(
        collapsible: true,
        show_toggle: true,
        **system_arguments
      )
        super(**system_arguments)
        @collapsible = collapsible
        @show_toggle = show_toggle
      end

      def call
        content_tag(:aside, **aside_attributes) do
          safe_join([
            render_header,
            render_nav_content,
            (footer if footer?)
          ].compact)
        end
      end

      private

      def render_header
        return unless @collapsible && @show_toggle

        content_tag(:div, class: "p-4 border-b border-[var(--color-border)]") do
          content_tag(:button,
            class: "w-full flex items-center justify-between p-2 rounded-lg hover:bg-[var(--color-muted)] transition-colors",
            data: {
              action: "click->navbar#toggleDesktop",
              navbar_target: "toggle"
            },
            aria: { label: "Toggle sidebar" }) do
            safe_join([
              content_tag(:span, "Menu", class: "font-medium", data: { navbar_target: "collapseText" }),
              render_chevron_icon
            ])
          end
        end
      end

      def render_chevron_icon
        content_tag(:svg, class: "w-5 h-5 transition-transform duration-200", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24", data: { navbar_target: "chevron" }) do
          tag.path("stroke-linecap": "round", "stroke-linejoin": "round", "stroke-width": "2", d: "M15 19l-7-7 7-7")
        end
      end

      def render_nav_content
        content_tag(:div, class: "flex-1 overflow-y-auto overflow-x-hidden p-4") do
          content_tag(:nav, class: "space-y-2", data: { controller: "left-nav" }) do
            safe_join([
              *sections,
              *items,
              (content unless items? || sections?)
            ].compact)
          end
        end
      end

      def aside_attributes
        merge_attributes(
          class: aside_classes,
          data: {
            navbar_target: "leftNav"
          }
        )
      end

      def aside_classes
        classes(
          # Mobile: hidden by default, slides from right as overlay
          "hidden md:flex",
          "fixed md:relative",
          "right-0 md:left-0",
          "top-0 bottom-0",
          "translate-x-full md:translate-x-0",
          "transition-transform duration-300",
          "z-40",
          # Layout
          "flex-col",
          "bg-[var(--color-background)]",
          "border-r border-[var(--color-border)]",
          # Width (controlled by JS on desktop)
          "w-64",
          # Shadows for mobile overlay
          "shadow-xl md:shadow-none"
        )
      end
    end
  end
end
