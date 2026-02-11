# frozen_string_literal: true

module FlatPack
  module Navbar
    class Component < FlatPack::BaseComponent
      renders_one :sidebar_slot, lambda { |*args|
        kwargs = {}
        args.each_slice(2) { |k, v| kwargs[k] = v }
        SidebarComponent.new(**kwargs)
      }

      renders_one :top_nav_slot, lambda { |*args|
        kwargs = {}
        args.each_slice(2) { |k, v| kwargs[k] = v }
        TopNavComponent.new(**kwargs)
      }

      def initialize(**system_arguments)
        super
      end

      # Define cleaner API methods
      def sidebar(...)
        with_sidebar_slot(...)
      end

      def top_nav(...)
        with_top_nav_slot(...)
      end

      def call
        content_tag(:div, **wrapper_attributes) do
          safe_join([
            sidebar_slot,
            content_tag(:div, class: "flex flex-col flex-1") do
              safe_join([top_nav_slot, content_tag(:main, content, class: main_classes)].compact)
            end
          ].compact)
        end
      end

      private

      def wrapper_attributes
        merge_attributes(
          class: wrapper_classes,
          data: {
            controller: "flat-pack--navbar",
            flat_pack__navbar_expanded_width_value: "256px",
            flat_pack__navbar_collapsed_width_value: "64px",
            flat_pack__navbar_collapsed_value: false
          }
        )
      end

      def wrapper_classes
        classes(
          "flex",
          "h-full",
          "bg-[var(--color-background)]"
        )
      end

      def main_classes
        "flex-1 overflow-auto"
      end
    end
  end
end
