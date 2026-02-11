# frozen_string_literal: true

module FlatPack
  module Navbar
    class TopNavComponent < ViewComponent::Base
      renders_many :actions
      renders_one :theme_toggle, ThemeToggleComponent

      # Alias for shorter syntax (optional - both work)
      def action(**kwargs, &block)
        with_action(**kwargs, &block)
      end

      def initialize(
        transparent: true,
        blur: true,
        border_bottom: true,
        logo_url: nil,
        logo_text: nil,
        logo_href: "/",
        show_menu_toggle: true,
        show_theme_toggle: true,
        contained: false,
        height: "64px",
        **system_arguments
      )
        @transparent = transparent
        @blur = blur
        @border_bottom = border_bottom
        @logo_url = logo_url
        @logo_text = logo_text
        @show_menu_toggle = show_menu_toggle
        @show_theme_toggle = show_theme_toggle
        @contained = contained
        @height = height
        @system_arguments = system_arguments

        # Sanitize URL for security and validate
        if logo_href
          @logo_href = FlatPack::AttributeSanitizer.sanitize_url(logo_href)
          validate_logo_href!(logo_href)
        else
          @logo_href = "/"
        end
      end

      def call
        content_tag(:nav, **nav_attributes) do
          safe_join([
            render_left_section,
            render_right_section
          ])
        end
      end

      private

      def nav_attributes
        {
          class: nav_classes,
          style: "height: #{@height}",
          data: {navbar_target: "topNav"}
        }.merge(@system_arguments)
      end

      def nav_classes
        classes = [
          "flatpack-navbar-top",
          @contained ? "absolute" : "fixed",
          "top-0",
          "left-0",
          "right-0",
          "z-40",
          "flex",
          "items-center",
          "justify-between",
          "px-4",
          "transition-all",
          "duration-300"
        ]

        classes << "bg-[var(--color-background)]/80" if @transparent
        classes << "bg-[var(--color-background)]" unless @transparent
        classes << "backdrop-blur-sm" if @blur
        classes << "border-b border-[var(--color-border)]" if @border_bottom

        classes.join(" ")
      end

      def validate_logo_href!(original_href)
        # Check if the original href was provided but sanitization failed
        return if @logo_href.present?

        # Use a generic error message to avoid leaking sensitive information in logs
        raise ArgumentError, "Unsafe URL detected. Only http, https, mailto, tel protocols and relative URLs are allowed."
      end

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
          class: "p-2 rounded-md hover:bg-[var(--color-muted)] transition-colors lg:hidden",
          data: {action: "click->navbar#toggleLeftNav"},
          aria: {label: "Toggle navigation menu"}) do
          tag.svg(
            class: "w-6 h-6",
            xmlns: "http://www.w3.org/2000/svg",
            fill: "none",
            viewBox: "0 0 24 24",
            stroke: "currentColor",
            "stroke-width": "2"
          ) do
            safe_join([
              tag.line(x1: "3", y1: "6", x2: "21", y2: "6"),
              tag.line(x1: "3", y1: "12", x2: "21", y2: "12"),
              tag.line(x1: "3", y1: "18", x2: "21", y2: "18")
            ])
          end
        end
      end

      def render_logo
        link_to @logo_href, class: "flex items-center gap-2 text-lg font-semibold" do
          safe_join([
            (@logo_url ? image_tag(@logo_url, alt: "Logo", class: "h-8 w-8") : nil),
            (@logo_text ? content_tag(:span, @logo_text) : nil)
          ].compact)
        end
      end

      def render_right_section
        content_tag(:div, class: "flex items-center gap-2") do
          safe_join([
            (actions.map { |action| action } if actions?),
            render_theme_toggle
          ].flatten.compact)
        end
      end

      def render_theme_toggle
        if @show_theme_toggle && !theme_toggle?
          render FlatPack::Navbar::ThemeToggleComponent.new
        elsif theme_toggle?
          theme_toggle
        end
      end

      def classes(*class_list)
        class_list.compact.join(" ")
      end
    end
  end
end
