# frozen_string_literal: true

module FlatPack
  module Navbar
    class NavItemComponent < ViewComponent::Base
      def initialize(
        text:,
        href: nil,
        icon: nil,
        active: false,
        badge: nil,
        badge_style: :primary,
        **system_arguments
      )
        @text = text
        @icon = icon
        @active = active
        @badge = badge
        @badge_style = badge_style
        @system_arguments = system_arguments

        # Sanitize URL for security and validate
        if href
          @href = FlatPack::AttributeSanitizer.sanitize_url(href)
          validate_href!(href)
        else
          @href = nil
        end
      end

      def call
        if @href
          link_to @href, **item_attributes do
            render_item_content
          end
        else
          content_tag(:div, **item_attributes) do
            render_item_content
          end
        end
      end

      private

      def item_attributes
        {
          class: item_classes,
          data: {flat_pack__navbar_target: "navItem"}
        }.merge(@system_arguments)
      end

      def item_classes
        classes(
          "flatpack-navbar-item",
          "flex",
          "items-center",
          "gap-3",
          "px-3",
          "py-2",
          "rounded-[var(--radius-md)]",
          "text-sm",
          "font-medium",
          "transition-colors",
          "duration-200",
          @active ? active_classes : inactive_classes
        )
      end

      def active_classes
        "bg-[var(--color-primary)] text-[var(--color-primary-text)]"
      end

      def inactive_classes
        "text-[var(--color-foreground)] hover:bg-[var(--color-muted)] hover:text-[var(--color-foreground)]"
      end

      def render_item_content
        safe_join([
          (render_icon if @icon),
          content_tag(:span, @text, class: "flex-1 truncate transition-all duration-300", data: {flat_pack__navbar_target: "itemText"}),
          (render_badge if @badge)
        ].compact)
      end

      def render_icon
        content_tag(:span, class: "flex-shrink-0") do
          render FlatPack::Shared::IconComponent.new(name: @icon, size: :sm)
        end
      end

      def render_badge
        content_tag(:span, class: "transition-all duration-300", data: {flat_pack__navbar_target: "badge"}) do
          render FlatPack::Badge::Component.new(text: @badge, style: @badge_style, size: :sm)
        end
      end

      def validate_href!(original_href)
        # Check if the original href was provided but sanitization failed
        return if @href.present?

        # Use a generic error message to avoid leaking sensitive information in logs
        raise ArgumentError, "Unsafe URL detected. Only http, https, mailto, tel protocols and relative URLs are allowed."
      end

      def classes(*class_list)
        class_list.compact.join(" ")
      end
    end
  end
end
