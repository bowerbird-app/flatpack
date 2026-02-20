# frozen_string_literal: true

module FlatPack
  module Navbar
    module SidebarItem
      class Component < FlatPack::BaseComponent
        BADGE_STYLES = {
          primary: "bg-[var(--color-primary)] text-[var(--color-primary-text)]",
          secondary: "bg-[var(--color-secondary)] text-[var(--color-secondary-text)]",
          success: "bg-[var(--color-success)] text-[var(--color-success-text)]",
          warning: "bg-[var(--color-warning)] text-[var(--color-warning-text)]",
          danger: "bg-[var(--color-danger)] text-[var(--color-danger-text)]"
        }.freeze

        def initialize(text:, href: nil, icon: nil, active: false, badge: nil, badge_style: :primary, **system_arguments)
          @text = text
          @href = href
          @icon = icon
          @active = active
          @badge = badge
          @badge_style = badge_style.to_sym

          super(**system_arguments)

          validate_text!
          validate_badge_style! if @badge
        end

        def call
          if @href
            link_to @href, **link_attributes do
              item_content
            end
          else
            content_tag(:button, **button_attributes) do
              item_content
            end
          end
        end

        private

        def item_content
          safe_join([
            render_icon,
            content_tag(:span, @text, class: "flex-1 text-left", data: {flat_pack__navbar_target: "itemText"}),
            render_badge
          ].compact)
        end

        def render_icon
          return unless @icon

          content_tag(:span, class: "flex items-center justify-center", data: {flat_pack__navbar_target: "itemIcon"}) do
            render FlatPack::Shared::IconComponent.new(name: @icon, size: :md)
          end
        end

        def render_badge
          return unless @badge

          content_tag(:span, @badge, class: badge_classes, data: {flat_pack__navbar_target: "itemBadge"})
        end

        def link_attributes
          merge_attributes(
            class: item_classes
          )
        end

        def button_attributes
          merge_attributes(
            type: "button",
            class: item_classes
          )
        end

        def item_classes
          classes(
            "flex items-center gap-3",
            "w-full px-3 py-2 rounded-md",
            "text-sm font-medium",
            "transition-colors duration-200",
            "hover:bg-[var(--color-muted)]",
            active_classes
          )
        end

        def active_classes
          return unless @active

          "bg-[var(--color-primary)] text-[var(--color-primary-text)] hover:bg-[var(--color-primary)]"
        end

        def badge_classes
          classes(
            "px-2 py-0.5",
            "text-xs font-semibold",
            "rounded-full",
            BADGE_STYLES.fetch(@badge_style)
          )
        end

        def validate_text!
          return if @text.present?
          raise ArgumentError, "SidebarItem requires a text parameter"
        end

        def validate_badge_style!
          return if BADGE_STYLES.key?(@badge_style)
          raise ArgumentError, "Invalid badge_style: #{@badge_style}. Must be one of: #{BADGE_STYLES.keys.join(", ")}"
        end
      end
    end
  end
end
