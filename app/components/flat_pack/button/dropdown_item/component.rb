# frozen_string_literal: true

module FlatPack
  module Button
    module DropdownItem
      class Component < FlatPack::BaseComponent
        def initialize(
          text:,
          icon: nil,
          badge: nil,
          badge_style: :primary,
          href: nil,
          disabled: false,
          destructive: false,
          **system_arguments
        )
          super(**system_arguments)
          @text = text
          @icon = icon
          @badge = badge
          @badge_style = badge_style
          @href = href
          @disabled = disabled
          @destructive = destructive

          # Sanitize URL if provided
          if @href
            @href = FlatPack::AttributeSanitizer.sanitize_url(@href)
            validate_url!
          end
        end

        def call
          if @href && !@disabled
            render_link
          else
            render_button
          end
        end

        private

        def render_link
          link_to @href, **item_attributes do
            item_content
          end
        end

        def render_button
          button_tag(**item_attributes) do
            item_content
          end
        end

        def item_content
          content = []
          content << render(FlatPack::Shared::IconComponent.new(name: @icon, size: :sm)) if @icon
          content << content_tag(:span, @text, class: "flex-1")
          if @badge
            content << content_tag(:span, @badge, class: badge_classes)
          end
          safe_join(content)
        end

        def item_attributes
          attrs = {
            class: item_classes,
            role: "menuitem",
            tabindex: @disabled ? "-1" : "0"
          }
          attrs[:disabled] = true if @disabled && !@href
          merge_attributes(**attrs)
        end

        def item_classes
          base_classes = [
            "flex items-center gap-2",
            "w-full",
            "px-2 py-1.5",
            "text-sm",
            "text-left",
            "rounded-[var(--radius-sm)]",
            "transition-colors duration-[var(--transition-base)]",
            "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-[var(--color-ring)]"
          ]

          if @disabled
            base_classes << "opacity-50 cursor-not-allowed"
          elsif @destructive
            base_classes << "text-[var(--color-destructive)]"
            base_classes << "hover:bg-[var(--color-destructive)]/10"
          else
            base_classes << "text-[var(--color-foreground)]"
            base_classes << "hover:bg-[var(--color-muted)]"
            base_classes << "cursor-pointer"
          end

          classes(*base_classes)
        end

        def badge_classes
          "inline-flex items-center justify-center min-w-[1.25rem] h-5 px-1.5 text-xs font-medium rounded-full bg-[var(--color-primary)] text-[var(--color-primary-text)]"
        end

        def validate_url!
          # Raise error if sanitization removed the URL (meaning it was unsafe)
          raise ArgumentError, "Unsafe URL detected. Only http, https, mailto, tel protocols and relative URLs are allowed." if @href.blank?
        end
      end
    end
  end
end
