# frozen_string_literal: true

module FlatPack
  module Navbar
    class NavItemComponent < FlatPack::BaseComponent
      # Tailwind CSS scanning requires these classes to be present as string literals.
      # DO NOT REMOVE - These duplicates ensure CSS generation:
      # "bg-[var(--color-primary)]" "text-[var(--color-primary-text)]" "bg-[var(--color-success)]" "text-[var(--color-success-text)]" "bg-[var(--color-warning)]" "text-[var(--color-warning-text)]" "bg-[var(--color-danger)]" "text-[var(--color-danger-text)]"
      BADGE_STYLES = {
        primary: "bg-[var(--color-primary)] text-[var(--color-primary-text)]",
        success: "bg-[var(--color-success)] text-[var(--color-success-text)]",
        warning: "bg-[var(--color-warning)] text-[var(--color-warning-text)]",
        danger: "bg-[var(--color-danger)] text-[var(--color-danger-text)]"
      }.freeze

      def initialize(
        text:,
        href: nil,
        icon: nil,
        active: false,
        badge: nil,
        badge_style: :primary,
        **system_arguments
      )
        super(**system_arguments)
        @text = text
        @icon = icon
        @active = active
        @badge = badge
        @badge_style = badge_style.to_sym

        # Sanitize URL for security
        if href
          @href = FlatPack::AttributeSanitizer.sanitize_url(href)
          validate_href!(href)
        else
          @href = nil
        end

        validate_badge_style! if @badge
      end

      def call
        if @href
          link_to @href, **item_attributes do
            render_content
          end
        else
          content_tag(:button, **item_attributes) do
            render_content
          end
        end
      end

      private

      def render_content
        safe_join([
          render_icon,
          render_text,
          render_badge
        ].compact)
      end

      def render_icon
        return unless @icon

        content_tag(:span, class: "flex-shrink-0") do
          render FlatPack::Shared::IconComponent.new(name: @icon, size: :md)
        end
      end

      def render_text
        content_tag(:span, @text, class: "flex-1 truncate", data: { navbar_target: "collapseText" })
      end

      def render_badge
        return unless @badge

        content_tag(:span, @badge, class: badge_classes, data: { navbar_target: "collapseText" })
      end

      def item_attributes
        attrs = {
          class: item_classes
        }
        attrs[:aria] = { current: "page" } if @active
        merge_attributes(**attrs)
      end

      def item_classes
        classes(
          "flex items-center gap-3 px-3 py-2 rounded-lg",
          "text-sm font-medium",
          "transition-colors duration-200",
          active_state_classes,
          hover_classes
        )
      end

      def active_state_classes
        if @active
          "bg-[var(--color-primary)] text-[var(--color-primary-text)]"
        else
          "text-[var(--color-foreground)]"
        end
      end

      def hover_classes
        @active ? nil : "hover:bg-[var(--color-muted)]"
      end

      def badge_classes
        classes(
          "px-2 py-0.5 text-xs rounded-full font-semibold",
          BADGE_STYLES.fetch(@badge_style)
        )
      end

      def validate_href!(original_href)
        return if @href.present?

        raise ArgumentError, "Unsafe URL detected. Only http, https, mailto, tel protocols and relative URLs are allowed."
      end

      def validate_badge_style!
        return if BADGE_STYLES.key?(@badge_style)

        raise ArgumentError, "Invalid badge_style: #{@badge_style}. Must be one of: #{BADGE_STYLES.keys.join(", ")}"
      end
    end
  end
end
