# frozen_string_literal: true

module FlatPack
  module Navbar
    class TopNavComponent < FlatPack::BaseComponent
      renders_many :actions
      renders_one :theme_toggle, ThemeToggleComponent
      renders_one :center_content

      def initialize(
        transparent: true,
        blur: true,
        border_bottom: true,
        logo_url: nil,
        logo_text: nil,
        show_menu_toggle: true,
        show_theme_toggle: true,
        height: "64px",
        **system_arguments
      )
        super(**system_arguments)
        @transparent = transparent
        @blur = blur
        @border_bottom = border_bottom
        @logo_text = logo_text
        @show_menu_toggle = show_menu_toggle
        @show_theme_toggle = show_theme_toggle
        @height = height

        # Sanitize URL for security
        if logo_url
          @logo_url = FlatPack::AttributeSanitizer.sanitize_url(logo_url)
          validate_logo_url!(logo_url)
        else
          @logo_url = nil
        end
      end

      def call
        content_tag(:nav, **nav_attributes) do
          content_tag(:div, class: container_classes) do
            safe_join([
              render_left_section,
              (center_content if center_content?),
              render_right_section
            ].compact)
          end
        end
      end

      private

      def render_left_section
        content_tag(:div, class: "flex items-center gap-4") do
          safe_join([
            (render_menu_toggle if @show_menu_toggle),
            render_logo
          ].compact)
        end
      end

      def render_menu_toggle
        content_tag(:button,
          class: "md:hidden p-2 rounded-lg hover:bg-[var(--color-muted)] transition-colors",
          data: { action: "click->navbar#toggleMobile" },
          aria: { label: "Toggle menu" }) do
          # Hamburger icon
          content_tag(:svg, class: "w-6 h-6", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do
            safe_join([
              tag.path("stroke-linecap": "round", "stroke-linejoin": "round", "stroke-width": "2", d: "M4 6h16"),
              tag.path("stroke-linecap": "round", "stroke-linejoin": "round", "stroke-width": "2", d: "M4 12h16"),
              tag.path("stroke-linecap": "round", "stroke-linejoin": "round", "stroke-width": "2", d: "M4 18h16")
            ])
          end
        end
      end

      def render_logo
        logo_classes = "flex items-center gap-2 text-lg font-semibold text-[var(--color-foreground)]"
        
        if @logo_url
          link_to @logo_url, class: logo_classes do
            @logo_text || "Logo"
          end
        elsif @logo_text
          content_tag(:div, class: logo_classes) do
            @logo_text
          end
        end
      end

      def render_right_section
        content_tag(:div, class: "flex items-center gap-2") do
          safe_join([
            *actions,
            (theme_toggle if @show_theme_toggle && !theme_toggle?)
          ].compact)
        end
      end

      def nav_attributes
        merge_attributes(
          class: nav_classes,
          style: "height: #{@height}"
        )
      end

      def nav_classes
        classes(
          "fixed top-0 left-0 right-0 z-50",
          "transition-all duration-200",
          background_classes,
          border_classes
        )
      end

      def background_classes
        if @transparent
          classes(
            "bg-[var(--color-background)]/80",
            (@blur ? "backdrop-blur-md" : nil)
          )
        else
          "bg-[var(--color-background)]"
        end
      end

      def border_classes
        @border_bottom ? "border-b border-[var(--color-border)]" : nil
      end

      def container_classes
        "h-full px-4 md:px-6 flex items-center justify-between"
      end

      def validate_logo_url!(original_url)
        return if @logo_url.present?

        raise ArgumentError, "Unsafe URL detected. Only http, https, mailto, tel protocols and relative URLs are allowed."
      end
    end
  end
end
