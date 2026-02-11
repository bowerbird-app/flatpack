# frozen_string_literal: true

module FlatPack
  module Navbar
    class Component < FlatPack::BaseComponent
      renders_one :top_nav_slot, TopNavComponent
      renders_one :left_nav_slot, LeftNavComponent

      # Aliases for cleaner syntax (optional - both `with_*` and non-prefixed work)
      def top_nav(**kwargs, &block)
        with_top_nav_slot(**kwargs.merge(contained: @contained, height: @top_nav_height), &block)
      end

      def left_nav(**kwargs, &block)
        # Only pass top_nav_height if top_nav_slot is actually rendered
        height = top_nav_slot? ? @top_nav_height : nil
        with_left_nav_slot(**kwargs.merge(contained: @contained, top_nav_height: height), &block)
      end

      def initialize(
        left_nav_collapsed: false,
        left_nav_width: "256px",
        left_nav_collapsed_width: "64px",
        top_nav_height: "64px",
        dark_mode: :auto,
        contained: false,
        **system_arguments
      )
        super(**system_arguments)
        @left_nav_collapsed = left_nav_collapsed
        @left_nav_width = left_nav_width
        @left_nav_collapsed_width = left_nav_collapsed_width
        @top_nav_height = top_nav_height
        @dark_mode = dark_mode
        @contained = contained
        validate_dark_mode!
      end

      private

      def container_attributes
        merge_attributes(
          class: container_classes,
          data: navbar_data_attributes
        )
      end

      def container_classes
        classes(
          "flatpack-navbar",
          "relative",
          @contained ? "h-full" : "h-full min-h-screen",
          "bg-[var(--color-background)]",
          "text-[var(--color-foreground)]"
        )
      end

      def navbar_data_attributes
        {
          controller: "navbar",
          navbar_left_nav_width_value: @left_nav_width,
          navbar_left_nav_collapsed_width_value: @left_nav_collapsed_width,
          navbar_top_nav_height_value: @top_nav_height,
          navbar_collapsed_value: @left_nav_collapsed
        }
      end

      def main_attributes
        {
          class: main_classes,
          style: main_styles
        }
      end

      def main_classes
        classes(
          "flatpack-navbar-main",
          "transition-all",
          "duration-300",
          "ease-in-out"
        )
      end

      def main_styles
        styles = []
        styles << "margin-top: #{@top_nav_height}" if top_nav_slot?
        if left_nav_slot?
          styles << "margin-left: var(--navbar-left-nav-width, #{@left_nav_width})"
        end
        styles.join("; ")
      end

      def validate_dark_mode!
        valid_modes = [:auto, :light, :dark]
        return if valid_modes.include?(@dark_mode)

        raise ArgumentError, "Invalid dark_mode: #{@dark_mode}. Must be one of: #{valid_modes.join(", ")}"
      end
    end
  end
end
