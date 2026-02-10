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
        **system_arguments
      )
        @collapsible = collapsible
        @show_toggle = show_toggle
        @system_arguments = system_arguments
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

      def classes(*class_list)
        class_list.compact.join(" ")
      end
    end
  end
end
