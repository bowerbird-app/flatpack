# frozen_string_literal: true

module FlatPack
  module Navbar
    class Component < FlatPack::BaseComponent
      renders_one :top_nav, TopNavComponent
      renders_one :left_nav, LeftNavComponent

      def initialize(
        left_nav_collapsed: false,
        left_nav_width: "256px",
        left_nav_collapsed_width: "64px",
        top_nav_height: "64px",
        dark_mode: :auto,
        **system_arguments
      )
        super(**system_arguments)
        @left_nav_collapsed = left_nav_collapsed
        @left_nav_width = left_nav_width
        @left_nav_collapsed_width = left_nav_collapsed_width
        @top_nav_height = top_nav_height
        @dark_mode = dark_mode.to_sym

        validate_dark_mode!
      end

      def call
        content_tag(:div, **wrapper_attributes) do
          safe_join([
            (top_nav if top_nav?),
            render_layout
          ].compact)
        end
      end

      private

      def render_layout
        content_tag(:div, class: "flex h-screen pt-[#{@top_nav_height}]") do
          safe_join([
            (left_nav if left_nav?),
            render_main_content
          ].compact)
        end
      end

      def render_main_content
        content_tag(:main, class: main_content_classes) do
          content
        end
      end

      def wrapper_attributes
        merge_attributes(
          class: wrapper_classes,
          data: {
            controller: "navbar theme",
            navbar_collapsed_value: @left_nav_collapsed,
            navbar_width_value: @left_nav_width,
            navbar_collapsed_width_value: @left_nav_collapsed_width,
            theme_mode_value: @dark_mode
          }
        )
      end

      def wrapper_classes
        classes(
          "relative",
          dark_mode_class
        )
      end

      def dark_mode_class
        case @dark_mode
        when :light then "light"
        when :dark then "dark"
        else nil # auto mode, no class
        end
      end

      def main_content_classes
        "flex-1 overflow-auto bg-[var(--color-background)] text-[var(--color-foreground)] transition-all duration-300"
      end

      def validate_dark_mode!
        valid_modes = [:auto, :light, :dark]
        return if valid_modes.include?(@dark_mode)

        raise ArgumentError, "Invalid dark_mode: #{@dark_mode}. Must be one of: #{valid_modes.join(", ")}"
      end
    end
  end
end
