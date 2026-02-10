# frozen_string_literal: true

module FlatPack
  module Navbar
    class NavSectionComponent < ViewComponent::Base
      renders_many :items_slot, NavItemComponent

      # Custom setter methods that provide the cleaner syntax
      def item(**args, &block)
        with_items_slot(**args, &block)
      end

      # Custom predicate methods
      def items?
        items_slot?
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
            render_items_list
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
            class: "w-full flex items-center justify-between px-3 py-2 text-sm font-semibold text-[var(--color-muted-foreground)] hover:text-[var(--color-foreground)] transition-colors",
            data: {
              controller: "navbar-section",
              action: "click->navbar-section#toggle",
              navbar_section_collapsed_value: @collapsed
            }) do
            safe_join([
              content_tag(:span, @title),
              render_chevron_icon
            ])
          end
        else
          content_tag(:div, @title, class: "px-3 py-2 text-sm font-semibold text-[var(--color-muted-foreground)]")
        end
      end

      def render_chevron_icon
        content_tag(:svg,
          class: "w-4 h-4 transition-transform duration-200",
          data: {navbar_section_target: "chevron"},
          xmlns: "http://www.w3.org/2000/svg",
          fill: "none",
          viewBox: "0 0 24 24",
          stroke: "currentColor",
          "stroke-width": "2") do
          content_tag(:polyline, nil, points: "6 9 12 15 18 9")
        end
      end

      def render_items_list
        content_tag(:div,
          class: "space-y-1",
          data: @collapsible ? {navbar_section_target: "content"} : {}) do
          safe_join(items_slot.map { |item| item })
        end
      end

      def classes(*class_list)
        class_list.compact.join(" ")
      end
    end
  end
end
