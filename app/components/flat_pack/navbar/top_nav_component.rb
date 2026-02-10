# frozen_string_literal: true

module FlatPack
  module Navbar
    class TopNavComponent < ViewComponent::Base
      renders_many :actions
      renders_one :theme_toggle_slot, ThemeToggleComponent

      # Alias for shorter syntax (optional - both work)
      def action(**kwargs, &block)
        with_action(**kwargs, &block)
      end

      # For renders_one, we don't need an alias since `with_theme_toggle` works

      def initialize(
        transparent: true,
        blur: true,
        border_bottom: true,
        logo_url: nil,
        logo_text: nil,
        logo_href: "/",
        show_menu_toggle: true,
        show_theme_toggle: true,
        **system_arguments
      )
        @transparent = transparent
        @blur = blur
        @border_bottom = border_bottom
        @logo_url = logo_url
        @logo_text = logo_text
        @show_menu_toggle = show_menu_toggle
        @show_theme_toggle = show_theme_toggle
        @system_arguments = system_arguments

        # Sanitize URL for security and validate
        if logo_href
          @logo_href = FlatPack::AttributeSanitizer.sanitize_url(logo_href)
          validate_logo_href!(logo_href)
        else
          @logo_href = "/"
        end
      end

      private

      def nav_attributes
        {
          class: nav_classes,
          data: {navbar_target: "topNav"}
        }.merge(@system_arguments)
      end

      def nav_classes
        classes = [
          "flatpack-navbar-top",
          "fixed",
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

      def classes(*class_list)
        class_list.compact.join(" ")
      end
    end
  end
end
