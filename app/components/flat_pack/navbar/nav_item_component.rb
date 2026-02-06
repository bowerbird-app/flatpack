# frozen_string_literal: true

module FlatPack
  module Navbar
    class NavItemComponent < FlatPack::BaseComponent
      def initialize(
        text:,
        url: nil,
        icon: nil,
        active: false,
        **system_arguments
      )
        super(**system_arguments)
        @text = text
        @icon = icon
        @active = active

        # Sanitize URL for security
        if url
          @url = FlatPack::AttributeSanitizer.sanitize_url(url)
          validate_url!(url)
        else
          @url = nil
        end
      end

      def call
        if @url
          link_to @url, **link_attributes do
            item_content
          end
        else
          tag.div(**item_attributes) do
            item_content
          end
        end
      end

      private

      def link_attributes
        merge_attributes(
          class: item_classes
        )
      end

      def item_attributes
        merge_attributes(
          class: item_classes
        )
      end

      def item_classes
        classes(
          "flex items-center gap-3 px-3 py-2 rounded-md",
          "text-sm font-medium",
          "transition-colors duration-200",
          @active ? active_classes : inactive_classes,
          "group"
        )
      end

      def active_classes
        [
          "bg-[var(--color-primary)]",
          "text-[var(--color-primary-text)]"
        ]
      end

      def inactive_classes
        [
          "text-[var(--color-foreground)]",
          "hover:bg-[var(--color-muted)]",
          "hover:text-[var(--color-foreground)]"
        ]
      end

      def item_content
        safe_join([
          render_icon,
          tag.span(@text, class: "flex-1", data: { flat_pack__navbar_target: "itemText" })
        ].compact)
      end

      def render_icon
        return unless @icon

        if @icon.is_a?(String)
          # Assume it's an icon name and use the shared icon component
          render FlatPack::Shared::IconComponent.new(name: @icon, size: :sm)
        else
          # It's custom content
          @icon
        end
      end

      def validate_url!(original_url)
        return if @url.present?
        raise ArgumentError, "Unsafe URL detected. Only http, https, mailto, tel protocols and relative URLs are allowed."
      end
    end
  end
end
