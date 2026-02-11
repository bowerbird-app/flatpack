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

      private

      def aside_attributes
        attrs = {
          class: aside_classes,
          data: {navbar_target: "leftNav"}
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

      def classes(*class_list)
        class_list.compact.join(" ")
      end
    end
  end
end
