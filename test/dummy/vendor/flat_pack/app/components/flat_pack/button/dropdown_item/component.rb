# frozen_string_literal: true

module FlatPack
  module Button
    module DropdownItem
      class Component < FlatPack::BaseComponent
        ICON_VARIANTS = IconOptions::VARIANTS
        ICON_STYLES = IconOptions::STYLES

        ICON_POSITIONS = %i[start end].freeze

        BADGE_STYLES = {
          default: "border border-[var(--badge-default-border-color)] bg-[var(--badge-default-background-color)] text-[var(--badge-default-text-color)]",
          primary: "border border-[var(--badge-primary-border-color)] bg-[var(--badge-primary-background-color)] text-[var(--badge-primary-text-color)]",
          secondary: "border border-[var(--badge-secondary-border-color)] bg-[var(--badge-secondary-background-color)] text-[var(--badge-secondary-text-color)]",
          success: "border border-[var(--badge-success-border-color)] bg-[var(--badge-success-background-color)] text-[var(--badge-success-text-color)]",
          warning: "border border-[var(--badge-warning-border-color)] bg-[var(--badge-warning-background-color)] text-[var(--badge-warning-text-color)]",
          danger: "border border-[var(--badge-danger-border-color)] bg-[var(--badge-danger-background-color)] text-[var(--badge-danger-text-color)]",
          info: "border border-[var(--badge-info-border-color)] bg-[var(--badge-info-background-color)] text-[var(--badge-info-text-color)]"
        }.freeze

        def initialize(
          text:,
          icon: nil,
          icon_variant: nil,
          icon_style: nil,
          badge: nil,
          badge_style: :primary,
          href: nil,
          disabled: false,
          destructive: false,
          icon_position: :start,
          keep_open: false,
          **system_arguments
        )
          super(**system_arguments)
          @text = text
          @icon = icon
          @icon_variant = IconOptions.normalize_variant!(icon_variant)
          @icon_style = IconOptions.normalize_style!(icon_style)
          @badge = badge
          @badge_style = badge_style.to_sym
          @href = href
          @disabled = disabled
          @destructive = destructive
          @icon_position = icon_position.to_sym
          @keep_open = keep_open

          # Sanitize URL if provided
          if @href
            @href = FlatPack::AttributeSanitizer.sanitize_url(@href)
            validate_url!
          end

          validate_badge_style! if @badge
          validate_icon_position!
          validate_keep_open!
        end

        def menu_row
          {
            divider: false,
            label: @text,
            href: @href,
            icon: @icon,
            icon_position: @icon_position,
            destructive: @destructive,
            disabled: @disabled
          }
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
          if @icon
            content << render(FlatPack::Shared::IconComponent.new(**item_icon_arguments))
          end
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
          attrs[:data] = {flat_pack_dropdown_keep_open: true} if @keep_open
          merge_attributes(**attrs)
        end

        def item_icon_arguments
          arguments = IconOptions.component_arguments(
            name: @icon,
            size: :sm,
            icon_variant: @icon_variant,
            icon_style: @icon_style
          )
          return arguments unless @icon_position == :end

          arguments.merge(class: [arguments[:class], "order-last"].compact.join(" "))
        end

        def item_classes
          base_classes = [
            "flex items-center gap-[var(--dropdown-item-gap)]",
            "w-full",
            "px-[var(--dropdown-item-padding-x)] py-[var(--dropdown-item-padding-y)]",
            "text-sm",
            "text-left",
            "rounded-[var(--dropdown-item-radius)]",
            "transition-colors duration-base",
            "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-ring"
          ]

          if @disabled
            base_classes << "opacity-50 cursor-not-allowed"
          elsif @destructive
            base_classes << "text-danger-text-color"
            base_classes << "hover:bg-danger-background-color/10"
          else
            base_classes << "text-[var(--surface-content-color)]"
            base_classes << "hover:bg-[var(--surface-muted-background-color)]"
            base_classes << "cursor-pointer"
          end

          classes(*base_classes)
        end

        def badge_classes
          classes(
            "inline-flex items-center justify-center min-w-[1.25rem] h-5 px-1.5 text-xs font-medium rounded-[var(--badge-radius)]",
            BADGE_STYLES.fetch(@badge_style)
          )
        end

        def validate_badge_style!
          return if BADGE_STYLES.key?(@badge_style)

          raise ArgumentError, "Invalid badge_style: #{@badge_style}. Must be one of: #{BADGE_STYLES.keys.join(", ")}"
        end

        def validate_icon_position!
          return if ICON_POSITIONS.include?(@icon_position)

          raise ArgumentError, "Invalid icon_position: #{@icon_position.inspect}. Must be :start or :end."
        end

        def validate_keep_open!
          return if @keep_open == true || @keep_open == false

          raise ArgumentError, "Invalid keep_open: #{@keep_open.inspect}. Must be true or false."
        end

        def validate_url!
          # Raise error if sanitization removed the URL (meaning it was unsafe)
          raise ArgumentError, "Unsafe URL detected. Only http, https, mailto, tel protocols and relative URLs are allowed." if @href.blank?
        end
      end
    end
  end
end
