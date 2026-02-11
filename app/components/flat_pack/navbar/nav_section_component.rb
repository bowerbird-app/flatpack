# frozen_string_literal: true

module FlatPack
  module Navbar
    class NavSectionComponent < ViewComponent::Base
      renders_many :items, NavItemComponent

      # Alias for shorter syntax (optional - both work)
      def item(**kwargs, &block)
        with_item(**kwargs, &block)
      end

      def initialize(
        title: nil,
        collapsible: false,
        collapsed: false,
        **system_arguments
      )
        @title = title
        @collapsible = collapsible
        @collapsed = collapsed
        @system_arguments = system_arguments
      end

      def call
        content_tag(:div, **section_attributes) do
          safe_join([
            (render_title if @title),
            render_items
          ].compact)
        end
      end

      private

      def section_attributes
        {
          class: section_classes
        }.merge(@system_arguments)
      end

      def section_classes
        classes(
          "flatpack-navbar-section",
          "space-y-1"
        )
      end

      def render_title
        if @collapsible
          content_tag(:button,
            class: "w-full flex items-center justify-between px-3 py-2 text-sm font-semibold text-[var(--color-muted-foreground)] hover:text-[var(--color-foreground)] transition-all duration-300",
            data: {
              controller: "flat-pack--navbar-section",
              action: "click->flat-pack--navbar-section#toggle",
              flat_pack__navbar_section_collapsed_value: @collapsed,
              flat_pack__navbar_target: "sectionTitle"
            }) do
            safe_join([
              content_tag(:span, @title),
              tag.svg(
                class: "w-4 h-4 transition-transform duration-200",
                data: {flat_pack__navbar_section_target: "chevron"},
                xmlns: "http://www.w3.org/2000/svg",
                fill: "none",
                viewBox: "0 0 24 24",
                stroke: "currentColor",
                "stroke-width": "2"
              ) do
                tag.polyline(points: "6 9 12 15 18 9")
              end
            ])
          end
        else
          content_tag(:div, @title,
            class: "px-3 py-2 text-sm font-semibold text-[var(--color-muted-foreground)] transition-all duration-300",
            data: {flat_pack__navbar_target: "sectionTitle"})
        end
      end

      def render_items
        attrs = {class: "space-y-1"}
        attrs[:data] = {navbar_section_target: "content"} if @collapsible
        content_tag(:div, **attrs) do
          safe_join(items.map { |item| item })
        end
      end

      def classes(*class_list)
        class_list.compact.join(" ")
      end
    end
  end
end
